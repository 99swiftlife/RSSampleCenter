package org.jeecg.modules.sample.task;

import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.service.IDataSetService;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.Arrays;
@Component
public class SampleIntegrationJob implements Job {
    @Autowired
    private IDataSetService dataSetService;
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        // 从 JobDataMap 获取传递的参数
        JobDataMap dataMap = context.getMergedJobDataMap();
        Dataset dst = (Dataset)dataMap.get("datasetInfo");
        System.out.println("Parsing Job Started====================");

        // TODO 修改以兼容样本集细分为train/val/test的数据集
        /**
         * 数据集解析形式，暂时支持两种形式：
         * 1、样本所在目录名为标签类型的树形结构形式
         * 2、包含单独存储的的标签文件，存储样本名到标签的映射
         **/
        // 获取样本集的标签存储类型
        String labelPath = dst.getLabelPath();
        if(labelPath == null){
            for(String folder: dst.getImgFolders()){
                String datasetImgFolder = Paths.get(dst.getDatasetUrl(),folder).toString();
                try {
                    dataSetService.parseDataset(datasetImgFolder,dst);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        }
        System.out.println("Parsing Job Finished====================");

        // 记录数据集信息，写入数据集表
        if(dst.getProcessedNum()>0){
            dataSetService.increasProcessed(dst.getId(),dst.getProcessedNum());
            dst.setProcessedNum(null);
        }
        dataSetService.saveOrUpdate(dst);
    }
}
