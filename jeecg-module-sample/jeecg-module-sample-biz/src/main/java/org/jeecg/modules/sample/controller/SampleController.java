package org.jeecg.modules.sample.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.checkerframework.checker.units.qual.A;
import org.jeecg.common.util.RedisUtil;
import org.jeecg.modules.sample.client.CBIRServiceClient;
import org.jeecg.modules.sample.client.ClassifyClient;
import org.jeecg.modules.sample.entity.*;
import org.jeecg.modules.sample.service.IDataSetService;
import org.jeecg.modules.sample.service.IDynamicSetService;
import org.jeecg.modules.sample.service.ISampleService;
import org.jeecg.modules.sample.util.AlluxioUtils;
import org.jeecg.modules.sample.vo.Result;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import org.apache.commons.beanutils.BeanUtils;

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
	private IDynamicSetService dynamicSetService;
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
				if(dst.validate()){
					// TODO 返回信息：数据集已在样本库中
					return org.jeecg.common.api.vo.Result.OK("数据集已在样本库中！",datasets.get(0));
				}
			}
			dst.copyFromDto(datasetDTO);
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
			dst.setDatasetUrl(alluxioPath);
			// 重置已处理的样本数量
			dst.setProcessedNum(0);
			dataSetService.saveOrUpdate(dst);


			// TODO 修改以兼容样本集细分为train/val/test的数据集
			/**
			 * 数据集解析形式，暂时支持两种形式：
			 * 1、样本所在目录名为标签类型的树形结构形式
			 * 2、包含单独存储的的标签文件，存储样本名到标签的映射
			 **/
			// 获取样本集的标签存储类型
			String labelPath = datasetDTO.getLabelPath();
			if(labelPath == null){
				if(datasetDTO.getImgFolders()==null){
					datasetDTO.setImgFolders(Arrays.asList(""));
				}
				for(String folder: datasetDTO.getImgFolders()){
					String datasetImgFolder = Paths.get(alluxioPath,folder).toString();
					dataSetService.parseDataset(datasetImgFolder,dst);
				}
			}
			// 记录数据集信息，写入数据集表
			if(dst.getProcessedNum()>0){
				dataSetService.increasProcessed(dst.getId(),dst.getProcessedNum());
				dst.setProcessedNum(null);
			}
			dataSetService.saveOrUpdate(dst);
		}catch (Exception e){
			e.printStackTrace();
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
		Dataset dst = dataSetService.findByName(datasetName).get(0);
		Integer totalNum =  dst.getInsNum();
		Integer resolveNum = dst.getProcessedNum();
		if(totalNum!=null&&resolveNum!=null){
			return Arrays.asList(new Integer[]{resolveNum, totalNum});
		}
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
	 * 数据集解析程度校验
	 * param: datasetDTO	数据集数据传输对象
	 * return: ResultVo	结果视图
	 *
	 * 总结果：是否全部成功解析
	 * failedSamples List<RSSample> 未解析成功的样本
	 *
	 * */
	@ApiOperation(value = "dataset check", notes = "数据集解析完毕校验")
	@GetMapping(value = "/resolve/check/{name}")
	public List<RSSample> dataSetCheck(@PathVariable(value = "name")String datasetName){
		Dataset dst = dataSetService.findByName(datasetName).get(0);
		List<RSSample> failedSamples = new ArrayList<>();
		List<SCOpticalSample> samples = scOpticalSampleService.findByDatasetId(dst.getId());
		for(RSSample sample : samples){
			if(sample.getStatue() != SampleStatue.SUCCESS){
				failedSamples.add(sample);
			}
		}
		return failedSamples;
	}

	// 重试数据集中未解析成功的样本
	@GetMapping(value = "/resolve/retry/{name}")
	private void retry(@PathVariable(value = "name")String datasetName){
		Dataset dst = dataSetService.findByName(datasetName).get(0);
		List<RSSample>failedSamples = dataSetCheck(datasetName);
		List<SampleDTO>dtos = new ArrayList<>();
		for(RSSample sample: failedSamples){
			switch(sample.getStatue())
			{
				case FAIL:
					// 补全样本数据集id等基本信息

				case INIT:
				case RESOLVED:
					// 重新解析样本图像元素据和特征
					dtos.add(new SampleDTO(sample.getId(), sample.getLabelId(),sample.getImgPath()));
					break;
				default :
					System.out.println("未知任务状态");
			}
		}
		dataSetService.sendBatchToSampleResolver(dtos,dst.getBandInfo());
	}

	@ApiOperation(value = "dataset list", notes = "数据集检索")
	@GetMapping(value = "/dataset/list")
	public Result<IPage<DatasetVO>>listDatasets( Dataset dataset,
							   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
							   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
							   HttpServletRequest req){
		Result<IPage<DatasetVO>> result = new Result<>();
		IPage<Dataset> page = new Page<>(pageNo, pageSize);
		page = dataSetService.page(page);
		IPage<DatasetVO> pageVO = new Page<>(pageNo, pageSize);
		List<DatasetVO> voData =  new ArrayList<>();
		for(Dataset record:  page.getRecords()){
			DatasetVO dstVO = new DatasetVO(record);
			List<Long> randIds = scOpticalSampleService.randSampleByDatasetId(record.getId(), 9L)
					.stream()
					.map(RSSample::getId)
					.collect(Collectors.toList());
			dstVO.setRandImageIds(randIds);
			voData.add(dstVO);
		}
		pageVO.setRecords(voData);
		result.setSuccess(true);
		result.setResult(pageVO);
		return result;
	}
	@ApiOperation(value = "dynamic dataset create", notes = "创建动态数据集")
	@PostMapping(value = "/dynamic/create")
	public boolean createDynamicDataset( @RequestBody DynamicDataset dataset){
		dynamicSetService.saveOrUpdate(dataset);
		return true;
	}

}
