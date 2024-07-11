package org.jeecg.modules.sample.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.annotations.ApiModel;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.util.List;

/**
 * @program: RSSampleCenter
 * @description: 样本所属的源数据集
 * @author: Mr.Wang
 * @create: 2023-12-04 20:51
 **/
@Data
@TableName(value = "sample_dataset",autoResultMap=true)
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@ApiModel(value="dataset对象", description="样本数据集表")
public class Dataset {
    @TableId(value = "id",type = IdType.AUTO)
    private Long id;
    private String datasetName;
    private String sensor;
    private Integer catNum;
    private Integer insNum;
    private String taskType;
//    private String source;
//    private String version;
//    private String copyRight;
//    private String description;
//    private BoundingBox spitalRange;
//    private List<String > timeRange;
    private Integer processedNum = 0;
    public Boolean validate(){
        return id !=null && datasetName!=null && catNum!=null && insNum!=null && processedNum!=null && processedNum == insNum ;
    }
}
