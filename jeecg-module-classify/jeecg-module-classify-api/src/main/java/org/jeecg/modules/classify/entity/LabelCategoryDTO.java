package org.jeecg.modules.classify.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.util.List;

/**
 * @program: RSSampleCenter
 * @description: 标签类别数据传输对象
 * @author: swiftlife
 * @create: 2024-04-05 23:59
 **/
@Data
public class LabelCategoryDTO {
    private String name;
    private String descr;
    private String osmUrl;
    private String textFeature;
}
