package org.jeecg.modules.cbir.api.fallback;

import org.springframework.cloud.openfeign.FallbackFactory;
import org.jeecg.modules.cbir.api.CBIRHelloApi;
import lombok.Setter;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;

/**
 * @author JeecgBoot
 */
@Slf4j
@Component
public class CBIRHelloFallback implements FallbackFactory<CBIRHelloApi> {
    @Setter
    private Throwable cause;

    @Override
    public CBIRHelloApi create(Throwable throwable) {
        log.error("微服务接口调用失败： {}", cause);
        return null;
    }

}
