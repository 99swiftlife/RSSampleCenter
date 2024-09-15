package org.jeecg.modules.cbir.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * @program: RSSampleCenter
 * @description: 样本元数据数据传输对象
 * @author: swiftlife
 * @create: 2024-03-27 01:38
 **/
@Data
public class SampleMetaDTO {
     @JsonProperty("sample_size")
     private Integer sampleSize;
     private BoundingBox bbox;
     @JsonProperty("resolution")
     private Float res;
     private String time;
}
