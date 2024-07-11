package org.jeecg.modules.sample.client;

import org.jeecg.modules.sample.entity.LabelCategoryDO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * @program: RSSampleCenter
 * @description: 标签体系管理子模块调用接口
 * @author: swiftlife
 * @create: 2024-03-24 14:02
 *
 **/
@FeignClient(value = "jeecg-classify")
public interface ClassifyClient {
    @PutMapping("/classify/update")
    Map<String,Long> addClassify(@RequestBody Map<String,List<String>>edges);
    @PutMapping("/classify/label/saveOrUpdate")
    void saveOrUpdateLabelCategory(@RequestBody Collection<LabelCategoryDO> labels);
    @GetMapping("/classify/label/getById/{id}")
    LabelCategoryDO getLabelCategoryById(@PathVariable Long id);
}