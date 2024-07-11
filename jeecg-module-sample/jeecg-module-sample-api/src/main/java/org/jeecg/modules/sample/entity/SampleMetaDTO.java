package org.jeecg.modules.sample.entity;

import lombok.Data;

/**
 * @program: RSSampleCenter
 * @description: 样本元数据数据传输对象
 * @author: swiftlife
 * @create: 2024-03-27 01:38
 **/
@Data
public class SampleMetaDTO {
     private Integer sampleSize;
     private BoundingBox bbox;
     private Float res;
     private String time;
}
