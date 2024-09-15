package org.jeecg.modules.cbir.entity;

import lombok.AllArgsConstructor;
import lombok.Data;

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
    private Long categoryId;
    private String imgPath;
    // private Integer sampleSize;
    // private BoundingBox bbox;
    // private Double res;
    // private String time;
}
