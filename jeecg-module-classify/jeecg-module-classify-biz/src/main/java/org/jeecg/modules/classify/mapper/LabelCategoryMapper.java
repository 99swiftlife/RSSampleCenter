package org.jeecg.modules.classify.mapper;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import org.apache.ibatis.annotations.Param;
import org.jeecg.modules.classify.entity.LabelCategoryDO;

public interface LabelCategoryMapper extends BaseMapper<LabelCategoryDO> {
    LabelCategoryDO findById(@Param("id") Long id);

}
