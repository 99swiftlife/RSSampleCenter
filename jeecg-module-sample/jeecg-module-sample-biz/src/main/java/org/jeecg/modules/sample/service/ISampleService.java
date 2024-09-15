package org.jeecg.modules.sample.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.entity.RSSample;
import org.jeecg.modules.sample.entity.SCOpticalSample;
import org.jeecg.modules.sample.entity.SampleStatue;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * 测试接口
 */
public interface ISampleService extends IService<SCOpticalSample> {

    String hello();

    /*
     * 1.listRSSample : 根据 id, sensor等动态条件查询RSSample
     */
    IPage<SCOpticalSample> listSCOpticalSamples(IPage<SCOpticalSample> page, Map<String,String[]> paramMap, SCOpticalSample rssample);
    List<SCOpticalSample> findByDatasetId(Long datasetId);
    SCOpticalSample findByImgPath(String imgPath);
    Boolean validate(RSSample sample, SampleStatue st);
}
