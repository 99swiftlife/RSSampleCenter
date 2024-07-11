package org.jeecg.modules.classify.api.fallback;

import org.springframework.cloud.openfeign.FallbackFactory;
import org.jeecg.modules.classify.api.ClassifyHelloApi;
import lombok.Setter;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;

/**
 * @author JeecgBoot
 */
@Slf4j
@Component
public class ClassifyHelloFallback implements FallbackFactory<ClassifyHelloApi> {
    @Setter
    private Throwable cause;

    @Override
    public ClassifyHelloApi create(Throwable throwable) {
        log.error("微服务接口调用失败： {}", cause);
        return null;
    }

}
