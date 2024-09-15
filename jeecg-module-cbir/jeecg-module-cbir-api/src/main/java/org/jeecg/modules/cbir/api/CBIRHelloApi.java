package org.jeecg.modules.cbir.api;
import org.jeecg.modules.cbir.api.fallback.CBIRHelloFallback;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(value = "jeecg-cbir", fallbackFactory = CBIRHelloFallback.class)
public interface CBIRHelloApi {

    /**
     * cbir hello 微服务接口
     * @param
     * @return
     */
    @GetMapping(value = "/cbir/hello")
    String callHello();
}
