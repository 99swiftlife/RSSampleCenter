package org.jeecg.modules.sample.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @program: RSSampleCenter
 * @description: 遥感样本视图展示对象
 * @author: swiftlife
 * @create: 2024-06-17 16:35
 **/
@Data
@AllArgsConstructor
@NoArgsConstructor
public class RSSampleVO {
    private Long id;
    private String datasetName;
    private String labelName;
    private Float resolution;
    private Integer sampleSize;
    private String imgType;

    public RSSampleVO(RSSample record) {
        id = record.getId();
        resolution = record.getResolution();
        sampleSize = record.getSampleSize();
        imgType = record.getImgType();
    }
}
