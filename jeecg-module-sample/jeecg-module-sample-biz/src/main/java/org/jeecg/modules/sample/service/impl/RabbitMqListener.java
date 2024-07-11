package org.jeecg.modules.sample.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.boot.starter.rabbitmq.core.BaseRabbiMqHandler;
import org.jeecg.boot.starter.rabbitmq.listenter.MqListener;
import org.jeecg.common.annotation.RabbitComponent;
import org.jeecg.common.util.RedisUtil;
import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.entity.SCOpticalSample;
import org.jeecg.modules.sample.entity.SampleMetaDTO;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.service.IDataSetService;
import org.jeecg.modules.sample.util.ProgressWebSocketHandler;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * @program: RSSampleCenter
 * @description: RabbitMQ消息监听类
 * @author: swiftlife
 * @create: 2024-05-15 14:45
 **/

@Slf4j
@RabbitListener(queues = "meta")
@RabbitComponent(value = "sampleMetaListener")
public class RabbitMqListener extends BaseRabbiMqHandler<byte[]>{
    @Autowired
    private ISampleService sampleService;
    @Autowired
    private IDataSetService dataSetService;

    @Autowired
    private RedisUtil redisUtil;
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
                    throw new RuntimeException(e);
                }
                log.info("业务处理开始，处理返回的样本元数据！");
                // 更新样本元数据信息
                // 更新样本元数据信息
                Long datasetId = null;
                for (Long id : sampleMetaMap.keySet()) {
                    SampleMetaDTO metaDTO = sampleMetaMap.get(id);
                    SCOpticalSample sample = sampleService.getById(id);
                    if(datasetId ==null)datasetId = sample.getDatasetId();
                    Long labelId = sample.getLabelId();
                    if(sample==null)sample = new SCOpticalSample();
                    if(metaDTO==null)continue;
                        sample.setSampleSize(metaDTO.getSampleSize());
                    if(metaDTO.getRes()!=null)
                        sample.setResolution(metaDTO.getRes());
                    if(metaDTO.getBbox()!=null)
                        sample.setBbox(metaDTO.getBbox());
                    if(metaDTO.getTime()!=null)
                        sample.setTime(metaDTO.getTime());
                    sampleService.updateById(sample);
                }

                // TODO 缓存数据集实例解析进度
                Dataset dataset = dataSetService.getById(datasetId);
                if(dataset != null){
                    String datasetName = dataset.getDatasetName();
                    Integer insNum = dataset.getInsNum();
                    if(!redisUtil.hHasKey("dataset_progress",datasetName))
                        redisUtil.hset("dataset_progress",datasetName,0,10800);
                    else
                        redisUtil.hincr("dataset_progress",datasetName,sampleMetaMap.size());

                    if(!redisUtil.hHasKey("dataset_total",datasetName))
                        redisUtil.hset("dataset_total",datasetName,insNum,10800);
                }
            }
        });
    }
}
