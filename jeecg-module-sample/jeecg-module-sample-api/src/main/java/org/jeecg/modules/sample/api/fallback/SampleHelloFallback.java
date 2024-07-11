package org.jeecg.modules.sample.api.fallback;

import org.springframework.cloud.openfeign.FallbackFactory;
import org.jeecg.modules.sample.api.SampleHelloApi;
import lombok.Setter;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;

/**
 * @author JeecgBoot
 */
@Slf4j
@Component
public class SampleHelloFallback implements FallbackFactory<SampleHelloApi> {
    @Setter
    private Throwable cause;

    @Override
    public SampleHelloApi create(Throwable throwable) {
        log.error("微服务接口调用失败： {}", cause);
        return null;
    }

}
