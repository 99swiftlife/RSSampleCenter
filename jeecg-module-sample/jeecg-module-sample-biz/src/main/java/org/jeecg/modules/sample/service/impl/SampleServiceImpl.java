package org.jeecg.modules.sample.service.impl;


import alluxio.client.file.URIStatus;
import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.models.auth.In;
import org.apache.commons.lang3.tuple.Pair;
import org.checkerframework.checker.units.qual.A;
import org.jeecg.boot.starter.rabbitmq.client.RabbitMqClient;
import org.jeecg.common.system.query.QueryGenerator;
import org.jeecg.modules.sample.client.CBIRServiceClient;
import org.jeecg.modules.sample.client.ClassifyClient;
import org.jeecg.modules.sample.entity.*;
import org.jeecg.modules.sample.mapper.SCOpticalSampleMapper;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.util.AlluxioUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * 测试Service
 */
@Service
@DS("postgis")
public class SampleServiceImpl extends ServiceImpl<SCOpticalSampleMapper, SCOpticalSample> implements ISampleService {
    @Override
    public String hello() {
        return "hello ，我是 sample 微服务节点!";
    }

    @Override
    public IPage<SCOpticalSample> listSCOpticalSamples(IPage<SCOpticalSample> page, Map<String,String[]>paramMap, SCOpticalSample rsSample){
        // 如果存在BoundingBox参数则从请求参数中排除，因为该参数是用于空间查询而非QueryGenerator默认的全限定查询
        BoundingBox bbox = null;
        if(rsSample.getBbox()!=null){
            bbox = new BoundingBox(rsSample.getBbox().getLl(),rsSample.getBbox().getLr(),rsSample.getBbox().getUl(),rsSample.getBbox().getUr());
            rsSample.setBbox(null);
            Iterator<Map.Entry<String, String[]>> iterator = paramMap.entrySet().iterator();
            while (iterator.hasNext()) {
                Map.Entry<String, String[]> entry = iterator.next();
                if (entry.getKey().contains("bbox")) {
                    iterator.remove();
                }
            }
        }
        // 若存在需要过滤的label_id，则添加过滤条件
        Long label_id = null;
        if(paramMap.containsKey("labelId_Filter")){
            label_id = Long.parseLong(paramMap.get("labelId_Filter")[0]);
        }
        QueryWrapper<SCOpticalSample> queryWrapper = QueryGenerator.initQueryWrapper(rsSample, paramMap);
        return baseMapper.listSCOpticalSamples(page,queryWrapper,bbox,label_id);
    }

    @Override
    public SCOpticalSample findByImgPath(String imgPath){
        LambdaQueryWrapper<SCOpticalSample> lambdaQueryWrapper  =new LambdaQueryWrapper<SCOpticalSample>()
                .eq(SCOpticalSample::getImgPath,imgPath);
        List<SCOpticalSample> res = getBaseMapper().selectList(lambdaQueryWrapper);
        return res.get(0);
    }
    @Override
    public List<SCOpticalSample> findByDatasetId(Long datasetId){
        LambdaQueryWrapper<SCOpticalSample> lambdaQueryWrapper  =new LambdaQueryWrapper<SCOpticalSample>()
                .eq(SCOpticalSample::getDatasetId,datasetId);
        List<SCOpticalSample> res = getBaseMapper().selectList(lambdaQueryWrapper);
        return res;
    }
   
}
