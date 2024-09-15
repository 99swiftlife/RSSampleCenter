package org.jeecg.modules.sample.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.beans.BeanUtils;

/**
 * @program: RSSampleCenter
 * @description: 数据集类视图类
 * @author: swiftlife
 * @create: 2024-03-26 19:57
 **/
@AllArgsConstructor
@NoArgsConstructor
@Data
public class DatasetVO {
    private String datasetName;
    private Long defaultImageId;
    private String sensor;
    private Integer catNum;
    private Integer insNum;
    private String taskType;
    private String source;
    private String version;
    private String copyRight;
    private String description;

    public DatasetVO(Dataset dst){
        BeanUtils.copyProperties(dst,this);
    }
}
