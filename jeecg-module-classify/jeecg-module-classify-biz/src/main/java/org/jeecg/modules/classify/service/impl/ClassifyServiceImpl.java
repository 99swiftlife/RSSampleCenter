package org.jeecg.modules.classify.service.impl;

import org.apache.commons.lang3.tuple.Pair;
import org.jeecg.modules.classify.client.MetricClient;
import org.jeecg.modules.classify.entity.*;
import org.jeecg.modules.classify.service.ClassifyService;
import org.jeecg.modules.classify.service.ILabelCategoryService;
import org.jeecg.modules.classify.service.LabelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class ClassifyServiceImpl implements ClassifyService {
    private final LabelRepository labelRepository;
    @Autowired
    private ILabelCategoryService labelCategoryService;
    @Autowired
    private MetricClient metricClient;
    @Value("${custom.MAX_DISTANCE}")
    private final Integer MAX_DISTANCE;

    ClassifyServiceImpl(LabelRepository labelRepository, @Value("${custom.MAX_DISTANCE}") Integer maxDistance){
        this.labelRepository = labelRepository;
        MAX_DISTANCE = maxDistance;
    }

    /**
     * @program: RSSampleCenter
     * @description: 添加新的标签分类体系并合并到已有的标签体系
     * @author: swiftlife
     * @create: 2024-03-11 20:44
     **/
    @Override
    public Map<String,Long> addGraph(List<String>nodes,List<Edge> egdes) {
        // 获取图和分类体系中的所有节点
        Map<String,Long> cate2Id_res =  new HashMap<String,Long>();
        // 新增的节点
        List<String>cates = new ArrayList<>();
        for (String nodeName : nodes) {
            // Neo4j中是否已存在对应的节点
            LabelCategory res = labelRepository.findByName(nodeName);
            if(res == null)
                cates.add(nodeName);
            else
                cate2Id_res.put(res.getName(),res.getId());
        }
        // 建立节点间“父/子类”关系
        for (Edge egde : egdes) {
            labelRepository.linkToNodeByName(egde.getStartVertex(),egde.getEndVertex(),"SUB",0.0);
            labelRepository.linkToNodeByName(egde.getEndVertex(),egde.getStartVertex(),"SUPER",1.0);
        }
        // 度量节点相似度
        // 额外返回descr,osm_url,样本文本特征
        PairDTO<List<Edge>, List<LabelCategoryDTO>> res = metricClient.mergeLists(cates);
//        System.out.println(res);
        if(res ==null) return cate2Id_res;

        // todo>>等相似度度量完毕后再写入，这样可以减轻neo4j和postgresql中的数据不一致情况
        for (String nodeName : cates) {
            LabelCategory node = new LabelCategory();
            node.setName(nodeName);
            labelRepository.save(node);
            cate2Id_res.put(node.getName(),node.getId());
        }
        // 写入标签类别表
        List<LabelCategoryDO> labelCategoryDOs = new ArrayList<>();
        for (LabelCategoryDTO labelCategoryDTO : res.getRight()){
            Long labelId = cate2Id_res.get(labelCategoryDTO.getName());
            LabelCategoryDO labelCategoryDO = new LabelCategoryDO(labelCategoryDTO);
            labelCategoryDO.setId(labelId);
            labelCategoryDOs.add(labelCategoryDO);
        }
        try {
            // todo>>处理label_id和label_name冲突的情况，避免阻塞
            labelCategoryService.saveOrUpdateBatch(labelCategoryDOs);
        }catch (Exception e){
            e.printStackTrace();
            // todo>> 若postgresql中标签写入出现异常，删除Neo4j中已写入的标签类别
            for(LabelCategoryDO labelCategoryDO : labelCategoryDOs){
                labelRepository.deleteById(labelCategoryDO.getId());
            }
            return cate2Id_res;
        }
        // Neo4j中建立节点间相似关系，startNode为新插入的标签，endNode为Neo4j中的标签
        for (Edge re : res.getLeft()) {
//            System.out.println(re.getStartVertex()+"----->"+re.getEndVertex());
            if(re.getStartVertex().equals(re.getEndVertex()))continue;
            labelRepository.linkToNodeByName(re.getStartVertex(),re.getEndVertex(),"SYNONYM",re.getWeight());
        }
        System.out.println("返回类别到Id的映射！");
        System.out.println(cate2Id_res);
        return cate2Id_res;
    }
}
