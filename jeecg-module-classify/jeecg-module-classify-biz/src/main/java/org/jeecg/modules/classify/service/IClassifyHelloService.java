package org.jeecg.modules.classify.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.classify.entity.ClassifyHelloEntity;

/**
 * 测试接口
 */
public interface IClassifyHelloService extends IService<ClassifyHelloEntity> {

    String hello();

}
