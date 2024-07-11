package org.jeecg.modules.sample.client;

import org.apache.commons.lang3.tuple.Pair;
import org.jeecg.modules.sample.entity.LabelCategoryDO;
import org.jeecg.modules.sample.entity.PairDTO;
import org.jeecg.modules.sample.entity.SampleDTO;
import org.jeecg.modules.sample.entity.SampleMetaDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;
import java.util.Map;

@FeignClient(name = "metricservice", url = "http://10.3.1.128:8084")
public interface CBIRServiceClient {
    @PostMapping("/category/resolve/")
    PairDTO<Map<Long,SampleMetaDTO>,Map<Long,List<String>>> addDataSet(@RequestBody PairDTO<List<SampleDTO>,Map<Integer,Map<String,Integer>>> samples);
    @PostMapping("/category/cbir/")
    List<Long> contentBasedSearch(@RequestBody List<Long> ids);
    @GetMapping("/category/check/{id}")
    Boolean validateSampleFeature(@PathVariable Long id);
}
