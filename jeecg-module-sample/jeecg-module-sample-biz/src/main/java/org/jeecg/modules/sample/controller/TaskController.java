package org.jeecg.modules.sample.controller;

import org.jeecg.modules.sample.task.QuartzService;
import org.quartz.SchedulerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.socket.WebSocketSession;

@RestController
@RequestMapping("/tasks")
public class TaskController {

    @Autowired
    private QuartzService quartzService;


    // 暂停任务
    @PostMapping("/pause/{taskId}")
    public String pauseTask(@PathVariable String taskId) {
        try {
            quartzService.pauseTask(taskId);
            return "Task " + taskId + " paused successfully.";
        } catch (SchedulerException e) {
            return "Failed to pause task: " + e.getMessage();
        }
    }

    // 恢复任务
    @PostMapping("/resume/{taskId}")
    public String resumeTask(@PathVariable String taskId) {
        try {
            quartzService.resumeTask(taskId);
            return "Task " + taskId + " resumed successfully.";
        } catch (SchedulerException e) {
            return "Failed to resume task: " + e.getMessage();
        }
    }

    // 删除任务
    @PostMapping("/delete/{taskId}")
    public String deleteTask(@PathVariable String taskId) {
        try {
            quartzService.deleteTask(taskId);
            return "Task " + taskId + " deleted successfully.";
        } catch (SchedulerException e) {
            return "Failed to delete task: " + e.getMessage();
        }
    }
}
