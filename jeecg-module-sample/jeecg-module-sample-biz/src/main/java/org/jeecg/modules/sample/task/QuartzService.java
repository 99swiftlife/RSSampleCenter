package org.jeecg.modules.sample.task;

import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.service.IDataSetService;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class QuartzService {

    @Autowired
    private Scheduler scheduler;

    // 启动任务
    public void startTask(String taskId, Dataset dst) throws SchedulerException {
        // 检查任务是否已经存在
        if (scheduler.checkExists(new JobKey(taskId))) {
            System.out.println("任务已存在，taskId: " + taskId);
            return;
        }

        JobDataMap jobDataMap = new JobDataMap();
        jobDataMap.put("taskId", taskId);
        jobDataMap.put("datasetInfo", dst);

        JobDetail jobDetail = JobBuilder.newJob(SampleIntegrationJob.class)
                .withIdentity(taskId)  // 设置任务ID
                .usingJobData(jobDataMap)
                .build();

        Trigger trigger = TriggerBuilder.newTrigger()
                .withIdentity(taskId + "_trigger")
                .startNow()
                .build();
        try{
            if (!scheduler.isStarted()) {
                scheduler.start();
            }
            scheduler.scheduleJob(jobDetail, trigger);
        } catch (Exception e){
            System.out.println(e);
        }

    }

    // 暂停任务
    public void pauseTask(String taskId) throws SchedulerException {
        scheduler.pauseJob(JobKey.jobKey(taskId));
    }

    // 恢复任务
    public void resumeTask(String taskId) throws SchedulerException {
        scheduler.resumeJob(JobKey.jobKey(taskId));
    }

    // 删除任务
    public void deleteTask(String taskId) throws SchedulerException {
        scheduler.deleteJob(JobKey.jobKey(taskId));
    }
}
