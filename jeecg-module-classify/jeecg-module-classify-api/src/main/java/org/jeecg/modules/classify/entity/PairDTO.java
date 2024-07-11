package org.jeecg.modules.classify.entity;

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
public class PairDTO<T, U> {
    private T left;
    private U right;
}
