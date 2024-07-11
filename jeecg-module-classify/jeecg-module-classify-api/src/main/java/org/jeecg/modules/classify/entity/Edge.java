package org.jeecg.modules.classify.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * @program: RSSampleCenter
 * @description: 带权有向边
 * @author: swiftlife
 * @create: 2024-03-11 20:44
 **/
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Edge implements Serializable {
    private String startVertex;  //此有向边的起始点
    private String endVertex;  //此有向边的终点
    private String type; //边类型
    private Double weight;  //此有向边的权值

    public Edge(String startVertex, String endVertex, Double weight) {
        this.startVertex = startVertex;
        this.endVertex = endVertex;
        this.weight = weight;
    }
}
