package org.jeecg.modules.sample.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.sample.entity.Dataset;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public interface IDataSetService extends IService<Dataset> {
    List<Dataset> findByName(String datasetName);
    void parseDataset(String path, String datasetName, String imgExt, Map<Integer, Map<String,Integer>>bands, Dataset dst, Integer maxLevel) throws IOException;
}
