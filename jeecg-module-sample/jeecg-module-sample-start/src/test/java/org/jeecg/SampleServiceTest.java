package org.jeecg;

import alluxio.client.file.URIStatus;
import alluxio.exception.AlluxioException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.sample.client.ClassifyClient;
import org.jeecg.modules.sample.controller.SampleController;
import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.entity.DatasetDTO;
import org.jeecg.modules.sample.service.IDataSetService;
import org.jeecg.modules.sample.service.impl.SampleServiceImpl;
import org.jeecg.modules.sample.util.AlluxioUtils;
import org.junit.Assert;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.Resource;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * @program: RSSampleCenter
 * @description: 样本元数据管理服务测试类
 * @author: swiftlife
 * @create: 2023-12-14 20:28
 **/
@Slf4j
public class SampleServiceTest extends ApplicationTest{
    @Resource
    SampleServiceImpl sampleService;
    @Resource
    ClassifyClient classifyClient;
    @Autowired
    private SampleController sampleController;
    @Autowired
    private IDataSetService dataSetService;

    @Test
    public void alluxioTest(){
        // AlluxioUtils.mount("/dataset/fmow-rgb","s3://spacenet-dataset/Hosted-Datasets/fmow/fmow-rgb/");
        List<URIStatus>statuses =  AlluxioUtils.listStatus("/dataset/fmow-rgb");
        for(URIStatus stat:statuses){
            System.out.println(stat);
        }
    }
    @Test
    public void unzipTest() throws IOException, AlluxioException {
        AlluxioUtils.unzip("/SampleDataSets/zip_file/UCMerced_LandUse.zip","/test/UCMerced_LandUse");

    }

    @Test
    public void loadFromAlluxioTest() throws IOException, AlluxioException {
        AlluxioUtils.uploadImage("/home/mca/422643.jpg","/test/1.jpg");
        byte[] res = AlluxioUtils.openFileByte("/test/422643.jpg");
        System.out.println(res);
    }
    @Test
    public void getClasiifyTest() throws JsonProcessingException {
        Integer maxLevel = 1;
        String datasetName = "fmow-full";
        String path = "s3://spacenet-dataset/Hosted-Datasets/fmow/fmow-full/";
        String alluxioPath = "/dataset/"+datasetName;
//        AlluxioUtils.mount(alluxioPath,path);
        String imgExt = "tif";
        // 解析得到数据集标签分类体系
        Map<String,List<String>> edges = new HashMap<>();
        List<String> imgPathList = new ArrayList<String>();
//        sampleService.getDataSetClassify(alluxioPath+"/train",imgExt,edges,imgPathList,maxLevel);
        for (String key : edges.keySet()) {
            System.out.println(key);
            for(String to:edges.get(key))
                System.out.println(key+" --> "+to);
        }
        ObjectMapper objectMapper = new ObjectMapper();
        String json = objectMapper.writeValueAsString(edges);
        System.out.println(json);
//        classifyClient.addClassify(edges);
//        System.out.println("===============IMG LIST ==================");
//        for (String s : imgPathList) {
//            System.out.println(s);
//        }
    }

    public void accuracyExperiment(){
//        label2Id = classifyClient.addClassify(edges);

    }

    public void checkDatasetValidate(){
        DatasetDTO datasetDTO = new DatasetDTO();
        // 模拟特征提取失败的情况（关闭特征管理模块）
        sampleController.resolveDataSet(datasetDTO);
        sampleController.resolveDataSet(datasetDTO);
        Dataset dst = dataSetService.findByName(datasetDTO.getDatasetName()).get(0);
        assertTrue(dst.validate(),"check dst is validated");
    }

}
