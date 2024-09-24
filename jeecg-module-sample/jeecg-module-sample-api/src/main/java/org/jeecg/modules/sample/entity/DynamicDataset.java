package org.jeecg.modules.sample.entity;

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
import org.apache.ibatis.type.JdbcType;
import org.jeecg.modules.sample.handler.MapToJosnTypeHandler;

import java.util.List;
import java.util.Map;
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "dynamic_dataset",autoResultMap=true)
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@ApiModel(value="dynamic_dataset对象", description="动态样本数据集表")
public class DynamicDataset {
    @TableId(value = "id",type = IdType.AUTO)
    private Long id;
    private String datasetName;
    @TableField(value = "ins_map",typeHandler = InsMapTypeHandler.class, jdbcType = JdbcType.VARCHAR)
    private Map<Integer, List<Integer>> insMap;
    public static class InsMapTypeHandler extends MapToJosnTypeHandler<Map<Integer, List<Integer>> >{
    }
}
