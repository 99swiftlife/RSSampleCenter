package org.jeecg.modules.cbir.service.impl;

import cn.hutool.core.util.StrUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.boot.starter.rabbitmq.client.RabbitMqClient;
import org.jeecg.boot.starter.rabbitmq.core.BaseRabbiMqHandler;
import org.jeecg.boot.starter.rabbitmq.listenter.MqListener;
import org.jeecg.common.annotation.RabbitComponent;
import org.jeecg.common.util.RedisUtil;
import org.jeecg.modules.cbir.client.CBIRServiceClient;
import org.jeecg.modules.cbir.entity.PairDTO;
import org.jeecg.modules.cbir.entity.SampleListenerDTO;
import org.jeecg.modules.cbir.entity.SampleMetaDTO;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;

import java.util.List;
import java.util.Map;


/**
 * @program: RSSampleCenter
 * @description: RabbitMQ消息监听类
 * @author: swiftlife
 * @create: 2024-05-15 14:45
 **/

@Slf4j
@RabbitListener(queues = "sample")
@RabbitComponent(value = "resolveListener")
public class RabbitMqListener extends BaseRabbiMqHandler<byte[]>{
    @Autowired
    private CBIRServiceClient cbirServiceClient;
    @Autowired
    private RabbitMqClient rabbitMqClient;
    private ObjectMapper objectMapper = new ObjectMapper();
    @RabbitHandler
    public void onMessage(byte[] res, Channel channel, @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        super.onMessage(res, deliveryTag, channel, new MqListener<byte[]>() {
            @Override
            public void handler(byte[] message, Channel channel) {
                System.out.println(StrUtil.format("开始解析样本！\n{}", message));
                String resJson = cbirServiceClient.resolveStr(new String(message));
                SampleListenerDTO res = null;
                try {
                    res = objectMapper.readValue(resJson, SampleListenerDTO.class);
                } catch (JsonProcessingException e) {
                    System.out.println(e.getMessage());
                    throw new RuntimeException(e);
                }
                Map<String,SampleMetaDTO>meta = res.getMeta();
                Map<Long,Integer> labelInsNum = res.getLabelInsNum();
                try {
                    rabbitMqClient.sendMessage("meta", objectMapper.writeValueAsBytes(meta), 1000);
                } catch (JsonProcessingException e) {
                    throw new RuntimeException(e);
                }
                try {
                    rabbitMqClient.sendMessage("centroids", objectMapper.writeValueAsBytes(labelInsNum), 1000);
                } catch (JsonProcessingException e) {
                    throw new RuntimeException(e);
                }
            }
        });
    }
}
