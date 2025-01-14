package org.jeecg.modules.sample.controller;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.jeecg.modules.sample.task.QuartzService;
import org.quartz.SchedulerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.socket.WebSocketSession;

@Api(tags = "task示例")
@RestController
@RequestMapping("/tasks")
public class TaskController {

    @Autowired
    private QuartzService quartzService;


    // 暂停任务
    @ApiOperation(value = "pause task", notes = "暂停任务接口")
    @GetMapping("/pause/{taskId}")
    public String pauseTask(@PathVariable String taskId) {
        try {
            quartzService.pauseTask(taskId);
            return "Task " + taskId + " paused successfully.";
        } catch (SchedulerException e) {
            return "Failed to pause task: " + e.getMessage();
        }
    }

    // 恢复任务
    @ApiOperation(value = "resume task", notes = "恢复任务接口")
    @GetMapping("/resume/{taskId}")
    public String resumeTask(@PathVariable String taskId) {
        try {
            quartzService.resumeTask(taskId);
            return "Task " + taskId + " resumed successfully.";
        } catch (SchedulerException e) {
            return "Failed to resume task: " + e.getMessage();
        }
    }

    // 删除任务
    @ApiOperation(value = "delete task", notes = "删除任务接口")
    @GetMapping("/delete/{taskId}")
    public String deleteTask(@PathVariable String taskId) {
        try {
            quartzService.deleteTask(taskId);
            return "Task " + taskId + " deleted successfully.";
        } catch (SchedulerException e) {
            return "Failed to delete task: " + e.getMessage();
        }
    }
}
