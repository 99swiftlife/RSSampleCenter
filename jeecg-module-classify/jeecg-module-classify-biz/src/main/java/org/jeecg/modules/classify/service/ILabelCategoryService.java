package org.jeecg.modules.classify.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.classify.entity.LabelCategoryDO;

public interface ILabelCategoryService extends IService<LabelCategoryDO> {
    LabelCategoryDO findById(Long id);

}
