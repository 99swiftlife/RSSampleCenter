package org.jeecg.modules.classify.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.boot.starter.rabbitmq.core.BaseRabbiMqHandler;
import org.jeecg.boot.starter.rabbitmq.listenter.MqListener;
import org.jeecg.common.annotation.RabbitComponent;
import org.jeecg.modules.classify.entity.LabelCategoryDO;
import org.jeecg.modules.classify.entity.PairDTO;
import org.jeecg.modules.classify.service.ILabelCategoryService;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;

/**
 * @program: RSSampleCenter
 * @description: 标签体系管理模块中的RabbitMQ监听类
 * @author: swiftlife
 * @create: 2024-05-15 15:26
 **/
@Slf4j
@RabbitListener(queues = "centroids")
@RabbitComponent(value = "centroidsListener")
public class RabbitMQListener extends BaseRabbiMqHandler<byte[]>{
    @Autowired
    private ILabelCategoryService labelCategoryService;
    private Long expectNum = new Long(0);
    private ObjectMapper objectMapper = new ObjectMapper();
    @RabbitHandler
    public void onMessage(byte[] res, Channel channel, @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        super.onMessage(res, deliveryTag, channel, new MqListener<byte[]>() {
            @Override
            public void handler(byte[] body, Channel channel) {
                PairDTO<Map<Long, List<String>>,Long> msg = null;
                try {
                    msg = objectMapper.readValue(new String(body),
                            new TypeReference<PairDTO<Map<Long, List<String>>, Long>>() {});
                } catch (JsonProcessingException e) {
                    throw new RuntimeException(e);
                }
                System.out.println("业务处理开始，处理待更新的标签聚类中心！");

                // 因为多线程状态下消息队列中的更新消息为无序状态，因此用expectNum作为版本标识，只接收更新版本比当前更新的数据
                if(msg.getRight()<expectNum)return;
                expectNum = msg.getRight();
                Map<Long, List<String>> centroids = msg.getLeft();
                // 更新类别的特征聚类中心
                List<LabelCategoryDO>labelList = new ArrayList<>();
                for (Long labelId : centroids.keySet()) {
                    List<byte[]> decodedBytesArray = new ArrayList<>();
                    // 特征字符串解码
                    for (String encoded:centroids.get(labelId)) {
                        byte[] decodedBytes = Base64.getDecoder().decode(encoded);
                        decodedBytesArray.add(decodedBytes);
                    }
                    LabelCategoryDO labelCategoryDO = labelCategoryService.getById(labelId);
                    if(labelCategoryDO==null)labelCategoryDO= new LabelCategoryDO();
                    labelCategoryDO.setImgFeature(decodedBytesArray);
                    labelCategoryDO.setNum(Math.toIntExact(msg.getRight().longValue()));
                    labelList.add(labelCategoryDO);
                }
                labelCategoryService.saveOrUpdateBatch(labelList);
            }
        });
    }

}
