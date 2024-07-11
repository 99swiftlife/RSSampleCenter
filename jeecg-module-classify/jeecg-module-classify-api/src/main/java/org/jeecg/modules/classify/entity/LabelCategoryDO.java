package org.jeecg.modules.classify.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.annotations.ApiModel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;
import org.jeecg.modules.classify.handler.ByteArrayHandler;

import java.util.Base64;
import java.util.List;

/**
 * @program: RSSampleCenter
 * @description: 标签类别数据对象
 * @author: swiftlife
 * @create: 2024-04-03 16:35
 **/
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName(value = "category",autoResultMap=true)
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@ApiModel(value="category数据对象", description="标签类别表")
public class LabelCategoryDO {
    @TableId(value = "id",type = IdType.INPUT)
    private Long id;
    private String name;
    private Integer num;
//    private String taskType;
    private String descr;
    private String osmUrl;
    private byte[] textFeature;
    @TableField(value = "img_feature",typeHandler = ByteArrayHandler.class)
    private List<byte[]> imgFeature;

    public LabelCategoryDO(LabelCategoryDTO labelCategoryDTO){
        this.name = labelCategoryDTO.getName();
        this.descr = labelCategoryDTO.getDescr();
        this.osmUrl = labelCategoryDTO.getOsmUrl();
        this.textFeature = Base64.getDecoder().decode(labelCategoryDTO.getTextFeature());
    }
}
