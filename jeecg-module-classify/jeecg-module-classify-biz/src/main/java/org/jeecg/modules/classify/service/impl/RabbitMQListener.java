package org.jeecg.modules.classify.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.boot.starter.rabbitmq.core.BaseRabbiMqHandler;
import org.jeecg.boot.starter.rabbitmq.listenter.MqListener;
import org.jeecg.common.annotation.RabbitComponent;
import org.jeecg.modules.classify.client.MetricClient;
import org.jeecg.modules.classify.entity.LabelCategoryDO;
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
    @Autowired
    private MetricClient metricClient;
    private Long expectNum = new Long(0);
    private ObjectMapper objectMapper = new ObjectMapper();
    private final static Double THRESHOLD = 0.1;
    @RabbitHandler
    public void onMessage(byte[] res, Channel channel, @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        super.onMessage(res, deliveryTag, channel, new MqListener<byte[]>() {
            @Override
            public void handler(byte[] body, Channel channel) {
                Map<Long, Integer> msg = null;
                try {
                    msg = objectMapper.readValue(new String(body),
                            new TypeReference<Map<Long, Integer>>() {});
                } catch (JsonProcessingException e) {
                    throw new RuntimeException(e);
                }
                System.out.println("业务处理开始，处理待更新的标签聚类中心！");
                List<LabelCategoryDO>labelList = new ArrayList<>();
                for(Map.Entry<Long, Integer> item :msg.entrySet()){
                    LabelCategoryDO label = labelCategoryService.findById(item.getKey());
                    // 过滤无效的标签
                    if(label == null){
                        continue;
                    }
                    int unsolvedNum = label.getUnsolvedNum() + item.getValue();
                    // 若未参与聚类的样本实例到达一定阈值则更新特征聚类中心
                    if((double)unsolvedNum / label.getNum() > THRESHOLD){
                        List<String> codes = metricClient.getCentroids(label.getId());
                        List<byte[]> centroids = new ArrayList<>();
                        for (String code : codes) {
                            // 特征字符串解码
                            byte[] centroid = Base64.getDecoder().decode(code);
                            centroids.add(centroid);
                        }
                        // 更新特征聚类中心
                        label.setImgFeature(centroids);
                        unsolvedNum = 0;
                    }
                    label.setUnsolvedNum(unsolvedNum);
                    labelList.add(label);
                }
                labelCategoryService.updateBatchById(labelList);
            }
        });
    }

}
