package org.jeecg;

import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.classify.client.MetricClient;
import org.jeecg.modules.classify.entity.LabelCategory;
import org.jeecg.modules.classify.service.ClassifyService;
import org.jeecg.modules.classify.service.ILabelCategoryService;
import org.jeecg.modules.classify.service.LabelRepository;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import reactor.core.publisher.Flux;

import javax.annotation.Resource;
import java.util.*;

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
    @Resource
    private LabelRepository labelRepository;
    @Resource
    private ILabelCategoryService labelCategoryService;
    @Autowired
    private MetricClient metricClient;
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
    public void experiment(){
        String [] label_list = {"sada","asd"};
        for(String label_name : Arrays.asList(label_list)){
            Long id = labelRepository.findByName(label_name).getId();
            Map<Long,String> id2Name = new HashMap<>();
            List<Long>labelIdList = new ArrayList<>();
            /**
             * 查找关联标签的算法：(如何确定父类和空间关联类别的权重）
             * 1、所有子类：distWeight = 0.0
             * 2、父类: distWeight = 1.0
             * 3、相似类别根据相似度距离度量 > 0.0
             * 4、空间关联类别：distWeight= 由关联计数指定，最大初始值为5.0（5.0/关联计数）
             */
            //todo>>maxDistance怎么确定
            List<LabelCategory> res =  labelRepository.findNodesWithinDistance(id,1.5);
            for (LabelCategory re : res) {
                // 排除用作检索条件的标签本身
                if(re.getId()==id) continue;
                // 排除实例数为0的类别
                Integer insNum = labelCategoryService.getById(re.getId()).getNum();
                if(insNum == 0) continue;
                id2Name.put(re.getId(),re.getName());
                labelIdList.add(re.getId());
            }

        }
    }
}
