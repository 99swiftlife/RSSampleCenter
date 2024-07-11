package org.jeecg.modules.classify.service.impl;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.jeecg.modules.classify.entity.LabelCategoryDO;
import org.jeecg.modules.classify.mapper.LabelCategoryMapper;
import org.jeecg.modules.classify.service.ILabelCategoryService;
import org.springframework.stereotype.Service;

/**
 * @program: RSSampleCenter
 * @description: 标签类别表业务类
 * @author: swiftlife
 * @create: 2024-04-03 20:28
 **/
@Service
@DS("postgis")
public class LabelCategoryServiceImpl extends ServiceImpl<LabelCategoryMapper, LabelCategoryDO> implements ILabelCategoryService {
    @Override
    public LabelCategoryDO findById(Long id) {
        return baseMapper.findById(id);
    }
}
