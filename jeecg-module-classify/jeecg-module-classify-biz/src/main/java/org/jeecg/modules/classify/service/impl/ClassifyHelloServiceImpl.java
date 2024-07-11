package org.jeecg.modules.classify.service.impl;


import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.jeecg.modules.classify.entity.ClassifyHelloEntity;
import org.jeecg.modules.classify.mapper.ClassifyHelloMapper;
import org.jeecg.modules.classify.service.IClassifyHelloService;
import org.springframework.stereotype.Service;

/**
 * 测试Service
 */
@Service
public class ClassifyHelloServiceImpl extends ServiceImpl<ClassifyHelloMapper, ClassifyHelloEntity> implements IClassifyHelloService {

    @Override
    public String hello() {
        return "hello ，我是 classify 微服务节点!";
    }
}
