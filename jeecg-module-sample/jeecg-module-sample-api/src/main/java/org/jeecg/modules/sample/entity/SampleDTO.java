package org.jeecg.modules.sample.entity;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Set;

/**
 * @program: RSSampleCenter
 * @description: 样本数据数据传输对象
 * @author: swiftlife
 * @create: 2024-03-26 10:07
 **/
@Data
@AllArgsConstructor
public class SampleDTO {
    private Long sampleId;
    private Set<Long> categoryId;
    private String imgPath;
    // private Integer sampleSize;
    // private BoundingBox bbox;
    // private Double res;
    // private String time;
}
