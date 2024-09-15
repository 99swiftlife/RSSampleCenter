package org.jeecg.modules.cbir.client;

import org.jeecg.modules.cbir.entity.PairDTO;
import org.jeecg.modules.cbir.entity.SampleListenerDTO;
import org.jeecg.modules.cbir.entity.SampleMetaDTO;
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
    SampleListenerDTO resolve(@RequestBody String samplesByteCode);
    @PostMapping("/category/resolve/")
    String resolveStr(@RequestBody String samplesByteCode);
}
