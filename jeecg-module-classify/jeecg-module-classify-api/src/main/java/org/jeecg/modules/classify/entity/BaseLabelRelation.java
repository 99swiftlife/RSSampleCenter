package org.jeecg.modules.classify.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.neo4j.core.schema.*;

/**
 * @program: RSSampleCenter
 * @description: 标签类别关系基类
 * @author: Mr.Wang
 * @create: 2023-12-06 16:40
 **/
@Data
@RelationshipProperties
@NoArgsConstructor(force = true)
public class BaseLabelRelation {
    @Id @GeneratedValue
    private final Long id;
    @TargetNode
    private final LabelCategory endNode;
    private Double distWeight;
}
