package org.jeecg.modules.sample.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @program: RSSampleCenter
 * @description: 样本元数据数据传输对象
 * @author: swiftlife
 * @create: 2024-03-27 01:38
 **/
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SampleMetaDTO {
     @JsonProperty("sample_size")
     private Integer sampleSize;
     @JsonProperty("bbox")
     private BoundingBox bbox;
     @JsonProperty("resolution")
     private Float res;
     private String time;
}
