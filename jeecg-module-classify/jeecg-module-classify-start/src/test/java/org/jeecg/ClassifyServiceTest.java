package org.jeecg;

import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.classify.entity.LabelCategory;
import org.jeecg.modules.classify.service.ClassifyService;
import org.junit.Test;
import reactor.core.publisher.Flux;

import javax.annotation.Resource;

/**
 * @program: RSSampleCenter
 * @description: 标签分类体系模块服务Bean测试类
 * @author: swiftlife
 * @create: 2023-12-06 22:06
 **/
@Slf4j
public class ClassifyServiceTest extends ApplicationTest {
    @Resource
    ClassifyService classifyService;
    @Test
    public void findSimilarByName(){
//        Flux<LabelCategory> res =  classifyService.findSimilarByName("a");
//        res.subscribe(
//                x -> {
//                    System.out.println("Received: " + x.getName()+"  Descr: "+x.getDescription());
//                },
//                error -> System.err.println("Error: " + error.getMessage()),
//                () -> System.out.println("Completed")
//        );
    }
}
