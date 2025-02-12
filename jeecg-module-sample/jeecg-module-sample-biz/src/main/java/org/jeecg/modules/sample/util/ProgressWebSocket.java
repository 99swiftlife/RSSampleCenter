package org.jeecg.modules.sample.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.sample.entity.PairDTO;
import org.springframework.stereotype.Component;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.util.concurrent.ConcurrentHashMap;
@Slf4j
@Component
@ServerEndpoint("/websocket/progress/{taskId}")
public class ProgressWebSocket {

    // ConcurrentHashMap 用于存储 taskId 对应的 WebSocket 会话
    private static final ConcurrentHashMap<String, Session> taskSessions = new ConcurrentHashMap<>();

    private Session session;
    private String taskId;

    @OnOpen
    public void onOpen(Session session, @PathParam("taskId") String taskId) {
        this.session = session;
        this.taskId = taskId;

        // 将当前 WebSocket 会话存入 ConcurrentHashMap
        taskSessions.put(taskId, session);
        log.info("WebSocket opened for taskId: " + taskId + ", Session ID: " + session.getId());
    }

    @OnMessage
    public void onMessage(String message) {
        // 处理来自客户端的消息
        log.info("Received message for taskId: " + taskId + " - " + message);
    }

    @OnClose
    public void onClose() {
        // WebSocket 连接关闭时，移除 taskId 对应的 session
        taskSessions.remove(taskId);
        log.info("WebSocket closed for taskId: " + taskId + ", Session ID: " + session.getId());
    }

    @OnError
    public void onError(Throwable error) {
        // 错误处理
        error.printStackTrace();
    }

    public static void broadcastProgress(String dstName, Double progress) {
        PairDTO<String, Double> msg = new PairDTO<>(dstName, progress);

        for (String id : taskSessions.keySet()) {
            Session session = taskSessions.get(id);
            if (session != null && session.isOpen()) {
                try {
                    session.getAsyncRemote().sendText(msg.toJson(), result -> {
                        if (result.isOK()) {
                            System.out.println("消息发送成功，目标: " + id + ", 数据集: " + dstName + ", 进度: " + progress);
                        } else {
                            System.out.println("消息发送失败，Session ID: " + session.getId() + " " + result.getException());
                        }
                    });
                } catch (JsonProcessingException e) {
                    System.out.println("消息发送失败，Session ID: " + session.getId() + " " + e.getMessage());
                }
            }
        }
    }


}

