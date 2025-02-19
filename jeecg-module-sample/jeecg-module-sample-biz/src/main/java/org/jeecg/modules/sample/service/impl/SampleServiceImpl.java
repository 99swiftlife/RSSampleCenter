package org.jeecg.modules.sample.service.impl;


import alluxio.client.file.URIStatus;
import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
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
import java.util.stream.Collectors;

/**
 * 测试Service
 */
@Service
@DS("postgis")
public class SampleServiceImpl extends ServiceImpl<SCOpticalSampleMapper, SCOpticalSample> implements ISampleService {
    @Autowired
    private CBIRServiceClient cbirServiceClient;

    @Override
    public String hello() {
        return "hello ，我是 sample 微服务节点!";
    }

    @Override
    public IPage<SCOpticalSample> listSCOpticalSamples(IPage<SCOpticalSample> page, Map<String,String[]>paramMap, SCOpticalSample rsSample){
        // 创建一个可修改的副本
        Map<String, String[]> mutableParamMap = new HashMap<>(paramMap);
        // 如果存在BoundingBox参数则从请求参数中排除，因为该参数是用于空间查询而非QueryGenerator默认的全限定查询
        BoundingBox bbox = null;
        if(rsSample.getBbox()!=null){
            bbox = new BoundingBox(rsSample.getBbox().getLl(),rsSample.getBbox().getLr(),rsSample.getBbox().getUl(),rsSample.getBbox().getUr());
            rsSample.setBbox(null);
            Iterator<Map.Entry<String, String[]>> iterator = mutableParamMap.entrySet().iterator();
            try{
                // 移除 "bbox" 条目
                mutableParamMap.entrySet().removeIf(entry -> entry.getKey().contains("bbox"));
            } catch (Exception e){
                System.out.println(e);
            }

        }
        // 若存在需要过滤的label_id，则添加过滤条件
        List<Long> labelIds = new ArrayList<>();
        QueryWrapper<SCOpticalSample> queryWrapper = QueryGenerator.initQueryWrapper(rsSample, mutableParamMap);
        if(bbox!=null){
            queryWrapper.apply("ST_Intersects(bbox, #{area,typeHandler=org.jeecg.modules.sample.handler.GeometryTypeHandler})");
        }
        if(paramMap.containsKey("labelId_Filter")){
            labelIds = Arrays.stream(paramMap.get("labelId_Filter")[0].split(","))
                    .map(Long::parseLong) // 将String转换为Long
                    .collect(Collectors.toList());
            if(labelIds.size()>0){
//            queryWrapper.notIn("label_id", labelIds);
                String excludedValues = "ARRAY[" + paramMap.get("labelId_Filter")[0] + "]::bigint[]";
// 直接拼接 SQL 语句
                queryWrapper.apply("NOT (array_length(label_id, 1) = 1 AND label_id[1] = ANY(" + excludedValues + "))");

            }
        }
        if(paramMap.containsKey("labelId_MultiStr")){
            labelIds = Arrays.stream(paramMap.get("labelId_MultiStr")[0].split(","))
                    .map(Long::parseLong) // 将String转换为Long
                    .collect(Collectors.toList());
            if(labelIds.size()>0){
                for(Long labelId:labelIds){
                    queryWrapper.apply(labelId + " = ANY(label_id)");
                }
            }
        }
        return baseMapper.listSCOpticalSamples(page,queryWrapper,bbox);
    }

    @Override
    public SCOpticalSample findByImgPath(String imgPath){
        LambdaQueryWrapper<SCOpticalSample> lambdaQueryWrapper  =new LambdaQueryWrapper<SCOpticalSample>()
                .eq(SCOpticalSample::getImgPath,imgPath);
        List<SCOpticalSample> res = getBaseMapper().selectList(lambdaQueryWrapper);
        if(res.size() == 0) return null;
        return res.get(0);
    }
    @Override
    public List<SCOpticalSample> findByDatasetId(Long datasetId){
        LambdaQueryWrapper<SCOpticalSample> lambdaQueryWrapper  =new LambdaQueryWrapper<SCOpticalSample>()
                .eq(SCOpticalSample::getDatasetId,datasetId);
        List<SCOpticalSample> res = getBaseMapper().selectList(lambdaQueryWrapper);
        return res;
    }

    @Override
    public List<SCOpticalSample> randSampleByDatasetId(Long datasetId,Long sz){
        if(sz==null) {
            sz=10L;
        }
        LambdaQueryWrapper<SCOpticalSample> lambdaQueryWrapper  =new LambdaQueryWrapper<SCOpticalSample>()
                .eq(SCOpticalSample::getDatasetId,datasetId).last("ORDER BY RANDOM() LIMIT "+sz);
        List<SCOpticalSample> res = getBaseMapper().selectList(lambdaQueryWrapper);
        return res;
    }
    @Override
    public Boolean validate(RSSample sample, SampleStatue st){
        Boolean flag = true;
        switch (st){
            case SUCCESS:
                flag &= cbirServiceClient.validateSampleFeature(sample.getId());
            case RESOLVED:
                flag &= (sample.getResolution() != null &&
                        sample.getSampleSize() != null);
            case INIT:
                flag &= (sample.getId() != null &&
                        sample.getDatasetId() != null &&
                        sample.getLabelId() != null &&
                        sample.getImgType() != null &&
                        sample.getImgPath() != null);
            default :
                break;
        }
        return flag;
    }
}
