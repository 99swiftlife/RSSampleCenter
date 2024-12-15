package org.jeecg.config.quartz;

import org.quartz.Job;
import org.quartz.spi.TriggerFiredBundle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.scheduling.quartz.AdaptableJobFactory;
import org.springframework.stereotype.Component;

@Component
public class SpringJobFactory extends AdaptableJobFactory {
    @Autowired
    private ApplicationContext applicationContext;
    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        Class<? extends Job> jobClass = bundle.getJobDetail().getJobClass();
        return applicationContext.getBean(jobClass);
    }
}