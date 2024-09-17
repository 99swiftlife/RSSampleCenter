package org.jeecg.modules.sample.mapper;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import org.jeecg.modules.sample.entity.BoundingBox;
import org.apache.ibatis.annotations.Param;
import org.jeecg.modules.sample.entity.SCOpticalSample;

import java.util.List;

public interface SCOpticalSampleMapper extends BaseMapper<SCOpticalSample> {
    IPage<SCOpticalSample> listSCOpticalSamples(IPage<SCOpticalSample> page, @Param("ew") Wrapper<SCOpticalSample> wrapper, @Param("area") BoundingBox area);
}
