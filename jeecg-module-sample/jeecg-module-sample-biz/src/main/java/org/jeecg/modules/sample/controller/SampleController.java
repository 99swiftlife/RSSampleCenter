package org.jeecg.modules.sample.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.common.util.RedisUtil;
import org.jeecg.modules.sample.client.CBIRServiceClient;
import org.jeecg.modules.sample.client.ClassifyClient;
import org.jeecg.modules.sample.entity.*;
import org.jeecg.modules.sample.service.IDataSetService;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.util.AlluxioUtils;
import org.jeecg.modules.sample.vo.Result;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@Api(tags = "sample示例")
@RestController
@RequestMapping("/sample")
@Slf4j
public class SampleController {

	@Autowired
	private ISampleService scOpticalSampleService;
	@Autowired
	private CBIRServiceClient cbirServiceClient;
	@Autowired
    private ClassifyClient classifyClient;
	@Autowired
	private IDataSetService dataSetService;
	@Autowired
	private RedisUtil redisUtil;

	@ApiOperation(value = "hello", notes = "对外服务接口")
	@GetMapping(value = "/hello")
	public String sayHello() {
		log.info(" ---我被调用了--- ");
		return scOpticalSampleService.hello();
	}
	@ApiOperation(value = "queryById", notes = "样本元数据根据id检索接口")
	@GetMapping(value = "/query/{id}")
	public SCOpticalSample getSample(@PathVariable(value = "id")Integer id) {
		log.info(" ---根据id查询样本信息--- ");
		return scOpticalSampleService.getById(id);
	}
	@ApiOperation(value = "exact query", notes = "样本元数据检索接口")
	@GetMapping(value = "/query/exact")
	public Result<IPage<RSSampleVO>> listSample(SCOpticalSample rsSample,
													 @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
													 @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
													 HttpServletRequest req) throws NoSuchFieldException, IllegalAccessException {
		log.info(" ---查询样本信息--- ");
		return getiPageResult(rsSample, pageNo, pageSize, req.getParameterMap());
	}
	@ApiOperation(value = "save", notes = "写入样本元数据")
	@PostMapping(value = "/save")
	public boolean saveSample(@RequestBody SCOpticalSample rsSample) {
		log.info(" ---写入样本信息--- ");
		return scOpticalSampleService.save(rsSample);
	}
	@ApiOperation(value = "update", notes = "更新样本元数据")
	@PutMapping(value = "/update")
	public boolean updateSample(@RequestBody SCOpticalSample rsSample) {
		log.info(" ---更新样本信息--- ");
		return scOpticalSampleService.updateById(rsSample);
	}
	@ApiOperation(value = "remove", notes = "删除样本元数据")
	@DeleteMapping (value = "/remove")
	public boolean removeSample(@RequestBody List<Integer> ids) {
		log.info(" ---批量删除--- ");
		return scOpticalSampleService.removeBatchByIds(ids);
	}

	/**
	 * @description: 解析输入的样本数据集定义，获取数据集属性，写入数据集表
	 **/
	@ApiOperation(value = "resolve", notes = "解析样本数据集")
	@PutMapping (value = "/resolve")
	public org.jeecg.common.api.vo.Result<Dataset> resolveDataSet(@RequestBody DatasetDTO datasetDTO) {
		log.info(" ---解析样本数据集--- ");
		Dataset dst = new Dataset();
		try{
			// TODO 解析数据集位置（本地、HDFS、AWS、Google),调用对应的方法将数据集挂载至alluxio
			// 判断数据集是否已存入样本库
			List<Dataset> datasets =  dataSetService.findByName(datasetDTO.getDatasetName());
			if(datasets.size()>0){
				dst = datasets.get(0);
				if(dst.validate())
					// TODO 返回信息：数据集已在样本库中
					return org.jeecg.common.api.vo.Result.OK("数据集已在样本库中！",datasets.get(0));
			}

			// 先写入部分数据集信息，以获取datasetId
			dst.setSensor(datasetDTO.getSensor()) ;
			dst.setDatasetName(datasetDTO.getDatasetName());
			dst.setTaskType(datasetDTO.getTaskType());
			dataSetService.saveOrUpdate(dst);

			// TODO 解析数据集位置（本地、HDFS、AWS、Google),根据不同位置调用对应的数据获取方法
			String dataSetUrl = datasetDTO.getDatasetUrl();
			String alluxioPath = "";
			if (dataSetUrl.contains("file") || dataSetUrl.contains("s3")){
				alluxioPath = Paths.get("/SampleDataSets",datasetDTO.getDatasetName()).toString();
				AlluxioUtils.mount(alluxioPath,dataSetUrl);
			}
			else if(dataSetUrl.contains("alluxio")){
				alluxioPath =  dataSetUrl.substring(8);
				System.out.println("ALLUXIO PATH: "+alluxioPath);
			}

			/**解析数据集波段信息*/
			Map<Integer,Map<String,Integer>> bandInfoMap = new HashMap<>();
			List<List<String>>bandInfos = datasetDTO.getBandInfo();
			if(bandInfos!=null && bandInfos.size()>0){
				for(List<String> bands :bandInfos){
					Integer sz = bands.size();
					Map<String,Integer> bandMap = new HashMap<>();
					for(int i = 0;i<sz;++i){
						String band= bands.get(i);
						bandMap.put(band.toLowerCase().replace('_',' '),i+1);
					}
					bandInfoMap.put(sz,bandMap);
				}
			}

			// TODO 修改以兼容样本集细分为train/val/test的数据集
			/**
			 * 数据集解析形式，暂时支持两种形式：
			 * 1、样本所在目录名为标签类型的树形结构形式
			 * 2、包含单独存储的的标签文件，存储样本名到标签的映射
			 **/
			// 获取样本集的标签存储类型
			String labelPath = datasetDTO.getLabelPath();
			if(labelPath == null){
				for(String folder: datasetDTO.getImgFolder()){
					String datasetImgFolder = Paths.get(alluxioPath,folder).toString();
					dataSetService.parseDataset(datasetImgFolder,datasetDTO.getDatasetName(),datasetDTO.getImgExt(),bandInfoMap,dst,datasetDTO.getMaxCategoryLevel());
				}
			}
			// 记录数据集信息，写入数据集表
			dataSetService.saveOrUpdate(dst);
		}catch (Exception e){
			return org.jeecg.common.api.vo.Result.error("数据集解析错误！"+e.getMessage(),dst);
		}
		// TODO 若解析成功则取消数据集的挂载 ?

		return org.jeecg.common.api.vo.Result.OK("数据集解析成功！",dst);
	}
	/**
	 * 检索准确样本+可能相关的弱样本
	 * param: labelId_MultiString	标签类别id列表
	 * param: labelId_Filter	标签类别id列表
	 * */
	@ApiOperation(value = "general query", notes = "样本元数据检索接口")
	@GetMapping(value = "/query/general")
	Result<IPage<RSSampleVO>> listDynamicSamples(SCOpticalSample rsSample,
							@RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
							@RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
							HttpServletRequest req) throws NoSuchFieldException, IllegalAccessException {
		Map<String, String[]> paramMap = new HashMap(req.getParameterMap());
		// todo>>若不存在labelIds，则返回错误信息
		if(!paramMap.containsKey("labelId_MultiString")){
			Result<IPage<RSSampleVO>> result = new Result<>();
			result.setSuccess(false);
			return result;
		}
		// 从paramMap中获取标签id集合
		List<Long> ids = Arrays.stream(paramMap.get("labelId_MultiString")[0].split(","))
				.map(Long::parseLong) // 将String转换为Long
				.collect(Collectors.toList());
		paramMap.remove("labelId_MultiString");

		// 将CBIR检索得到的sampleIds作为in过滤条件
		List<Long>sampleIds = cbirServiceClient.contentBasedSearch(ids);
		paramMap.put("id_MultiString",new String[]{sampleIds.stream()
				.map(String::valueOf) // 将Long转换为String
				.collect(Collectors.joining(","))}); // 用逗号连接);

		// 调用分页多条件过滤获取查询结果
		return getiPageResult(rsSample, pageNo, pageSize, paramMap);
	}

