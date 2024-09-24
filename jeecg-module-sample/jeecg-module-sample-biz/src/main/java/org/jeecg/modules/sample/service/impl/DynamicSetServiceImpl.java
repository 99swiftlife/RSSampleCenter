package org.jeecg.modules.sample.service.impl;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.entity.DynamicDataset;
import org.jeecg.modules.sample.mapper.DataSetMapper;
import org.jeecg.modules.sample.mapper.DynamicSetMapper;
import org.jeecg.modules.sample.service.IDynamicSetService;
import org.springframework.stereotype.Service;

@Service
@DS("postgis")
public class DynamicSetServiceImpl extends ServiceImpl<DynamicSetMapper, DynamicDataset> implements IDynamicSetService {

}
