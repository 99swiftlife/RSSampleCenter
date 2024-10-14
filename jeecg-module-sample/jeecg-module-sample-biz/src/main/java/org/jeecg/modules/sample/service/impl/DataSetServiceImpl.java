package org.jeecg.modules.sample.service.impl;

import alluxio.client.file.URIStatus;
import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.jeecg.boot.starter.rabbitmq.client.RabbitMqClient;
import org.jeecg.modules.sample.client.CBIRServiceClient;
import org.jeecg.modules.sample.client.ClassifyClient;
import org.jeecg.modules.sample.entity.*;
import org.jeecg.modules.sample.mapper.DataSetMapper;
import org.jeecg.modules.sample.service.IDataSetService;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.util.AlluxioUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.*;

import static org.jeecg.modules.sample.entity.SampleStatue.*;

/**
 * @program: RSSampleCenter
 * @description: 数据集表服务类
 * @author: swiftlife
 * @create: 2024-03-26 18:43
 **/
@Service
@DS("postgis")
public class DataSetServiceImpl extends ServiceImpl<DataSetMapper, Dataset> implements IDataSetService {
    @Autowired
    private ClassifyClient classifyClient;
    @Autowired
    private CBIRServiceClient cbirServiceClient;
    @Autowired
    private RabbitMqClient rabbitMqClient;
    @Autowired
    private ISampleService scOpticalSampleService;

    private final Integer BATCH_SIZE = 256;

    @Override
    public List<Dataset> findByName(String datasetName){
        LambdaQueryWrapper<Dataset> lambdaQueryWrapper  =new LambdaQueryWrapper<Dataset>()
                .eq(Dataset::getDatasetName,datasetName);
        List<Dataset> res = getBaseMapper().selectList(lambdaQueryWrapper);
        return res;
    }
    /**
     * 给定数据集路径
     * 获取数据集（如何获取，数据集就放在本地还是网络传输）放在本地/HDFS/S3
     * alluxio挂载数据集
     * 解析得到数据集标签分类体系
     * 插入标签分类体系，得到类别编码
     */
    @Override
    public void parseDataset(String path, Dataset dst) throws IOException {
        // 解析得到数据集标签分类体系
        Map<String,List<String>> edges = new HashMap<>();
        List<SampleDTO> sampleList = new ArrayList<>();
        getDataSetClassify(path,dst,edges,sampleList);
        if(edges.size()==0 || sampleList.size()==0){
            if(dst.getProcessedNum()==0)
                System.out.println("找不到数据集目录！");
            return ;
        }

        // 插入标签分类体系，得到类别编码
        Map<Long,Integer> labelInsNum =  new HashMap<>();

        // 统计此数据集中每个类别的实例数量
        for (SampleDTO s : sampleList) {
            // 获取样本对应的类别id
            Long labelId = s.getCategoryId();
            // 统计标签类别的新增样本实例数
            if(labelInsNum.get(labelId)==null)labelInsNum.put(labelId,0);
            labelInsNum.put(labelId,labelInsNum.get(labelId)+1);
        }

        // TODO 先将初步标签信息（类别ID,类别实例数）写入标签表，此处要注意和rabitmq监听器的冲突(update操作默认更新非空字段）
        List<LabelCategoryDO>labelDTOs = new ArrayList<>();
        for(Long labelId:labelInsNum.keySet()){
            LabelCategoryDO labelCategoryDO = new LabelCategoryDO();
            labelCategoryDO.setId(labelId);
            labelCategoryDO.setNum(labelInsNum.get(labelId));
            labelDTOs.add(labelCategoryDO);
        }
        classifyClient.saveOrUpdateLabelCategory(labelDTOs);

        // 返回数据集信息
        dst.setInsNum(sampleList.size());
        dst.setCatNum(edges.keySet().size());
    }


    class Node implements Comparable<Node> {
        URIStatus path;
        Node father;
        Integer depth;

        Node(URIStatus cur, Node father, Integer depth) {
            this.path = cur;
            this.father = father;
            this.depth = depth;
        }

