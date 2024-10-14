package org.jeecg.modules.classify.service;

import org.jeecg.modules.classify.entity.BaseLabelRelation;
import org.jeecg.modules.classify.entity.Edge;
import org.jeecg.modules.classify.entity.LabelCategory;
import org.jeecg.modules.classify.entity.PairDTO;
import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.ReactiveNeo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.data.repository.query.Param;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface LabelRepository extends Neo4jRepository<LabelCategory, Long> {
//    Mono<LabelCategory> findOneByName(String name);
    @Query("START startNode = node($startId), endNode = node($endId) " +
            "MATCH paths = allShortestPaths((startNode)-[*]-(endNode)) " +
            "RETURN nodes(paths)")
    Iterable<Map<String, Iterable<Object>>> findShortestPaths(@Param("startId") Long startId, @Param("endId") Long endId);

    /**
     * 先采用bfs对层级进行前置过滤
     MATCH (p:Category)
     WHERE id(p) = 66
     CALL apoc.path.expandConfig(p, {
     relationshipFilter: 'SUB>|SUPER>|SYNONYM|SPATIAL',
     weightProperty: "distWeight",
     minLevel: 1,
     maxLevel: 3,
     bfs: true
     })YIELD path
     WITH p,last(nodes(path)) AS e
     WHERE id(e) <> 66
     call apoc.algo.dijkstra(p,e, 'SUB>|SUPER>|SYNONYM|SPATIAL', 'distWeight') yield path,weight WITH path,weight
     WHERE weight <=0
     RETURN nodes(path)[-1] AS endNode,weight
     ORDER BY weight*/
    @Query("match (p:Category) where id(p) = $startId " +
            "match (e:Category) where id(e) <> $startId " +
            "call apoc.algo.dijkstra(p,e, \"SUB>|SUPER>|SYNONYM|SPATIAL\", \"distWeight\") yield path,weight " +
            "WITH path,weight " +
            "  WHERE weight <= $maxDistance " +
            "RETURN nodes(path)[-1] AS endNode " +
            "  ORDER BY weight")
    List<LabelCategory> findNodesWithinDistance(@Param("startId") Long startId,
                                                @Param("maxDistance") Double maxDistance);
    @Query("MATCH (n:Category) WHERE n.name = $nodeName RETURN n")
    LabelCategory findByName(@Param("nodeName")String nodeName);
    @Query("MATCH (a), (b)\n"+
            "WHERE a.name = $startNode AND b.name = $endNode\n"+
            "CALL apoc.merge.relationship(a, $type, {}, {distWeight: $distWeight}, b) YIELD rel\n"+
            "RETURN NULL"
    )
    void linkToNodeByName(@Param("startNode")String startNode, @Param("endNode")String endNode, @Param("type")String type, @Param("distWeight")Double distWeight);

    @Query("MATCH (n:Category) RETURN n")
    List<LabelCategory> findAllNodes();

    @Query("MATCH (p)-[r]->(other)\n" +
            "WHERE type(r) = 'SYNONYM' OR \n" +
            "      type(r) = 'SUB' OR \n" +
            "      type(r) = 'SUPER' OR \n" +
            "      type(r) = 'SPATIAL'\n" +
            "RETURN {\n" +
            "  start: id(p),\n" +
            "  end: id(other),\n" +
            "  type: type(r),\n" +
            "  weight: r.distWeight\n" +
            "} AS relationship")

    List<HashMap<String, Object>> findAllRelates();

    @Query("MATCH (n:Category)-[r]->(m:Category) " +
            "WHERE n.name IN $nameList AND m.name IN $nameList " +
            "RETURN { " +
            "  start: id(n), " +  // 返回起点的 ID
            "  startName: n.name, " + //返回起点的名称
            "  end: id(m), " +    // 返回终点的 ID
            "  endName: m.name, " + //返回终点的名称
            "  type: type(r), " + // 返回关系类型
            "  weight: r.distWeight " +  // 返回关系权重
            "} AS relationship")
    List<HashMap<String, Object>> findSubgraphByNames(@Param("nameList") List<String> nameList);

    @Query("MATCH (start:Category {name: $startNodeName}), (end:Category {name: $endNodeName}) " +
            "CALL apoc.algo.dijkstra(start, end, \"SUB>|SUPER>|SYNONYM|SPATIAL\", \"distWeight\") YIELD path " +
            "UNWIND relationships(path) AS r " +  // 展开路径中的每个关系
            "WITH r, startNode(r) AS n, endNode(r) AS m " +  // 获取关系的起点和终点
            "RETURN { " +
            "  start: id(n), " +  // 返回起点的 ID
            "  end: id(m), " +    // 返回终点的 ID
            "  type: type(r), " + // 返回关系类型
            "  weight: r.distWeight " +  // 返回关系权重
            "} AS relationship")
    List<HashMap<String, Object>> findShortestPathByWeight(@Param("startNodeName") String startNodeName,
                                                           @Param("endNodeName") String endNodeName);


}
