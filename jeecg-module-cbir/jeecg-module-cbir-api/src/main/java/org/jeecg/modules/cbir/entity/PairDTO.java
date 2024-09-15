package org.jeecg.modules.cbir.entity;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @program: RSSampleCenter
 * @description: 封装两个返回值的对类型数据传输对象
 * @author: swiftlife
 * @create: 2024-04-08 03:23
 **/
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PairDTO<T, U>{
    private T left;
    private U right;
    public String toJson() throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(this);
        return json;
    }
}
