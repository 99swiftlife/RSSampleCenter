package org.jeecg.modules.sample.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.sample.entity.Dataset;
import org.jeecg.modules.sample.entity.SampleDTO;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public interface IDataSetService extends IService<Dataset> {
    List<Dataset> findByName(String datasetName);
    void parseDataset(String path, Dataset dst) throws IOException;
    public Boolean increasProcessed(Long id,Integer num);
    public void sendBatchToSampleResolver(List<SampleDTO> dtos,Map<Integer,Map<String,Integer>> bandInfoMap);
}
