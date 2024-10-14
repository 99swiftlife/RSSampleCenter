package org.jeecg.modules.sample.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.annotations.ApiModel;
import io.swagger.models.auth.In;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;
import org.jeecg.modules.sample.handler.GeometryTypeHandler;

/**
 * @program: RSSampleCenter
 * @description: 场景分类光学样本类
 * @author: Mr.Wang
 * @create: 2023-12-06 16:40
 **/
@Data
@TableName(value = "sc_sample",autoResultMap=true)
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@ApiModel(value="sc_sample对象", description="场景分类光学样本类表")
public class SCOpticalSample extends RSSample{
    private String sensor;
    @TableField(value = "bbox",typeHandler = GeometryTypeHandler.class)
    private BoundingBox bbox;
    private String time;

    @Override
    public byte[] contentFeatureExtract() {
        return new byte[0];
    }

    @Override
    public void loadImage() {

    }

}
