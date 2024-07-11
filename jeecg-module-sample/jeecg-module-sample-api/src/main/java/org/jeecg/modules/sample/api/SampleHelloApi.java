package org.jeecg.modules.sample.api;
import org.jeecg.modules.sample.api.fallback.SampleHelloFallback;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(value = "jeecg-sample", fallbackFactory = SampleHelloFallback.class)
public interface SampleHelloApi {

    /**
     * sample hello 微服务接口
     * @param
     * @return
     */
    @GetMapping(value = "/sample/hello")
    String callHello();
}
