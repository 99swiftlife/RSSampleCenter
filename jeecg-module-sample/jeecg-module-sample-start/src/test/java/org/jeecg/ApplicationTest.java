package org.jeecg;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;

/**
 * @program: RSSampleCenter
 * @description: 测试类基类
 * @author: swiftlife
 * @create: 2023-12-06 22:41
 **/
@SpringBootTest(classes = JeecgSampleCloudApplication.class)
@RunWith(SpringRunner.class)
@WebAppConfiguration
public class ApplicationTest {
    @Test
    public void contextLoads() {
    }
    @Before
    public void init() {
        System.out.println("开始测试-----------------");
    }

    @After
    public void after() {
        System.out.println("测试结束-----------------");
    }
}
