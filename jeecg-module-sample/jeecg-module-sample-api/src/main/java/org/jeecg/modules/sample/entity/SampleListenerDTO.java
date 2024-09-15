package org.jeecg.modules.sample.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * @program: RSSampleCenter
 * @description: sampleListener监听器返回的数据传输对象
 * @author: swiftlife
 * @create: 2024-07-30 23:57
 **/
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SampleListenerDTO {
    @JsonProperty("label_ins_num")
    private Map<Long, Integer>labelInsNum;
    private Map<String, SampleMetaDTO> meta;
}
