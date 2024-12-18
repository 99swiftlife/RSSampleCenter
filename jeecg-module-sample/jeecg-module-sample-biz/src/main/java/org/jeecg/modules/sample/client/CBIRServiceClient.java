package org.jeecg.modules.sample.client;

import org.jeecg.modules.sample.entity.SampleListenerDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "metricservice", url = "http://10.3.1.128:8084")
public interface CBIRServiceClient {
    @PostMapping("/category/resolve/")
    String resolveStr(@RequestBody String samplesByteCode);
    @PostMapping("/category/resolve/")
    SampleListenerDTO resolve(@RequestBody String samplesByteCode);
    @PostMapping("/category/cbir/")
    List<Long> contentBasedSearch(@RequestBody List<Long> ids);
    @GetMapping("/category/check/{id}")
    Boolean validateSampleFeature(@PathVariable Long id);
}
