## 基于知识图谱和特征索引的深度学习样本平台 
### 技术栈
Redis,SpringCloud,RabbitMQ,Docker,Neo4j

### 项目介绍：
样本库整合了多个开源数据集，构建了统一标签分类体系，并支持基于样本内容相似性的搜索。
* 标签体系融合：通过地理知识图谱中标签的描述信息和标签文本实现标签间的相似性度量，基于相似性合并多个数据
* 集的标签集并构建标签分类体系，利用Neo4j实现多数据集标签分类体系的存储
* 特征提取和管理：采用基于可扩展邻域判别损失训练的多标签遥感场景分类模型提取样本图像特征，并基于乘积量化
* 算法实现特征的快速近似最近邻索引构建，以支持快速的特征匹配
* 样本元数据管理：利用PostgreSQL数据库实现样本表、标签类别表等元数据的管理，模块间采用消息队列解耦。

### 系统概览：
#### 数据集总览界面
![overview.png](static%2Fimg%2Foverview.png)
#### 准确样本检索&补充样本检索界面
![search_page.png](static%2Fimg%2Fsearch_page.png)
#### 样本库标签分类图谱概览
![classify.png](static%2Fimg%2Fclassify.png)