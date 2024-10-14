package org.jeecg.modules.classify.controller;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.checkerframework.checker.units.qual.A;
import org.jeecg.common.api.vo.Result;
import org.jeecg.modules.classify.client.MetricClient;
import org.jeecg.modules.classify.entity.*;
import org.jeecg.modules.classify.service.ClassifyService;
import org.jeecg.modules.classify.service.IClassifyHelloService;
import org.jeecg.modules.classify.service.ILabelCategoryService;
import org.springframework.http.MediaType;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.classify.service.LabelRepository;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Api(tags = "classify示例")
@RestController
@RequestMapping("/classify")
@Slf4j
public class ClassifyHelloController {

	@Autowired
	private IClassifyHelloService jeecgHelloService;
	@Autowired
	private MetricClient metricClient;
	@Autowired
	private ILabelCategoryService labelCategoryService;
	private final LabelRepository labelRepository;
	private final ClassifyService classifyService;

	public ClassifyHelloController(LabelRepository labelRepository,ClassifyService classifyService) {
		this.labelRepository = labelRepository;
		this.classifyService = classifyService;
	}

	@ApiOperation(value = "hello", notes = "对外服务接口")
	@GetMapping(value = "/hello")
	public String sayHello() {
		log.info(" ---我被调用了--- ");
		return jeecgHelloService.hello();
	}

	@ApiOperation(value = "update", notes = "更新分类体系")
	@PutMapping(value = "/update")
	Map<String,Long> createOrUpdateClassify(@RequestBody Map<String,List<String> > edges) {

		// todo>过滤无效的节点
//		List<String>filterNodes = new ArrayList<>();
//		for (String node : nodes) {
//			boolean is_bad = false;
//			for (String filterName : filterNames) {
//				filterName.replace('_',' ');
//				Pattern pattern = Pattern.compile(filterName, Pattern.CASE_INSENSITIVE);
//				Matcher matcher = pattern.matcher(node.replace('_',' '));
//				if(matcher.find()){
//					is_bad = true;break;
//				}
//			}
//			if(is_bad==false)
//				filterNodes.add(node);
//		}
//		// 删除这些无效节点对应的边,对于a->b,b->c，若b无效则修改为a->c
//		List<Edge>edgeList = new ArrayList<>();
//		for (String node : filterNodes) {
//			for(String to: edges.get(node)){
//
//			}
//		}

		List<Edge>edgeList = new ArrayList<>();
		List<String>nodes = new ArrayList<>();
		for (String node : edges.keySet()) {
			nodes.add(node);
			for (String endNode:edges.get(node)){
				edgeList.add(new Edge(node,endNode,0.0));
			}
		}
		return classifyService.addGraph(nodes,edgeList);
	}

	@ApiOperation(value = "queryAll", notes = "获取标签分类体系的所有节点和边")
	@GetMapping(value = { "/query/all" })
	Result<PairDTO<Map<Long,String>,List<HashMap<String, Object>>>> getLabelCategory() {
		List<LabelCategory> labels = labelRepository.findAllNodes();
		List<HashMap<String, Object>> relates = labelRepository.findAllRelates();
		Map<Long,String>id2Name = new HashMap<>();
		for (LabelCategory cate : labels){
			id2Name.put(cate.getId(),cate.getName());
		}
		PairDTO<Map<Long,String>,List<HashMap<String, Object>>> result = new PairDTO<>(id2Name,relates);
		return Result.OK("加载分类体系成功！",result);
	}
	@ApiOperation(value = "querySub", notes = "获取标签分类体系的子图")
	@PostMapping(value = "/query/sub")
	Result<List<HashMap<String, Object>>> getSubGraphById(@RequestBody List<String> nameList) {
		// todo>>labelRepository中添加获取子图的Cypher绑定语句
		List<HashMap<String, Object>> result = labelRepository.findSubgraphByNames(nameList);
		return Result.OK("加载子图成功！",result);
	}

	/**
	 * 根据起始节点和终点节点，查询它们之间最短路径上的所有关联关系
	 * @param startNodeName 起始节点名称
	 * @param endNodeName 终点节点名称
	 * @return 最短路径上的关系集合
	 */
	@ApiOperation(value = "queryShortestPath", notes = "查询最短路")
	@GetMapping("/shortest-path")
	public Result<List<HashMap<String, Object>>> getShortestPathRelationships(@RequestParam String startNodeName,
																	  @RequestParam String endNodeName) {
		// 调用 LabelRepository 接口方法查询最短路径上的关系
		List<HashMap<String, Object>> result = labelRepository.findShortestPathByWeight(startNodeName, endNodeName);
		return Result.OK("加载最短路成功！",result);
	}

