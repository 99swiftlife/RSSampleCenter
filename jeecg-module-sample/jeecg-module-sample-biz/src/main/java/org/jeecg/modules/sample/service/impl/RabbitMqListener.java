package org.jeecg.modules.sample.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.boot.starter.rabbitmq.core.BaseRabbiMqHandler;
import org.jeecg.boot.starter.rabbitmq.listenter.MqListener;
import org.jeecg.common.annotation.RabbitComponent;
import org.jeecg.common.util.RedisUtil;
import org.jeecg.modules.sample.client.CBIRServiceClient;
import org.jeecg.modules.sample.entity.*;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.service.IDataSetService;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.jeecg.modules.sample.entity.SampleStatue.*;

/**
 * @program: RSSampleCenter
 * @description: RabbitMQ消息监听类
 * @author: swiftlife
 * @create: 2024-05-15 14:45
 **/

@Slf4j
@RabbitListener(queues = "meta")
@RabbitComponent(value = "sampleMetaListener")
public class RabbitMqListener extends BaseRabbiMqHandler<byte[]> {
    @Autowired
    private ISampleService sampleService;
    @Autowired
    private IDataSetService dataSetService;
    private ObjectMapper objectMapper = new ObjectMapper();

    @RabbitHandler
    public void onMessage(byte[] res, Channel channel, @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        super.onMessage(res, deliveryTag, channel, new MqListener<byte[]>() {
            @Override
            public void handler(byte[] message, Channel channel) {
                Map<Long, SampleMetaDTO> sampleMetaMap = null;
                try {
                    sampleMetaMap = objectMapper.readValue(new String(message),
                            objectMapper.getTypeFactory().constructMapType(Map.class, Long.class, SampleMetaDTO.class));
                } catch (JsonProcessingException e) {
                    System.out.println(e.getMessage());
                    throw new RuntimeException(e);
                }
                System.out.println("业务处理开始，处理返回的样本元数据！");
                // 更新样本元数据信息
                // 更新样本元数据信息
                Long datasetId = null;
                List<SCOpticalSample> sampleList = new ArrayList<>();
                for (Long id : sampleMetaMap.keySet()) {
                    SampleMetaDTO metaDTO = sampleMetaMap.get(id);
                    SCOpticalSample sample = sampleService.getById(id);
                    if (sample == null) {
                        System.out.println("存在过期数据！id = " + id);
                    }
                    if (datasetId == null) datasetId = sample.getDatasetId();
                    if (sample == null) sample = new SCOpticalSample();
                    if (metaDTO == null) continue;
                    if (metaDTO.getSampleSize() != null)
                        sample.setSampleSize(metaDTO.getSampleSize());
                    if (metaDTO.getRes() != null)
                        sample.setResolution(metaDTO.getRes());
                    if (metaDTO.getBbox() != null)
                        sample.setBbox(metaDTO.getBbox());
                    if (metaDTO.getTime() != null)
                        sample.setTime(metaDTO.getTime());
// TODO 设置校验开关，当需要校验在解析同步校验时进行校验
//                    if(sampleService.validate(sample,SUCCESS))
//                        sample.setStatue(SUCCESS);
//                    else{
//                        if(sampleService.validate(sample,RESOLVED))
//                            sample.setStatue(RESOLVED);
//                    }
                    sample.setStatue(SUCCESS);
                    sampleList.add(sample);
                }
                sampleService.updateBatchById(sampleList);
                // 数据集已处理样本数量增加
                System.out.println("增加已处理的数量");
                dataSetService.increasProcessed(datasetId, sampleList.size());
            }
        });
    }
}
