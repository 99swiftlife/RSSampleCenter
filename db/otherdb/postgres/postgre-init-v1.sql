CREATE EXTENSION IF NOT EXISTS postgis;
-- ---------------------------
-- Table structure for sc_sample
-- ----------------------------
create table if not exists category
(
    id        bigint default 0 not null
        constraint category_pk
            primary key
        constraint category_pk2
            unique,
    name      varchar          not null,
    num       bigint default 0,
    task_type varchar          not null
);

comment on table category is '标签类别表';

comment on column category.id is '类别唯一标识符';

comment on column category.name is '类别名称';

comment on column category.num is '类别实例数';

comment on column category.task_type is '适用的任务类别';

alter table category
    owner to postgres;

create table if not exists sc_sample
(
    id          bigint default 0 not null
        constraint sc_sample_pk2
            primary key,
    dataset_id  bigint,
    resolution  real,
    sample_size bigint           not null,
    img_type    varchar,
    img_path    varchar          not null,
    label_path  varchar,
    bbox        geometry(POLYGON,4326),
    time        varchar,
    sensor      varchar
);

comment on table sc_sample is 'sence classification sample';

comment on column sc_sample.id is '样本唯一编码';

comment on column sc_sample.dataset_id is '样本来自的数据集编码';

comment on column sc_sample.resolution is '分辨率';

comment on column sc_sample.sample_size is '样本尺寸';

comment on column sc_sample.img_type is '样本图像类型';

comment on column sc_sample.img_path is '影像路径';

comment on column sc_sample.label_path is '样本标签路径';

comment on column sc_sample.bbox is '样本图像对应的空间矩形边界框WKT编码';

comment on column sc_sample.time is '样本采集时间';

comment on column sc_sample.sensor is '传感器信息';

alter table sc_sample
    owner to postgres;

create table if not exists sample_dataset
(
    id     bigint default 0 not null
        constraint sample_dataset_pk
            primary key,
    name   varchar          not null,
    sensor varchar,
    num    bigint
);

comment on table sample_dataset is '样本数据集';

comment on column sample_dataset.id is '数据集唯一编码';

comment on column sample_dataset.name is '数据集名';

comment on column sample_dataset.sensor is '数据集传感器信息';

comment on column sample_dataset.num is '样本数量';

alter table sample_dataset
    owner to postgres;

create table if not exists classify
(
    category_id bigint not null,
    sample_id   bigint not null
);

comment on table classify is '样本和类别间的多对多关系';

comment on column classify.category_id is '类别唯一标识';

comment on column classify.sample_id is '样本实例唯一标识';

alter table classify
    owner to postgres;

create table  if not exists k_v_descr
(
    key   varchar not null primary key unique key,
    value varchar not null
);

comment on table public.k_v_descr is 'OSM键值对到对应描述信息的哈希表';

comment on column public.k_v_descr.value is '描述信息';

alter table k_v_descr
    owner to postgres;

create table if not exists category_k_v
(
    key   varchar not null primary key unique key,
    value varchar not null
);

comment on table public.category_key_value is '类别到OSM键值对的哈希表';

comment on column public.category_key_value.key is '类别名';

comment on column public.category_key_value.value is 'OSM键值对';

alter table category_k_v
    owner to postgres;








-- ----------------------------
-- Records of ceshi_note
-- ----------------------------
INSERT INTO sc_sample  ( id,
                                           sensor,
                                           bbox,
                                           time,
                                           dataset_id,
                                           resolution,
                                           sample_size,
                                           img_type,
                                           img_path,
                                           label_path )  VALUES  ( 1,
    'GF',
    ST_GeomFromText('SRID=4326;Polygon((117.357442 30.231278,119.235188 30.231278,119.235188 32.614617,117.357442 32.614617,117.357442 30.231278))'),
    'XXX',
    1,
    0.5,
    256,
    'xx',
    'xx',
    'xx' );