package org.jeecg.modules.classify.client;

import org.jeecg.modules.classify.entity.Edge;
import org.jeecg.modules.classify.entity.LabelCategoryDTO;
import org.jeecg.modules.classify.entity.PairDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@FeignClient(name = "metricservice", url = "http://10.3.1.128:8084")
public interface MetricClient {
    @PostMapping("/category/similar/")
    PairDTO<List<Edge>, List<LabelCategoryDTO>> mergeLists(@RequestBody List<String> nodes);
    @GetMapping("/category/centroids/{label_id}")
    List<String> getCentroids(@PathVariable Long label_id);
}
