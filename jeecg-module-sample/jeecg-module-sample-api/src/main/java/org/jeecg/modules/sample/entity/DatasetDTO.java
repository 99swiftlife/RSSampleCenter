package org.jeecg.modules.sample.entity;

import lombok.Data;

import java.util.List;

/**
 * @program: RSSampleCenter
 * @description: 数据集类数据传输对象
 * @author: swiftlife
 * @create: 2024-03-26 19:57
 **/
@Data
public class DatasetDTO {
    private String datasetName;
    private String datasetUrl;
    private String labelPath;
    private String imgExt;
    private List<String> imgFolders;
    // 数据集标签体系的最大层级数：
    private Integer maxCategoryLevel;
    // 传感器类型和平台类型
    private String sensor;
    private String platForm;
    private List<List<String>> bandInfo;
    private String taskType;
    // 是否包含时空信息
    private String metaPath;
}