	/**根据标签id查找标签体系中意思相近的标签的id*/
	@ApiOperation(value = "queryAssociatedById", notes = "标签分类体系根据标签ID检索关联标签的ID")
	@GetMapping(value = "/query/associated/{id}")
	Result<Map<Long,String>> getAssociatedCategoryIds(@PathVariable(value = "id")Long id) {
		Map<Long,String> id2Name = new HashMap<>();
		/**
		 * 查找关联标签的算法：(如何确定父类和空间关联类别的权重）
		 * 1、所有子类：distWeight = 0.0
		 * 2、父类: distWeight = 1.0
		 * 3、相似类别根据相似度距离度量 > 0.0
		 * 4、空间关联类别：distWeight= 由关联计数指定，最大初始值为5.0（5.0/关联计数）
		 */
		//todo>>maxDistance怎么确定
		List<LabelCategory>res =  labelRepository.findNodesWithinDistance(id,1.5);
		for (LabelCategory re : res) {
			// 排除用作检索条件的标签本身
			if(re.getId().equals(id)) {
				continue;
			}
			// 排除实例数为0的类别
			Integer insNum = labelCategoryService.getById(re.getId()).getNum();
			if(insNum == 0) {
				continue;
			}

			id2Name.put(re.getId(),re.getName());
		}
		Result<Map<Long,String>> result = null;
		if(id2Name.size()==0){
			result = Result.error("关联标签查找失败，无关联的标签类别！",id2Name);
		}
		else {
			result = Result.OK("关联标签查找成功，数量："+id2Name.size(),id2Name);
		}
		return result;
	}

	/**根据标签名查找分类体系中的标签*/
	@ApiOperation(value = "queryByName", notes = "标签分类体系根据标签名检索接口")
	@GetMapping(value = "/query/{name}")
	Result<Map<Long,String>> getLabelIdsByName(@PathVariable(value = "name")String name) {
		Map<Long,String> id2Name = new HashMap<>();
		// 先根据名称直接从分类体系中检索
		LabelCategory category =  labelRepository.findByName(name);
		// 若不存在，则尝试检索文本相似的类别
		if(category == null){
			List<Edge> res = metricClient.mergeLists(Arrays.asList(name)).getLeft() ;
			for (Edge re : res) {
				LabelCategory cur = labelRepository.findByName(re.getEndVertex());
				id2Name.put(cur.getId(),cur.getName());
			}
		}
		else {
			id2Name.put(category.getId(),category.getName());
		}
		// todo>>若都不存在，返回提示不存在该类别
		Result<Map<Long,String> > result = null;
		if(id2Name.size()==0){
			result = Result.error("样本库中不存在名称相似的标签,请检查输入！",id2Name);
		}
		else {
			result = Result.OK("查找到样本库中相似的标签类别，数量："+id2Name.size(),id2Name);
		}
		return result;
	}

	@ApiOperation(value = "deleteByName", notes = "根据标签名删除标签")
	@DeleteMapping("/delete/{name}")
	void delete(@PathVariable String name) {
		LabelCategory category =  labelRepository.findByName(name);
		labelRepository.deleteById(category.getId());
	}

	/**批量写入或更新标签类别表*/
	@PutMapping("/update/category")
	void createOrUpdateLabelCategory(@RequestBody Collection<LabelCategoryDO> labelCategoryDOs){
		labelCategoryService.saveOrUpdateBatch(labelCategoryDOs);
	}

	/**建立空间相邻关系*/
	@ApiOperation(value = "createAdjacentRelations", notes = "在标签间建立空间相邻关系")
	@PutMapping("/create/adjacent")
	void createAdjacentRelations(@RequestBody List<Edge>edges ){
		// todo>>是否需要增加排除本身具有相似关系，以及本身为子类父类关系的类别（暂不增加）
		for (Edge edge : edges) {
			// todo>> distWeight如何指定，跟计数有关，计数越高，distWeight越低
			labelRepository.linkToNodeByName(edge.getStartVertex(),edge.getEndVertex(),"SPATIAL",edge.getWeight());
		}
	}

	@ApiOperation(value = "getById", notes = "根据id获取标签类别")
	@GetMapping("/label/getById/{id}")
	LabelCategoryDO getLabelCategoryById(@PathVariable Long id){
		return labelCategoryService.getById(id);
	}

	@ApiOperation(value = "saveOrUpdateBatch", notes = "批量写入或更新标签类别信息")
	@PutMapping("/label/saveOrUpdate")
	void saveOrUpdateLabelCategory(@RequestBody Collection<LabelCategoryDO> labels){
		labelCategoryService.saveOrUpdateBatch(labels);
	}

}
