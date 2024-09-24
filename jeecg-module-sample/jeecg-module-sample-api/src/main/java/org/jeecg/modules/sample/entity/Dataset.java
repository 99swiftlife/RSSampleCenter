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
import org.jeecg.modules.sample.handler.MapToJosnTypeHandler;
import org.springframework.beans.BeanUtils;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @program: RSSampleCenter
 * @description: 样本所属的源数据集
 * @author: Mr.Wang
 * @create: 2023-12-04 20:51
 **/
@Data
@AllArgsConstructor
@NoArgsConstructor
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

    private String datasetUrl;
    @TableField(value = "band_info",typeHandler = BandInfoTypeHandler.class)
    private Map<Integer, Map<String,Integer>> bandInfo;
    private String labelPath;
    private String metaPath;
    @TableField(value = "img_folders",typeHandler = com.example.typehandler.StringListTypeHandler.class)
    private List<String> imgFolders;
    private String platform;
    private String imgExt;
    private Integer maxCategoryLevel;

    public Boolean validate(){
        return id !=null && datasetName!=null && catNum!=null && insNum!=null && processedNum!=null && processedNum.equals(insNum);
    }
    public void copyFromDto(DatasetDTO dto) throws InvocationTargetException, IllegalAccessException {
        BeanUtils.copyProperties(dto,this);
        /**解析数据集波段信息*/
        Map<Integer,Map<String,Integer>> bandInfoMap = new HashMap<>();
        List<List<String>>bandInfos = dto.getBandInfo();
        if(bandInfos!=null && bandInfos.size()>0){
            for(List<String> bands :bandInfos){
                Integer sz = bands.size();
                Map<String,Integer> bandMap = new HashMap<>();
                for(int i = 0;i<sz;++i){
                    String band= bands.get(i);
                    bandMap.put(band.toLowerCase().replace('_',' '),i+1);
                }
                bandInfoMap.put(sz,bandMap);
            }
        }

        bandInfo = bandInfoMap;

    }
    public void addProcessedNum(){
        processedNum+=1;
    }
    public static class BandInfoTypeHandler extends MapToJosnTypeHandler<Map<Integer,Map<String,Integer>>> {
    }
}
