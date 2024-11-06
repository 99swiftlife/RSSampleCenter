package org.jeecg.modules.sample.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.sun.org.apache.xpath.internal.operations.Bool;
import lombok.Data;
import lombok.experimental.Accessors;
import org.jeecg.modules.sample.handler.GeometryTypeHandler;
import org.jeecg.modules.sample.handler.LongSetTypeHandler;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Set;

@Data
@Accessors(chain = true)
public abstract class RSSample {
    @TableId(value = "id",type = IdType.AUTO)
    private Long id;
    private Long datasetId;
    @TableField(value = "label_id",typeHandler = LongSetTypeHandler.class)
    private Set<Long> labelId;
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