	/**
	 * 检索准确样本+可能相关的弱样本
	 * param: labelId_MultiString	标签类别id列表
	 * param: labelId_Filter	标签类别id列表
	 * */
	@ApiOperation(value = "resolve progress", notes = "样本解析进度监控")
	@GetMapping(value = "/resolve/progress/{name}")
	public List<Integer> parseProgress(@PathVariable(value = "name")String datasetName){
		Integer totalNum =  (Integer)redisUtil.hget("dataset_total",datasetName);
		Integer resolveNum = (Integer)redisUtil.hget("dataset_progress",datasetName);
		if(totalNum!=null&&resolveNum!=null)
			return Arrays.asList(new Integer[]{resolveNum, totalNum});
		return new ArrayList<>();
	}

	@NotNull
	private Result<IPage<RSSampleVO>> getiPageResult(SCOpticalSample rsSample, @RequestParam(name = "pageNo", defaultValue = "1") Integer pageNo, @RequestParam(name = "pageSize", defaultValue = "10") Integer pageSize, Map<String,String[]>paramMap) {
		Result<IPage<RSSampleVO>> result = new Result<>();
		IPage<SCOpticalSample> page = new Page<>(pageNo, pageSize);
		page = scOpticalSampleService.listSCOpticalSamples(page, paramMap, rsSample);
		IPage<RSSampleVO> pageVO = new Page<>(pageNo, pageSize);
		List<RSSampleVO> voData =  new ArrayList<>();
		for(RSSample record:  page.getRecords()){
			LabelCategoryDO label =  classifyClient.getLabelCategoryById(record.getLabelId());
			Dataset dataset = dataSetService.getById(record.getDatasetId());
			RSSampleVO rsVO = new RSSampleVO(record);
			rsVO.setDatasetName(dataset.getDatasetName());
			rsVO.setLabelName(label.getName());
			voData.add(rsVO);
		}
		pageVO.setRecords(voData);
		result.setSuccess(true);
		result.setResult(pageVO);
		return result;
	}

	/**
	 * 数据集解析情况校验
	 * param: labelId_MultiString	标签类别id列表
	 * param: labelId_Filter	标签类别id列表
	 * */
	@ApiOperation(value = "resolve progress", notes = "样本解析进度监控")
	@GetMapping(value = "/resolve/progress/{name}")
	public Boolean dataSetCheck(@RequestBody DatasetDTO datasetDTO){
		String datasetName = datasetDTO.getDatasetName();
		Dataset dst = dataSetService.findByName(datasetName).get(0);
		if(dst.getInsNum() != null ){
			if(dst.getProcessedNum() != null && dst.getInsNum() == dst.getProcessedNum())
				return true;
			else{
				List<SCOpticalSample> samples = scOpticalSampleService.findByDatasetId(dst.getId());
				Boolean validated = true;
				Integer processedNum = 0;
				for(SCOpticalSample sample : samples){
					validated = validated && sample.validate();
					if(validated)processedNum+=1;
				}
				dst.setProcessedNum(processedNum);
				return validated;
			}
		}
		return false;
	}
}