        @Override
        public int compareTo(Node other) {
            // 比较当前节点的深度与另一个节点的深度
            // 注意：这里假设depth字段不为null
            return this.depth.compareTo(other.depth);
        }
    }
    /**
     * 1、递归获取数据集的标签分类体系
     * 2、获取数据集中所有样本图像的路径、标签集合
     */
    // TODO 特殊情况的处理：fmow中最后一层目录名为样本编号，内部为该样本的rgb图像、tif图像和json元数据   =>    解决方法：正则表达式忽略部分目录结构
    // TODO 有多种图像类型：bandinfo不同，如何处理    =>    解决传入全部的bandInfo,根据band num匹配bandInfo
    // TODO 修改引入多线程并发，每解析出1000条数据就传给后特征管理模块提取特征
    // TODO 若要提前提交分类体系要将广度优先修改为深度优先
    public Boolean getDataSetClassify(String path, Dataset dst, Map<String,List<String>>edges,List<SampleDTO> dtos){
        Map<String,Long> label2Id = new HashMap<>();
        Boolean flag = false;
        Queue<Node> queue = new PriorityQueue<>();
        queue.add(new Node(AlluxioUtils.getStatus(path),null,0));
        List<URIStatus>leafNodes = new ArrayList<>();
        while(queue.size()>0){
            Node cur= queue.poll();
            // TODO 若层级已经超过最大层级，认为标签分类体系已解析完毕
            // TODO 超过最大层级改为深度优先遍历以获取样本路径
            if(dst.getMaxCategoryLevel()!=null&&cur.depth>dst.getMaxCategoryLevel()){
                queue.clear();
                break;
            }
            // TODO 判断子文件夹中是否包含folder
            boolean hasSubDir = false;
            for(URIStatus sub : AlluxioUtils.listStatus(cur.path.getPath())) {
                if(sub.isFolder()){
                    hasSubDir = true;
                    queue.add(new Node(sub,cur,cur.depth+1));
                }
            }
            // 添加标签分类体系
            if(cur.depth>0 && (dst.getMaxCategoryLevel()==null||cur.depth<=dst.getMaxCategoryLevel())){
                String to = cur.path.getName().toLowerCase().replace('_',' ');
                System.out.println("解析得到标签："+to);
                if(cur.father.depth>0){
                    String from = cur.father.path.getName().toLowerCase().replace('_',' ');
                    if(!edges.containsKey(from)){
                        edges.put(from,new ArrayList<>());
                    }
                    edges.get(from).add(to);
                }
                if(!edges.containsKey(to)){
                    edges.put(to,new ArrayList<>());
                }
                if(cur.depth == dst.getMaxCategoryLevel()||hasSubDir==false){
                    leafNodes.add(cur.path);
                }
            }
        }
        //，分类体系解析完毕，写入标签分类体系
        if(edges.size()>0)
            label2Id = classifyClient.addClassify(edges);

        // TODO 从每个具备实例的类目录开始向下深度搜索(多线程），搜索完毕统计类实例数量
        ExecutorService executorService = Executors.newFixedThreadPool(200);
        List<Future<List<SampleDTO> >> futures = new ArrayList<>();
        // TODO 提交多个任务给线程池
        for(URIStatus leaf:leafNodes){
            String tmp[] = leaf.getPath().split("/");
            String category = tmp[tmp.length-1].toLowerCase().replace('_',' ');
            Long labelId = label2Id.get(category);
            // TODO 取消使用rabbitmq,修改为状态策略
            Future<List<SampleDTO> > future = executorService.submit(() -> {
                List<SampleDTO>subDtos = new ArrayList<>();
                System.out.println("Executing Task For Label " + labelId + " in Thread " + Thread.currentThread().getName());
                getSampleList(leaf,dst,subDtos,labelId);
                if(subDtos.size()%BATCH_SIZE!=0){
                    int r = subDtos.size();
                    int l = r/BATCH_SIZE*BATCH_SIZE;
                    PairDTO<List<SampleDTO>,Map<Integer,Map<String,Integer>>> params = new PairDTO<>(subDtos.subList(l,r),dst.getBandInfo());
                    rabbitMqClient.sendMessage("sample", params.toBytes(), 1000);
                }
                return subDtos;
            });
            futures.add(future);
        }
        for (Future<List<SampleDTO>> future : futures) {
            try {
                dtos.addAll(future.get());  // 调用 get() 将会阻塞，直到任务完成
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        }
        // 关闭线程池
        executorService.shutdown();

        try {
            // 等待线程池中的所有任务完成
            if (!executorService.awaitTermination(60, TimeUnit.SECONDS)) {
                executorService.shutdownNow(); // 超时后取消正在执行的任务
            }
        } catch (InterruptedException e) {
            executorService.shutdownNow();
            Thread.currentThread().interrupt(); // 保持中断状态
        }
        return flag;
    }

    /**
     * 不会和rabitmq监听器中的更新样本元数据操作冲突，因为对于一个样本元数据项
     * 在本方法中写入后才会提交给特征模块处理，监听器才会收到结果数据
     */
    public void getSampleList(URIStatus f,Dataset dst,List<SampleDTO> dtos,Long labelId){
        String ext = dst.getImgExt();
        Long datasetId = dst.getId();
        if(f.isFolder()){
            for(URIStatus sub : AlluxioUtils.listStatus(f.getPath())) {
                getSampleList(sub,dst,dtos,labelId);
            }
        }
        else{
            if(f.getPath().toLowerCase().endsWith(ext)){
                // 如果样本已经写入过，则获取已写入的元数据并校验，避免重复写入
                SCOpticalSample rsSample = scOpticalSampleService.findByImgPath(f.getPath());
                if(rsSample != null)
                    if(rsSample.getStatue() == SUCCESS){
                        dst.addProcessedNum();
                        return ;
                    }
                    else
                        System.out.printf(String.format("===================================Refine sample : %s===================================", rsSample.getId()));
                else
                    rsSample =  new SCOpticalSample();

                rsSample.setDatasetId(datasetId);
                rsSample.setImgPath(f.getPath());
                rsSample.setLabelId(labelId);
                rsSample.setImgType(ext);
                // 先写入表获取sampleId
                scOpticalSampleService.saveOrUpdate(rsSample);
                // 设置样本状态为初始化/失败
                if(scOpticalSampleService.validate(rsSample,INIT))
                    rsSample.setStatue(INIT);
                else
                    rsSample.setStatue(FAIL);
                // 更新样本状态
                scOpticalSampleService.updateById(rsSample);
                Long sampleId = rsSample.getId();
                // 生成初始元数据列表
                dtos.add(new SampleDTO(sampleId, labelId, f.getPath()));
                // 以BATCH_SIZE个实例为一个批次提交给rabbitmq
                if(dtos.size()%BATCH_SIZE==0){
                    int r = dtos.size();
                    int l = r-BATCH_SIZE;
                    PairDTO<List<SampleDTO>,Map<Integer,Map<String,Integer>>> params = new PairDTO(dtos.subList(l,r),dst.getBandInfo());
                    try {
                        System.out.println("========================================Send To Meta Queue!=================================");
                        rabbitMqClient.sendMessage("sample", params.toBytes(), 1000);
                    }catch(Exception e){
                        e.printStackTrace();
                        System.out.println(e.getMessage());
                    }
                }
            }
        }
    }
    public void sendBatchToSampleResolver(List<SampleDTO> dtos,Map<Integer,Map<String,Integer>> bandInfoMap){
        for(int l = 0;l<dtos.size();l+=BATCH_SIZE){
            int r = l + BATCH_SIZE;
            if(r > dtos.size())r = dtos.size();
            PairDTO<List<SampleDTO>,Map<Integer,Map<String,Integer>>> params = new PairDTO(dtos.subList(l,r),bandInfoMap);
            try {
                rabbitMqClient.sendMessage("sample", params.toBytes(), 1000);
            }catch(Exception e){
                e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
    }
    public synchronized Boolean increasProcessed(Long id, Integer num){
        try{
            Dataset dst = getById(id);
            dst.setProcessedNum(dst.getProcessedNum()+num);
            updateById(dst);
            return true;
        }catch(Exception e){
            System.out.println(e);
            return false;
        }
    }
}
