package org.jeecg.modules.sample.entity;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.baomidou.mybatisplus.annotation.IEnum;
import lombok.AllArgsConstructor;

/**
 * @program: RSSampleCenter
 * @description: 样本解析状态公共字符串类
 * @author: swiftlife
 * @create: 2024-07-09 23:30
 **/
@AllArgsConstructor
public enum SampleStatue implements IEnum<String> {
    // 定义枚举实例，每个实例具有一个String类型的成员变量
    INIT("INIT"),
    RESOLVED("RESOLVED"),
    SUCCESS("SUCCESS"),
    FAIL("FAIL");

    // String类型的成员变量
    @EnumValue
    private final String status;

    @Override
    public String getValue() {
        return this.status;
    }
}
