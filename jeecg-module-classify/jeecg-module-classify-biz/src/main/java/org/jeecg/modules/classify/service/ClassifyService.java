package org.jeecg.modules.classify.service;

import org.jeecg.modules.classify.entity.Edge;
import org.jeecg.modules.classify.entity.LabelCategory;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

public interface ClassifyService {
    Map<String,Long> addGraph(List<String> nodeNames, List<Edge> egdes);
}
