package org.jeecg.modules.sample.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.sun.org.apache.xpath.internal.operations.Bool;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;

@Data
public abstract class RSSample {
    @TableId(value = "id",type = IdType.AUTO)
    private Long id;
    private Long datasetId;
    private Long labelId;
    private Float resolution;
    private Integer sampleSize;
    private String imgType;
    private String imgPath;
    private String labelPath;
    // 2024/7/8 新增属性：样本解析状态
    private SampleStatue statue;
    public abstract byte[] contentFeatureExtract();
    public abstract void loadImage() ;

}
