package org.jeecg.modules.classify.api;
import org.jeecg.modules.classify.api.fallback.ClassifyHelloFallback;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(value = "jeecg-classify", fallbackFactory = ClassifyHelloFallback.class)
public interface ClassifyHelloApi {

    /**
     * classify hello 微服务接口
     * @param
     * @return
     */
    @GetMapping(value = "/classify/hello")
    String callHello();
}
