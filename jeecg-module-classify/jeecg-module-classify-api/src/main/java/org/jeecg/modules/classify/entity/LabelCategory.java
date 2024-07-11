package org.jeecg.modules.classify.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.neo4j.core.schema.*;
import java.util.List;

@Data
@NoArgsConstructor(force = true)
@Node("Category")
public class LabelCategory {
    @Id
    @GeneratedValue
    private Long id;
    @Property("name")
    private String name;
    @Relationship(type = "SYNONYM")
    private List<BaseLabelRelation > synonym ;
    @Relationship(type = "SUPER")
    private List<BaseLabelRelation> sup ;
    @Relationship(type = "SUB")
    private List<BaseLabelRelation > sub;
    // 空间相邻关系
    @Relationship(type = "SPATIAL")
    private List<BaseLabelRelation > Spatial;
}
