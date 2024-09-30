-- we don't know how to generate root <with-no-name> (class Root) :(
create sequence public.sc_sample_id_seq;

comment on sequence public.sc_sample_id_seq is '场景分类样本表id自增序列';

alter sequence public.sc_sample_id_seq owner to postgres;

create sequence public.sample_dataset_id_seq;

comment on sequence public.sample_dataset_id_seq is '样本数据集表id自增序列';

alter sequence public.sample_dataset_id_seq owner to postgres;

-- Unknown how to generate base type type

alter type public.spheroid owner to postgres;

-- Unknown how to generate base type type

comment on type public.geometry is 'postgis type: The type representing spatial features with planar coordinate systems.';

alter type public.geometry owner to postgres;

-- Unknown how to generate base type type

comment on type public.box3d is 'postgis type: The type representing a 3-dimensional bounding box.';

alter type public.box3d owner to postgres;

-- Unknown how to generate base type type

comment on type public.box2d is 'postgis type: The type representing a 2-dimensional bounding box.';

alter type public.box2d owner to postgres;

-- Unknown how to generate base type type

alter type public.box2df owner to postgres;

-- Unknown how to generate base type type

alter type public.gidx owner to postgres;

create type public.geometry_dump as
    (
    path integer[],
    geom geometry
    );

comment on type public.geometry_dump is 'postgis type: A composite type used to describe the parts of complex geometry.';

alter type public.geometry_dump owner to postgres;

create type public.valid_detail as
    (
    valid    boolean,
    reason   varchar,
    location geometry
    );

alter type public.valid_detail owner to postgres;

-- Unknown how to generate base type type

comment on type public.geography is 'postgis type: The type representing spatial features with geodetic (ellipsoidal) coordinate systems.';

alter type public.geography owner to postgres;

create table public.spatial_ref_sys
(
    srid      integer not null
        primary key
        constraint spatial_ref_sys_srid_check
            check ((srid > 0) AND (srid <= 998999)),
    auth_name varchar(256),
    auth_srid integer,
    srtext    varchar(2048),
    proj4text varchar(2048)
);

alter table public.spatial_ref_sys
    owner to postgres;

grant select on public.spatial_ref_sys to public;

create table public.category
(
    id           bigint default 0 not null
        constraint category_pk
            primary key,
    name         varchar          not null,
    num          bigint default 0,
    task_type    varchar,
    descr        varchar,
    osm_url      varchar,
    text_feature bytea,
    img_feature  bytea[]
);

comment on table public.category is '标签类别表';

comment on column public.category.id is '类别唯一标识符';

comment on column public.category.name is '类别名称';

comment on column public.category.num is '类别实例数';

comment on column public.category.task_type is '适用的任务类别';

alter table public.category
    owner to postgres;

create table public.sc_sample
(
    id          bigint default nextval('sc_sample_id_seq'::regclass) not null
        constraint sc_sample_pk2
            primary key,
    dataset_id  bigint,
    resolution  real,
    sample_size bigint,
    img_type    varchar,
    img_path    varchar                                              not null,
    label_path  varchar,
    bbox        geometry(Polygon, 4326),
    time        varchar,
    sensor      varchar,
    label_id    bigint
);

comment on table public.sc_sample is 'sence classification sample';

comment on column public.sc_sample.id is '样本唯一编码';

comment on column public.sc_sample.dataset_id is '样本来自的数据集编码';

comment on column public.sc_sample.resolution is '分辨率';

comment on column public.sc_sample.sample_size is '样本尺寸';

comment on column public.sc_sample.img_type is '样本图像类型';

comment on column public.sc_sample.img_path is '影像路径';

comment on column public.sc_sample.label_path is '样本标签路径';

comment on column public.sc_sample.bbox is '样本图像对应的空间矩形边界框WKT编码';

comment on column public.sc_sample.time is '样本采集时间';

comment on column public.sc_sample.sensor is '传感器信息';

comment on column public.sc_sample.label_id is '样本对应的类别唯一编码';

alter table public.sc_sample
    owner to postgres;

create table public.sample_dataset
(
    id            bigint default nextval('sample_dataset_id_seq'::regclass) not null
        constraint sample_dataset_pk
            primary key,
    dataset_name  varchar                                                   not null,
    sensor        varchar,
    ins_num       bigint,
    cat_num       bigint,
    task_type     varchar,
    processed_num bigint
);

comment on table public.sample_dataset is '样本数据集';

comment on column public.sample_dataset.id is '数据集唯一编码';

comment on column public.sample_dataset.dataset_name is '数据集名';

comment on column public.sample_dataset.sensor is '数据集传感器信息';

comment on column public.sample_dataset.ins_num is '样本数量';

comment on column public.sample_dataset.cat_num is '类别数量';

comment on column public.sample_dataset.task_type is '数据集适用的遥感任务类型';

comment on column public.sample_dataset.processed_num is '已解析的样本数';

alter table public.sample_dataset
    owner to postgres;

create table public.k_v_descr
(
    key   varchar not null
        primary key,
    value varchar not null
);

comment on table public.k_v_descr is 'OSM键值对到对应描述信息的哈希表';

comment on column public.k_v_descr.value is '描述信息';

alter table public.k_v_descr
    owner to postgres;

create table public.category_k_v
(
    key   varchar not null
        primary key,
    value varchar not null
);

comment on table public.category_k_v is '类别到OSM键值对的哈希表';

comment on column public.category_k_v.key is '类别名';

comment on column public.category_k_v.value is 'OSM键值对';

alter table public.category_k_v
    owner to postgres;

create table public.index_sample_id
(
    index     bigint not null,
    sample_id bigint not null
);

comment on table public.index_sample_id is '插入索引的序号到样本编码的哈希表';

comment on column public.index_sample_id.index is '插入索引的序号';

comment on column public.index_sample_id.sample_id is '样本唯一编码';

alter table public.index_sample_id
    owner to postgres;

create table public.index_img_feature
(
    index       bigint not null,
    img_feature bytea  not null
);

comment on table public.index_img_feature is '插入索引的序号到图像特征的哈希表';

comment on column public.index_img_feature.index is '插入索引的序号';

comment on column public.index_img_feature.img_feature is '字节形式的图像特征编码';

alter table public.index_img_feature
    owner to postgres;

create table public.index_txt_feature
(
    index       bigint,
    txt_feature bytea
);

comment on table public.index_txt_feature is '特征索引到文本特征的哈希表';

comment on column public.index_txt_feature.index is '插入索引的序号';

comment on column public.index_txt_feature.txt_feature is '字节形式的文本特征';

alter table public.index_txt_feature
    owner to postgres;

create table public.index_label
(
    index bigint,
    label varchar
);

comment on table public.index_label is '文本特征序号到标签类别名的哈希表';

comment on column public.index_label.index is '插入索引的序号';

comment on column public.index_label.label is '标签类别名';

alter table public.index_label
    owner to postgres;

create view public.geography_columns
            (f_table_catalog, f_table_schema, f_table_name, f_geography_column, coord_dimension, srid, type) as
SELECT current_database()               AS f_table_catalog,
       n.nspname                        AS f_table_schema,
       c.relname                        AS f_table_name,
       a.attname                        AS f_geography_column,
       postgis_typmod_dims(a.atttypmod) AS coord_dimension,
       postgis_typmod_srid(a.atttypmod) AS srid,
       postgis_typmod_type(a.atttypmod) AS type
FROM pg_class c,
     pg_attribute a,
     pg_type t,
     pg_namespace n
WHERE t.typname = 'geography'::name
  AND a.attisdropped = false
  AND a.atttypid = t.oid
  AND a.attrelid = c.oid
  AND c.relnamespace = n.oid
  AND (c.relkind = ANY (ARRAY ['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"]))
  AND NOT pg_is_other_temp_schema(c.relnamespace)
  AND has_table_privilege(c.oid, 'SELECT'::text);

alter table public.geography_columns
    owner to postgres;

grant select on public.geography_columns to public;

create view public.geometry_columns
            (f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type) as
SELECT current_database()::character varying(256)                                                                     AS f_table_catalog,
       n.nspname                                                                                                      AS f_table_schema,
       c.relname                                                                                                      AS f_table_name,
       a.attname                                                                                                      AS f_geometry_column,
       COALESCE(postgis_typmod_dims(a.atttypmod), sn.ndims, 2)                                                        AS coord_dimension,
       COALESCE(NULLIF(postgis_typmod_srid(a.atttypmod), 0), sr.srid,
                0)                                                                                                    AS srid,
       replace(replace(COALESCE(NULLIF(upper(postgis_typmod_type(a.atttypmod)), 'GEOMETRY'::text), st.type,
                                'GEOMETRY'::text), 'ZM'::text, ''::text), 'Z'::text,
               ''::text)::character varying(30)                                                                       AS type
FROM pg_class c
         JOIN pg_attribute a ON a.attrelid = c.oid AND NOT a.attisdropped
         JOIN pg_namespace n ON c.relnamespace = n.oid
         JOIN pg_type t ON a.atttypid = t.oid
         LEFT JOIN (SELECT s.connamespace,
                           s.conrelid,
                           s.conkey,
                           replace(split_part(s.consrc, ''''::text, 2), ')'::text, ''::text) AS type
                    FROM (SELECT pg_constraint.connamespace,
                                 pg_constraint.conrelid,
                                 pg_constraint.conkey,
                                 pg_get_constraintdef(pg_constraint.oid) AS consrc
                          FROM pg_constraint) s
                    WHERE s.consrc ~~* '%geometrytype(% = %'::text) st
                   ON st.connamespace = n.oid AND st.conrelid = c.oid AND (a.attnum = ANY (st.conkey))
         LEFT JOIN (SELECT s.connamespace,
                           s.conrelid,
                           s.conkey,
                           replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text)::integer AS ndims
                    FROM (SELECT pg_constraint.connamespace,
                                 pg_constraint.conrelid,
                                 pg_constraint.conkey,
                                 pg_get_constraintdef(pg_constraint.oid) AS consrc
                          FROM pg_constraint) s
                    WHERE s.consrc ~~* '%ndims(% = %'::text) sn
                   ON sn.connamespace = n.oid AND sn.conrelid = c.oid AND (a.attnum = ANY (sn.conkey))
         LEFT JOIN (SELECT s.connamespace,
                           s.conrelid,
                           s.conkey,
                           replace(replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text), '('::text,
                                   ''::text)::integer AS srid
                    FROM (SELECT pg_constraint.connamespace,
                                 pg_constraint.conrelid,
                                 pg_constraint.conkey,
                                 pg_get_constraintdef(pg_constraint.oid) AS consrc
                          FROM pg_constraint) s
                    WHERE s.consrc ~~* '%srid(% = %'::text) sr
                   ON sr.connamespace = n.oid AND sr.conrelid = c.oid AND (a.attnum = ANY (sr.conkey))
WHERE (c.relkind = ANY (ARRAY ['r'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"]))
  AND NOT c.relname = 'raster_columns'::name
  AND t.typname = 'geometry'::name
  AND NOT pg_is_other_temp_schema(c.relnamespace)
  AND has_table_privilege(c.oid, 'SELECT'::text);

alter table public.geometry_columns
    owner to postgres;

CREATE RULE geometry_columns_insert AS
    ON INSERT TO geometry_columns DO INSTEAD NOTHING;

CREATE RULE geometry_columns_update AS
    ON UPDATE TO geometry_columns DO INSTEAD NOTHING;

CREATE RULE geometry_columns_delete AS
    ON DELETE TO geometry_columns DO INSTEAD NOTHING;

grant select on public.geometry_columns to public;

create function public._postgis_deprecate(oldname text, newname text, version text) returns void
    immutable
    strict
    cost 250
    language plpgsql
as
$$
DECLARE
curver_text text;
BEGIN
  --
  -- Raises a NOTICE if it was deprecated in this version,
  -- a WARNING if in a previous version (only up to minor version checked)
  --
	curver_text := '3.4.2';
	IF pg_catalog.split_part(curver_text,'.',1)::int > pg_catalog.split_part(version,'.',1)::int OR
	   ( pg_catalog.split_part(curver_text,'.',1) = pg_catalog.split_part(version,'.',1) AND
		 pg_catalog.split_part(curver_text,'.',2) != split_part(version,'.',2) )
	THEN
	  RAISE WARNING '% signature was deprecated in %. Please use %', oldname, version, newname;
ELSE
	  RAISE DEBUG '% signature was deprecated in %. Please use %', oldname, version, newname;
END IF;
END;
$$;

alter function public._postgis_deprecate(text, text, text) owner to postgres;

create function public.spheroid_in(cstring) returns spheroid
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.spheroid_in(cstring) owner to postgres;

create function public.spheroid_out(spheroid) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.spheroid_out(spheroid) owner to postgres;

create function public.geometry_in(cstring) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_in(cstring) owner to postgres;

create function public.geometry_out(geometry) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_out(geometry) owner to postgres;

create function public.geometry_typmod_in(cstring[]) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_typmod_in(cstring[]) owner to postgres;

create function public.geometry_typmod_out(integer) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_typmod_out(integer) owner to postgres;

create function public.geometry_analyze(internal) returns boolean
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_analyze(internal) owner to postgres;

create function public.geometry_recv(internal) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_recv(internal) owner to postgres;

create function public.geometry_send(geometry) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_send(geometry) owner to postgres;

create function public.geometry(geometry, integer, boolean) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(geometry, integer, boolean) owner to postgres;

create function public.geometry(point) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(point) owner to postgres;

create function public.point(geometry) returns point
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.point(geometry) owner to postgres;

create function public.geometry(path) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(path) owner to postgres;

create function public.path(geometry) returns path
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.path(geometry) owner to postgres;

create function public.geometry(polygon) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(polygon) owner to postgres;

create function public.polygon(geometry) returns polygon
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.polygon(geometry) owner to postgres;

create function public.st_x(geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_x(geometry) is 'args: a_point - Returns the X coordinate of a Point.';

alter function public.st_x(geometry) owner to postgres;

create function public.st_y(geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_y(geometry) is 'args: a_point - Returns the Y coordinate of a Point.';

alter function public.st_y(geometry) owner to postgres;

create function public.st_z(geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_z(geometry) is 'args: a_point - Returns the Z coordinate of a Point.';

alter function public.st_z(geometry) owner to postgres;

create function public.st_m(geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_m(geometry) is 'args: a_point - Returns the M coordinate of a Point.';

alter function public.st_m(geometry) owner to postgres;

create function public.box3d_in(cstring) returns box3d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box3d_in(cstring) owner to postgres;

create function public.box3d_out(box3d) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box3d_out(box3d) owner to postgres;

create function public.box2d_in(cstring) returns box2d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box2d_in(cstring) owner to postgres;

create function public.box2d_out(box2d) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box2d_out(box2d) owner to postgres;

create function public.box2df_in(cstring) returns box2df
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box2df_in(cstring) owner to postgres;

create function public.box2df_out(box2df) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box2df_out(box2df) owner to postgres;

create function public.gidx_in(cstring) returns gidx
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gidx_in(cstring) owner to postgres;

create function public.gidx_out(gidx) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gidx_out(gidx) owner to postgres;

create function public.geometry_lt(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_lt(geometry, geometry) owner to postgres;

create function public.geometry_le(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_le(geometry, geometry) owner to postgres;

create function public.geometry_gt(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gt(geometry, geometry) owner to postgres;

create function public.geometry_ge(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_ge(geometry, geometry) owner to postgres;

create function public.geometry_eq(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_eq(geometry, geometry) owner to postgres;

create function public.geometry_cmp(geom1 geometry, geom2 geometry) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_cmp(geometry, geometry) owner to postgres;

create function public.geometry_sortsupport(internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_sortsupport(internal) owner to postgres;

create function public.geometry_hash(geometry) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_hash(geometry) owner to postgres;

create function public.geometry_gist_distance_2d(internal, geometry, integer) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_distance_2d(internal, geometry, integer) owner to postgres;

create function public.geometry_gist_consistent_2d(internal, geometry, integer) returns boolean
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_consistent_2d(internal, geometry, integer) owner to postgres;

create function public.geometry_gist_compress_2d(internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_compress_2d(internal) owner to postgres;

create function public.geometry_gist_penalty_2d(internal, internal, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_penalty_2d(internal, internal, internal) owner to postgres;

create function public.geometry_gist_picksplit_2d(internal, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_picksplit_2d(internal, internal) owner to postgres;

create function public.geometry_gist_union_2d(bytea, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_union_2d(bytea, internal) owner to postgres;

create function public.geometry_gist_same_2d(geom1 geometry, geom2 geometry, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_same_2d(geometry, geometry, internal) owner to postgres;

create function public.geometry_gist_decompress_2d(internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_decompress_2d(internal) owner to postgres;

create function public.geometry_gist_sortsupport_2d(internal) returns void
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_sortsupport_2d(internal) owner to postgres;

create function public._postgis_selectivity(tbl regclass, att_name text, geom geometry, mode text default '2'::text) returns double precision
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._postgis_selectivity(regclass, text, geometry, text) owner to postgres;

create function public._postgis_join_selectivity(regclass, text, regclass, text, text default '2'::text) returns double precision
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._postgis_join_selectivity(regclass, text, regclass, text, text) owner to postgres;

create function public._postgis_stats(tbl regclass, att_name text, text default '2'::text) returns text
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._postgis_stats(regclass, text, text) owner to postgres;

create function public._postgis_index_extent(tbl regclass, col text) returns box2d
    stable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._postgis_index_extent(regclass, text) owner to postgres;

create function public.gserialized_gist_sel_2d(internal, oid, internal, integer) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gserialized_gist_sel_2d(internal, oid, internal, integer) owner to postgres;

create function public.gserialized_gist_sel_nd(internal, oid, internal, integer) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gserialized_gist_sel_nd(internal, oid, internal, integer) owner to postgres;

create function public.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) owner to postgres;

create function public.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) owner to postgres;

create function public.geometry_overlaps(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overlaps(geometry, geometry) owner to postgres;

create function public.geometry_same(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_same(geometry, geometry) owner to postgres;

create function public.geometry_distance_centroid(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_distance_centroid(geometry, geometry) owner to postgres;

create function public.geometry_distance_box(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_distance_box(geometry, geometry) owner to postgres;

create function public.geometry_contains(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_contains(geometry, geometry) owner to postgres;

create function public.geometry_within(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_within(geometry, geometry) owner to postgres;

create function public.geometry_left(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_left(geometry, geometry) owner to postgres;

create function public.geometry_overleft(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overleft(geometry, geometry) owner to postgres;

create function public.geometry_below(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_below(geometry, geometry) owner to postgres;

create function public.geometry_overbelow(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overbelow(geometry, geometry) owner to postgres;

create function public.geometry_overright(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overright(geometry, geometry) owner to postgres;

create function public.geometry_right(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_right(geometry, geometry) owner to postgres;

create function public.geometry_overabove(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overabove(geometry, geometry) owner to postgres;

create function public.geometry_above(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_above(geometry, geometry) owner to postgres;

create function public.geometry_gist_consistent_nd(internal, geometry, integer) returns boolean
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_consistent_nd(internal, geometry, integer) owner to postgres;

create function public.geometry_gist_compress_nd(internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_compress_nd(internal) owner to postgres;

create function public.geometry_gist_penalty_nd(internal, internal, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_penalty_nd(internal, internal, internal) owner to postgres;

create function public.geometry_gist_picksplit_nd(internal, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_picksplit_nd(internal, internal) owner to postgres;

create function public.geometry_gist_union_nd(bytea, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_union_nd(bytea, internal) owner to postgres;

create function public.geometry_gist_same_nd(geometry, geometry, internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_same_nd(geometry, geometry, internal) owner to postgres;

create function public.geometry_gist_decompress_nd(internal) returns internal
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_decompress_nd(internal) owner to postgres;

create function public.geometry_overlaps_nd(geometry, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overlaps_nd(geometry, geometry) owner to postgres;

create function public.geometry_contains_nd(geometry, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_contains_nd(geometry, geometry) owner to postgres;

create function public.geometry_within_nd(geometry, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_within_nd(geometry, geometry) owner to postgres;

create function public.geometry_same_nd(geometry, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_same_nd(geometry, geometry) owner to postgres;

create function public.geometry_distance_centroid_nd(geometry, geometry) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_distance_centroid_nd(geometry, geometry) owner to postgres;

create function public.geometry_distance_cpa(geometry, geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_distance_cpa(geometry, geometry) owner to postgres;

create function public.geometry_gist_distance_nd(internal, geometry, integer) returns double precision
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_gist_distance_nd(internal, geometry, integer) owner to postgres;

create function public.st_shiftlongitude(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_shiftlongitude(geometry) is 'args: geom - Shifts the longitude coordinates of a geometry between -180..180 and 0..360.';

alter function public.st_shiftlongitude(geometry) owner to postgres;

create function public.st_wrapx(geom geometry, wrap double precision, move double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_wrapx(geometry, double precision, double precision) is 'args: geom, wrap, move - Wrap a geometry around an X value.';

alter function public.st_wrapx(geometry, double precision, double precision) owner to postgres;

create function public.st_xmin(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_xmin(box3d) is 'args: aGeomorBox2DorBox3D - Returns the X minima of a 2D or 3D bounding box or a geometry.';

alter function public.st_xmin(box3d) owner to postgres;

create function public.st_ymin(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_ymin(box3d) is 'args: aGeomorBox2DorBox3D - Returns the Y minima of a 2D or 3D bounding box or a geometry.';

alter function public.st_ymin(box3d) owner to postgres;

create function public.st_zmin(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_zmin(box3d) is 'args: aGeomorBox2DorBox3D - Returns the Z minima of a 2D or 3D bounding box or a geometry.';

alter function public.st_zmin(box3d) owner to postgres;

create function public.st_xmax(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_xmax(box3d) is 'args: aGeomorBox2DorBox3D - Returns the X maxima of a 2D or 3D bounding box or a geometry.';

alter function public.st_xmax(box3d) owner to postgres;

create function public.st_ymax(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_ymax(box3d) is 'args: aGeomorBox2DorBox3D - Returns the Y maxima of a 2D or 3D bounding box or a geometry.';

alter function public.st_ymax(box3d) owner to postgres;

create function public.st_zmax(box3d) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_zmax(box3d) is 'args: aGeomorBox2DorBox3D - Returns the Z maxima of a 2D or 3D bounding box or a geometry.';

alter function public.st_zmax(box3d) owner to postgres;

create function public.st_expand(box2d, double precision) returns box2d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(box2d, double precision) is 'args: box, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(box2d, double precision) owner to postgres;

create function public.st_expand(box box2d, dx double precision, dy double precision) returns box2d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(box2d, double precision, double precision) is 'args: box, dx, dy - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(box2d, double precision, double precision) owner to postgres;

create function public.postgis_getbbox(geometry) returns box2d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_getbbox(geometry) owner to postgres;

create function public.st_makebox2d(geom1 geometry, geom2 geometry) returns box2d
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makebox2d(geometry, geometry) is 'args: pointLowLeft, pointUpRight - Creates a BOX2D defined by two 2D point geometries.';

alter function public.st_makebox2d(geometry, geometry) owner to postgres;

create function public.st_estimatedextent(text, text, text, boolean) returns box2d
    stable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_estimatedextent(text, text, text, boolean) is 'args: schema_name, table_name, geocolumn_name, parent_only - Returns the estimated extent of a spatial table.';

alter function public.st_estimatedextent(text, text, text, boolean) owner to postgres;

create function public.st_estimatedextent(text, text, text) returns box2d
    stable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_estimatedextent(text, text, text) is 'args: schema_name, table_name, geocolumn_name - Returns the estimated extent of a spatial table.';

alter function public.st_estimatedextent(text, text, text) owner to postgres;

create function public.st_estimatedextent(text, text) returns box2d
    stable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_estimatedextent(text, text) is 'args: table_name, geocolumn_name - Returns the estimated extent of a spatial table.';

alter function public.st_estimatedextent(text, text) owner to postgres;

create function public.st_findextent(text, text, text) returns box2d
    stable
    strict
    parallel safe
    language plpgsql
as
$$
DECLARE
schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;
BEGIN
FOR myrec IN EXECUTE 'SELECT public.ST_Extent("' || columnname || '") As extent FROM "' || schemaname || '"."' || tablename || '"' LOOP
		return myrec.extent;
END LOOP;
END;
$$;

alter function public.st_findextent(text, text, text) owner to postgres;

create function public.st_findextent(text, text) returns box2d
    stable
    strict
    parallel safe
    language plpgsql
as
$$
DECLARE
tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;

BEGIN
FOR myrec IN EXECUTE 'SELECT public.ST_Extent("' || columnname || '") As extent FROM "' || tablename || '"' LOOP
		return myrec.extent;
END LOOP;
END;
$$;

alter function public.st_findextent(text, text) owner to postgres;

create function public.postgis_addbbox(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_addbbox(geometry) is 'args: geomA - Add bounding box to the geometry.';

alter function public.postgis_addbbox(geometry) owner to postgres;

create function public.postgis_dropbbox(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_dropbbox(geometry) is 'args: geomA - Drop the bounding box cache from the geometry.';

alter function public.postgis_dropbbox(geometry) owner to postgres;

create function public.postgis_hasbbox(geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_hasbbox(geometry) is 'args: geomA - Returns TRUE if the bbox of this geometry is cached, FALSE otherwise.';

alter function public.postgis_hasbbox(geometry) owner to postgres;

create function public.st_quantizecoordinates(g geometry, prec_x integer, prec_y integer default NULL::integer, prec_z integer default NULL::integer, prec_m integer default NULL::integer) returns geometry
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_quantizecoordinates(geometry, integer, integer, integer, integer) is 'args: g, prec_x, prec_y, prec_z, prec_m - Sets least significant bits of coordinates to zero';

alter function public.st_quantizecoordinates(geometry, integer, integer, integer, integer) owner to postgres;

create function public.st_memsize(geometry) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_memsize(geometry) is 'args: geomA - Returns the amount of memory space a geometry takes.';

alter function public.st_memsize(geometry) owner to postgres;

create function public.st_summary(geometry) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_summary(geometry) is 'args: g - Returns a text summary of the contents of a geometry.';

alter function public.st_summary(geometry) owner to postgres;

create function public.st_npoints(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_npoints(geometry) is 'args: g1 - Returns the number of points (vertices) in a geometry.';

alter function public.st_npoints(geometry) owner to postgres;

create function public.st_nrings(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_nrings(geometry) is 'args: geomA - Returns the number of rings in a polygonal geometry.';

alter function public.st_nrings(geometry) owner to postgres;

create function public.st_3dlength(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dlength(geometry) is 'args: a_3dlinestring - Returns the 3D length of a linear geometry.';

alter function public.st_3dlength(geometry) owner to postgres;

create function public.st_length2d(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_length2d(geometry) is 'args: a_2dlinestring - Returns the 2D length of a linear geometry. Alias for ST_Length';

alter function public.st_length2d(geometry) owner to postgres;

create function public.st_length(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_length(geometry) is 'args: a_2dlinestring - Returns the 2D length of a linear geometry.';

alter function public.st_length(geometry) owner to postgres;

create function public.st_lengthspheroid(geometry, spheroid) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lengthspheroid(geometry, spheroid) is 'args: a_geometry, a_spheroid - Returns the 2D or 3D length/perimeter of a lon/lat geometry on a spheroid.';

alter function public.st_lengthspheroid(geometry, spheroid) owner to postgres;

create function public.st_length2dspheroid(geometry, spheroid) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_length2dspheroid(geometry, spheroid) owner to postgres;

create function public.st_3dperimeter(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dperimeter(geometry) is 'args: geomA - Returns the 3D perimeter of a polygonal geometry.';

alter function public.st_3dperimeter(geometry) owner to postgres;

create function public.st_perimeter2d(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_perimeter2d(geometry) is 'args: geomA - Returns the 2D perimeter of a polygonal geometry. Alias for ST_Perimeter.';

alter function public.st_perimeter2d(geometry) owner to postgres;

create function public.st_perimeter(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_perimeter(geometry) is 'args: g1 - Returns the length of the boundary of a polygonal geometry or geography.';

alter function public.st_perimeter(geometry) owner to postgres;

create function public.st_area2d(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_area2d(geometry) owner to postgres;

create function public.st_area(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_area(geometry) is 'args: g1 - Returns the area of a polygonal geometry.';

alter function public.st_area(geometry) owner to postgres;

create function public.st_ispolygoncw(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_ispolygoncw(geometry) is 'args: geom - Tests if Polygons have exterior rings oriented clockwise and interior rings oriented counter-clockwise.';

alter function public.st_ispolygoncw(geometry) owner to postgres;

create function public.st_ispolygonccw(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_ispolygonccw(geometry) is 'args: geom - Tests if Polygons have exterior rings oriented counter-clockwise and interior rings oriented clockwise.';

alter function public.st_ispolygonccw(geometry) owner to postgres;

create function public.st_distancespheroid(geom1 geometry, geom2 geometry, spheroid) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_distancespheroid(geometry, geometry, spheroid) is 'args: geomlonlatA, geomlonlatB, measurement_spheroid=WGS84 - Returns the minimum distance between two lon/lat geometries using a spheroidal earth model.';

alter function public.st_distancespheroid(geometry, geometry, spheroid) owner to postgres;

create function public.st_distancespheroid(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_distancespheroid(geometry, geometry) owner to postgres;

create function public.st_distance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_distance(geometry, geometry) is 'args: g1, g2 - Returns the distance between two geometry or geography values.';

alter function public.st_distance(geometry, geometry) owner to postgres;

create function public.st_pointinsidecircle(geometry, double precision, double precision, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_pointinsidecircle(geometry, double precision, double precision, double precision) owner to postgres;

create function public.st_azimuth(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_azimuth(geometry, geometry) is 'args: origin, target - Returns the north-based azimuth of a line between two points.';

alter function public.st_azimuth(geometry, geometry) owner to postgres;

create function public.st_project(geom1 geometry, distance double precision, azimuth double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_project(geometry, double precision, double precision) is 'args: g1, distance, azimuth - Returns a point projected from a start point by a distance and bearing (azimuth).';

alter function public.st_project(geometry, double precision, double precision) owner to postgres;

create function public.st_project(geom1 geometry, geom2 geometry, distance double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_project(geometry, geometry, double precision) is 'args: g1, g2, distance - Returns a point projected from a start point by a distance and bearing (azimuth).';

alter function public.st_project(geometry, geometry, double precision) owner to postgres;

create function public.st_angle(pt1 geometry, pt2 geometry, pt3 geometry, pt4 geometry default '0101000000000000000000F87F000000000000F87F'::geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_angle(geometry, geometry, geometry, geometry) is 'args: point1, point2, point3, point4 - Returns the angle between two vectors defined by 3 or 4 points, or 2 lines.';

alter function public.st_angle(geometry, geometry, geometry, geometry) owner to postgres;

create function public.st_lineextend(geom geometry, distance_forward double precision, distance_backward double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lineextend(geometry, double precision, double precision) is 'args: line, distance_forward, distance_backward=0.0 - Returns a line with the last and first segments extended the specified distance(s).';

alter function public.st_lineextend(geometry, double precision, double precision) owner to postgres;

create function public.st_force2d(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_force2d(geometry) is 'args: geomA - Force the geometries into a "2-dimensional mode".';

alter function public.st_force2d(geometry) owner to postgres;

create function public.st_force3dz(geom geometry, zvalue double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_force3dz(geometry, double precision) is 'args: geomA, Zvalue = 0.0 - Force the geometries into XYZ mode.';

alter function public.st_force3dz(geometry, double precision) owner to postgres;

create function public.st_force3d(geom geometry, zvalue double precision DEFAULT 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Force3DZ($1, $2)$$;

comment on function public.st_force3d(geometry, double precision) is 'args: geomA, Zvalue = 0.0 - Force the geometries into XYZ mode. This is an alias for ST_Force3DZ.';

alter function public.st_force3d(geometry, double precision) owner to postgres;

create function public.st_force3dm(geom geometry, mvalue double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_force3dm(geometry, double precision) is 'args: geomA, Mvalue = 0.0 - Force the geometries into XYM mode.';

alter function public.st_force3dm(geometry, double precision) owner to postgres;

create function public.st_force4d(geom geometry, zvalue double precision default 0.0, mvalue double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_force4d(geometry, double precision, double precision) is 'args: geomA, Zvalue = 0.0, Mvalue = 0.0 - Force the geometries into XYZM mode.';

alter function public.st_force4d(geometry, double precision, double precision) owner to postgres;

create function public.st_forcecollection(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcecollection(geometry) is 'args: geomA - Convert the geometry into a GEOMETRYCOLLECTION.';

alter function public.st_forcecollection(geometry) owner to postgres;

create function public.st_collectionextract(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_collectionextract(geometry, integer) is 'args: collection, type - Given a geometry collection, returns a multi-geometry containing only elements of a specified type.';

alter function public.st_collectionextract(geometry, integer) owner to postgres;

create function public.st_collectionextract(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_collectionextract(geometry) is 'args: collection - Given a geometry collection, returns a multi-geometry containing only elements of a specified type.';

alter function public.st_collectionextract(geometry) owner to postgres;

create function public.st_collectionhomogenize(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_collectionhomogenize(geometry) is 'args: collection - Returns the simplest representation of a geometry collection.';

alter function public.st_collectionhomogenize(geometry) owner to postgres;

create function public.st_multi(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_multi(geometry) is 'args: geom - Return the geometry as a MULTI* geometry.';

alter function public.st_multi(geometry) owner to postgres;

create function public.st_forcecurve(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcecurve(geometry) is 'args: g - Upcast a geometry into its curved type, if applicable.';

alter function public.st_forcecurve(geometry) owner to postgres;

create function public.st_forcesfs(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcesfs(geometry) is 'args: geomA - Force the geometries to use SFS 1.1 geometry types only.';

alter function public.st_forcesfs(geometry) owner to postgres;

create function public.st_forcesfs(geometry, version text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcesfs(geometry, text) is 'args: geomA, version - Force the geometries to use SFS 1.1 geometry types only.';

alter function public.st_forcesfs(geometry, text) owner to postgres;

create function public.st_expand(box3d, double precision) returns box3d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(box3d, double precision) is 'args: box, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(box3d, double precision) owner to postgres;

create function public.st_expand(box box3d, dx double precision, dy double precision, dz double precision default 0) returns box3d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(box3d, double precision, double precision, double precision) is 'args: box, dx, dy, dz=0 - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(box3d, double precision, double precision, double precision) owner to postgres;

create function public.st_expand(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(geometry, double precision) is 'args: geom, units_to_expand - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(geometry, double precision) owner to postgres;

create function public.st_expand(geom geometry, dx double precision, dy double precision, dz double precision default 0, dm double precision default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_expand(geometry, double precision, double precision, double precision, double precision) is 'args: geom, dx, dy, dz=0, dm=0 - Returns a bounding box expanded from another bounding box or a geometry.';

alter function public.st_expand(geometry, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_envelope(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_envelope(geometry) is 'args: g1 - Returns a geometry representing the bounding box of a geometry.';

alter function public.st_envelope(geometry) owner to postgres;

create function public.st_boundingdiagonal(geom geometry, fits boolean default false) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_boundingdiagonal(geometry, boolean) is 'args: geom, fits=false - Returns the diagonal of a geometrys bounding box.';

alter function public.st_boundingdiagonal(geometry, boolean) owner to postgres;

create function public.st_reverse(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_reverse(geometry) is 'args: g1 - Return the geometry with vertex order reversed.';

alter function public.st_reverse(geometry) owner to postgres;

create function public.st_scroll(geometry, geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_scroll(geometry, geometry) is 'args: linestring, point - Change start point of a closed LineString.';

alter function public.st_scroll(geometry, geometry) owner to postgres;

create function public.st_forcepolygoncw(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcepolygoncw(geometry) is 'args: geom - Orients all exterior rings clockwise and all interior rings counter-clockwise.';

alter function public.st_forcepolygoncw(geometry) owner to postgres;

create function public.st_forcepolygonccw(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$ SELECT public.ST_Reverse(public.ST_ForcePolygonCW($1)) $$;

comment on function public.st_forcepolygonccw(geometry) is 'args: geom - Orients all exterior rings counter-clockwise and all interior rings clockwise.';

alter function public.st_forcepolygonccw(geometry) owner to postgres;

create function public.st_forcerhr(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_forcerhr(geometry) is 'args: g - Force the orientation of the vertices in a polygon to follow the Right-Hand-Rule.';

alter function public.st_forcerhr(geometry) owner to postgres;

create function public.postgis_noop(geometry) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_noop(geometry) owner to postgres;

create function public.postgis_geos_noop(geometry) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_geos_noop(geometry) owner to postgres;

create function public.st_normalize(geom geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_normalize(geometry) is 'args: geom - Return the geometry in its canonical form.';

alter function public.st_normalize(geometry) owner to postgres;

create function public.st_zmflag(geometry) returns smallint
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_zmflag(geometry) is 'args: geomA - Returns a code indicating the ZM coordinate dimension of a geometry.';

alter function public.st_zmflag(geometry) owner to postgres;

create function public.st_ndims(geometry) returns smallint
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_ndims(geometry) is 'args: g1 - Returns the coordinate dimension of a geometry.';

alter function public.st_ndims(geometry) owner to postgres;

create function public.st_asewkt(geometry) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkt(geometry) owner to postgres;

create function public.st_asewkt(geometry, integer) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkt(geometry, integer) owner to postgres;

create function public.st_astwkb(geom geometry, prec integer default NULL::integer, prec_z integer default NULL::integer, prec_m integer default NULL::integer, with_sizes boolean default NULL::boolean, with_boxes boolean default NULL::boolean) returns bytea
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astwkb(geometry, integer, integer, integer, boolean, boolean) owner to postgres;

create function public.st_astwkb(geom geometry[], ids bigint[], prec integer default NULL::integer, prec_z integer default NULL::integer, prec_m integer default NULL::integer, with_sizes boolean default NULL::boolean, with_boxes boolean default NULL::boolean) returns bytea
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astwkb(geometry[], bigint[], integer, integer, integer, boolean, boolean) owner to postgres;

create function public.st_asewkb(geometry) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkb(geometry) owner to postgres;

create function public.st_ashexewkb(geometry) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_ashexewkb(geometry) owner to postgres;

create function public.st_ashexewkb(geometry, text) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_ashexewkb(geometry, text) owner to postgres;

create function public.st_asewkb(geometry, text) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkb(geometry, text) owner to postgres;

create function public.st_aslatlontext(geom geometry, tmpl text default ''::text) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_aslatlontext(geometry, text) owner to postgres;

create function public.geomfromewkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geomfromewkb(bytea) owner to postgres;

create function public.st_geomfromewkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromewkb(bytea) owner to postgres;

create function public.st_geomfromtwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromtwkb(bytea) owner to postgres;

create function public.geomfromewkt(text) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geomfromewkt(text) owner to postgres;

create function public.st_geomfromewkt(text) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromewkt(text) owner to postgres;

create function public.postgis_cache_bbox() returns trigger
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_cache_bbox() owner to postgres;

create function public.st_makepoint(double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepoint(double precision, double precision) is 'args: x, y - Creates a 2D, 3DZ or 4D Point.';

alter function public.st_makepoint(double precision, double precision) owner to postgres;

create function public.st_makepoint(double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepoint(double precision, double precision, double precision) is 'args: x, y, z - Creates a 2D, 3DZ or 4D Point.';

alter function public.st_makepoint(double precision, double precision, double precision) owner to postgres;

create function public.st_makepoint(double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepoint(double precision, double precision, double precision, double precision) is 'args: x, y, z, m - Creates a 2D, 3DZ or 4D Point.';

alter function public.st_makepoint(double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_makepointm(double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepointm(double precision, double precision, double precision) is 'args: x, y, m - Creates a Point from X, Y and M values.';

alter function public.st_makepointm(double precision, double precision, double precision) owner to postgres;

create function public.st_3dmakebox(geom1 geometry, geom2 geometry) returns box3d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dmakebox(geometry, geometry) is 'args: point3DLowLeftBottom, point3DUpRightTop - Creates a BOX3D defined by two 3D point geometries.';

alter function public.st_3dmakebox(geometry, geometry) owner to postgres;

create function public.st_makeline(geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makeline(geometry[]) is 'args: geoms_array - Creates a LineString from Point, MultiPoint, or LineString geometries.';

alter function public.st_makeline(geometry[]) owner to postgres;

create function public.st_linefrommultipoint(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linefrommultipoint(geometry) is 'args: aMultiPoint - Creates a LineString from a MultiPoint geometry.';

alter function public.st_linefrommultipoint(geometry) owner to postgres;

create function public.st_makeline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makeline(geometry, geometry) is 'args: geom1, geom2 - Creates a LineString from Point, MultiPoint, or LineString geometries.';

alter function public.st_makeline(geometry, geometry) owner to postgres;

create function public.st_addpoint(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_addpoint(geometry, geometry) is 'args: linestring, point - Add a point to a LineString.';

alter function public.st_addpoint(geometry, geometry) owner to postgres;

create function public.st_addpoint(geom1 geometry, geom2 geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_addpoint(geometry, geometry, integer) is 'args: linestring, point, position = -1 - Add a point to a LineString.';

alter function public.st_addpoint(geometry, geometry, integer) owner to postgres;

create function public.st_removepoint(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_removepoint(geometry, integer) is 'args: linestring, offset - Remove a point from a linestring.';

alter function public.st_removepoint(geometry, integer) owner to postgres;

create function public.st_setpoint(geometry, integer, geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_setpoint(geometry, integer, geometry) is 'args: linestring, zerobasedposition, point - Replace point of a linestring with a given point.';

alter function public.st_setpoint(geometry, integer, geometry) owner to postgres;

create function public.st_makeenvelope(double precision, double precision, double precision, double precision, integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makeenvelope(double precision, double precision, double precision, double precision, integer) is 'args: xmin, ymin, xmax, ymax, srid=unknown - Creates a rectangular Polygon from minimum and maximum coordinates.';

alter function public.st_makeenvelope(double precision, double precision, double precision, double precision, integer) owner to postgres;

create function public.st_tileenvelope(zoom integer, x integer, y integer, bounds geometry default '0102000020110F00000200000093107C45F81B73C193107C45F81B73C193107C45F81B734193107C45F81B7341'::geometry, margin double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_tileenvelope(integer, integer, integer, geometry, double precision) is 'args: tileZoom, tileX, tileY, bounds=SRID=3857;LINESTRING(-20037508.342789 -20037508.342789,20037508.342789 20037508.342789), margin=0.0 - Creates a rectangular Polygon in Web Mercator (SRID:3857) using the XYZ tile system.';

alter function public.st_tileenvelope(integer, integer, integer, geometry, double precision) owner to postgres;

create function public.st_makepolygon(geometry, geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepolygon(geometry, geometry[]) is 'args: outerlinestring, interiorlinestrings - Creates a Polygon from a shell and optional list of holes.';

alter function public.st_makepolygon(geometry, geometry[]) owner to postgres;

create function public.st_makepolygon(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makepolygon(geometry) is 'args: linestring - Creates a Polygon from a shell and optional list of holes.';

alter function public.st_makepolygon(geometry) owner to postgres;

create function public.st_buildarea(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_buildarea(geometry) is 'args: geom - Creates a polygonal geometry formed by the linework of a geometry.';

alter function public.st_buildarea(geometry) owner to postgres;

create function public.st_polygonize(geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_polygonize(geometry[]) is 'args: geom_array - Computes a collection of polygons formed from the linework of a set of geometries.';

alter function public.st_polygonize(geometry[]) owner to postgres;

create function public.st_clusterintersecting(geometry[]) returns geometry[]
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_clusterintersecting(geometry[]) owner to postgres;

create function public.st_clusterwithin(geometry[], double precision) returns geometry[]
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_clusterwithin(geometry[], double precision) owner to postgres;

create function public.st_clusterdbscan(geometry, eps double precision, minpoints integer) returns integer
    immutable
    window
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_clusterdbscan(geometry, double precision, integer) is 'args: geom, eps, minpoints - Window function that returns a cluster id for each input geometry using the DBSCAN algorithm.';

alter function public.st_clusterdbscan(geometry, double precision, integer) owner to postgres;

create function public.st_clusterwithinwin(geometry, distance double precision) returns integer
    immutable
    window
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_clusterwithinwin(geometry, double precision) is 'args: geom, distance - Window function that returns a cluster id for each input geometry, clustering using separation distance.';

alter function public.st_clusterwithinwin(geometry, double precision) owner to postgres;

create function public.st_clusterintersectingwin(geometry) returns integer
    immutable
    window
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_clusterintersectingwin(geometry) is 'args: geom - Window function that returns a cluster id for each input geometry, clustering input geometries into connected sets.';

alter function public.st_clusterintersectingwin(geometry) owner to postgres;

create function public.st_linemerge(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linemerge(geometry) is 'args: amultilinestring - Return the lines formed by sewing together a MultiLineString.';

alter function public.st_linemerge(geometry) owner to postgres;

create function public.st_linemerge(geometry, boolean) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linemerge(geometry, boolean) is 'args: amultilinestring, directed - Return the lines formed by sewing together a MultiLineString.';

alter function public.st_linemerge(geometry, boolean) owner to postgres;

create function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) is 'args: geomA, a, b, c, d, e, f, g, h, i, xoff, yoff, zoff - Apply a 3D affine transformation to a geometry.';

alter function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$$;

comment on function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) is 'args: geomA, a, b, d, e, xoff, yoff - Apply a 3D affine transformation to a geometry.';

alter function public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_rotate(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$$;

comment on function public.st_rotate(geometry, double precision) is 'args: geomA, rotRadians - Rotates a geometry about an origin point.';

alter function public.st_rotate(geometry, double precision) owner to postgres;

create function public.st_rotate(geometry, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1,	$3 - cos($2) * $3 + sin($2) * $4, $4 - sin($2) * $3 - cos($2) * $4, 0)$$;

comment on function public.st_rotate(geometry, double precision, double precision, double precision) is 'args: geomA, rotRadians, x0, y0 - Rotates a geometry about an origin point.';

alter function public.st_rotate(geometry, double precision, double precision, double precision) owner to postgres;

create function public.st_rotate(geometry, double precision, geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1, public.ST_X($3) - cos($2) * public.ST_X($3) + sin($2) * public.ST_Y($3), public.ST_Y($3) - sin($2) * public.ST_X($3) - cos($2) * public.ST_Y($3), 0)$$;

comment on function public.st_rotate(geometry, double precision, geometry) is 'args: geomA, rotRadians, pointOrigin - Rotates a geometry about an origin point.';

alter function public.st_rotate(geometry, double precision, geometry) owner to postgres;

create function public.st_rotatez(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Rotate($1, $2)$$;

comment on function public.st_rotatez(geometry, double precision) is 'args: geomA, rotRadians - Rotates a geometry about the Z axis.';

alter function public.st_rotatez(geometry, double precision) owner to postgres;

create function public.st_rotatex(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)$$;

comment on function public.st_rotatex(geometry, double precision) is 'args: geomA, rotRadians - Rotates a geometry about the X axis.';

alter function public.st_rotatex(geometry, double precision) owner to postgres;

create function public.st_rotatey(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)$$;

comment on function public.st_rotatey(geometry, double precision) is 'args: geomA, rotRadians - Rotates a geometry about the Y axis.';

alter function public.st_rotatey(geometry, double precision) owner to postgres;

create function public.st_translate(geometry, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$$;

comment on function public.st_translate(geometry, double precision, double precision, double precision) is 'args: g1, deltax, deltay, deltaz - Translates a geometry by given offsets.';

alter function public.st_translate(geometry, double precision, double precision, double precision) owner to postgres;

create function public.st_translate(geometry, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Translate($1, $2, $3, 0)$$;

comment on function public.st_translate(geometry, double precision, double precision) is 'args: g1, deltax, deltay - Translates a geometry by given offsets.';

alter function public.st_translate(geometry, double precision, double precision) owner to postgres;

create function public.st_scale(geometry, geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_scale(geometry, geometry) is 'args: geom, factor - Scales a geometry by given factors.';

alter function public.st_scale(geometry, geometry) owner to postgres;

create function public.st_scale(geometry, geometry, origin geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_scale(geometry, geometry, geometry) is 'args: geom, factor, origin - Scales a geometry by given factors.';

alter function public.st_scale(geometry, geometry, geometry) owner to postgres;

create function public.st_scale(geometry, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Scale($1, public.ST_MakePoint($2, $3, $4))$$;

comment on function public.st_scale(geometry, double precision, double precision, double precision) is 'args: geomA, XFactor, YFactor, ZFactor - Scales a geometry by given factors.';

alter function public.st_scale(geometry, double precision, double precision, double precision) owner to postgres;

create function public.st_scale(geometry, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Scale($1, $2, $3, 1)$$;

comment on function public.st_scale(geometry, double precision, double precision) is 'args: geomA, XFactor, YFactor - Scales a geometry by given factors.';

alter function public.st_scale(geometry, double precision, double precision) owner to postgres;

create function public.st_transscale(geometry, double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_Affine($1,  $4, 0, 0,  0, $5, 0,
		0, 0, 1,  $2 * $4, $3 * $5, 0)$$;

comment on function public.st_transscale(geometry, double precision, double precision, double precision, double precision) is 'args: geomA, deltaX, deltaY, XFactor, YFactor - Translates and scales a geometry by given offsets and factors.';

alter function public.st_transscale(geometry, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_dump(geometry) returns setof setof geometry_dump
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_dump(geometry) is 'args: g1 - Returns a set of geometry_dump rows for the components of a geometry.';

alter function public.st_dump(geometry) owner to postgres;

create function public.st_dumprings(geometry) returns setof setof geometry_dump
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_dumprings(geometry) is 'args: a_polygon - Returns a set of geometry_dump rows for the exterior and interior rings of a Polygon.';

alter function public.st_dumprings(geometry) owner to postgres;

create function public.st_dumppoints(geometry) returns setof setof geometry_dump
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_dumppoints(geometry) is 'args: geom - Returns a set of geometry_dump rows for the coordinates in a geometry.';

alter function public.st_dumppoints(geometry) owner to postgres;

create function public.st_dumpsegments(geometry) returns setof setof geometry_dump
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_dumpsegments(geometry) is 'args: geom - Returns a set of geometry_dump rows for the segments in a geometry.';

alter function public.st_dumpsegments(geometry) owner to postgres;

create function public.populate_geometry_columns(use_typmod boolean DEFAULT true) returns text
    language plpgsql
as
$$
DECLARE
inserted	integer;
	oldcount	integer;
	probed	  integer;
	stale	   integer;
	gcs		 RECORD;
	gc		  RECORD;
	gsrid	   integer;
	gndims	  integer;
	gtype	   text;
	query	   text;
	gc_is_valid boolean;

BEGIN
SELECT count(*) INTO oldcount FROM public.geometry_columns;
inserted := 0;

	-- Count the number of geometry columns in all tables and views
SELECT count(DISTINCT c.oid) INTO probed
FROM pg_class c,
     pg_attribute a,
     pg_type t,
     pg_namespace n
WHERE c.relkind IN('r','v','f', 'p')
  AND t.typname = 'geometry'
  AND a.attisdropped = false
  AND a.atttypid = t.oid
  AND a.attrelid = c.oid
  AND c.relnamespace = n.oid
  AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns' ;

-- Iterate through all non-dropped geometry columns
RAISE DEBUG 'Processing Tables.....';

FOR gcs IN
SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
FROM pg_class c,
    pg_attribute a,
    pg_type t,
    pg_namespace n
WHERE c.relkind IN( 'r', 'f', 'p')
  AND t.typname = 'geometry'
  AND a.attisdropped = false
  AND a.atttypid = t.oid
  AND a.attrelid = c.oid
  AND c.relnamespace = n.oid
  AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns'
    LOOP

    inserted := inserted + public.populate_geometry_columns(gcs.oid, use_typmod);
END LOOP;

	IF oldcount > inserted THEN
		stale = oldcount-inserted;
ELSE
		stale = 0;
END IF;

RETURN 'probed:' ||probed|| ' inserted:'||inserted;
END

$$;

comment on function public.populate_geometry_columns(boolean) is 'args: use_typmod=true - Ensures geometry columns are defined with type modifiers or have appropriate spatial constraints.';

alter function public.populate_geometry_columns(boolean) owner to postgres;

create function public.populate_geometry_columns(tbl_oid oid, use_typmod boolean DEFAULT true) returns integer
    language plpgsql
as
$$
DECLARE
gcs		 RECORD;
	gc		  RECORD;
	gc_old	  RECORD;
	gsrid	   integer;
	gndims	  integer;
	gtype	   text;
	query	   text;
	gc_is_valid boolean;
	inserted	integer;
	constraint_successful boolean := false;

BEGIN
	inserted := 0;

	-- Iterate through all geometry columns in this table
FOR gcs IN
SELECT n.nspname, c.relname, a.attname, c.relkind
FROM pg_class c,
     pg_attribute a,
     pg_type t,
     pg_namespace n
WHERE c.relkind IN('r', 'f', 'p')
  AND t.typname = 'geometry'
  AND a.attisdropped = false
  AND a.atttypid = t.oid
  AND a.attrelid = c.oid
  AND c.relnamespace = n.oid
  AND n.nspname NOT ILIKE 'pg_temp%'
		AND c.oid = tbl_oid
	LOOP

		RAISE DEBUG 'Processing column %.%.%', gcs.nspname, gcs.relname, gcs.attname;

gc_is_valid := true;
		-- Find the srid, coord_dimension, and type of current geometry
		-- in geometry_columns -- which is now a view

SELECT type, srid, coord_dimension, gcs.relkind INTO gc_old
FROM geometry_columns
WHERE f_table_schema = gcs.nspname AND f_table_name = gcs.relname AND f_geometry_column = gcs.attname;

IF upper(gc_old.type) = 'GEOMETRY' THEN
		-- This is an unconstrained geometry we need to do something
		-- We need to figure out what to set the type by inspecting the data
			EXECUTE 'SELECT public.ST_srid(' || quote_ident(gcs.attname) || ') As srid, public.GeometryType(' || quote_ident(gcs.attname) || ') As type, public.ST_NDims(' || quote_ident(gcs.attname) || ') As dims ' ||
					 ' FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||
					 ' WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1;'
				INTO gc;
			IF gc IS NULL THEN -- there is no data so we can not determine geometry type
				RAISE WARNING 'No data in table %.%, so no information to determine geometry type and srid', gcs.nspname, gcs.relname;
RETURN 0;
END IF;
			gsrid := gc.srid; gtype := gc.type; gndims := gc.dims;

			IF use_typmod THEN
BEGIN
EXECUTE 'ALTER TABLE ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' ALTER COLUMN ' || quote_ident(gcs.attname) ||
        ' TYPE geometry(' || postgis_type_name(gtype, gndims, true) || ', ' || gsrid::text  || ') ';
inserted := inserted + 1;
EXCEPTION
						WHEN invalid_parameter_value OR feature_not_supported THEN
						RAISE WARNING 'Could not convert ''%'' in ''%.%'' to use typmod with srid %, type %: %', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), gsrid, postgis_type_name(gtype, gndims, true), SQLERRM;
							gc_is_valid := false;
END;

ELSE
				-- Try to apply srid check to column
				constraint_successful = false;
				IF (gsrid > 0 AND postgis_constraint_srid(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
BEGIN
EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) ||
        ' ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) ||
        ' CHECK (ST_srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';
constraint_successful := true;
EXCEPTION
						WHEN check_violation THEN
							RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;
							gc_is_valid := false;
END;
END IF;

				-- Try to apply ndims check to column
				IF (gndims IS NOT NULL AND postgis_constraint_dims(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
BEGIN
EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
								 ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || '
								 CHECK (st_ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';
constraint_successful := true;
EXCEPTION
						WHEN check_violation THEN
							RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;
							gc_is_valid := false;
END;
END IF;

				-- Try to apply geometrytype check to column
				IF (gtype IS NOT NULL AND postgis_constraint_type(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
BEGIN
EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
						ADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || '
						CHECK (geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ')';
constraint_successful := true;
EXCEPTION
						WHEN check_violation THEN
							-- No geometry check can be applied. This column contains a number of geometry types.
							RAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);
END;
END IF;
				 --only count if we were successful in applying at least one constraint
				IF constraint_successful THEN
					inserted := inserted + 1;
END IF;
END IF;
END IF;

END LOOP;

RETURN inserted;
END

$$;

comment on function public.populate_geometry_columns(oid, boolean) is 'args: relation_oid, use_typmod=true - Ensures geometry columns are defined with type modifiers or have appropriate spatial constraints.';

alter function public.populate_geometry_columns(oid, boolean) owner to postgres;

create function public.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true) returns text
    strict
    language plpgsql
as
$$
DECLARE
rec RECORD;
	sr varchar;
	real_schema name;
sql text;
	new_srid integer;

BEGIN

	-- Verify geometry type
	IF (postgis_type_name(new_type,new_dim) IS NULL )
	THEN
		RAISE EXCEPTION 'Invalid type name "%(%)" - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM, TRIANGLE, TRIANGLEM,
	POLYHEDRALSURFACE, POLYHEDRALSURFACEM, TIN, TINM
	or GEOMETRYCOLLECTIONM', new_type, new_dim;
RETURN 'fail';
END IF;

	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <2) ) THEN
		RAISE EXCEPTION 'invalid dimension';
RETURN 'fail';
END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
RETURN 'fail';
END IF;

	-- Verify SRID
	IF ( new_srid_in > 0 ) THEN
		IF new_srid_in > 998999 THEN
			RAISE EXCEPTION 'AddGeometryColumn() - SRID must be <= %', 998999;
END IF;
		new_srid := new_srid_in;
SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumn() - invalid SRID';
RETURN 'fail';
END IF;
ELSE
		new_srid := public.ST_SRID('POINT EMPTY'::public.geometry);
		IF ( new_srid_in != new_srid ) THEN
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
END IF;
END IF;

	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
EXECUTE sql INTO real_schema;

IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
RETURN 'fail';
END IF;
END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
EXECUTE sql INTO real_schema;

IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
RETURN 'fail';
END IF;
END IF;

	-- Add geometry column to table
	IF use_typmod THEN
		 sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD COLUMN ' || quote_ident(column_name) ||
			' geometry(' || public.postgis_type_name(new_type, new_dim) || ', ' || new_srid::text || ')';
		RAISE DEBUG '%', sql;
ELSE
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD COLUMN ' || quote_ident(column_name) ||
			' geometry ';
		RAISE DEBUG '%', sql;
END IF;
EXECUTE sql;

IF NOT use_typmod THEN
		-- Add table CHECKs
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD CONSTRAINT '
			|| quote_ident('enforce_srid_' || column_name)
			|| ' CHECK (st_srid(' || quote_ident(column_name) ||
			') = ' || new_srid::text || ')' ;
		RAISE DEBUG '%', sql;
EXECUTE sql;

sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name)
			|| ' ADD CONSTRAINT '
			|| quote_ident('enforce_dims_' || column_name)
			|| ' CHECK (st_ndims(' || quote_ident(column_name) ||
			') = ' || new_dim::text || ')' ;
		RAISE DEBUG '%', sql;
EXECUTE sql;

IF ( NOT (new_type = 'GEOMETRY')) THEN
			sql := 'ALTER TABLE ' ||
				quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
				quote_ident('enforce_geotype_' || column_name) ||
				' CHECK (GeometryType(' ||
				quote_ident(column_name) || ')=' ||
				quote_literal(new_type) || ' OR (' ||
				quote_ident(column_name) || ') is null)';
			RAISE DEBUG '%', sql;
EXECUTE sql;
END IF;
END IF;

RETURN
        real_schema || '.' ||
        table_name || '.' || column_name ||
        ' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$$;

comment on function public.addgeometrycolumn(varchar, varchar, varchar, varchar, integer, varchar, integer, boolean) is 'args: catalog_name, schema_name, table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

alter function public.addgeometrycolumn(varchar, varchar, varchar, varchar, integer, varchar, integer, boolean) owner to postgres;

create function public.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true) returns text
    stable
    strict
    language plpgsql
as
$$
DECLARE
ret  text;
BEGIN
SELECT public.AddGeometryColumn('',$1,$2,$3,$4,$5,$6,$7) into ret;
RETURN ret;
END;
$$;

comment on function public.addgeometrycolumn(varchar, varchar, varchar, integer, varchar, integer, boolean) is 'args: schema_name, table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

alter function public.addgeometrycolumn(varchar, varchar, varchar, integer, varchar, integer, boolean) owner to postgres;

create function public.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true) returns text
    strict
    language plpgsql
as
$$
DECLARE
ret  text;
BEGIN
SELECT public.AddGeometryColumn('','',$1,$2,$3,$4,$5, $6) into ret;
RETURN ret;
END;
$$;

comment on function public.addgeometrycolumn(varchar, varchar, integer, varchar, integer, boolean) is 'args: table_name, column_name, srid, type, dimension, use_typmod=true - Adds a geometry column to an existing table.';

alter function public.addgeometrycolumn(varchar, varchar, integer, varchar, integer, boolean) owner to postgres;

create function public.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying) returns text
    strict
    language plpgsql
as
$$
DECLARE
myrec RECORD;
	okay boolean;
	real_schema name;

BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;

FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
END LOOP;

		IF ( okay <>  true ) THEN
			RAISE NOTICE 'Invalid schema name - using current_schema()';
SELECT current_schema() into real_schema;
ELSE
			real_schema = schema_name;
END IF;
ELSE
SELECT current_schema() into real_schema;
END IF;

	-- Find out if the column is in the geometry_columns table
	okay = false;
FOR myrec IN SELECT * from public.geometry_columns where f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
END LOOP;
	IF (okay <> true) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
RETURN false;
END IF;

	-- Remove table column
EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' ||
        quote_ident(table_name) || ' DROP COLUMN ' ||
        quote_ident(column_name);

RETURN real_schema || '.' || table_name || '.' || column_name ||' effectively removed.';

END;
$$;

comment on function public.dropgeometrycolumn(varchar, varchar, varchar, varchar) is 'args: catalog_name, schema_name, table_name, column_name - Removes a geometry column from a spatial table.';

alter function public.dropgeometrycolumn(varchar, varchar, varchar, varchar) owner to postgres;

create function public.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying) returns text
    strict
    language plpgsql
as
$$
DECLARE
ret text;
BEGIN
SELECT public.DropGeometryColumn('',$1,$2,$3) into ret;
RETURN ret;
END;
$$;

comment on function public.dropgeometrycolumn(varchar, varchar, varchar) is 'args: schema_name, table_name, column_name - Removes a geometry column from a spatial table.';

alter function public.dropgeometrycolumn(varchar, varchar, varchar) owner to postgres;

create function public.dropgeometrycolumn(table_name character varying, column_name character varying) returns text
    strict
    language plpgsql
as
$$
DECLARE
ret text;
BEGIN
SELECT public.DropGeometryColumn('','',$1,$2) into ret;
RETURN ret;
END;
$$;

comment on function public.dropgeometrycolumn(varchar, varchar) is 'args: table_name, column_name - Removes a geometry column from a spatial table.';

alter function public.dropgeometrycolumn(varchar, varchar) owner to postgres;

create function public.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying) returns text
    strict
    language plpgsql
as
$$
DECLARE
real_schema name;

BEGIN

	IF ( schema_name = '' ) THEN
SELECT current_schema() into real_schema;
ELSE
		real_schema = schema_name;
END IF;

	-- TODO: Should we warn if table doesn't exist probably instead just saying dropped
	-- Remove table
EXECUTE 'DROP TABLE IF EXISTS '
    || quote_ident(real_schema) || '.' ||
        quote_ident(table_name) || ' RESTRICT';

RETURN
        real_schema || '.' ||
        table_name ||' dropped.';

END;
$$;

comment on function public.dropgeometrytable(varchar, varchar, varchar) is 'args: catalog_name, schema_name, table_name - Drops a table and all its references in geometry_columns.';

alter function public.dropgeometrytable(varchar, varchar, varchar) owner to postgres;

create function public.dropgeometrytable(schema_name character varying, table_name character varying) returns text
    strict
    language sql
as
$$ SELECT public.DropGeometryTable('',$1,$2) $$;

comment on function public.dropgeometrytable(varchar, varchar) is 'args: schema_name, table_name - Drops a table and all its references in geometry_columns.';

alter function public.dropgeometrytable(varchar, varchar) owner to postgres;

create function public.dropgeometrytable(table_name character varying) returns text
    strict
    language sql
as
$$ SELECT public.DropGeometryTable('','',$1) $$;

comment on function public.dropgeometrytable(varchar) is 'args: table_name - Drops a table and all its references in geometry_columns.';

alter function public.dropgeometrytable(varchar) owner to postgres;

create function public.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer) returns text
    strict
    language plpgsql
as
$$
DECLARE
myrec RECORD;
	okay boolean;
	cname varchar;
	real_schema name;
	unknown_srid integer;
	new_srid integer := new_srid_in;

BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;

FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
END LOOP;

		IF ( okay <> true ) THEN
			RAISE EXCEPTION 'Invalid schema name';
ELSE
			real_schema = schema_name;
END IF;
ELSE
SELECT INTO real_schema current_schema()::text;
END IF;

	-- Ensure that column_name is in geometry_columns
	okay = false;
FOR myrec IN SELECT type, coord_dimension FROM public.geometry_columns WHERE f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
END LOOP;
	IF (NOT okay) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
RETURN false;
END IF;

	-- Ensure that new_srid is valid
	IF ( new_srid > 0 ) THEN
		IF ( SELECT count(*) = 0 from spatial_ref_sys where srid = new_srid ) THEN
			RAISE EXCEPTION 'invalid SRID: % not found in spatial_ref_sys', new_srid;
RETURN false;
END IF;
ELSE
		unknown_srid := public.ST_SRID('POINT EMPTY'::public.geometry);
		IF ( new_srid != unknown_srid ) THEN
			new_srid := unknown_srid;
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
END IF;
END IF;

	IF postgis_constraint_srid(real_schema, table_name, column_name) IS NOT NULL THEN
	-- srid was enforced with constraints before, keep it that way.
		-- Make up constraint name
		cname = 'enforce_srid_'  || column_name;

		-- Drop enforce_srid constraint
EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
        '.' || quote_ident(table_name) ||
        ' DROP constraint ' || quote_ident(cname);

-- Update geometries SRID
EXECUTE 'UPDATE ' || quote_ident(real_schema) ||
        '.' || quote_ident(table_name) ||
        ' SET ' || quote_ident(column_name) ||
        ' = public.ST_SetSRID(' || quote_ident(column_name) ||
        ', ' || new_srid::text || ')';

-- Reset enforce_srid constraint
EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
        '.' || quote_ident(table_name) ||
        ' ADD constraint ' || quote_ident(cname) ||
        ' CHECK (st_srid(' || quote_ident(column_name) ||
        ') = ' || new_srid::text || ')';
ELSE
		-- We will use typmod to enforce if no srid constraints
		-- We are using postgis_type_name to lookup the new name
		-- (in case Paul changes his mind and flips geometry_columns to return old upper case name)
		EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' || quote_ident(table_name) ||
		' ALTER COLUMN ' || quote_ident(column_name) || ' TYPE  geometry(' || public.postgis_type_name(myrec.type, myrec.coord_dimension, true) || ', ' || new_srid::text || ') USING public.ST_SetSRID(' || quote_ident(column_name) || ',' || new_srid::text || ');' ;
END IF;

RETURN real_schema || '.' || table_name || '.' || column_name ||' SRID changed to ' || new_srid::text;

END;
$$;

comment on function public.updategeometrysrid(varchar, varchar, varchar, varchar, integer) is 'args: catalog_name, schema_name, table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

alter function public.updategeometrysrid(varchar, varchar, varchar, varchar, integer) owner to postgres;

create function public.updategeometrysrid(character varying, character varying, character varying, integer) returns text
    strict
    language plpgsql
as
$$
DECLARE
ret  text;
BEGIN
SELECT public.UpdateGeometrySRID('',$1,$2,$3,$4) into ret;
RETURN ret;
END;
$$;

comment on function public.updategeometrysrid(varchar, varchar, varchar, integer) is 'args: schema_name, table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

alter function public.updategeometrysrid(varchar, varchar, varchar, integer) owner to postgres;

create function public.updategeometrysrid(character varying, character varying, integer) returns text
    strict
    language plpgsql
as
$$
DECLARE
ret  text;
BEGIN
SELECT public.UpdateGeometrySRID('','',$1,$2,$3) into ret;
RETURN ret;
END;
$$;

comment on function public.updategeometrysrid(varchar, varchar, integer) is 'args: table_name, column_name, srid - Updates the SRID of all features in a geometry column, and the table metadata.';

alter function public.updategeometrysrid(varchar, varchar, integer) owner to postgres;

create function public.find_srid(character varying, character varying, character varying) returns integer
    stable
    strict
    parallel safe
    language plpgsql
as
$$
DECLARE
schem varchar =  $1;
	tabl varchar = $2;
	sr int4;
BEGIN
-- if the table contains a . and the schema is empty
-- split the table into a schema and a table
-- otherwise drop through to default behavior
	IF ( schem = '' and strpos(tabl,'.') > 0 ) THEN
	 schem = substr(tabl,1,strpos(tabl,'.')-1);
	 tabl = substr(tabl,length(schem)+2);
END IF;

select SRID into sr from public.geometry_columns where (f_table_schema = schem or schem = '') and f_table_name = tabl and f_geometry_column = $3;
IF NOT FOUND THEN
	   RAISE EXCEPTION 'find_srid() - could not find the corresponding SRID - is the geometry registered in the GEOMETRY_COLUMNS table?  Is there an uppercase/lowercase mismatch?';
END IF;
return sr;
END;
$$;

comment on function public.find_srid(varchar, varchar, varchar) is 'args: a_schema_name, a_table_name, a_geomfield_name - Returns the SRID defined for a geometry column.';

alter function public.find_srid(varchar, varchar, varchar) owner to postgres;

create function public.get_proj4_from_srid(integer) returns text
    immutable
    strict
    parallel safe
    language plpgsql
as
$$
BEGIN
RETURN proj4text::text FROM public.spatial_ref_sys WHERE srid= $1;
END;
	$$;

alter function public.get_proj4_from_srid(integer) owner to postgres;

create function public.st_setsrid(geom geometry, srid integer) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_setsrid(geometry, integer) is 'args: geom, srid - Set the SRID on a geometry.';

alter function public.st_setsrid(geometry, integer) owner to postgres;

create function public.st_srid(geom geometry) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_srid(geometry) is 'args: g1 - Returns the spatial reference identifier for a geometry.';

alter function public.st_srid(geometry) owner to postgres;

create function public.postgis_transform_geometry(geom geometry, text, text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_transform_geometry(geometry, text, text, integer) owner to postgres;

create function public.postgis_srs_codes(auth_name text) returns setof setof text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.postgis_srs_codes(text) is 'args: auth_name - Return the list of SRS codes associated with the given authority.';

alter function public.postgis_srs_codes(text) owner to postgres;

create function public.postgis_srs(auth_name text, auth_srid text) returns setof table("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" geometry, "point_ne" geometry)
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.postgis_srs(text, text) is 'args: auth_name, auth_srid - Return a metadata record for the requested authority and srid.';

alter function public.postgis_srs(text, text) owner to postgres;

create function public.postgis_srs_all() returns setof table("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" geometry, "point_ne" geometry)
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.postgis_srs_all() is 'Return metadata records for every spatial reference system in the underlying Proj database.';

alter function public.postgis_srs_all() owner to postgres;

create function public.postgis_srs_search(bounds geometry, authname text default 'EPSG'::text) returns setof table("auth_name" text, "auth_srid" text, "srname" text, "srtext" text, "proj4text" text, "point_sw" geometry, "point_ne" geometry)
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.postgis_srs_search(geometry, text) is 'args: bounds, auth_name=EPSG - Return metadata records for projected coordinate systems that have areas of useage that fully contain the bounds parameter.';

alter function public.postgis_srs_search(geometry, text) owner to postgres;

create function public.st_transform(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_transform(geometry, integer) is 'args: g1, srid - Return a new geometry with coordinates transformed to a different spatial reference system.';

alter function public.st_transform(geometry, integer) owner to postgres;

create function public.st_transform(geom geometry, to_proj text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public.postgis_transform_geometry($1, proj4text, $2, 0)
	FROM spatial_ref_sys WHERE srid=public.ST_SRID($1);$$;

comment on function public.st_transform(geometry, text) is 'args: geom, to_proj - Return a new geometry with coordinates transformed to a different spatial reference system.';

alter function public.st_transform(geometry, text) owner to postgres;

create function public.st_transform(geom geometry, from_proj text, to_proj text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public.postgis_transform_geometry($1, $2, $3, 0)$$;

comment on function public.st_transform(geometry, text, text) is 'args: geom, from_proj, to_proj - Return a new geometry with coordinates transformed to a different spatial reference system.';

alter function public.st_transform(geometry, text, text) owner to postgres;

create function public.st_transform(geom geometry, from_proj text, to_srid integer) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public.postgis_transform_geometry($1, $2, proj4text, $3)
	FROM spatial_ref_sys WHERE srid=$3;$$;

comment on function public.st_transform(geometry, text, integer) is 'args: geom, from_proj, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system.';

alter function public.st_transform(geometry, text, integer) owner to postgres;

create function public.postgis_transform_pipeline_geometry(geom geometry, pipeline text, forward boolean, to_srid integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_transform_pipeline_geometry(geometry, text, boolean, integer) owner to postgres;

create function public.st_transformpipeline(geom geometry, pipeline text, to_srid integer DEFAULT 0) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public.postgis_transform_pipeline_geometry($1, $2, TRUE, $3)$$;

comment on function public.st_transformpipeline(geometry, text, integer) is 'args: g1, pipeline, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system using a defined coordinate transformation pipeline.';

alter function public.st_transformpipeline(geometry, text, integer) owner to postgres;

create function public.st_inversetransformpipeline(geom geometry, pipeline text, to_srid integer DEFAULT 0) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public.postgis_transform_pipeline_geometry($1, $2, FALSE, $3)$$;

comment on function public.st_inversetransformpipeline(geometry, text, integer) is 'args: geom, pipeline, to_srid - Return a new geometry with coordinates transformed to a different spatial reference system using the inverse of a defined coordinate transformation pipeline.';

alter function public.st_inversetransformpipeline(geometry, text, integer) owner to postgres;

create function public.postgis_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_version() is 'Returns PostGIS version number and compile-time options.';

alter function public.postgis_version() owner to postgres;

create function public.postgis_liblwgeom_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_liblwgeom_version() is 'Returns the version number of the liblwgeom library. This should match the version of PostGIS.';

alter function public.postgis_liblwgeom_version() owner to postgres;

create function public.postgis_proj_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_proj_version() is 'Returns the version number of the PROJ4 library.';

alter function public.postgis_proj_version() owner to postgres;

create function public.postgis_wagyu_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_wagyu_version() is 'Returns the version number of the internal Wagyu library.';

alter function public.postgis_wagyu_version() owner to postgres;

create function public.postgis_scripts_installed() returns text
    immutable
    language sql
as
$$ SELECT trim('3.4.2'::text || $rev$ c19ce56 $rev$) AS version $$;

comment on function public.postgis_scripts_installed() is 'Returns version of the PostGIS scripts installed in this database.';

alter function public.postgis_scripts_installed() owner to postgres;

create function public.postgis_lib_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_lib_version() is 'Returns the version number of the PostGIS library.';

alter function public.postgis_lib_version() owner to postgres;

create function public.postgis_scripts_released() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_scripts_released() is 'Returns the version number of the postgis.sql script released with the installed PostGIS lib.';

alter function public.postgis_scripts_released() owner to postgres;

create function public.postgis_geos_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_geos_version() is 'Returns the version number of the GEOS library.';

alter function public.postgis_geos_version() owner to postgres;

create function public.postgis_geos_compiled_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_geos_compiled_version() is 'Returns the version number of the GEOS library against which PostGIS was built.';

alter function public.postgis_geos_compiled_version() owner to postgres;

create function public.postgis_lib_revision() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_lib_revision() owner to postgres;

create function public.postgis_svn_version() returns text
    immutable
    language sql
as
$$
SELECT public._postgis_deprecate(
               'postgis_svn_version', 'postgis_lib_revision', '3.1.0');
SELECT public.postgis_lib_revision();
$$;

alter function public.postgis_svn_version() owner to postgres;

create function public.postgis_libxml_version() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_libxml_version() is 'Returns the version number of the libxml2 library.';

alter function public.postgis_libxml_version() owner to postgres;

create function public.postgis_scripts_build_date() returns text
    immutable
    language sql
as
$$SELECT '2024-02-08 17:55:49'::text AS version$$;

comment on function public.postgis_scripts_build_date() is 'Returns build date of the PostGIS scripts.';

alter function public.postgis_scripts_build_date() owner to postgres;

create function public.postgis_lib_build_date() returns text
    immutable
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.postgis_lib_build_date() is 'Returns build date of the PostGIS library.';

alter function public.postgis_lib_build_date() owner to postgres;

create function public._postgis_scripts_pgsql_version() returns text
    immutable
    language sql
as
$$SELECT '160'::text AS version$$;

alter function public._postgis_scripts_pgsql_version() owner to postgres;

create function public._postgis_pgsql_version() returns text
    stable
    language sql
as
$$
SELECT CASE WHEN pg_catalog.split_part(s,'.',1)::integer > 9 THEN pg_catalog.split_part(s,'.',1) || '0'
	ELSE pg_catalog.split_part(s,'.', 1) || pg_catalog.split_part(s,'.', 2) END AS v
	FROM pg_catalog.substring(version(), E'PostgreSQL ([0-9\\.]+)') AS s;
$$;

alter function public._postgis_pgsql_version() owner to postgres;

create function public.postgis_extensions_upgrade(target_version text DEFAULT NULL::text) returns text
    language plpgsql
as
$$
DECLARE
rec record;
sql text;
	var_schema text;
BEGIN

FOR rec IN
SELECT name, default_version, installed_version
FROM pg_catalog.pg_available_extensions
WHERE name IN (
               'postgis',
               'postgis_raster',
               'postgis_sfcgal',
               'postgis_topology',
               'postgis_tiger_geocoder'
    )
ORDER BY length(name) -- this is to make sure 'postgis' is first !
    LOOP --{

		IF target_version IS NULL THEN
			target_version := rec.default_version;
END IF;

		IF rec.installed_version IS NULL THEN --{
			-- If the support installed by available extension
			-- is found unpackaged, we package it
			IF --{
				 -- PostGIS is always available (this function is part of it)
				 rec.name = 'postgis'

				 -- PostGIS raster is available if type 'raster' exists
				 OR ( rec.name = 'postgis_raster' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_type
							WHERE typname = 'raster' ) )

				 -- PostGIS SFCGAL is availble if
				 -- 'postgis_sfcgal_version' function exists
				 OR ( rec.name = 'postgis_sfcgal' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_proc
							WHERE proname = 'postgis_sfcgal_version' ) )

				 -- PostGIS Topology is available if
				 -- 'topology.topology' table exists
				 -- NOTE: watch out for https://trac.osgeo.org/postgis/ticket/2503
				 OR ( rec.name = 'postgis_topology' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_class c
							JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )
							WHERE n.nspname = 'topology' AND c.relname = 'topology') )

				 OR ( rec.name = 'postgis_tiger_geocoder' AND EXISTS (
							SELECT 1 FROM pg_catalog.pg_class c
							JOIN pg_catalog.pg_namespace n ON (c.relnamespace = n.oid )
							WHERE n.nspname = 'tiger' AND c.relname = 'geocode_settings') )
			THEN --}{ -- the code is unpackaged
				-- Force install in same schema as postgis
SELECT INTO var_schema n.nspname
FROM pg_namespace n, pg_proc p
WHERE p.proname = 'postgis_full_version'
  AND n.oid = p.pronamespace
    LIMIT 1;
IF rec.name NOT IN('postgis_topology', 'postgis_tiger_geocoder')
				THEN
					sql := format(
							  'CREATE EXTENSION %1$I SCHEMA %2$I VERSION unpackaged;'
							  'ALTER EXTENSION %1$I UPDATE TO %3$I',
							  rec.name, var_schema, target_version);
ELSE
					sql := format(
							 'CREATE EXTENSION %1$I VERSION unpackaged;'
							 'ALTER EXTENSION %1$I UPDATE TO %2$I',
							 rec.name, target_version);
END IF;
				RAISE NOTICE 'Packaging and updating %', rec.name;
				RAISE DEBUG '%', sql;
EXECUTE sql;
ELSE
				RAISE DEBUG 'Skipping % (not in use)', rec.name;
END IF; --}
ELSE -- The code is already packaged, upgrade it --}{
			sql = format(
				'ALTER EXTENSION %1$I UPDATE TO "ANY";'
				'ALTER EXTENSION %1$I UPDATE TO %2$I',
				rec.name, target_version
				);
			RAISE NOTICE 'Updating extension % %', rec.name, rec.installed_version;
			RAISE DEBUG '%', sql;
EXECUTE sql;
END IF; --}

END LOOP; --}

RETURN format(
        'Upgrade to version %s completed, run SELECT postgis_full_version(); for details',
        target_version
    );


END
$$;

comment on function public.postgis_extensions_upgrade(text) is 'args: target_version=null - Packages and upgrades PostGIS extensions (e.g. postgis_raster,postgis_topology, postgis_sfcgal) to given or latest version.';

alter function public.postgis_extensions_upgrade(text) owner to postgres;

create function public.postgis_full_version() returns text
    immutable
    language plpgsql
as
$$
DECLARE
libver text;
	librev text;
	projver text;
	geosver text;
	geosver_compiled text;
	sfcgalver text;
	gdalver text := NULL;
	libxmlver text;
	liblwgeomver text;
	dbproc text;
	relproc text;
	fullver text;
	rast_lib_ver text := NULL;
	rast_scr_ver text := NULL;
	topo_scr_ver text := NULL;
	json_lib_ver text;
	protobuf_lib_ver text;
	wagyu_lib_ver text;
	sfcgal_lib_ver text;
	sfcgal_scr_ver text;
	pgsql_scr_ver text;
	pgsql_ver text;
	core_is_extension bool;
BEGIN
SELECT public.postgis_lib_version() INTO libver;
SELECT public.postgis_proj_version() INTO projver;
SELECT public.postgis_geos_version() INTO geosver;
SELECT public.postgis_geos_compiled_version() INTO geosver_compiled;
SELECT public.postgis_libjson_version() INTO json_lib_ver;
SELECT public.postgis_libprotobuf_version() INTO protobuf_lib_ver;
SELECT public.postgis_wagyu_version() INTO wagyu_lib_ver;
SELECT public._postgis_scripts_pgsql_version() INTO pgsql_scr_ver;
SELECT public._postgis_pgsql_version() INTO pgsql_ver;
BEGIN
SELECT public.postgis_gdal_version() INTO gdalver;
EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_gdal_version() not found.  Is raster support enabled and rtpostgis.sql installed?';
END;
BEGIN
SELECT public.postgis_sfcgal_full_version() INTO sfcgalver;
BEGIN
SELECT public.postgis_sfcgal_scripts_installed() INTO sfcgal_scr_ver;
EXCEPTION
			WHEN undefined_function THEN
				sfcgal_scr_ver := 'missing';
END;
EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_sfcgal_scripts_installed() not found. Is sfcgal support enabled and sfcgal.sql installed?';
END;
SELECT public.postgis_liblwgeom_version() INTO liblwgeomver;
SELECT public.postgis_libxml_version() INTO libxmlver;
SELECT public.postgis_scripts_installed() INTO dbproc;
SELECT public.postgis_scripts_released() INTO relproc;
SELECT public.postgis_lib_revision() INTO librev;
BEGIN
SELECT topology.postgis_topology_scripts_installed() INTO topo_scr_ver;
EXCEPTION
		WHEN undefined_function OR invalid_schema_name THEN
			RAISE DEBUG 'Function postgis_topology_scripts_installed() not found. Is topology support enabled and topology.sql installed?';
WHEN insufficient_privilege THEN
			RAISE NOTICE 'Topology support cannot be inspected. Is current user granted USAGE on schema "topology" ?';
WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_topology_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;
END;

BEGIN
SELECT postgis_raster_scripts_installed() INTO rast_scr_ver;
EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_raster_scripts_installed() not found. Is raster support enabled and rtpostgis.sql installed?';
WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_raster_scripts_installed() could not be called: % (%)', SQLERRM, SQLSTATE;
END;

BEGIN
SELECT public.postgis_raster_lib_version() INTO rast_lib_ver;
EXCEPTION
		WHEN undefined_function THEN
			RAISE DEBUG 'Function postgis_raster_lib_version() not found. Is raster support enabled and rtpostgis.sql installed?';
WHEN OTHERS THEN
			RAISE NOTICE 'Function postgis_raster_lib_version() could not be called: % (%)', SQLERRM, SQLSTATE;
END;

	fullver = 'POSTGIS="' || libver;

	IF  librev IS NOT NULL THEN
		fullver = fullver || ' ' || librev;
END IF;

	fullver = fullver || '"';

	IF EXISTS (
		SELECT * FROM pg_catalog.pg_extension
		WHERE extname = 'postgis')
	THEN
			fullver = fullver || ' [EXTENSION]';
			core_is_extension := true;
ELSE
			core_is_extension := false;
END IF;

	IF liblwgeomver != relproc THEN
		fullver = fullver || ' (liblwgeom version mismatch: "' || liblwgeomver || '")';
END IF;

	fullver = fullver || ' PGSQL="' || pgsql_scr_ver || '"';
	IF pgsql_scr_ver != pgsql_ver THEN
		fullver = fullver || ' (procs need upgrade for use with PostgreSQL "' || pgsql_ver || '")';
END IF;

	IF  geosver IS NOT NULL THEN
		fullver = fullver || ' GEOS="' || geosver || '"';
		IF (string_to_array(geosver, '.'))[1:2] != (string_to_array(geosver_compiled, '.'))[1:2]
		THEN
			fullver = format('%s (compiled against GEOS %s)', fullver, geosver_compiled);
END IF;
END IF;

	IF  sfcgalver IS NOT NULL THEN
		fullver = fullver || ' SFCGAL="' || sfcgalver || '"';
END IF;

	IF  projver IS NOT NULL THEN
		fullver = fullver || ' PROJ="' || projver || '"';
END IF;

	IF  gdalver IS NOT NULL THEN
		fullver = fullver || ' GDAL="' || gdalver || '"';
END IF;

	IF  libxmlver IS NOT NULL THEN
		fullver = fullver || ' LIBXML="' || libxmlver || '"';
END IF;

	IF json_lib_ver IS NOT NULL THEN
		fullver = fullver || ' LIBJSON="' || json_lib_ver || '"';
END IF;

	IF protobuf_lib_ver IS NOT NULL THEN
		fullver = fullver || ' LIBPROTOBUF="' || protobuf_lib_ver || '"';
END IF;

	IF wagyu_lib_ver IS NOT NULL THEN
		fullver = fullver || ' WAGYU="' || wagyu_lib_ver || '"';
END IF;

	IF dbproc != relproc THEN
		fullver = fullver || ' (core procs from "' || dbproc || '" need upgrade)';
END IF;

	IF topo_scr_ver IS NOT NULL THEN
		fullver = fullver || ' TOPOLOGY';
		IF topo_scr_ver != relproc THEN
			fullver = fullver || ' (topology procs from "' || topo_scr_ver || '" need upgrade)';
END IF;
		IF core_is_extension AND NOT EXISTS (
			SELECT * FROM pg_catalog.pg_extension
			WHERE extname = 'postgis_topology')
		THEN
				fullver = fullver || ' [UNPACKAGED!]';
END IF;
END IF;

	IF rast_lib_ver IS NOT NULL THEN
		fullver = fullver || ' RASTER';
		IF rast_lib_ver != relproc THEN
			fullver = fullver || ' (raster lib from "' || rast_lib_ver || '" need upgrade)';
END IF;
		IF core_is_extension AND NOT EXISTS (
			SELECT * FROM pg_catalog.pg_extension
			WHERE extname = 'postgis_raster')
		THEN
				fullver = fullver || ' [UNPACKAGED!]';
END IF;
END IF;

	IF rast_scr_ver IS NOT NULL AND rast_scr_ver != relproc THEN
		fullver = fullver || ' (raster procs from "' || rast_scr_ver || '" need upgrade)';
END IF;

	IF sfcgal_scr_ver IS NOT NULL AND sfcgal_scr_ver != relproc THEN
		fullver = fullver || ' (sfcgal procs from "' || sfcgal_scr_ver || '" need upgrade)';
END IF;

	-- Check for the presence of deprecated functions
	IF EXISTS ( SELECT oid FROM pg_catalog.pg_proc WHERE proname LIKE '%_deprecated_by_postgis_%' )
	THEN
		fullver = fullver || ' (deprecated functions exist, upgrade is not complete)';
END IF;

RETURN fullver;
END
$$;

comment on function public.postgis_full_version() is 'Reports full PostGIS version and build configuration infos.';

alter function public.postgis_full_version() owner to postgres;

create function public.box2d(geometry) returns box2d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.box2d(geometry) is 'args: geom - Returns a BOX2D representing the 2D extent of a geometry.';

alter function public.box2d(geometry) owner to postgres;

create function public.box3d(geometry) returns box3d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.box3d(geometry) is 'args: geom - Returns a BOX3D representing the 3D extent of a geometry.';

alter function public.box3d(geometry) owner to postgres;

create function public.box(geometry) returns box
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box(geometry) owner to postgres;

create function public.box2d(box3d) returns box2d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box2d(box3d) owner to postgres;

create function public.box3d(box2d) returns box3d
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box3d(box2d) owner to postgres;

create function public.box(box3d) returns box
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box(box3d) owner to postgres;

create function public.text(geometry) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.text(geometry) owner to postgres;

create function public.box3dtobox(box3d) returns box
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.box3dtobox(box3d) owner to postgres;

create function public.geometry(box2d) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(box2d) owner to postgres;

create function public.geometry(box3d) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(box3d) owner to postgres;

create function public.geometry(text) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(text) owner to postgres;

create function public.geometry(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(bytea) owner to postgres;

create function public.bytea(geometry) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.bytea(geometry) owner to postgres;

create function public.st_simplify(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_simplify(geometry, double precision) is 'args: geomA, tolerance - Returns a simplified version of a geometry, using the Douglas-Peucker algorithm.';

alter function public.st_simplify(geometry, double precision) owner to postgres;

create function public.st_simplify(geometry, double precision, boolean) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_simplify(geometry, double precision, boolean) is 'args: geomA, tolerance, preserveCollapsed - Returns a simplified version of a geometry, using the Douglas-Peucker algorithm.';

alter function public.st_simplify(geometry, double precision, boolean) owner to postgres;

create function public.st_simplifyvw(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_simplifyvw(geometry, double precision) is 'args: geomA, tolerance - Returns a simplified version of a geometry, using the Visvalingam-Whyatt algorithm';

alter function public.st_simplifyvw(geometry, double precision) owner to postgres;

create function public.st_seteffectivearea(geometry, double precision default '-1'::integer, integer default 1) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_seteffectivearea(geometry, double precision, integer) is 'args: geomA, threshold = 0, set_area = 1 - Sets the effective area for each vertex, using the Visvalingam-Whyatt algorithm.';

alter function public.st_seteffectivearea(geometry, double precision, integer) owner to postgres;

create function public.st_filterbym(geometry, double precision, double precision default NULL::double precision, boolean default false) returns geometry
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_filterbym(geometry, double precision, double precision, boolean) is 'args: geom, min, max = null, returnM = false - Removes vertices based on their M value';

alter function public.st_filterbym(geometry, double precision, double precision, boolean) owner to postgres;

create function public.st_chaikinsmoothing(geometry, integer default 1, boolean default false) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_chaikinsmoothing(geometry, integer, boolean) is 'args: geom, nIterations = 1, preserveEndPoints = false - Returns a smoothed version of a geometry, using the Chaikin algorithm';

alter function public.st_chaikinsmoothing(geometry, integer, boolean) owner to postgres;

create function public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision) is 'args: geomA, originX, originY, sizeX, sizeY - Snap all points of the input geometry to a regular grid.';

alter function public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_snaptogrid(geometry, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_SnapToGrid($1, 0, 0, $2, $3)$$;

comment on function public.st_snaptogrid(geometry, double precision, double precision) is 'args: geomA, sizeX, sizeY - Snap all points of the input geometry to a regular grid.';

alter function public.st_snaptogrid(geometry, double precision, double precision) owner to postgres;

create function public.st_snaptogrid(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_SnapToGrid($1, 0, 0, $2, $2)$$;

comment on function public.st_snaptogrid(geometry, double precision) is 'args: geomA, size - Snap all points of the input geometry to a regular grid.';

alter function public.st_snaptogrid(geometry, double precision) owner to postgres;

create function public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_snaptogrid(geometry, geometry, double precision, double precision, double precision, double precision) is 'args: geomA, pointOrigin, sizeX, sizeY, sizeZ, sizeM - Snap all points of the input geometry to a regular grid.';

alter function public.st_snaptogrid(geometry, geometry, double precision, double precision, double precision, double precision) owner to postgres;

create function public.st_segmentize(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_segmentize(geometry, double precision) is 'args: geom, max_segment_length - Returns a modified geometry/geography having no segment longer than a given distance.';

alter function public.st_segmentize(geometry, double precision) owner to postgres;

create function public.st_lineinterpolatepoint(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lineinterpolatepoint(geometry, double precision) is 'args: a_linestring, a_fraction - Returns a point interpolated along a line at a fractional location.';

alter function public.st_lineinterpolatepoint(geometry, double precision) owner to postgres;

create function public.st_lineinterpolatepoints(geometry, double precision, repeat boolean default true) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lineinterpolatepoints(geometry, double precision, boolean) is 'args: a_linestring, a_fraction, repeat - Returns points interpolated along a line at a fractional interval.';

alter function public.st_lineinterpolatepoints(geometry, double precision, boolean) owner to postgres;

create function public.st_linesubstring(geometry, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linesubstring(geometry, double precision, double precision) is 'args: a_linestring, startfraction, endfraction - Returns the part of a line between two fractional locations.';

alter function public.st_linesubstring(geometry, double precision, double precision) owner to postgres;

create function public.st_linelocatepoint(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linelocatepoint(geometry, geometry) is 'args: a_linestring, a_point - Returns the fractional location of the closest point on a line to a point.';

alter function public.st_linelocatepoint(geometry, geometry) owner to postgres;

create function public.st_addmeasure(geometry, double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_addmeasure(geometry, double precision, double precision) is 'args: geom_mline, measure_start, measure_end - Interpolates measures along a linear geometry.';

alter function public.st_addmeasure(geometry, double precision, double precision) owner to postgres;

create function public.st_closestpointofapproach(geometry, geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_closestpointofapproach(geometry, geometry) is 'args: track1, track2 - Returns a measure at the closest point of approach of two trajectories.';

alter function public.st_closestpointofapproach(geometry, geometry) owner to postgres;

create function public.st_distancecpa(geometry, geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_distancecpa(geometry, geometry) is 'args: track1, track2 - Returns the distance between the closest point of approach of two trajectories.';

alter function public.st_distancecpa(geometry, geometry) owner to postgres;

create function public.st_cpawithin(geometry, geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_cpawithin(geometry, geometry, double precision) is 'args: track1, track2, dist - Tests if the closest point of approach of two trajectoriesis within the specified distance.';

alter function public.st_cpawithin(geometry, geometry, double precision) owner to postgres;

create function public.st_isvalidtrajectory(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isvalidtrajectory(geometry) is 'args: line - Tests if the geometry is a valid trajectory.';

alter function public.st_isvalidtrajectory(geometry) owner to postgres;

create function public.st_intersection(geom1 geometry, geom2 geometry, gridsize double precision default '-1'::integer) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_intersection(geometry, geometry, double precision) is 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the shared portion of geometries A and B.';

alter function public.st_intersection(geometry, geometry, double precision) owner to postgres;

create function public.st_buffer(geom geometry, radius double precision, options text default ''::text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_buffer(geometry, double precision, text) is 'args: g1, radius_of_buffer, buffer_style_parameters = '' - Computes a geometry covering all points within a given distance from a geometry.';

alter function public.st_buffer(geometry, double precision, text) owner to postgres;

create function public.st_buffer(geom geometry, radius double precision, quadsegs integer) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$ SELECT public.ST_Buffer($1, $2, CAST('quad_segs='||CAST($3 AS text) as text)) $$;

comment on function public.st_buffer(geometry, double precision, integer) is 'args: g1, radius_of_buffer, num_seg_quarter_circle - Computes a geometry covering all points within a given distance from a geometry.';

alter function public.st_buffer(geometry, double precision, integer) owner to postgres;

create function public.st_minimumboundingradius(geometry, out center geometry, out radius double precision) returns record
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_minimumboundingradius(geometry, out geometry, out double precision) is 'args: geom - Returns the center point and radius of the smallest circle that contains a geometry.';

alter function public.st_minimumboundingradius(geometry, out geometry, out double precision) owner to postgres;

create function public.st_minimumboundingcircle(inputgeom geometry, segs_per_quarter integer default 48) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_minimumboundingcircle(geometry, integer) is 'args: geomA, num_segs_per_qt_circ=48 - Returns the smallest circle polygon that contains a geometry.';

alter function public.st_minimumboundingcircle(geometry, integer) owner to postgres;

create function public.st_orientedenvelope(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_orientedenvelope(geometry) is 'args: geom - Returns a minimum-area rectangle containing a geometry.';

alter function public.st_orientedenvelope(geometry) owner to postgres;

create function public.st_offsetcurve(line geometry, distance double precision, params text default ''::text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_offsetcurve(geometry, double precision, text) is 'args: line, signed_distance, style_parameters='' - Returns an offset line at a given distance and side from an input line.';

alter function public.st_offsetcurve(geometry, double precision, text) owner to postgres;

create function public.st_generatepoints(area geometry, npoints integer) returns geometry
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_generatepoints(geometry, integer) is 'args: g, npoints - Generates random points contained in a Polygon or MultiPolygon.';

alter function public.st_generatepoints(geometry, integer) owner to postgres;

create function public.st_generatepoints(area geometry, npoints integer, seed integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_generatepoints(geometry, integer, integer) is 'args: g, npoints, seed = 0 - Generates random points contained in a Polygon or MultiPolygon.';

alter function public.st_generatepoints(geometry, integer, integer) owner to postgres;

create function public.st_convexhull(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_convexhull(geometry) is 'args: geomA - Computes the convex hull of a geometry.';

alter function public.st_convexhull(geometry) owner to postgres;

create function public.st_simplifypreservetopology(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_simplifypreservetopology(geometry, double precision) is 'args: geomA, tolerance - Returns a simplified and valid version of a geometry, using the Douglas-Peucker algorithm.';

alter function public.st_simplifypreservetopology(geometry, double precision) owner to postgres;

create function public.st_isvalidreason(geometry) returns text
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isvalidreason(geometry) is 'args: geomA - Returns text stating if a geometry is valid, or a reason for invalidity.';

alter function public.st_isvalidreason(geometry) owner to postgres;

create function public.st_isvaliddetail(geom geometry, flags integer default 0) returns valid_detail
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isvaliddetail(geometry, integer) is 'args: geom, flags - Returns a valid_detail row stating if a geometry is valid or if not a reason and a location.';

alter function public.st_isvaliddetail(geometry, integer) owner to postgres;

create function public.st_isvalidreason(geometry, integer) returns text
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$
SELECT CASE WHEN valid THEN 'Valid Geometry' ELSE reason END FROM (
                                                                      SELECT (public.ST_isValidDetail($1, $2)).*
                                                                  ) foo
    $$;

comment on function public.st_isvalidreason(geometry, integer) is 'args: geomA, flags - Returns text stating if a geometry is valid, or a reason for invalidity.';

alter function public.st_isvalidreason(geometry, integer) owner to postgres;

create function public.st_isvalid(geometry, integer) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT (public.ST_isValidDetail($1, $2)).valid$$;

comment on function public.st_isvalid(geometry, integer) is 'args: g, flags - Tests if a geometry is well-formed in 2D.';

alter function public.st_isvalid(geometry, integer) owner to postgres;

create function public.st_hausdorffdistance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_hausdorffdistance(geometry, geometry) is 'args: g1, g2 - Returns the Hausdorff distance between two geometries.';

alter function public.st_hausdorffdistance(geometry, geometry) owner to postgres;

create function public.st_hausdorffdistance(geom1 geometry, geom2 geometry, double precision) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_hausdorffdistance(geometry, geometry, double precision) is 'args: g1, g2, densifyFrac - Returns the Hausdorff distance between two geometries.';

alter function public.st_hausdorffdistance(geometry, geometry, double precision) owner to postgres;

create function public.st_frechetdistance(geom1 geometry, geom2 geometry, double precision default '-1'::integer) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_frechetdistance(geometry, geometry, double precision) is 'args: g1, g2, densifyFrac = -1 - Returns the Fréchet distance between two geometries.';

alter function public.st_frechetdistance(geometry, geometry, double precision) owner to postgres;

create function public.st_maximuminscribedcircle(geometry, out center geometry, out nearest geometry, out radius double precision) returns record
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_maximuminscribedcircle(geometry, out geometry, out geometry, out double precision) is 'args: geom - Computes the largest circle contained within a geometry.';

alter function public.st_maximuminscribedcircle(geometry, out geometry, out geometry, out double precision) owner to postgres;

create function public.st_largestemptycircle(geom geometry, tolerance double precision default 0.0, boundary geometry default '0101000000000000000000F87F000000000000F87F'::geometry, out center geometry, out nearest geometry, out radius double precision) returns record
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_largestemptycircle(geometry, double precision, geometry, out geometry, out geometry, out double precision) is 'args: geom, tolerance=0.0, boundary=POINT EMPTY - Computes the largest circle not overlapping a geometry.';

alter function public.st_largestemptycircle(geometry, double precision, geometry, out geometry, out geometry, out double precision) owner to postgres;

create function public.st_difference(geom1 geometry, geom2 geometry, gridsize double precision default '-1.0'::numeric) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_difference(geometry, geometry, double precision) is 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the part of geometry A that does not intersect geometry B.';

alter function public.st_difference(geometry, geometry, double precision) owner to postgres;

create function public.st_boundary(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_boundary(geometry) is 'args: geomA - Returns the boundary of a geometry.';

alter function public.st_boundary(geometry) owner to postgres;

create function public.st_points(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_points(geometry) is 'args: geom - Returns a MultiPoint containing the coordinates of a geometry.';

alter function public.st_points(geometry) owner to postgres;

create function public.st_symdifference(geom1 geometry, geom2 geometry, gridsize double precision default '-1.0'::numeric) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_symdifference(geometry, geometry, double precision) is 'args: geomA, geomB, gridSize = -1 - Computes a geometry representing the portions of geometries A and B that do not intersect.';

alter function public.st_symdifference(geometry, geometry, double precision) owner to postgres;

create function public.st_symmetricdifference(geom1 geometry, geom2 geometry) returns geometry
    language sql
    as
$$SELECT ST_SymDifference(geom1, geom2, -1.0);$$;

alter function public.st_symmetricdifference(geometry, geometry) owner to postgres;

create function public.st_union(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_union(geometry, geometry) is 'args: g1, g2 - Computes a geometry representing the point-set union of the input geometries.';

alter function public.st_union(geometry, geometry) owner to postgres;

create function public.st_union(geom1 geometry, geom2 geometry, gridsize double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_union(geometry, geometry, double precision) is 'args: g1, g2, gridSize - Computes a geometry representing the point-set union of the input geometries.';

alter function public.st_union(geometry, geometry, double precision) owner to postgres;

create function public.st_unaryunion(geometry, gridsize double precision default '-1.0'::numeric) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_unaryunion(geometry, double precision) is 'args: geom, gridSize = -1 - Computes the union of the components of a single geometry.';

alter function public.st_unaryunion(geometry, double precision) owner to postgres;

create function public.st_removerepeatedpoints(geom geometry, tolerance double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_removerepeatedpoints(geometry, double precision) is 'args: geom, tolerance - Returns a version of a geometry with duplicate points removed.';

alter function public.st_removerepeatedpoints(geometry, double precision) owner to postgres;

create function public.st_clipbybox2d(geom geometry, box box2d) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_clipbybox2d(geometry, box2d) is 'args: geom, box - Computes the portion of a geometry falling within a rectangle.';

alter function public.st_clipbybox2d(geometry, box2d) owner to postgres;

create function public.st_subdivide(geom geometry, maxvertices integer default 256, gridsize double precision default '-1.0'::numeric) returns setof setof geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_subdivide(geometry, integer, double precision) is 'args: geom, max_vertices=256, gridSize = -1 - Computes a rectilinear subdivision of a geometry.';

alter function public.st_subdivide(geometry, integer, double precision) owner to postgres;

create function public.st_reduceprecision(geom geometry, gridsize double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_reduceprecision(geometry, double precision) is 'args: g, gridsize - Returns a valid geometry with points rounded to a grid tolerance.';

alter function public.st_reduceprecision(geometry, double precision) owner to postgres;

create function public.st_makevalid(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makevalid(geometry) is 'args: input - Attempts to make an invalid geometry valid without losing vertices.';

alter function public.st_makevalid(geometry) owner to postgres;

create function public.st_makevalid(geom geometry, params text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_makevalid(geometry, text) is 'args: input, params - Attempts to make an invalid geometry valid without losing vertices.';

alter function public.st_makevalid(geometry, text) owner to postgres;

create function public.st_cleangeometry(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_cleangeometry(geometry) owner to postgres;

create function public.st_split(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_split(geometry, geometry) is 'args: input, blade - Returns a collection of geometries created by splitting a geometry by another geometry.';

alter function public.st_split(geometry, geometry) owner to postgres;

create function public.st_sharedpaths(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_sharedpaths(geometry, geometry) is 'args: lineal1, lineal2 - Returns a collection containing paths shared by the two input linestrings/multilinestrings.';

alter function public.st_sharedpaths(geometry, geometry) owner to postgres;

create function public.st_snap(geom1 geometry, geom2 geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_snap(geometry, geometry, double precision) is 'args: input, reference, tolerance - Snap segments and vertices of input geometry to vertices of a reference geometry.';

alter function public.st_snap(geometry, geometry, double precision) owner to postgres;

create function public.st_relatematch(text, text) returns boolean
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_relatematch(text, text) owner to postgres;

create function public.st_node(g geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_node(geometry) is 'args: geom - Nodes a collection of lines.';

alter function public.st_node(geometry) owner to postgres;

create function public.st_delaunaytriangles(g1 geometry, tolerance double precision default 0.0, flags integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_delaunaytriangles(geometry, double precision, integer) is 'args: g1, tolerance = 0.0, flags = 0 - Returns the Delaunay triangulation of the vertices of a geometry.';

alter function public.st_delaunaytriangles(geometry, double precision, integer) owner to postgres;

create function public.st_triangulatepolygon(g1 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_triangulatepolygon(geometry) is 'args: geom - Computes the constrained Delaunay triangulation of polygons';

alter function public.st_triangulatepolygon(geometry) owner to postgres;

create function public._st_voronoi(g1 geometry, clip geometry default NULL::geometry, tolerance double precision default 0.0, return_polygons boolean default true) returns geometry
    immutable
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_voronoi(geometry, geometry, double precision, boolean) owner to postgres;

create function public.st_voronoipolygons(g1 geometry, tolerance double precision DEFAULT 0.0, extend_to geometry DEFAULT NULL::geometry) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public._ST_Voronoi(g1, extend_to, tolerance, true) $$;

comment on function public.st_voronoipolygons(geometry, double precision, geometry) is 'args: geom, tolerance = 0.0, extend_to = NULL - Returns the cells of the Voronoi diagram of the vertices of a geometry.';

alter function public.st_voronoipolygons(geometry, double precision, geometry) owner to postgres;

create function public.st_voronoilines(g1 geometry, tolerance double precision DEFAULT 0.0, extend_to geometry DEFAULT NULL::geometry) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public._ST_Voronoi(g1, extend_to, tolerance, false) $$;

comment on function public.st_voronoilines(geometry, double precision, geometry) is 'args: geom, tolerance = 0.0, extend_to = NULL - Returns the boundaries of the Voronoi diagram of the vertices of a geometry.';

alter function public.st_voronoilines(geometry, double precision, geometry) owner to postgres;

create function public.st_combinebbox(box3d, geometry) returns box3d
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_combinebbox(box3d, geometry) owner to postgres;

create function public.st_combinebbox(box3d, box3d) returns box3d
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_combinebbox(box3d, box3d) owner to postgres;

create function public.st_combinebbox(box2d, geometry) returns box2d
    immutable
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_combinebbox(box2d, geometry) owner to postgres;

create function public.st_collect(geom1 geometry, geom2 geometry) returns geometry
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_collect(geometry, geometry) is 'args: g1, g2 - Creates a GeometryCollection or Multi* geometry from a set of geometries.';

alter function public.st_collect(geometry, geometry) owner to postgres;

create function public.st_collect(geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_collect(geometry[]) is 'args: g1_array - Creates a GeometryCollection or Multi* geometry from a set of geometries.';

alter function public.st_collect(geometry[]) owner to postgres;

create function public.pgis_geometry_accum_transfn(internal, geometry) returns internal
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_accum_transfn(internal, geometry) owner to postgres;

create function public.pgis_geometry_accum_transfn(internal, geometry, double precision) returns internal
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_accum_transfn(internal, geometry, double precision) owner to postgres;

create function public.pgis_geometry_accum_transfn(internal, geometry, double precision, integer) returns internal
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_accum_transfn(internal, geometry, double precision, integer) owner to postgres;

create function public.pgis_geometry_collect_finalfn(internal) returns geometry
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_collect_finalfn(internal) owner to postgres;

create function public.pgis_geometry_polygonize_finalfn(internal) returns geometry
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_polygonize_finalfn(internal) owner to postgres;

create function public.pgis_geometry_clusterintersecting_finalfn(internal) returns geometry[]
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_clusterintersecting_finalfn(internal) owner to postgres;

create function public.pgis_geometry_clusterwithin_finalfn(internal) returns geometry[]
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_clusterwithin_finalfn(internal) owner to postgres;

create function public.pgis_geometry_makeline_finalfn(internal) returns geometry
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_makeline_finalfn(internal) owner to postgres;

create function public.pgis_geometry_coverageunion_finalfn(internal) returns geometry
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_coverageunion_finalfn(internal) owner to postgres;

create function public.pgis_geometry_union_parallel_transfn(internal, geometry) returns internal
    immutable
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_transfn(internal, geometry) owner to postgres;

create function public.pgis_geometry_union_parallel_transfn(internal, geometry, double precision) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_transfn(internal, geometry, double precision) owner to postgres;

create function public.pgis_geometry_union_parallel_combinefn(internal, internal) returns internal
    immutable
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_combinefn(internal, internal) owner to postgres;

create function public.pgis_geometry_union_parallel_serialfn(internal) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_serialfn(internal) owner to postgres;

create function public.pgis_geometry_union_parallel_deserialfn(bytea, internal) returns internal
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_deserialfn(bytea, internal) owner to postgres;

create function public.pgis_geometry_union_parallel_finalfn(internal) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_geometry_union_parallel_finalfn(internal) owner to postgres;

create function public.st_union(geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_union(geometry[]) is 'args: g1_array - Computes a geometry representing the point-set union of the input geometries.';

alter function public.st_union(geometry[]) owner to postgres;

create function public.st_coverageunion(geometry[]) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_coverageunion(geometry[]) owner to postgres;

create function public.st_coveragesimplify(geom geometry, tolerance double precision, simplifyboundary boolean default true) returns geometry
    immutable
    window
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_coveragesimplify(geometry, double precision, boolean) is 'args: geom, tolerance, simplifyBoundary = true - Window function that simplifies the edges of a polygonal coverage.';

alter function public.st_coveragesimplify(geometry, double precision, boolean) owner to postgres;

create function public.st_coverageinvalidedges(geom geometry, tolerance double precision default 0.0) returns geometry
    immutable
    window
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_coverageinvalidedges(geometry, double precision) is 'args: geom, tolerance = 0 - Window function that finds locations where polygons fail to form a valid coverage.';

alter function public.st_coverageinvalidedges(geometry, double precision) owner to postgres;

create function public.st_clusterkmeans(geom geometry, k integer, max_radius double precision default NULL::double precision) returns integer
    window
    strict
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_clusterkmeans(geometry, integer, double precision) is 'args: geom, number_of_clusters, max_radius - Window function that returns a cluster id for each input geometry using the K-means algorithm.';

alter function public.st_clusterkmeans(geometry, integer, double precision) owner to postgres;

create function public.st_relate(geom1 geometry, geom2 geometry) returns text
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_relate(geometry, geometry) owner to postgres;

create function public.st_relate(geom1 geometry, geom2 geometry, integer) returns text
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_relate(geometry, geometry, integer) owner to postgres;

create function public.st_relate(geom1 geometry, geom2 geometry, text) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_relate(geometry, geometry, text) owner to postgres;

create function public.st_disjoint(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_disjoint(geometry, geometry) owner to postgres;

create function public._st_linecrossingdirection(line1 geometry, line2 geometry) returns integer
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_linecrossingdirection(geometry, geometry) owner to postgres;

create function public._st_dwithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_dwithin(geometry, geometry, double precision) owner to postgres;

create function public._st_touches(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_touches(geometry, geometry) owner to postgres;

create function public._st_intersects(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_intersects(geometry, geometry) owner to postgres;

create function public._st_crosses(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_crosses(geometry, geometry) owner to postgres;

create function public._st_contains(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_contains(geometry, geometry) owner to postgres;

create function public._st_containsproperly(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_containsproperly(geometry, geometry) owner to postgres;

create function public._st_covers(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_covers(geometry, geometry) owner to postgres;

create function public._st_coveredby(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_coveredby(geometry, geometry) owner to postgres;

create function public._st_within(geom1 geometry, geom2 geometry) returns boolean
    immutable
    parallel safe
    language sql
as
$$SELECT public._ST_Contains($2,$1)$$;

alter function public._st_within(geometry, geometry) owner to postgres;

create function public._st_overlaps(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_overlaps(geometry, geometry) owner to postgres;

create function public._st_dfullywithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_dfullywithin(geometry, geometry, double precision) owner to postgres;

create function public._st_3ddwithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_3ddwithin(geometry, geometry, double precision) owner to postgres;

create function public._st_3ddfullywithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_3ddfullywithin(geometry, geometry, double precision) owner to postgres;

create function public._st_3dintersects(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_3dintersects(geometry, geometry) owner to postgres;

create function public._st_orderingequals(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_orderingequals(geometry, geometry) owner to postgres;

create function public._st_equals(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_equals(geometry, geometry) owner to postgres;

create function public.postgis_index_supportfn(internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_index_supportfn(internal) owner to postgres;

create function public.st_linecrossingdirection(line1 geometry, line2 geometry) returns integer
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_linecrossingdirection(geometry, geometry) owner to postgres;

create function public.st_dwithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_dwithin(geometry, geometry, double precision) owner to postgres;

create function public.st_touches(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_touches(geometry, geometry) owner to postgres;

create function public.st_intersects(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_intersects(geometry, geometry) owner to postgres;

create function public.st_crosses(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_crosses(geometry, geometry) owner to postgres;

create function public.st_contains(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_contains(geometry, geometry) owner to postgres;

create function public.st_containsproperly(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_containsproperly(geometry, geometry) owner to postgres;

create function public.st_within(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_within(geometry, geometry) owner to postgres;

create function public.st_covers(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_covers(geometry, geometry) owner to postgres;

create function public.st_coveredby(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_coveredby(geometry, geometry) owner to postgres;

create function public.st_overlaps(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_overlaps(geometry, geometry) owner to postgres;

create function public.st_dfullywithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_dfullywithin(geometry, geometry, double precision) owner to postgres;

create function public.st_3ddwithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_3ddwithin(geometry, geometry, double precision) owner to postgres;

create function public.st_3ddfullywithin(geom1 geometry, geom2 geometry, double precision) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_3ddfullywithin(geometry, geometry, double precision) owner to postgres;

create function public.st_3dintersects(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_3dintersects(geometry, geometry) owner to postgres;

create function public.st_orderingequals(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_orderingequals(geometry, geometry) owner to postgres;

create function public.st_equals(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_equals(geometry, geometry) owner to postgres;

create function public.st_isvalid(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isvalid(geometry) is 'args: g - Tests if a geometry is well-formed in 2D.';

alter function public.st_isvalid(geometry) owner to postgres;

create function public.st_minimumclearance(geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_minimumclearance(geometry) is 'args: g - Returns the minimum clearance of a geometry, a measure of a geometrys robustness.';

alter function public.st_minimumclearance(geometry) owner to postgres;

create function public.st_minimumclearanceline(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_minimumclearanceline(geometry) is 'args: g - Returns the two-point LineString spanning a geometrys minimum clearance.';

alter function public.st_minimumclearanceline(geometry) owner to postgres;

create function public.st_centroid(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_centroid(geometry) is 'args: g1 - Returns the geometric center of a geometry.';

alter function public.st_centroid(geometry) owner to postgres;

create function public.st_geometricmedian(g geometry, tolerance double precision default NULL::double precision, max_iter integer default 10000, fail_if_not_converged boolean default false) returns geometry
    immutable
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_geometricmedian(geometry, double precision, integer, boolean) is 'args: geom, tolerance = NULL, max_iter = 10000, fail_if_not_converged = false - Returns the geometric median of a MultiPoint.';

alter function public.st_geometricmedian(geometry, double precision, integer, boolean) owner to postgres;

create function public.st_isring(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isring(geometry) is 'args: g - Tests if a LineString is closed and simple.';

alter function public.st_isring(geometry) owner to postgres;

create function public.st_pointonsurface(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_pointonsurface(geometry) is 'args: g1 - Computes a point guaranteed to lie in a polygon, or on a geometry.';

alter function public.st_pointonsurface(geometry) owner to postgres;

create function public.st_issimple(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_issimple(geometry) is 'args: geomA - Tests if a geometry has no points of self-intersection or self-tangency.';

alter function public.st_issimple(geometry) owner to postgres;

create function public.st_iscollection(geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_iscollection(geometry) is 'args: g - Tests if a geometry is a geometry collection type.';

alter function public.st_iscollection(geometry) owner to postgres;

create function public.equals(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.equals(geometry, geometry) owner to postgres;

create function public._st_geomfromgml(text, integer) returns geometry
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_geomfromgml(text, integer) owner to postgres;

create function public.st_geomfromgml(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromgml(text, integer) owner to postgres;

create function public.st_geomfromgml(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public._ST_GeomFromGML($1, 0)$$;

alter function public.st_geomfromgml(text) owner to postgres;

create function public.st_gmltosql(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public._ST_GeomFromGML($1, 0)$$;

alter function public.st_gmltosql(text) owner to postgres;

create function public.st_gmltosql(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_gmltosql(text, integer) owner to postgres;

create function public.st_geomfromkml(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromkml(text) owner to postgres;

create function public.st_geomfrommarc21(marc21xml text) returns geometry
    immutable
    strict
    parallel safe
    cost 500
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfrommarc21(text) owner to postgres;

create function public.st_asmarc21(geom geometry, format text default 'hdddmmss'::text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asmarc21(geometry, text) owner to postgres;

create function public.st_geomfromgeojson(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromgeojson(text) owner to postgres;

create function public.st_geomfromgeojson(json) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_GeomFromGeoJson($1::text)$$;

alter function public.st_geomfromgeojson(json) owner to postgres;

create function public.st_geomfromgeojson(jsonb) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_GeomFromGeoJson($1::text)$$;

alter function public.st_geomfromgeojson(jsonb) owner to postgres;

create function public.postgis_libjson_version() returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_libjson_version() owner to postgres;

create function public.st_linefromencodedpolyline(txtin text, nprecision integer default 5) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_linefromencodedpolyline(text, integer) owner to postgres;

create function public.st_asencodedpolyline(geom geometry, nprecision integer default 5) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asencodedpolyline(geometry, integer) owner to postgres;

create function public.st_assvg(geom geometry, rel integer default 0, maxdecimaldigits integer default 15) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_assvg(geometry, integer, integer) owner to postgres;

create function public._st_asgml(integer, geometry, integer, integer, text, text) returns text
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_asgml(integer, geometry, integer, integer, text, text) owner to postgres;

create function public.st_asgml(geom geometry, maxdecimaldigits integer default 15, options integer default 0) returns text
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgml(geometry, integer, integer) owner to postgres;

create function public.st_asgml(version integer, geom geometry, maxdecimaldigits integer default 15, options integer default 0, nprefix text default NULL::text, id text default NULL::text) returns text
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgml(integer, geometry, integer, integer, text, text) owner to postgres;

create function public.st_askml(geom geometry, maxdecimaldigits integer default 15, nprefix text default ''::text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_askml(geometry, integer, text) owner to postgres;

create function public.st_asgeojson(geom geometry, maxdecimaldigits integer default 9, options integer default 8) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgeojson(geometry, integer, integer) owner to postgres;

create function public.st_asgeojson(r record, geom_column text default ''::text, maxdecimaldigits integer default 9, pretty_bool boolean default false) returns text
    stable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgeojson(record, text, integer, boolean) owner to postgres;

create function public.json(geometry) returns json
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.json(geometry) owner to postgres;

create function public.jsonb(geometry) returns jsonb
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.jsonb(geometry) owner to postgres;

create function public.pgis_asmvt_transfn(internal, anyelement) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_transfn(internal, anyelement) owner to postgres;

create function public.pgis_asmvt_transfn(internal, anyelement, text) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_transfn(internal, anyelement, text) owner to postgres;

create function public.pgis_asmvt_transfn(internal, anyelement, text, integer) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_transfn(internal, anyelement, text, integer) owner to postgres;

create function public.pgis_asmvt_transfn(internal, anyelement, text, integer, text) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_transfn(internal, anyelement, text, integer, text) owner to postgres;

create function public.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) owner to postgres;

create function public.pgis_asmvt_finalfn(internal) returns bytea
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_finalfn(internal) owner to postgres;

create function public.pgis_asmvt_combinefn(internal, internal) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_combinefn(internal, internal) owner to postgres;

create function public.pgis_asmvt_serialfn(internal) returns bytea
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_serialfn(internal) owner to postgres;

create function public.pgis_asmvt_deserialfn(bytea, internal) returns internal
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asmvt_deserialfn(bytea, internal) owner to postgres;

create function public.st_asmvtgeom(geom geometry, bounds box2d, extent integer default 4096, buffer integer default 256, clip_geom boolean default true) returns geometry
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asmvtgeom(geometry, box2d, integer, integer, boolean) owner to postgres;

create function public.postgis_libprotobuf_version() returns text
    immutable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_libprotobuf_version() owner to postgres;

create function public.pgis_asgeobuf_transfn(internal, anyelement) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asgeobuf_transfn(internal, anyelement) owner to postgres;

create function public.pgis_asgeobuf_transfn(internal, anyelement, text) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asgeobuf_transfn(internal, anyelement, text) owner to postgres;

create function public.pgis_asgeobuf_finalfn(internal) returns bytea
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asgeobuf_finalfn(internal) owner to postgres;

create function public.pgis_asflatgeobuf_transfn(internal, anyelement) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asflatgeobuf_transfn(internal, anyelement) owner to postgres;

create function public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) owner to postgres;

create function public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) returns internal
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) owner to postgres;

create function public.pgis_asflatgeobuf_finalfn(internal) returns bytea
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.pgis_asflatgeobuf_finalfn(internal) owner to postgres;

create function public.st_fromflatgeobuftotable(text, text, bytea) returns void
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_fromflatgeobuftotable(text, text, bytea) owner to postgres;

create function public.st_fromflatgeobuf(anyelement, bytea) returns setof setof anyelement
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

alter function public.st_fromflatgeobuf(anyelement, bytea) owner to postgres;

create function public.st_geohash(geom geometry, maxchars integer default 0) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geohash(geometry, integer) owner to postgres;

create function public._st_sortablehash(geom geometry) returns bigint
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_sortablehash(geometry) owner to postgres;

create function public.st_box2dfromgeohash(text, integer default NULL::integer) returns box2d
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_box2dfromgeohash(text, integer) owner to postgres;

create function public.st_pointfromgeohash(text, integer default NULL::integer) returns geometry
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_pointfromgeohash(text, integer) owner to postgres;

create function public.st_geomfromgeohash(text, integer DEFAULT NULL::integer) returns geometry
    immutable
    parallel safe
    cost 50
    language sql
as
$$ SELECT CAST(public.ST_Box2dFromGeoHash($1, $2) AS geometry); $$;

alter function public.st_geomfromgeohash(text, integer) owner to postgres;

create function public.st_numpoints(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_numpoints(geometry) is 'args: g1 - Returns the number of points in a LineString or CircularString.';

alter function public.st_numpoints(geometry) owner to postgres;

create function public.st_numgeometries(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_numgeometries(geometry) is 'args: geom - Returns the number of elements in a geometry collection.';

alter function public.st_numgeometries(geometry) owner to postgres;

create function public.st_geometryn(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_geometryn(geometry, integer) is 'args: geomA, n - Return an element of a geometry collection.';

alter function public.st_geometryn(geometry, integer) owner to postgres;

create function public.st_dimension(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_dimension(geometry) is 'args: g - Returns the topological dimension of a geometry.';

alter function public.st_dimension(geometry) owner to postgres;

create function public.st_exteriorring(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_exteriorring(geometry) is 'args: a_polygon - Returns a LineString representing the exterior ring of a Polygon.';

alter function public.st_exteriorring(geometry) owner to postgres;

create function public.st_numinteriorrings(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_numinteriorrings(geometry) is 'args: a_polygon - Returns the number of interior rings (holes) of a Polygon.';

alter function public.st_numinteriorrings(geometry) owner to postgres;

create function public.st_numinteriorring(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_numinteriorring(geometry) is 'args: a_polygon - Returns the number of interior rings (holes) of a Polygon. Aias for ST_NumInteriorRings';

alter function public.st_numinteriorring(geometry) owner to postgres;

create function public.st_interiorringn(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_interiorringn(geometry, integer) is 'args: a_polygon, n - Returns the Nth interior ring (hole) of a Polygon.';

alter function public.st_interiorringn(geometry, integer) owner to postgres;

create function public.geometrytype(geometry) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.geometrytype(geometry) is 'args: geomA - Returns the type of a geometry as text.';

alter function public.geometrytype(geometry) owner to postgres;

create function public.st_geometrytype(geometry) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_geometrytype(geometry) is 'args: g1 - Returns the SQL-MM type of a geometry as text.';

alter function public.st_geometrytype(geometry) owner to postgres;

create function public.st_pointn(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_pointn(geometry, integer) is 'args: a_linestring, n - Returns the Nth point in the first LineString or circular LineString in a geometry.';

alter function public.st_pointn(geometry, integer) owner to postgres;

create function public.st_numpatches(geometry) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'
                THEN public.ST_NumGeometries($1)
            ELSE NULL END
           $$;

comment on function public.st_numpatches(geometry) is 'args: g1 - Return the number of faces on a Polyhedral Surface. Will return null for non-polyhedral geometries.';

alter function public.st_numpatches(geometry) owner to postgres;

create function public.st_patchn(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.ST_GeometryType($1) = 'ST_PolyhedralSurface'
                THEN public.ST_GeometryN($1, $2)
            ELSE NULL END
           $$;

comment on function public.st_patchn(geometry, integer) is 'args: geomA, n - Returns the Nth geometry (face) of a PolyhedralSurface.';

alter function public.st_patchn(geometry, integer) owner to postgres;

create function public.st_startpoint(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_startpoint(geometry) is 'args: geomA - Returns the first point of a LineString.';

alter function public.st_startpoint(geometry) owner to postgres;

create function public.st_endpoint(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_endpoint(geometry) is 'args: g - Returns the last point of a LineString or CircularLineString.';

alter function public.st_endpoint(geometry) owner to postgres;

create function public.st_isclosed(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isclosed(geometry) is 'args: g - Tests if a LineStringss start and end points are coincident. For a PolyhedralSurface tests if it is closed (volumetric).';

alter function public.st_isclosed(geometry) owner to postgres;

create function public.st_isempty(geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_isempty(geometry) is 'args: geomA - Tests if a geometry is empty.';

alter function public.st_isempty(geometry) owner to postgres;

create function public.st_asbinary(geometry, text) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asbinary(geometry, text) owner to postgres;

create function public.st_asbinary(geometry) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asbinary(geometry) owner to postgres;

create function public.st_astext(geometry) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astext(geometry) owner to postgres;

create function public.st_astext(geometry, integer) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astext(geometry, integer) owner to postgres;

create function public.st_geometryfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geometryfromtext(text) owner to postgres;

create function public.st_geometryfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geometryfromtext(text, integer) owner to postgres;

create function public.st_geomfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromtext(text) owner to postgres;

create function public.st_geomfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromtext(text, integer) owner to postgres;

create function public.st_wkttosql(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_wkttosql(text) owner to postgres;

create function public.st_pointfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POINT'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_pointfromtext(text) owner to postgres;

create function public.st_pointfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POINT'
                THEN public.ST_GeomFromText($1, $2)
            ELSE NULL END
           $$;

alter function public.st_pointfromtext(text, integer) owner to postgres;

create function public.st_linefromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'LINESTRING'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_linefromtext(text) owner to postgres;

create function public.st_linefromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'LINESTRING'
                THEN public.ST_GeomFromText($1,$2)
            ELSE NULL END
           $$;

alter function public.st_linefromtext(text, integer) owner to postgres;

create function public.st_polyfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'POLYGON'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_polyfromtext(text) owner to postgres;

create function public.st_polyfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'POLYGON'
                THEN public.ST_GeomFromText($1, $2)
            ELSE NULL END
           $$;

alter function public.st_polyfromtext(text, integer) owner to postgres;

create function public.st_polygonfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_PolyFromText($1, $2)$$;

alter function public.st_polygonfromtext(text, integer) owner to postgres;

create function public.st_polygonfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_PolyFromText($1)$$;

alter function public.st_polygonfromtext(text) owner to postgres;

create function public.st_mlinefromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE
           WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTILINESTRING'
               THEN public.ST_GeomFromText($1,$2)
           ELSE NULL END
           $$;

alter function public.st_mlinefromtext(text, integer) owner to postgres;

create function public.st_mlinefromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTILINESTRING'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_mlinefromtext(text) owner to postgres;

create function public.st_multilinestringfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_MLineFromText($1)$$;

alter function public.st_multilinestringfromtext(text) owner to postgres;

create function public.st_multilinestringfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_MLineFromText($1, $2)$$;

alter function public.st_multilinestringfromtext(text, integer) owner to postgres;

create function public.st_mpointfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOINT'
                THEN ST_GeomFromText($1, $2)
            ELSE NULL END
           $$;

alter function public.st_mpointfromtext(text, integer) owner to postgres;

create function public.st_mpointfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOINT'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_mpointfromtext(text) owner to postgres;

create function public.st_multipointfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_MPointFromText($1)$$;

alter function public.st_multipointfromtext(text) owner to postgres;

create function public.st_mpolyfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromText($1,$2)
            ELSE NULL END
           $$;

alter function public.st_mpolyfromtext(text, integer) owner to postgres;

create function public.st_mpolyfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromText($1)
            ELSE NULL END
           $$;

alter function public.st_mpolyfromtext(text) owner to postgres;

create function public.st_multipolygonfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_MPolyFromText($1, $2)$$;

alter function public.st_multipolygonfromtext(text, integer) owner to postgres;

create function public.st_multipolygonfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$SELECT public.ST_MPolyFromText($1)$$;

alter function public.st_multipolygonfromtext(text) owner to postgres;

create function public.st_geomcollfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE
           WHEN public.geometrytype(public.ST_GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
               THEN public.ST_GeomFromText($1,$2)
           ELSE NULL END
           $$;

alter function public.st_geomcollfromtext(text, integer) owner to postgres;

create function public.st_geomcollfromtext(text) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT CASE
           WHEN public.geometrytype(public.ST_GeomFromText($1)) = 'GEOMETRYCOLLECTION'
               THEN public.ST_GeomFromText($1)
           ELSE NULL END
           $$;

alter function public.st_geomcollfromtext(text) owner to postgres;

create function public.st_geomfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geomfromwkb(bytea) owner to postgres;

create function public.st_geomfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT public.ST_SetSRID(public.ST_GeomFromWKB($1), $2)$$;

alter function public.st_geomfromwkb(bytea, integer) owner to postgres;

create function public.st_pointfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POINT'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_pointfromwkb(bytea, integer) owner to postgres;

create function public.st_pointfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POINT'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_pointfromwkb(bytea) owner to postgres;

create function public.st_linefromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_linefromwkb(bytea, integer) owner to postgres;

create function public.st_linefromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_linefromwkb(bytea) owner to postgres;

create function public.st_linestringfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'LINESTRING'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_linestringfromwkb(bytea, integer) owner to postgres;

create function public.st_linestringfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'LINESTRING'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_linestringfromwkb(bytea) owner to postgres;

create function public.st_polyfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'POLYGON'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_polyfromwkb(bytea, integer) owner to postgres;

create function public.st_polyfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_polyfromwkb(bytea) owner to postgres;

create function public.st_polygonfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'POLYGON'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_polygonfromwkb(bytea, integer) owner to postgres;

create function public.st_polygonfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'POLYGON'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_polygonfromwkb(bytea) owner to postgres;

create function public.st_mpointfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOINT'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_mpointfromwkb(bytea, integer) owner to postgres;

create function public.st_mpointfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_mpointfromwkb(bytea) owner to postgres;

create function public.st_multipointfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1,$2)) = 'MULTIPOINT'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_multipointfromwkb(bytea, integer) owner to postgres;

create function public.st_multipointfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOINT'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_multipointfromwkb(bytea) owner to postgres;

create function public.st_multilinefromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_multilinefromwkb(bytea) owner to postgres;

create function public.st_mlinefromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTILINESTRING'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_mlinefromwkb(bytea, integer) owner to postgres;

create function public.st_mlinefromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTILINESTRING'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_mlinefromwkb(bytea) owner to postgres;

create function public.st_mpolyfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_mpolyfromwkb(bytea, integer) owner to postgres;

create function public.st_mpolyfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_mpolyfromwkb(bytea) owner to postgres;

create function public.st_multipolyfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromWKB($1, $2)
            ELSE NULL END
           $$;

alter function public.st_multipolyfromwkb(bytea, integer) owner to postgres;

create function public.st_multipolyfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
                THEN public.ST_GeomFromWKB($1)
            ELSE NULL END
           $$;

alter function public.st_multipolyfromwkb(bytea) owner to postgres;

create function public.st_geomcollfromwkb(bytea, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE
           WHEN public.geometrytype(public.ST_GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
               THEN public.ST_GeomFromWKB($1, $2)
           ELSE NULL END
           $$;

alter function public.st_geomcollfromwkb(bytea, integer) owner to postgres;

create function public.st_geomcollfromwkb(bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT CASE
           WHEN public.geometrytype(public.ST_GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
               THEN public.ST_GeomFromWKB($1)
           ELSE NULL END
           $$;

alter function public.st_geomcollfromwkb(bytea) owner to postgres;

create function public._st_maxdistance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_maxdistance(geometry, geometry) owner to postgres;

create function public.st_maxdistance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public._ST_MaxDistance(public.ST_ConvexHull($1), public.ST_ConvexHull($2))$$;

comment on function public.st_maxdistance(geometry, geometry) is 'args: g1, g2 - Returns the 2D largest distance between two geometries in projected units.';

alter function public.st_maxdistance(geometry, geometry) owner to postgres;

create function public.st_closestpoint(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_closestpoint(geometry, geometry) is 'args: geom1, geom2 - Returns the 2D point on g1 that is closest to g2. This is the first point of the shortest line from one geometry to the other.';

alter function public.st_closestpoint(geometry, geometry) owner to postgres;

create function public.st_shortestline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_shortestline(geometry, geometry) is 'args: geom1, geom2 - Returns the 2D shortest line between two geometries';

alter function public.st_shortestline(geometry, geometry) owner to postgres;

create function public._st_longestline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_longestline(geometry, geometry) owner to postgres;

create function public.st_longestline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$SELECT public._ST_LongestLine(public.ST_ConvexHull($1), public.ST_ConvexHull($2))$$;

comment on function public.st_longestline(geometry, geometry) is 'args: g1, g2 - Returns the 2D longest line between two geometries.';

alter function public.st_longestline(geometry, geometry) owner to postgres;

create function public.st_swapordinates(geom geometry, ords cstring) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_swapordinates(geometry, cstring) is 'args: geom, ords - Returns a version of the given geometry with given ordinate values swapped.';

alter function public.st_swapordinates(geometry, cstring) owner to postgres;

create function public.st_flipcoordinates(geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_flipcoordinates(geometry) is 'args: geom - Returns a version of a geometry with X and Y axis flipped.';

alter function public.st_flipcoordinates(geometry) owner to postgres;

create function public.st_bdpolyfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    language plpgsql
as
$$
DECLARE
geomtext alias for $1;
	srid alias for $2;
	mline public.geometry;
	geom public.geometry;
BEGIN
	mline := public.ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
END IF;

	geom := public.ST_BuildArea(mline);

	IF public.GeometryType(geom) != 'POLYGON'
	THEN
		RAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';
END IF;

RETURN geom;
END;
$$;

alter function public.st_bdpolyfromtext(text, integer) owner to postgres;

create function public.st_bdmpolyfromtext(text, integer) returns geometry
    immutable
    strict
    parallel safe
    language plpgsql
as
$$
DECLARE
geomtext alias for $1;
	srid alias for $2;
	mline public.geometry;
	geom public.geometry;
BEGIN
	mline := public.ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
END IF;

	geom := public.ST_Multi(public.ST_BuildArea(mline));

RETURN geom;
END;
$$;

alter function public.st_bdmpolyfromtext(text, integer) owner to postgres;

create function public.unlockrows(text) returns integer
    strict
    language plpgsql
as
$$
DECLARE
ret int;
BEGIN

	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
END IF;

EXECUTE 'DELETE FROM authorization_table where authid = ' ||
        quote_literal($1);

GET DIAGNOSTICS ret = ROW_COUNT;

RETURN ret;
END;
$$;

comment on function public.unlockrows(text) is 'args: auth_token - Removes all locks held by an authorization token.';

alter function public.unlockrows(text) owner to postgres;

create function public.lockrow(text, text, text, text, timestamp without time zone) returns integer
    strict
    language plpgsql
as
$$
DECLARE
myschema alias for $1;
	mytable alias for $2;
	myrid   alias for $3;
	authid alias for $4;
	expires alias for $5;
	ret int;
	mytoid oid;
	myrec RECORD;

BEGIN

	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
END IF;

EXECUTE 'DELETE FROM authorization_table WHERE expires < now()';

SELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n
WHERE c.relname = mytable
  AND c.relnamespace = n.oid
  AND n.nspname = myschema;

-- RAISE NOTICE 'toid: %', mytoid;

FOR myrec IN SELECT * FROM authorization_table WHERE
        toid = mytoid AND rid = myrid
    LOOP
		IF myrec.authid != authid THEN
			RETURN 0;
ELSE
			RETURN 1;
END IF;
END LOOP;

EXECUTE 'INSERT INTO authorization_table VALUES ('||
        quote_literal(mytoid::text)||','||quote_literal(myrid)||
        ','||quote_literal(expires::text)||
        ','||quote_literal(authid) ||')';

GET DIAGNOSTICS ret = ROW_COUNT;

RETURN ret;
END;
$$;

comment on function public.lockrow(text, text, text, text, timestamp) is 'args: a_schema_name, a_table_name, a_row_key, an_auth_token, expire_dt - Sets lock/authorization for a row in a table.';

alter function public.lockrow(text, text, text, text, timestamp) owner to postgres;

create function public.lockrow(text, text, text, text) returns integer
    strict
    language sql
as
$$ SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); $$;

alter function public.lockrow(text, text, text, text) owner to postgres;

create function public.lockrow(text, text, text) returns integer
    strict
    language sql
as
$$ SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); $$;

comment on function public.lockrow(text, text, text) is 'args: a_table_name, a_row_key, an_auth_token - Sets lock/authorization for a row in a table.';

alter function public.lockrow(text, text, text) owner to postgres;

create function public.lockrow(text, text, text, timestamp without time zone) returns integer
    strict
    language sql
as
$$ SELECT LockRow(current_schema(), $1, $2, $3, $4); $$;

comment on function public.lockrow(text, text, text, timestamp) is 'args: a_table_name, a_row_key, an_auth_token, expire_dt - Sets lock/authorization for a row in a table.';

alter function public.lockrow(text, text, text, timestamp) owner to postgres;

create function public.addauth(text) returns boolean
    language plpgsql
as
$$
DECLARE
lockid alias for $1;
	okay boolean;
	myrec record;
BEGIN
	-- check to see if table exists
	--  if not, CREATE TEMP TABLE mylock (transid xid, lockcode text)
	okay := 'f';
FOR myrec IN SELECT * FROM pg_class WHERE relname = 'temp_lock_have_table' LOOP
		okay := 't';
END LOOP;
	IF (okay <> 't') THEN
		CREATE TEMP TABLE temp_lock_have_table (transid xid, lockcode text);
			-- this will only work from pgsql7.4 up
			-- ON COMMIT DELETE ROWS;
END IF;

	--  INSERT INTO mylock VALUES ( $1)
--	EXECUTE 'INSERT INTO temp_lock_have_table VALUES ( '||
--		quote_literal(getTransactionID()) || ',' ||
--		quote_literal(lockid) ||')';

INSERT INTO temp_lock_have_table VALUES (getTransactionID(), lockid);

RETURN true::boolean;
END;
$$;

comment on function public.addauth(text) is 'args: auth_token - Adds an authorization token to be used in the current transaction.';

alter function public.addauth(text) owner to postgres;

create function public.checkauth(text, text, text) returns integer
    language plpgsql
as
$$
DECLARE
schema text;
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
END IF;

	if ( $1 != '' ) THEN
		schema = $1;
ELSE
SELECT current_schema() into schema;
END IF;

	-- TODO: check for an already existing trigger ?

EXECUTE 'CREATE TRIGGER check_auth BEFORE UPDATE OR DELETE ON '
    || quote_ident(schema) || '.' || quote_ident($2)
    ||' FOR EACH ROW EXECUTE PROCEDURE CheckAuthTrigger('
    || quote_literal($3) || ')';

RETURN 0;
END;
$$;

comment on function public.checkauth(text, text, text) is 'args: a_schema_name, a_table_name, a_key_column_name - Creates a trigger on a table to prevent/allow updates and deletes of rows based on authorization token.';

alter function public.checkauth(text, text, text) owner to postgres;

create function public.checkauth(text, text) returns integer
    language sql
    as
$$ SELECT CheckAuth('', $1, $2) $$;

comment on function public.checkauth(text, text) is 'args: a_table_name, a_key_column_name - Creates a trigger on a table to prevent/allow updates and deletes of rows based on authorization token.';

alter function public.checkauth(text, text) owner to postgres;

create function public.checkauthtrigger() returns trigger
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.checkauthtrigger() owner to postgres;

create function public.gettransactionid() returns xid
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.gettransactionid() owner to postgres;

create function public.enablelongtransactions() returns text
    language plpgsql
as
$$
DECLARE
"query" text;
exists bool;
	rec RECORD;

BEGIN

exists = 'f';
FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table'
    LOOP
		exists = 't';
END LOOP;

	IF NOT exists
	THEN
		"query" = 'CREATE TABLE authorization_table (
			toid oid, -- table oid
			rid text, -- row id
			expires timestamp,
			authid text
		)';
EXECUTE "query";
END IF;

exists = 'f';
FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables'
    LOOP
		exists = 't';
END LOOP;

	IF NOT exists THEN
		"query" = 'CREATE VIEW authorized_tables AS ' ||
			'SELECT ' ||
			'n.nspname as schema, ' ||
			'c.relname as table, trim(' ||
			quote_literal(chr(92) || '000') ||
			' from t.tgargs) as id_column ' ||
			'FROM pg_trigger t, pg_class c, pg_proc p ' ||
			', pg_namespace n ' ||
			'WHERE p.proname = ' || quote_literal('checkauthtrigger') ||
			' AND c.relnamespace = n.oid' ||
			' AND t.tgfoid = p.oid and t.tgrelid = c.oid';
EXECUTE "query";
END IF;

RETURN 'Long transactions support enabled';
END;
$$;

comment on function public.enablelongtransactions() is 'Enables long transaction support.';

alter function public.enablelongtransactions() owner to postgres;

create function public.longtransactionsenabled() returns boolean
    language plpgsql
as
$$
DECLARE
rec RECORD;
BEGIN
FOR rec IN SELECT oid FROM pg_class WHERE relname = 'authorized_tables'
    LOOP
		return 't';
END LOOP;
return 'f';
END;
$$;

alter function public.longtransactionsenabled() owner to postgres;

create function public.disablelongtransactions() returns text
    language plpgsql
as
$$
DECLARE
rec RECORD;

BEGIN

	--
	-- Drop all triggers applied by CheckAuth()
	--
FOR rec IN
SELECT c.relname, t.tgname, t.tgargs FROM pg_trigger t, pg_class c, pg_proc p
WHERE p.proname = 'checkauthtrigger' and t.tgfoid = p.oid and t.tgrelid = c.oid
    LOOP
		EXECUTE 'DROP TRIGGER ' || quote_ident(rec.tgname) ||
			' ON ' || quote_ident(rec.relname);
END LOOP;

	--
	-- Drop the authorization_table table
	--
FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorization_table' LOOP
DROP TABLE authorization_table;
END LOOP;

	--
	-- Drop the authorized_tables view
	--
FOR rec IN SELECT * FROM pg_class WHERE relname = 'authorized_tables' LOOP
DROP VIEW authorized_tables;
END LOOP;

RETURN 'Long transactions support disabled';
END;
$$;

comment on function public.disablelongtransactions() is 'Disables long transaction support.';

alter function public.disablelongtransactions() owner to postgres;

create function public.geography_typmod_in(cstring[]) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_typmod_in(cstring[]) owner to postgres;

create function public.geography_typmod_out(integer) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_typmod_out(integer) owner to postgres;

create function public.geography_in(cstring, oid, integer) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_in(cstring, oid, integer) owner to postgres;

create function public.geography_out(geography) returns cstring
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_out(geography) owner to postgres;

create function public.geography_recv(internal, oid, integer) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_recv(internal, oid, integer) owner to postgres;

create function public.geography_send(geography) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_send(geography) owner to postgres;

create function public.geography_analyze(internal) returns boolean
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_analyze(internal) owner to postgres;

create function public.geography(geography, integer, boolean) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography(geography, integer, boolean) owner to postgres;

create function public.geography(bytea) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography(bytea) owner to postgres;

create function public.bytea(geography) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.bytea(geography) owner to postgres;

create function public.st_astext(geography) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astext(geography) owner to postgres;

create function public.st_astext(geography, integer) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_astext(geography, integer) owner to postgres;

create function public.st_astext(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public.ST_AsText($1::public.geometry);  $$;

alter function public.st_astext(text) owner to postgres;

create function public.st_geographyfromtext(text) returns geography
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geographyfromtext(text) owner to postgres;

create function public.st_geogfromtext(text) returns geography
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geogfromtext(text) owner to postgres;

create function public.st_geogfromwkb(bytea) returns geography
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geogfromwkb(bytea) owner to postgres;

create function public.postgis_typmod_dims(integer) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_typmod_dims(integer) owner to postgres;

create function public.postgis_typmod_srid(integer) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_typmod_srid(integer) owner to postgres;

create function public.postgis_typmod_type(integer) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.postgis_typmod_type(integer) owner to postgres;

create function public.geography(geometry) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography(geometry) owner to postgres;

create function public.geometry(geography) returns geometry
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry(geography) owner to postgres;

create function public.geography_gist_consistent(internal, geography, integer) returns boolean
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_consistent(internal, geography, integer) owner to postgres;

create function public.geography_gist_compress(internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_compress(internal) owner to postgres;

create function public.geography_gist_penalty(internal, internal, internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_penalty(internal, internal, internal) owner to postgres;

create function public.geography_gist_picksplit(internal, internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_picksplit(internal, internal) owner to postgres;

create function public.geography_gist_union(bytea, internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_union(bytea, internal) owner to postgres;

create function public.geography_gist_same(box2d, box2d, internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_same(box2d, box2d, internal) owner to postgres;

create function public.geography_gist_decompress(internal) returns internal
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_decompress(internal) owner to postgres;

create function public.geography_overlaps(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_overlaps(geography, geography) owner to postgres;

create function public.geography_distance_knn(geography, geography) returns double precision
    immutable
    strict
    parallel safe
    cost 100
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_distance_knn(geography, geography) owner to postgres;

create function public.geography_gist_distance(internal, geography, integer) returns double precision
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gist_distance(internal, geography, integer) owner to postgres;

create function public.overlaps_geog(gidx, geography) returns boolean
    immutable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_geog(gidx, geography) owner to postgres;

create function public.overlaps_geog(gidx, gidx) returns boolean
    immutable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_geog(gidx, gidx) owner to postgres;

create function public.overlaps_geog(geography, gidx) returns boolean
    immutable
    strict
    language sql
as
$$SELECT $2 OPERATOR(public.&&) $1;$$;

alter function public.overlaps_geog(geography, gidx) owner to postgres;

create function public.geog_brin_inclusion_add_value(internal, internal, internal, internal) returns boolean
    language c
    as
$$
begin
-- missing source code
end;
$$;

alter function public.geog_brin_inclusion_add_value(internal, internal, internal, internal) owner to postgres;

create function public.geography_lt(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_lt(geography, geography) owner to postgres;

create function public.geography_le(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_le(geography, geography) owner to postgres;

create function public.geography_gt(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_gt(geography, geography) owner to postgres;

create function public.geography_ge(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_ge(geography, geography) owner to postgres;

create function public.geography_eq(geography, geography) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_eq(geography, geography) owner to postgres;

create function public.geography_cmp(geography, geography) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_cmp(geography, geography) owner to postgres;

create function public.st_assvg(geog geography, rel integer default 0, maxdecimaldigits integer default 15) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_assvg(geography, integer, integer) owner to postgres;

create function public.st_assvg(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public.ST_AsSVG($1::public.geometry,0,15);  $$;

alter function public.st_assvg(text) owner to postgres;

create function public.st_asgml(version integer, geog geography, maxdecimaldigits integer default 15, options integer default 0, nprefix text default 'gml'::text, id text default ''::text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgml(integer, geography, integer, integer, text, text) owner to postgres;

create function public.st_asgml(geog geography, maxdecimaldigits integer default 15, options integer default 0, nprefix text default 'gml'::text, id text default ''::text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgml(geography, integer, integer, text, text) owner to postgres;

create function public.st_asgml(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public._ST_AsGML(2,$1::public.geometry,15,0, NULL, NULL);  $$;

alter function public.st_asgml(text) owner to postgres;

create function public.st_askml(geog geography, maxdecimaldigits integer default 15, nprefix text default ''::text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_askml(geography, integer, text) owner to postgres;

create function public.st_askml(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public.ST_AsKML($1::public.geometry, 15);  $$;

alter function public.st_askml(text) owner to postgres;

create function public.st_asgeojson(geog geography, maxdecimaldigits integer default 9, options integer default 0) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asgeojson(geography, integer, integer) owner to postgres;

create function public.st_asgeojson(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public.ST_AsGeoJson($1::public.geometry, 9, 0);  $$;

alter function public.st_asgeojson(text) owner to postgres;

create function public.st_distance(geog1 geography, geog2 geography, use_spheroid boolean default true) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_distance(geography, geography, boolean) is 'args: geog1, geog2, use_spheroid = true - Returns the distance between two geometry or geography values.';

alter function public.st_distance(geography, geography, boolean) owner to postgres;

create function public.st_distance(text, text) returns double precision
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Distance($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_distance(text, text) owner to postgres;

create function public._st_expand(geography, double precision) returns geography
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_expand(geography, double precision) owner to postgres;

create function public._st_distanceuncached(geography, geography, double precision, boolean) returns double precision
    immutable
    strict
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_distanceuncached(geography, geography, double precision, boolean) owner to postgres;

create function public._st_distanceuncached(geography, geography, boolean) returns double precision
    immutable
    strict
    language sql
as
$$SELECT public._ST_DistanceUnCached($1, $2, 0.0, $3)$$;

alter function public._st_distanceuncached(geography, geography, boolean) owner to postgres;

create function public._st_distanceuncached(geography, geography) returns double precision
    immutable
    strict
    language sql
as
$$SELECT public._ST_DistanceUnCached($1, $2, 0.0, true)$$;

alter function public._st_distanceuncached(geography, geography) owner to postgres;

create function public._st_distancetree(geography, geography, double precision, boolean) returns double precision
    immutable
    strict
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_distancetree(geography, geography, double precision, boolean) owner to postgres;

create function public._st_distancetree(geography, geography) returns double precision
    immutable
    strict
    language sql
as
$$SELECT public._ST_DistanceTree($1, $2, 0.0, true)$$;

alter function public._st_distancetree(geography, geography) owner to postgres;

create function public._st_dwithinuncached(geography, geography, double precision, boolean) returns boolean
    immutable
    strict
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_dwithinuncached(geography, geography, double precision, boolean) owner to postgres;

create function public._st_dwithinuncached(geography, geography, double precision) returns boolean
    immutable
    language sql
as
$$SELECT $1 OPERATOR(public.&&) public._ST_Expand($2,$3) AND $2 OPERATOR(public.&&) public._ST_Expand($1,$3) AND public._ST_DWithinUnCached($1, $2, $3, true)$$;

alter function public._st_dwithinuncached(geography, geography, double precision) owner to postgres;

create function public.st_area(geog geography, use_spheroid boolean default true) returns double precision
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_area(geography, boolean) is 'args: geog, use_spheroid = true - Returns the area of a polygonal geometry.';

alter function public.st_area(geography, boolean) owner to postgres;

create function public.st_area(text) returns double precision
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Area($1::public.geometry);  $$;

alter function public.st_area(text) owner to postgres;

create function public.st_length(geog geography, use_spheroid boolean default true) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_length(geography, boolean) is 'args: geog, use_spheroid = true - Returns the 2D length of a linear geometry.';

alter function public.st_length(geography, boolean) owner to postgres;

create function public.st_length(text) returns double precision
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Length($1::public.geometry);  $$;

alter function public.st_length(text) owner to postgres;

create function public.st_project(geog geography, distance double precision, azimuth double precision) returns geography
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_project(geography, double precision, double precision) is 'args: g1, distance, azimuth - Returns a point projected from a start point by a distance and bearing (azimuth).';

alter function public.st_project(geography, double precision, double precision) owner to postgres;

create function public.st_project(geog_from geography, geog_to geography, distance double precision) returns geography
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_project(geography, geography, double precision) is 'args: g1, g2, distance - Returns a point projected from a start point by a distance and bearing (azimuth).';

alter function public.st_project(geography, geography, double precision) owner to postgres;

create function public.st_azimuth(geog1 geography, geog2 geography) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_azimuth(geography, geography) is 'args: origin, target - Returns the north-based azimuth of a line between two points.';

alter function public.st_azimuth(geography, geography) owner to postgres;

create function public.st_perimeter(geog geography, use_spheroid boolean default true) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_perimeter(geography, boolean) is 'args: geog, use_spheroid = true - Returns the length of the boundary of a polygonal geometry or geography.';

alter function public.st_perimeter(geography, boolean) owner to postgres;

create function public._st_pointoutside(geography) returns geography
    immutable
    strict
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_pointoutside(geography) owner to postgres;

create function public.st_segmentize(geog geography, max_segment_length double precision) returns geography
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_segmentize(geography, double precision) is 'args: geog, max_segment_length - Returns a modified geometry/geography having no segment longer than a given distance.';

alter function public.st_segmentize(geography, double precision) owner to postgres;

create function public._st_bestsrid(geography, geography) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_bestsrid(geography, geography) owner to postgres;

create function public._st_bestsrid(geography) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_bestsrid(geography) owner to postgres;

create function public.st_asbinary(geography) returns bytea
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asbinary(geography) owner to postgres;

create function public.st_asbinary(geography, text) returns bytea
    immutable
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asbinary(geography, text) owner to postgres;

create function public.st_asewkt(geography) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkt(geography) owner to postgres;

create function public.st_asewkt(geography, integer) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_asewkt(geography, integer) owner to postgres;

create function public.st_asewkt(text) returns text
    immutable
    strict
    parallel safe
    cost 250
    language sql
as
$$ SELECT public.ST_AsEWKT($1::public.geometry);  $$;

alter function public.st_asewkt(text) owner to postgres;

create function public.geometrytype(geography) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometrytype(geography) owner to postgres;

create function public.st_summary(geography) returns text
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_summary(geography) is 'args: g - Returns a text summary of the contents of a geometry.';

alter function public.st_summary(geography) owner to postgres;

create function public.st_geohash(geog geography, maxchars integer default 0) returns text
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_geohash(geography, integer) owner to postgres;

create function public.st_srid(geog geography) returns integer
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_srid(geography) owner to postgres;

create function public.st_setsrid(geog geography, srid integer) returns geography
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_setsrid(geography, integer) owner to postgres;

create function public.st_centroid(geography, use_spheroid boolean default true) returns geography
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_centroid(geography, boolean) is 'args: g1, use_spheroid = true - Returns the geometric center of a geometry.';

alter function public.st_centroid(geography, boolean) owner to postgres;

create function public.st_centroid(text) returns geometry
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Centroid($1::public.geometry);  $$;

alter function public.st_centroid(text) owner to postgres;

create function public._st_covers(geog1 geography, geog2 geography) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_covers(geography, geography) owner to postgres;

create function public._st_dwithin(geog1 geography, geog2 geography, tolerance double precision, use_spheroid boolean default true) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_dwithin(geography, geography, double precision, boolean) owner to postgres;

create function public._st_coveredby(geog1 geography, geog2 geography) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_coveredby(geography, geography) owner to postgres;

create function public.st_covers(geog1 geography, geog2 geography) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_covers(geography, geography) owner to postgres;

create function public.st_dwithin(geog1 geography, geog2 geography, tolerance double precision, use_spheroid boolean default true) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_dwithin(geography, geography, double precision, boolean) owner to postgres;

create function public.st_coveredby(geog1 geography, geog2 geography) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_coveredby(geography, geography) owner to postgres;

create function public.st_intersects(geog1 geography, geog2 geography) returns boolean
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_intersects(geography, geography) owner to postgres;

create function public.st_buffer(geography, double precision) returns geography
    immutable
    strict
    parallel safe
    language sql
as
$$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2), public.ST_SRID($1)))$$;

alter function public.st_buffer(geography, double precision) owner to postgres;

create function public.st_buffer(geography, double precision, integer) returns geography
    immutable
    strict
    parallel safe
    language sql
as
$$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))$$;

comment on function public.st_buffer(geography, double precision, integer) is 'args: g1, radius_of_buffer, num_seg_quarter_circle - Computes a geometry covering all points within a given distance from a geometry.';

alter function public.st_buffer(geography, double precision, integer) owner to postgres;

create function public.st_buffer(geography, double precision, text) returns geography
    immutable
    strict
    parallel safe
    language sql
as
$$SELECT public.geography(public.ST_Transform(public.ST_Buffer(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1)), $2, $3), public.ST_SRID($1)))$$;

comment on function public.st_buffer(geography, double precision, text) is 'args: g1, radius_of_buffer, buffer_style_parameters - Computes a geometry covering all points within a given distance from a geometry.';

alter function public.st_buffer(geography, double precision, text) owner to postgres;

create function public.st_buffer(text, double precision) returns geometry
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Buffer($1::public.geometry, $2);  $$;

alter function public.st_buffer(text, double precision) owner to postgres;

create function public.st_buffer(text, double precision, integer) returns geometry
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Buffer($1::public.geometry, $2, $3);  $$;

alter function public.st_buffer(text, double precision, integer) owner to postgres;

create function public.st_buffer(text, double precision, text) returns geometry
    immutable
    strict
    parallel safe
    language sql
as
$$ SELECT public.ST_Buffer($1::public.geometry, $2, $3);  $$;

alter function public.st_buffer(text, double precision, text) owner to postgres;

create function public.st_intersection(geography, geography) returns geography
    immutable
    strict
    parallel safe
    language sql
as
$$SELECT public.geography(public.ST_Transform(public.ST_Intersection(public.ST_Transform(public.geometry($1), public._ST_BestSRID($1, $2)), public.ST_Transform(public.geometry($2), public._ST_BestSRID($1, $2))), public.ST_SRID($1)))$$;

comment on function public.st_intersection(geography, geography) is 'args: geogA, geogB - Computes a geometry representing the shared portion of geometries A and B.';

alter function public.st_intersection(geography, geography) owner to postgres;

create function public.st_intersection(text, text) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$ SELECT public.ST_Intersection($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_intersection(text, text) owner to postgres;

create function public.st_covers(text, text) returns boolean
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_Covers($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_covers(text, text) owner to postgres;

create function public.st_coveredby(text, text) returns boolean
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_CoveredBy($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_coveredby(text, text) owner to postgres;

create function public.st_dwithin(text, text, double precision) returns boolean
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_DWithin($1::public.geometry, $2::public.geometry, $3);  $$;

alter function public.st_dwithin(text, text, double precision) owner to postgres;

create function public.st_intersects(text, text) returns boolean
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_Intersects($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_intersects(text, text) owner to postgres;

create function public.st_closestpoint(geography, geography, use_spheroid boolean default true) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_closestpoint(geography, geography, boolean) is 'args: geom1, geom2, use_spheroid = true - Returns the 2D point on g1 that is closest to g2. This is the first point of the shortest line from one geometry to the other.';

alter function public.st_closestpoint(geography, geography, boolean) owner to postgres;

create function public.st_closestpoint(text, text) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_ClosestPoint($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_closestpoint(text, text) owner to postgres;

create function public.st_shortestline(geography, geography, use_spheroid boolean default true) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_shortestline(geography, geography, boolean) is 'args: geom1, geom2, use_spheroid = true - Returns the 2D shortest line between two geometries';

alter function public.st_shortestline(geography, geography, boolean) owner to postgres;

create function public.st_shortestline(text, text) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_ShortestLine($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_shortestline(text, text) owner to postgres;

create function public.st_linesubstring(geography, double precision, double precision) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linesubstring(geography, double precision, double precision) is 'args: a_linestring, startfraction, endfraction - Returns the part of a line between two fractional locations.';

alter function public.st_linesubstring(geography, double precision, double precision) owner to postgres;

create function public.st_linesubstring(text, double precision, double precision) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_LineSubstring($1::public.geometry, $2, $3);  $$;

alter function public.st_linesubstring(text, double precision, double precision) owner to postgres;

create function public.st_linelocatepoint(geography, geography, use_spheroid boolean default true) returns double precision
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linelocatepoint(geography, geography, boolean) is 'args: a_linestring, a_point, use_spheroid = true - Returns the fractional location of the closest point on a line to a point.';

alter function public.st_linelocatepoint(geography, geography, boolean) owner to postgres;

create function public.st_linelocatepoint(text, text) returns double precision
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_LineLocatePoint($1::public.geometry, $2::public.geometry);  $$;

alter function public.st_linelocatepoint(text, text) owner to postgres;

create function public.st_lineinterpolatepoints(geography, double precision, use_spheroid boolean default true, repeat boolean default true) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lineinterpolatepoints(geography, double precision, boolean, boolean) is 'args: a_linestring, a_fraction, use_spheroid = true, repeat = true - Returns points interpolated along a line at a fractional interval.';

alter function public.st_lineinterpolatepoints(geography, double precision, boolean, boolean) owner to postgres;

create function public.st_lineinterpolatepoints(text, double precision) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_LineInterpolatePoints($1::public.geometry, $2);  $$;

alter function public.st_lineinterpolatepoints(text, double precision) owner to postgres;

create function public.st_lineinterpolatepoint(geography, double precision, use_spheroid boolean default true) returns geography
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_lineinterpolatepoint(geography, double precision, boolean) is 'args: a_linestring, a_fraction, use_spheroid = true - Returns a point interpolated along a line at a fractional location.';

alter function public.st_lineinterpolatepoint(geography, double precision, boolean) owner to postgres;

create function public.st_lineinterpolatepoint(text, double precision) returns geometry
    immutable
    parallel safe
    language sql
as
$$ SELECT public.ST_LineInterpolatePoint($1::public.geometry, $2);  $$;

alter function public.st_lineinterpolatepoint(text, double precision) owner to postgres;

create function public.st_distancesphere(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    language sql
as
$$select public.ST_distance( public.geography($1), public.geography($2),false)$$;

alter function public.st_distancesphere(geometry, geometry) owner to postgres;

create function public.st_distancesphere(geom1 geometry, geom2 geometry, radius double precision) returns double precision
    immutable
    strict
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_distancesphere(geometry, geometry, double precision) is 'args: geomlonlatA, geomlonlatB, radius=6371008 - Returns minimum distance in meters between two lon/lat geometries using a spherical earth model.';

alter function public.st_distancesphere(geometry, geometry, double precision) owner to postgres;

create function public.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean DEFAULT true) returns character varying
    immutable
    strict
    parallel safe
    cost 5000
    language sql
as
$$
SELECT CASE WHEN $3 THEN new_name ELSE old_name END As geomname
FROM
    ( VALUES
          ('GEOMETRY', 'Geometry', 2),
          ('GEOMETRY', 'GeometryZ', 3),
          ('GEOMETRYM', 'GeometryM', 3),
          ('GEOMETRY', 'GeometryZM', 4),

          ('GEOMETRYCOLLECTION', 'GeometryCollection', 2),
          ('GEOMETRYCOLLECTION', 'GeometryCollectionZ', 3),
          ('GEOMETRYCOLLECTIONM', 'GeometryCollectionM', 3),
          ('GEOMETRYCOLLECTION', 'GeometryCollectionZM', 4),

          ('POINT', 'Point', 2),
          ('POINT', 'PointZ', 3),
          ('POINTM','PointM', 3),
          ('POINT', 'PointZM', 4),

          ('MULTIPOINT','MultiPoint', 2),
          ('MULTIPOINT','MultiPointZ', 3),
          ('MULTIPOINTM','MultiPointM', 3),
          ('MULTIPOINT','MultiPointZM', 4),

          ('POLYGON', 'Polygon', 2),
          ('POLYGON', 'PolygonZ', 3),
          ('POLYGONM', 'PolygonM', 3),
          ('POLYGON', 'PolygonZM', 4),

          ('MULTIPOLYGON', 'MultiPolygon', 2),
          ('MULTIPOLYGON', 'MultiPolygonZ', 3),
          ('MULTIPOLYGONM', 'MultiPolygonM', 3),
          ('MULTIPOLYGON', 'MultiPolygonZM', 4),

          ('MULTILINESTRING', 'MultiLineString', 2),
          ('MULTILINESTRING', 'MultiLineStringZ', 3),
          ('MULTILINESTRINGM', 'MultiLineStringM', 3),
          ('MULTILINESTRING', 'MultiLineStringZM', 4),

          ('LINESTRING', 'LineString', 2),
          ('LINESTRING', 'LineStringZ', 3),
          ('LINESTRINGM', 'LineStringM', 3),
          ('LINESTRING', 'LineStringZM', 4),

          ('CIRCULARSTRING', 'CircularString', 2),
          ('CIRCULARSTRING', 'CircularStringZ', 3),
          ('CIRCULARSTRINGM', 'CircularStringM' ,3),
          ('CIRCULARSTRING', 'CircularStringZM', 4),

          ('COMPOUNDCURVE', 'CompoundCurve', 2),
          ('COMPOUNDCURVE', 'CompoundCurveZ', 3),
          ('COMPOUNDCURVEM', 'CompoundCurveM', 3),
          ('COMPOUNDCURVE', 'CompoundCurveZM', 4),

          ('CURVEPOLYGON', 'CurvePolygon', 2),
          ('CURVEPOLYGON', 'CurvePolygonZ', 3),
          ('CURVEPOLYGONM', 'CurvePolygonM', 3),
          ('CURVEPOLYGON', 'CurvePolygonZM', 4),

          ('MULTICURVE', 'MultiCurve', 2),
          ('MULTICURVE', 'MultiCurveZ', 3),
          ('MULTICURVEM', 'MultiCurveM', 3),
          ('MULTICURVE', 'MultiCurveZM', 4),

          ('MULTISURFACE', 'MultiSurface', 2),
          ('MULTISURFACE', 'MultiSurfaceZ', 3),
          ('MULTISURFACEM', 'MultiSurfaceM', 3),
          ('MULTISURFACE', 'MultiSurfaceZM', 4),

          ('POLYHEDRALSURFACE', 'PolyhedralSurface', 2),
          ('POLYHEDRALSURFACE', 'PolyhedralSurfaceZ', 3),
          ('POLYHEDRALSURFACEM', 'PolyhedralSurfaceM', 3),
          ('POLYHEDRALSURFACE', 'PolyhedralSurfaceZM', 4),

          ('TRIANGLE', 'Triangle', 2),
          ('TRIANGLE', 'TriangleZ', 3),
          ('TRIANGLEM', 'TriangleM', 3),
          ('TRIANGLE', 'TriangleZM', 4),

          ('TIN', 'Tin', 2),
          ('TIN', 'TinZ', 3),
          ('TINM', 'TinM', 3),
          ('TIN', 'TinZM', 4) )
        As g(old_name, new_name, coord_dimension)
WHERE (upper(old_name) = upper($1) OR upper(new_name) = upper($1))
  AND coord_dimension = $2;
$$;

alter function public.postgis_type_name(varchar, integer, boolean) owner to postgres;

create function public.postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text) returns integer
    stable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT replace(replace(split_part(s.consrc, ' = ', 2), ')', ''), '(', '')::integer
FROM pg_class c, pg_namespace n, pg_attribute a
   , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
      FROM pg_constraint) AS s
WHERE n.nspname = $1
  AND c.relname = $2
  AND a.attname = $3
  AND a.attrelid = c.oid
  AND s.connamespace = n.oid
  AND s.conrelid = c.oid
  AND a.attnum = ANY (s.conkey)
  AND s.consrc LIKE '%srid(% = %';
$$;

alter function public.postgis_constraint_srid(text, text, text) owner to postgres;

create function public.postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text) returns integer
    stable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT  replace(split_part(s.consrc, ' = ', 2), ')', '')::integer
FROM pg_class c, pg_namespace n, pg_attribute a
   , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
      FROM pg_constraint) AS s
WHERE n.nspname = $1
  AND c.relname = $2
  AND a.attname = $3
  AND a.attrelid = c.oid
  AND s.connamespace = n.oid
  AND s.conrelid = c.oid
  AND a.attnum = ANY (s.conkey)
  AND s.consrc LIKE '%ndims(% = %';
$$;

alter function public.postgis_constraint_dims(text, text, text) owner to postgres;

create function public.postgis_constraint_type(geomschema text, geomtable text, geomcolumn text) returns character varying
    stable
    strict
    parallel safe
    cost 250
    language sql
as
$$
SELECT  replace(split_part(s.consrc, '''', 2), ')', '')::varchar
FROM pg_class c, pg_namespace n, pg_attribute a
   , (SELECT connamespace, conrelid, conkey, pg_get_constraintdef(oid) As consrc
      FROM pg_constraint) AS s
WHERE n.nspname = $1
  AND c.relname = $2
  AND a.attname = $3
  AND a.attrelid = c.oid
  AND s.connamespace = n.oid
  AND s.conrelid = c.oid
  AND a.attnum = ANY (s.conkey)
  AND s.consrc LIKE '%geometrytype(% = %';
$$;

alter function public.postgis_constraint_type(text, text, text) owner to postgres;

create function public.st_3ddistance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3ddistance(geometry, geometry) is 'args: g1, g2 - Returns the 3D cartesian minimum distance (based on spatial ref) between two geometries in projected units.';

alter function public.st_3ddistance(geometry, geometry) owner to postgres;

create function public.st_3dmaxdistance(geom1 geometry, geom2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dmaxdistance(geometry, geometry) is 'args: g1, g2 - Returns the 3D cartesian maximum distance (based on spatial ref) between two geometries in projected units.';

alter function public.st_3dmaxdistance(geometry, geometry) owner to postgres;

create function public.st_3dclosestpoint(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dclosestpoint(geometry, geometry) is 'args: g1, g2 - Returns the 3D point on g1 that is closest to g2. This is the first point of the 3D shortest line.';

alter function public.st_3dclosestpoint(geometry, geometry) owner to postgres;

create function public.st_3dshortestline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dshortestline(geometry, geometry) is 'args: g1, g2 - Returns the 3D shortest line between two geometries';

alter function public.st_3dshortestline(geometry, geometry) owner to postgres;

create function public.st_3dlongestline(geom1 geometry, geom2 geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dlongestline(geometry, geometry) is 'args: g1, g2 - Returns the 3D longest line between two geometries';

alter function public.st_3dlongestline(geometry, geometry) owner to postgres;

create function public.st_coorddim(geometry geometry) returns smallint
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_coorddim(geometry) is 'args: geomA - Return the coordinate dimension of a geometry.';

alter function public.st_coorddim(geometry) owner to postgres;

create function public.st_curvetoline(geom geometry, tol double precision default 32, toltype integer default 0, flags integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_curvetoline(geometry, double precision, integer, integer) is 'args: curveGeom, tolerance, tolerance_type, flags - Converts a geometry containing curves to a linear geometry.';

alter function public.st_curvetoline(geometry, double precision, integer, integer) owner to postgres;

create function public.st_hasarc(geometry geometry) returns boolean
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_hasarc(geometry) is 'args: geomA - Tests if a geometry contains a circular arc';

alter function public.st_hasarc(geometry) owner to postgres;

create function public.st_linetocurve(geometry geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_linetocurve(geometry) is 'args: geomANoncircular - Converts a linear geometry to a curved geometry.';

alter function public.st_linetocurve(geometry) owner to postgres;

create function public.st_point(double precision, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_point(double precision, double precision) is 'args: x, y - Creates a Point with X, Y and SRID values.';

alter function public.st_point(double precision, double precision) owner to postgres;

create function public.st_point(double precision, double precision, srid integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_point(double precision, double precision, integer) is 'args: x, y, srid=unknown - Creates a Point with X, Y and SRID values.';

alter function public.st_point(double precision, double precision, integer) owner to postgres;

create function public.st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_pointz(double precision, double precision, double precision, integer) is 'args: x, y, z, srid=unknown - Creates a Point with X, Y, Z and SRID values.';

alter function public.st_pointz(double precision, double precision, double precision, integer) owner to postgres;

create function public.st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_pointm(double precision, double precision, double precision, integer) is 'args: x, y, m, srid=unknown - Creates a Point with X, Y, M and SRID values.';

alter function public.st_pointm(double precision, double precision, double precision, integer) owner to postgres;

create function public.st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer default 0) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_pointzm(double precision, double precision, double precision, double precision, integer) is 'args: x, y, z, m, srid=unknown - Creates a Point with X, Y, Z, M and SRID values.';

alter function public.st_pointzm(double precision, double precision, double precision, double precision, integer) owner to postgres;

create function public.st_polygon(geometry, integer) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$
SELECT public.ST_SetSRID(public.ST_MakePolygon($1), $2)
           $$;

comment on function public.st_polygon(geometry, integer) is 'args: lineString, srid - Creates a Polygon from a LineString with a specified SRID.';

alter function public.st_polygon(geometry, integer) owner to postgres;

create function public.st_wkbtosql(wkb bytea) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.st_wkbtosql(bytea) owner to postgres;

create function public.st_locatebetween(geometry geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_locatebetween(geometry, double precision, double precision, double precision) is 'args: geom, measure_start, measure_end, offset = 0 - Returns the portions of a geometry that match a measure range.';

alter function public.st_locatebetween(geometry, double precision, double precision, double precision) owner to postgres;

create function public.st_locatealong(geometry geometry, measure double precision, leftrightoffset double precision default 0.0) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_locatealong(geometry, double precision, double precision) is 'args: geom_with_measure, measure, offset = 0 - Returns the point(s) on a geometry that match a measure value.';

alter function public.st_locatealong(geometry, double precision, double precision) owner to postgres;

create function public.st_locatebetweenelevations(geometry geometry, fromelevation double precision, toelevation double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_locatebetweenelevations(geometry, double precision, double precision) is 'args: geom, elevation_start, elevation_end - Returns the portions of a geometry that lie in an elevation (Z) range.';

alter function public.st_locatebetweenelevations(geometry, double precision, double precision) owner to postgres;

create function public.st_interpolatepoint(line geometry, point geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_interpolatepoint(geometry, geometry) is 'args: linear_geom_with_measure, point - Returns the interpolated measure of a geometry closest to a point.';

alter function public.st_interpolatepoint(geometry, geometry) owner to postgres;

create function public.st_hexagon(size double precision, cell_i integer, cell_j integer, origin geometry default '010100000000000000000000000000000000000000'::geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_hexagon(double precision, integer, integer, geometry) is 'args: size, cell_i, cell_j, origin - Returns a single hexagon, using the provided edge size and cell coordinate within the hexagon grid space.';

alter function public.st_hexagon(double precision, integer, integer, geometry) owner to postgres;

create function public.st_square(size double precision, cell_i integer, cell_j integer, origin geometry default '010100000000000000000000000000000000000000'::geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_square(double precision, integer, integer, geometry) is 'args: size, cell_i, cell_j, origin - Returns a single square, using the provided edge size and cell coordinate within the square grid space.';

alter function public.st_square(double precision, integer, integer, geometry) owner to postgres;

create function public.st_hexagongrid(size double precision, bounds geometry, out geom geometry, out i integer, out j integer) returns setof setof record
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_hexagongrid(double precision, geometry, out geometry, out integer, out integer) is 'args: size, bounds - Returns a set of hexagons and cell indices that completely cover the bounds of the geometry argument.';

alter function public.st_hexagongrid(double precision, geometry, out geometry, out integer, out integer) owner to postgres;

create function public.st_squaregrid(size double precision, bounds geometry, out geom geometry, out i integer, out j integer) returns setof setof record
    immutable
    strict
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;

$$;

comment on function public.st_squaregrid(double precision, geometry, out geometry, out integer, out integer) is 'args: size, bounds - Returns a set of grid squares and cell indices that completely cover the bounds of the geometry argument.';

alter function public.st_squaregrid(double precision, geometry, out geometry, out integer, out integer) owner to postgres;

create function public.contains_2d(box2df, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.contains_2d(box2df, geometry) owner to postgres;

create function public.is_contained_2d(box2df, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.is_contained_2d(box2df, geometry) owner to postgres;

create function public.overlaps_2d(box2df, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_2d(box2df, geometry) owner to postgres;

create function public.overlaps_2d(box2df, box2df) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_2d(box2df, box2df) owner to postgres;

create function public.contains_2d(box2df, box2df) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.contains_2d(box2df, box2df) owner to postgres;

create function public.is_contained_2d(box2df, box2df) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.is_contained_2d(box2df, box2df) owner to postgres;

create function public.contains_2d(geometry, box2df) returns boolean
    immutable
    strict
    parallel safe
    cost 1
    language sql
as
$$SELECT $2 OPERATOR(public.@) $1;$$;

alter function public.contains_2d(geometry, box2df) owner to postgres;

create function public.is_contained_2d(geometry, box2df) returns boolean
    immutable
    strict
    parallel safe
    cost 1
    language sql
as
$$SELECT $2 OPERATOR(public.~) $1;$$;

alter function public.is_contained_2d(geometry, box2df) owner to postgres;

create function public.overlaps_2d(geometry, box2df) returns boolean
    immutable
    strict
    parallel safe
    cost 1
    language sql
as
$$SELECT $2 OPERATOR(public.&&) $1;$$;

alter function public.overlaps_2d(geometry, box2df) owner to postgres;

create function public.overlaps_nd(gidx, geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_nd(gidx, geometry) owner to postgres;

create function public.overlaps_nd(gidx, gidx) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.overlaps_nd(gidx, gidx) owner to postgres;

create function public.overlaps_nd(geometry, gidx) returns boolean
    immutable
    strict
    parallel safe
    cost 1
    language sql
as
$$SELECT $2 OPERATOR(public.&&&) $1;$$;

alter function public.overlaps_nd(geometry, gidx) owner to postgres;

create function public.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) returns boolean
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) owner to postgres;

create function public.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) returns boolean
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) owner to postgres;

create function public.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) returns boolean
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) owner to postgres;

create function public.st_simplifypolygonhull(geom geometry, vertex_fraction double precision, is_outer boolean default true) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_simplifypolygonhull(geometry, double precision, boolean) is 'args: param_geom, vertex_fraction, is_outer = true - Computes a simplifed topology-preserving outer or inner hull of a polygonal geometry.';

alter function public.st_simplifypolygonhull(geometry, double precision, boolean) owner to postgres;

create function public._st_concavehull(param_inputgeom geometry) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language plpgsql
as
$$
DECLARE
vexhull public.geometry;
	var_resultgeom public.geometry;
	var_inputgeom public.geometry;
	vexring public.geometry;
	cavering public.geometry;
	cavept public.geometry[];
	seglength double precision;
	var_tempgeom public.geometry;
	scale_factor float := 1;
	i integer;
BEGIN
		-- First compute the ConvexHull of the geometry
		vexhull := public.ST_ConvexHull(param_inputgeom);
		var_inputgeom := param_inputgeom;
		--A point really has no concave hull
		IF public.ST_GeometryType(vexhull) = 'ST_Point' OR public.ST_GeometryType(vexHull) = 'ST_LineString' THEN
			RETURN vexhull;
END IF;

		-- convert the hull perimeter to a linestring so we can manipulate individual points
		vexring := CASE WHEN public.ST_GeometryType(vexhull) = 'ST_LineString' THEN vexhull ELSE public.ST_ExteriorRing(vexhull) END;
		IF abs(public.ST_X(public.ST_PointN(vexring,1))) < 1 THEN --scale the geometry to prevent stupid precision errors - not sure it works so make low for now
			scale_factor := 100;
			vexring := public.ST_Scale(vexring, scale_factor,scale_factor);
			var_inputgeom := public.ST_Scale(var_inputgeom, scale_factor, scale_factor);
			--RAISE NOTICE 'Scaling';
END IF;
		seglength := public.ST_Length(vexring)/least(public.ST_NPoints(vexring)*2,1000) ;

		vexring := public.ST_Segmentize(vexring, seglength);
		-- find the point on the original geom that is closest to each point of the convex hull and make a new linestring out of it.
		cavering := public.ST_Collect(
			ARRAY(

				SELECT
					public.ST_ClosestPoint(var_inputgeom, pt ) As the_geom
					FROM (
						SELECT  public.ST_PointN(vexring, n ) As pt, n
							FROM
							generate_series(1, public.ST_NPoints(vexring) ) As n
						) As pt

				)
			)
		;

		var_resultgeom := public.ST_MakeLine(geom)
			FROM public.ST_Dump(cavering) As foo;

		IF public.ST_IsSimple(var_resultgeom) THEN
			var_resultgeom := public.ST_MakePolygon(var_resultgeom);
			--RAISE NOTICE 'is Simple: %', var_resultgeom;
ELSE
			--RAISE NOTICE 'is not Simple: %', var_resultgeom;
			var_resultgeom := public.ST_ConvexHull(var_resultgeom);
END IF;

		IF scale_factor > 1 THEN -- scale the result back
			var_resultgeom := public.ST_Scale(var_resultgeom, 1/scale_factor, 1/scale_factor);
END IF;

		-- make sure result covers original (#3638)
		-- Using ST_UnaryUnion since SFCGAL doesn't replace with its own implementation
		-- and SFCGAL one chokes for some reason
		var_resultgeom := public.ST_UnaryUnion(public.ST_Collect(param_inputgeom, var_resultgeom) );
RETURN var_resultgeom;

END;
$$;

alter function public._st_concavehull(geometry) owner to postgres;

create function public.st_concavehull(param_geom geometry, param_pctconvex double precision, param_allow_holes boolean DEFAULT false) returns geometry
    immutable
    strict
    parallel safe
    cost 5000
    language plpgsql
as
$$
DECLARE
var_convhull public.geometry := public.ST_ForceSFS(public.ST_ConvexHull(param_geom));
		var_param_geom public.geometry := public.ST_ForceSFS(param_geom);
		var_initarea float := public.ST_Area(var_convhull);
		var_newarea float := var_initarea;
		var_div integer := 6;
		var_tempgeom public.geometry;
		var_tempgeom2 public.geometry;
		var_cent public.geometry;
		var_geoms public.geometry[4];
		var_enline public.geometry;
		var_resultgeom public.geometry;
		var_atempgeoms public.geometry[];
		var_buf float := 1;
BEGIN
		-- We start with convex hull as our base
		var_resultgeom := var_convhull;

		IF param_pctconvex = 1 THEN
			-- this is the same as asking for the convex hull
			return var_resultgeom;
		ELSIF public.ST_GeometryType(var_param_geom) = 'ST_Polygon' THEN -- it is as concave as it is going to get
			IF param_allow_holes THEN -- leave the holes
				RETURN var_param_geom;
ELSE -- remove the holes
				var_resultgeom := public.ST_MakePolygon(public.ST_ExteriorRing(var_param_geom));
RETURN var_resultgeom;
END IF;
END IF;
		IF public.ST_Dimension(var_resultgeom) > 1 AND param_pctconvex BETWEEN 0 and 0.99 THEN
		-- get linestring that forms envelope of geometry
			var_enline := public.ST_Boundary(public.ST_Envelope(var_param_geom));
			var_buf := public.ST_Length(var_enline)/1000.0;
			IF public.ST_GeometryType(var_param_geom) = 'ST_MultiPoint' AND public.ST_NumGeometries(var_param_geom) BETWEEN 4 and 200 THEN
			-- we make polygons out of points since they are easier to cave in.
			-- Note we limit to between 4 and 200 points because this process is slow and gets quadratically slow
				var_buf := sqrt(public.ST_Area(var_convhull)*0.8/(public.ST_NumGeometries(var_param_geom)*public.ST_NumGeometries(var_param_geom)));
				var_atempgeoms := ARRAY(SELECT geom FROM public.ST_DumpPoints(var_param_geom));
				-- 5 and 10 and just fudge factors
				var_tempgeom := public.ST_Union(ARRAY(SELECT geom
						FROM (
						-- fuse near neighbors together
						SELECT DISTINCT ON (i) i,  public.ST_Distance(var_atempgeoms[i],var_atempgeoms[j]), public.ST_Buffer(public.ST_MakeLine(var_atempgeoms[i], var_atempgeoms[j]) , var_buf*5, 'quad_segs=3') As geom
								FROM generate_series(1,array_upper(var_atempgeoms, 1)) As i
									INNER JOIN generate_series(1,array_upper(var_atempgeoms, 1)) As j
										ON (
								 NOT public.ST_Intersects(var_atempgeoms[i],var_atempgeoms[j])
									AND public.ST_DWithin(var_atempgeoms[i],var_atempgeoms[j], var_buf*10)
									)
								UNION ALL
						-- catch the ones with no near neighbors
								SELECT i, 0, public.ST_Buffer(var_atempgeoms[i] , var_buf*10, 'quad_segs=3') As geom
								FROM generate_series(1,array_upper(var_atempgeoms, 1)) As i
									LEFT JOIN generate_series(ceiling(array_upper(var_atempgeoms,1)/2)::integer,array_upper(var_atempgeoms, 1)) As j
										ON (
								 NOT public.ST_Intersects(var_atempgeoms[i],var_atempgeoms[j])
									AND public.ST_DWithin(var_atempgeoms[i],var_atempgeoms[j], var_buf*10)
									)
									WHERE j IS NULL
								ORDER BY 1, 2
							) As foo	) );
				IF public.ST_IsValid(var_tempgeom) AND public.ST_GeometryType(var_tempgeom) = 'ST_Polygon' THEN
					var_tempgeom := public.ST_ForceSFS(public.ST_Intersection(var_tempgeom, var_convhull));
					IF param_allow_holes THEN
						var_param_geom := var_tempgeom;
					ELSIF public.ST_GeometryType(var_tempgeom) = 'ST_Polygon' THEN
						var_param_geom := public.ST_ForceSFS(public.ST_MakePolygon(public.ST_ExteriorRing(var_tempgeom)));
ELSE
						var_param_geom := public.ST_ForceSFS(public.ST_ConvexHull(var_param_geom));
END IF;
					-- make sure result covers original (#3638)
					var_param_geom := public.ST_Union(param_geom, var_param_geom);
return var_param_geom;
ELSIF public.ST_IsValid(var_tempgeom) THEN
					var_param_geom := public.ST_ForceSFS(public.ST_Intersection(var_tempgeom, var_convhull));
END IF;
END IF;

			IF public.ST_GeometryType(var_param_geom) = 'ST_Polygon' THEN
				IF NOT param_allow_holes THEN
					var_param_geom := public.ST_ForceSFS(public.ST_MakePolygon(public.ST_ExteriorRing(var_param_geom)));
END IF;
				-- make sure result covers original (#3638)
				--var_param_geom := public.ST_Union(param_geom, var_param_geom);
return var_param_geom;
END IF;
			var_cent := public.ST_Centroid(var_param_geom);
			IF (public.ST_XMax(var_enline) - public.ST_XMin(var_enline) ) > var_buf AND (public.ST_YMax(var_enline) - public.ST_YMin(var_enline) ) > var_buf THEN
					IF public.ST_Dwithin(public.ST_Centroid(var_convhull) , public.ST_Centroid(public.ST_Envelope(var_param_geom)), var_buf/2) THEN
				-- If the geometric dimension is > 1 and the object is symettric (cutting at centroid will not work -- offset a bit)
						var_cent := public.ST_Translate(var_cent, (public.ST_XMax(var_enline) - public.ST_XMin(var_enline))/1000,  (public.ST_YMAX(var_enline) - public.ST_YMin(var_enline))/1000);
ELSE
						-- uses closest point on geometry to centroid. I can't explain why we are doing this
						var_cent := public.ST_ClosestPoint(var_param_geom,var_cent);
END IF;
					IF public.ST_DWithin(var_cent, var_enline,var_buf) THEN
						var_cent := public.ST_centroid(public.ST_Envelope(var_param_geom));
END IF;
					-- break envelope into 4 triangles about the centroid of the geometry and returned the clipped geometry in each quadrant
FOR i in 1 .. 4 LOOP
					   var_geoms[i] := public.ST_MakePolygon(public.ST_MakeLine(ARRAY[public.ST_PointN(var_enline,i), public.ST_PointN(var_enline,i+1), var_cent, public.ST_PointN(var_enline,i)]));
					   var_geoms[i] := public.ST_ForceSFS(public.ST_Intersection(var_param_geom, public.ST_Buffer(var_geoms[i],var_buf)));
					   IF public.ST_IsValid(var_geoms[i]) THEN

					   ELSE
							var_geoms[i] := public.ST_BuildArea(public.ST_MakeLine(ARRAY[public.ST_PointN(var_enline,i), public.ST_PointN(var_enline,i+1), var_cent, public.ST_PointN(var_enline,i)]));
END IF;
END LOOP;
					var_tempgeom := public.ST_Union(ARRAY[public.ST_ConvexHull(var_geoms[1]), public.ST_ConvexHull(var_geoms[2]) , public.ST_ConvexHull(var_geoms[3]), public.ST_ConvexHull(var_geoms[4])]);
					--RAISE NOTICE 'Curr vex % ', public.ST_AsText(var_tempgeom);
					IF public.ST_Area(var_tempgeom) <= var_newarea AND public.ST_IsValid(var_tempgeom)  THEN --AND public.ST_GeometryType(var_tempgeom) ILIKE '%Polygon'

						var_tempgeom := public.ST_Buffer(public.ST_ConcaveHull(var_geoms[1],least(param_pctconvex + param_pctconvex/var_div),true),var_buf, 'quad_segs=2');
FOR i IN 1 .. 4 LOOP
							var_geoms[i] := public.ST_Buffer(public.ST_ConcaveHull(var_geoms[i],least(param_pctconvex + param_pctconvex/var_div),true), var_buf, 'quad_segs=2');
							IF public.ST_IsValid(var_geoms[i]) Then
								var_tempgeom := public.ST_Union(var_tempgeom, var_geoms[i]);
ELSE
								RAISE NOTICE 'Not valid % %', i, public.ST_AsText(var_tempgeom);
								var_tempgeom := public.ST_Union(var_tempgeom, public.ST_ConvexHull(var_geoms[i]));
END IF;
END LOOP;

						--RAISE NOTICE 'Curr concave % ', public.ST_AsText(var_tempgeom);
						IF public.ST_IsValid(var_tempgeom) THEN
							var_resultgeom := var_tempgeom;
END IF;
						var_newarea := public.ST_Area(var_resultgeom);
					ELSIF public.ST_IsValid(var_tempgeom) THEN
						var_resultgeom := var_tempgeom;
END IF;

					IF public.ST_NumGeometries(var_resultgeom) > 1  THEN
						var_tempgeom := public._ST_ConcaveHull(var_resultgeom);
						IF public.ST_IsValid(var_tempgeom) AND public.ST_GeometryType(var_tempgeom) ILIKE 'ST_Polygon' THEN
							var_resultgeom := var_tempgeom;
ELSE
							var_resultgeom := public.ST_Buffer(var_tempgeom,var_buf, 'quad_segs=2');
END IF;
END IF;
					IF param_allow_holes = false THEN
					-- only keep exterior ring since we do not want holes
						var_resultgeom := public.ST_MakePolygon(public.ST_ExteriorRing(var_resultgeom));
END IF;
ELSE
					var_resultgeom := public.ST_Buffer(var_resultgeom,var_buf);
END IF;
				var_resultgeom := public.ST_ForceSFS(public.ST_Intersection(var_resultgeom, public.ST_ConvexHull(var_param_geom)));
ELSE
				-- dimensions are too small to cut
				var_resultgeom := public._ST_ConcaveHull(var_param_geom);
END IF;

RETURN var_resultgeom;
END;
$$;

comment on function public.st_concavehull(geometry, double precision, boolean) is 'args: param_geom, param_pctconvex, param_allow_holes = false - Computes a possibly concave geometry that contains all input geometry vertices';

alter function public.st_concavehull(geometry, double precision, boolean) owner to postgres;

create function public._st_asx3d(integer, geometry, integer, integer, text) returns text
    immutable
    parallel safe
    cost 250
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public._st_asx3d(integer, geometry, integer, integer, text) owner to postgres;

create function public.st_asx3d(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0) returns text
    immutable
    parallel safe
    cost 250
    language sql
as
$$SELECT public._ST_AsX3D(3,$1,$2,$3,'');$$;

alter function public.st_asx3d(geometry, integer, integer) owner to postgres;

create function public.st_angle(line1 geometry, line2 geometry) returns double precision
    immutable
    strict
    parallel safe
    cost 50
    language sql
as
$$SELECT ST_Angle(St_StartPoint($1), ST_EndPoint($1), St_StartPoint($2), ST_EndPoint($2))$$;

comment on function public.st_angle(geometry, geometry) is 'args: line1, line2 - Returns the angle between two vectors defined by 3 or 4 points, or 2 lines.';

alter function public.st_angle(geometry, geometry) owner to postgres;

create function public.st_3dlineinterpolatepoint(geometry, double precision) returns geometry
    immutable
    strict
    parallel safe
    cost 50
    language c
as
$$
begin
-- missing source code
end;
$$;

comment on function public.st_3dlineinterpolatepoint(geometry, double precision) is 'args: a_linestring, a_fraction - Returns a point interpolated along a 3D line at a fractional location.';

alter function public.st_3dlineinterpolatepoint(geometry, double precision) owner to postgres;

create function public.geometry_spgist_config_2d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_config_2d(internal, internal) owner to postgres;

create function public.geometry_spgist_choose_2d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_choose_2d(internal, internal) owner to postgres;

create function public.geometry_spgist_picksplit_2d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_picksplit_2d(internal, internal) owner to postgres;

create function public.geometry_spgist_inner_consistent_2d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_inner_consistent_2d(internal, internal) owner to postgres;

create function public.geometry_spgist_leaf_consistent_2d(internal, internal) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_leaf_consistent_2d(internal, internal) owner to postgres;

create function public.geometry_spgist_compress_2d(internal) returns internal
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_compress_2d(internal) owner to postgres;

create function public.geometry_overlaps_3d(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_overlaps_3d(geometry, geometry) owner to postgres;

create function public.geometry_contains_3d(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_contains_3d(geometry, geometry) owner to postgres;

create function public.geometry_contained_3d(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_contained_3d(geometry, geometry) owner to postgres;

create function public.geometry_same_3d(geom1 geometry, geom2 geometry) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_same_3d(geometry, geometry) owner to postgres;

create function public.geometry_spgist_config_3d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_config_3d(internal, internal) owner to postgres;

create function public.geometry_spgist_choose_3d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_choose_3d(internal, internal) owner to postgres;

create function public.geometry_spgist_picksplit_3d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_picksplit_3d(internal, internal) owner to postgres;

create function public.geometry_spgist_inner_consistent_3d(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_inner_consistent_3d(internal, internal) owner to postgres;

create function public.geometry_spgist_leaf_consistent_3d(internal, internal) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_leaf_consistent_3d(internal, internal) owner to postgres;

create function public.geometry_spgist_compress_3d(internal) returns internal
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_compress_3d(internal) owner to postgres;

create function public.geometry_spgist_config_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_config_nd(internal, internal) owner to postgres;

create function public.geometry_spgist_choose_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_choose_nd(internal, internal) owner to postgres;

create function public.geometry_spgist_picksplit_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_picksplit_nd(internal, internal) owner to postgres;

create function public.geometry_spgist_inner_consistent_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_inner_consistent_nd(internal, internal) owner to postgres;

create function public.geometry_spgist_leaf_consistent_nd(internal, internal) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_leaf_consistent_nd(internal, internal) owner to postgres;

create function public.geometry_spgist_compress_nd(internal) returns internal
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geometry_spgist_compress_nd(internal) owner to postgres;

create function public.geography_spgist_config_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_config_nd(internal, internal) owner to postgres;

create function public.geography_spgist_choose_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_choose_nd(internal, internal) owner to postgres;

create function public.geography_spgist_picksplit_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_picksplit_nd(internal, internal) owner to postgres;

create function public.geography_spgist_inner_consistent_nd(internal, internal) returns void
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_inner_consistent_nd(internal, internal) owner to postgres;

create function public.geography_spgist_leaf_consistent_nd(internal, internal) returns boolean
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_leaf_consistent_nd(internal, internal) owner to postgres;

create function public.geography_spgist_compress_nd(internal) returns internal
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.geography_spgist_compress_nd(internal) owner to postgres;

create function public.st_letters(letters text, font json DEFAULT NULL::json) returns geometry
    immutable
    parallel safe
    cost 250
    SET standard_conforming_strings = on
    language plpgsql
as
$$
DECLARE
letterarray text[];
  letter text;
  geom geometry;
  prevgeom geometry = NULL;
  adjustment float8 = 0.0;
position float8 = 0.0;
  text_height float8 = 100.0;
  width float8;
  m_width float8;
  spacing float8;
  dist float8;
  wordarr geometry[];
  wordgeom geometry;
  -- geometry has been run through replace(encode(st_astwkb(geom),'base64'), E'\n', '')
  font_default_height float8 = 1000.0;
  font_default json = '{
  "!":"BgACAQhUrgsTFOQCABQAExELiwi5AgAJiggBYQmJCgAOAg4CDAIOBAoEDAYKBgoGCggICAgICAgGCgYKBgoGCgQMBAoECgQMAgoADAIKAAoADAEKAAwBCgMKAQwDCgMKAwoFCAUKBwgHBgcIBwYJBgkECwYJBAsCDQILAg0CDQANAQ0BCwELAwsDCwUJBQkFCQcHBwcHBwcFCQUJBQkFCQMLAwkDCQMLAQkACwEJAAkACwIJAAsCCQQJAgsECQQJBAkGBwYJCAcIBQgHCAUKBQoDDAUKAQwDDgEMAQ4BDg==",
  "&":"BgABAskBygP+BowEAACZAmcAANsCAw0FDwUNBQ0FDQcLBw0HCwcLCQsJCwkLCQkJCwsJCwkLCQ0HCwcNBw8HDQUPBQ8DDwMRAw8DEQERAREBEQERABcAFQIXAhUCEwQVBBMGEwYTBhEIEQgPChEKDwoPDA0MDQwNDgsOCRAJEAkQBxAHEgUSBRQFFAMUAxQBFgEWARgAigEAFAISABICEgQQAhAEEAQQBg4GEAoOCg4MDg4ODgwSDgsMCwoJDAcMBwwFDgUMAw4DDgEOARABDgEQARIBEAASAHgAIAQeBB4GHAgaChoMGA4WDhYQFBISEhISDhQQFAwWDBYKFgoYBhgIGAQYBBgCGgAaABgBGAMYAxYHFgUWCRYJFAsUCxIPEg0SERARDhMOFQwVDBcIGQYbBhsCHQIfAR+dAgAADAAKAQoBCgEIAwgFBgUGBQYHBAUEBwQHAgcCBwIHAAcABwAHAQcBBwMHAwUDBwUFBQUHBQUBBwMJAQkBCQAJAJcBAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgAKSeECAJ8BFi84HUQDQCAAmAKNAQAvExMx",
  "\"":"BgACAQUmwguEAgAAkwSDAgAAlAQBBfACAIACAACTBP8BAACUBA==",
  "''":"BgABAQUmwguEAgAAkwSDAgAAlAQ=",
  "(":"BgABAUOQBNwLDScNKw0rCysLLwsxCTEJMwc1BzcHNwM7AzsDPwE/AEEANwI1AjMEMwIzBjEGLwYvCC0ILQgrCCkKKQonCicMJbkCAAkqCSoHLAksBywFLgcuBS4FMAMwAzADMgEwATQBMgA0ADwCOgI6BDoEOAY4BjYINgg2CjQKMgoyCjIMMAwwDi7AAgA=",
  ")":"BgABAUMQ3Au6AgAOLQwvDC8KMQoxCjEKMwg1CDUGNQY3BDcEOQI5AjkAOwAzATEBMQExAy8DLwMvBS8FLQctBS0HKwktBykJKwkpswIADCYKKAooCioIKggsCC4ILgYwBjAGMgQ0AjQCNAI2ADgAQgFAAz4DPAM8BzgHOAc2CTQJMgsyCzALLg0sDSoNKg==",
  "+":"BgABAQ3IBOwGALcBuAEAANUBtwEAALcB0wEAALgBtwEAANYBuAEAALgB1AEA",
  "/":"BgABAQVCAoIDwAuyAgCFA78LrQIA",
  "4":"BgABAhDkBr4EkgEAEREApwJ/AADxARIR5QIAEhIA9AHdAwAA7ALIA9AG6gIAEREA8QYFqwIAAIIDwwH/AgABxAEA",
  "v":"BgABASDmA5AEPu4CROwBExb6AgAZFdMC0wgUFaECABIU0wLWCBcW+AIAExVE6wEEFQQXBBUEFwQVBBUEFwQVBBUEFwQVBBUEFwQXBBUEFwYA",
  ",":"BgABAWMYpAEADgIOAgwCDgQMBAoGDAYKBgoICAgICAgICAoGCgYKBAoEDAQKBAoCDAIKAgwCCgAKAAwACgEMAQoBCgMMAwoDCgUKBQgFCgUIBwYJCAcGCQYJBAsGCQQLAg0CCwINAg0AAwABAAMAAwADAQMAAwADAAMBBQAFAQcBBwEHAwcBCQMJAQsDCwMLAw0FDQMNBQ8FDwURBxMFEwkTBxcJFwkXswEAIMgBCQYJBgkGBwYJCAcIBQgHCgUKBQoFDAEMAwwBDgEOABA=",
  "-":"BgABAQUq0AMArALEBAAAqwLDBAA=",
  ".":"BgABAWFOrAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4=",
  "0":"BgABAoMB+APaCxwAHAEaARoDFgMYBRYFFAcUBxIJEgkQCRALEAsOCwwNDA0MDQoPCg0IDwgPBhEGDwYRBA8EEQIRAhMCEQITABMA4QUAEQETAREBEQMRAxEFEQURBREHDwkPBw8JDwsNCw0LDQ0NDQsNCw8JEQkRCREJEwcTBxUFFQUVAxUDFwEXARkAGQAZAhcCFwQXBBUGEwYTCBMIEQoRCg8KDwoPDA0MDQ4NDgsOCQ4JEAkQBxAHEAUSBRIDEgMSAxIDEgESARQAEgDiBQASAhQCEgISBBIEEgYSBhIGEggQChAIEAoQDBAMDgwODg4ODA4MEgwQChIKEggUCBQIFgYWBBYGGAQYAhgCGgILZIcDHTZBEkMRHTUA4QUeOUITRBIePADiBQ==",
  "2":"BgABAWpUwALUA44GAAoBCAEKAQgDBgMGBQYFBgUEBwQFBAUCBwIHAgUABwAHAAUBBwMFAQcFBQMHBQUHBQcFBwMJAwkBCQELAQsAC68CAAAUAhIAFAISBBQCEgQUBBIEEgYUCBIGEAgSChAKEAoQDBAMDg4ODgwQDBIMEgoSChQIFggWCBgGGAQaAhwCHAIWABQBFgEUARQDFAMSAxQFEgUSBxIHEAkQCRALDgsODQ4NDA8KDwwRCBMKEwgTBhUGFwQXBBcEGwAbABsAHQEftwPJBdIDAACpAhIPzwYAFBIArgI=",
  "1":"BgABARCsBLALAJ0LEhERADcA2QEANwATABQSAOYIpwEAALgCERKEBAASABER",
  "3":"BgABAZ0B/gbEC/sB0QQOAwwBDAMMAwwFCgMKBQoFCgUIBwoFCAcICQgJBgkICQYLCAsECwYLBA0GDwINBA8CDwQRAhECEQITABUCFQAVAH0AEQETAREBEQETAxEDEQURBREFDwcRBw8JDwkNCQ8LDQsNDQsNCw0LDwsPCREJEQcRBxMFFQUVBRUDFwEXARkAGQAZAhkCFwQVBBUEEwYTCBEIEQgRCg0MDwoNDA0OCw4LDgkQCRAHEAkQBRAFEgUSAxIDFAMSAxYBFAEWARYAFqQCAAALAgkCCQQHAgcGBwYHBgUIBQYDCAMIAwYDCAEIAQgACAAIAAgCCAIIAgYCCAQIBAgGBgYEBgQIBAoCCgAKAAwAvAEABgEIAAYBBgMGAwQDBgMEBQQDBAUCBQQFAgUABwIFAJkBAACmAaIB3ALbAgAREQDmAhIRggYA",
  "5":"BgABAaAB0APgBxIAFAESABIBEgMSARADEgMQAxIFEAcOBRAHDgkOCQ4JDgsMCwwLCgsKDQoPCA0IDwgPBhEEEwYTAhMEFwIXABcAiQIAEwETABEBEQMTAxEDDwMRBQ8FDwUPBw8JDQcNCQ0LDQsLCwsNCw0JDwkPCREHEQcTBxMFEwMVAxcDGQEZARkAFwAVAhUCFQQTBBMGEwYRCBEIDwoPCg8KDQwNDA0MCw4LDgkOCRAJEAcOBxAHEgUQBRIDEAMSAxIBEgEUARIAFLgCAAAFAgUABQIFBAUCBQQDBAUEAwYDBgMIAwgBCAEIAQoACAAIAgYACAQGAgQEBgQEBAQGBAQCBgIGAgYCBgIIAAYA4AEABgEIAAYBBgMGAQQDBgMEAwQFBAMCBQQFAgUABwIFAPkBAG+OAQCCBRESAgAAAuYFABMRAK8CjQMAAJ8BNgA=",
  "7":"BgABAQrQBsILhQOvCxQR7wIAEhK+AvYIiwMAAKgCERKwBgA=",
  "6":"BgABAsYBnAOqBxgGFgYYBBYEFgIWABQBFgEUAxQDFAUUBRIFEAcSCRAJEAkOCw4NDgsMDQoPCg8KDwgRCBEGEQYRBBMCEwITAhUAkwIBAAERAREBEQEPAxEFEQMPBREFDwcPBw8HDwkNCQ0LDQsNCwsNCw0LDQkPCQ8JDwcRBxEHEwUTAxMFFQEXAxcBGQAVABUCEwIVBBMEEQYTBhEIEQgPChEKDQoPDA0MDQwNDgsOCxALDgkQCRAHEgcQBxIFEgUSBRIBFAMSARIBFAASAOIFABACEgIQAhIEEAQQBhIGEAYQCBAKEAgOChAMDgwMDA4ODA4MDgwODBAKEAoQChIIEggSBhQGFgYUAhYCGAIYABoAGAEYARYBFgMUBRQFEgUSBxAHEAcQCQ4LDgkMCwwNDA0KDQgPCg0GEQgPBhEEEQQRBBMEEwITAhMCFQIVABWrAgAACgEIAQoBCAEGAwYDBgUGBQQFBAUEBQQFAgUABwIFAAUABwEFAAUBBQMFAwUDBQMFBQMFAwUBBQEHAQkBBwAJAJcBDUbpBDASFi4A4AETLC8SBQAvERUrAN8BFC0yEQQA",
  "8":"BgABA9gB6gPYCxYAFAEUARYBEgMUBRQFEgUSBxIHEAcSCQ4JEAkOCw4LDgsMDQwNCg0KDQoPCg8IDwgPBhEGEQQPBBMCEQIRABMAQwAxAA8BEQEPAREDDwMRAw8FEQUPBxEJDwkPCQ8NDw0PDQ8IBwYHCAcGBwgHBgkGBwYJBgcECQYJBAkGCQQJBAsECwQLBA0CCwINAg8CDwIPAA8AaQATAREBEwERAxEFEQURBREHEQcPBw8JDwkPCw8LDQsNDQ0LCw0LDwsNCQ8JDwcPBw8HEQURAxEFEQMRARMBEwFDABEAEwIRAhEEEQQRBg8GEQgPCA8KDwoPCg0MDQwNDAsOCw4LDgkQCRAJDgkQBxIHEAcSBRADEgMUAxIBFAEUABQAagAOAhAADgIOAg4EDAIOBAwEDAQMBgwECgYMBAoGCAYKBgoGCggKBgoICgYICAoICA0MCwwLDgsOCRAHEAcQBxIFEgUSAxIDEgMSARABEgASADIARAASAhICEgQSAhIGEAYSBhAIEAgQCBAKDgoODA4MDgwMDgwODA4KEAwQCBIKEggSCBQIFAYUBBQEFgQWAhYCGAANT78EFis0EwYANBIYLgC0ARcsMRQFADERGS0AswELogHtAhcuNxA3DRkvALMBGjE6ETYSGDIAtAE=",
  "9":"BgABAsYBpASeBBcFFQUXAxUDFQEVABMCFQITBBMEEwYRBhMGDwgRCg8KDwoNDA0OCwwNDgkQCRAJEAcSBxIFEgUSAxQBFAEUARYAlAICAAISAhICEgQSAhAGEgQQBhIGEAgSCA4IEAoOChAMDAwODAwODA4MEAoOChAKEAgSCBIIFAYUBBQGFgIYBBgCGgAWABYBFAEWAxQDEgUUBRIHEgcQCRIJEAkOCw4LDgsODQwNDA0MDwoPCg8IDwgRCBEGEQYRBhEEEQITAhECEwARAOEFAA8BEQEPAREDDwMPBREFDwUPBw8JDwcNCQ8LDQsLCw0NCw0LDQsNCw8JEQkPCREHEQcTBRMFEwUTARUBFQEXABkAFwIXAhcCFQQTBhMGEQYRCA8IDwgNCg8MCwoLDAsOCQ4JDgkQBxAHEAUQBRIFEgMSAxQDFAEUAxQAFgEWABamAgAACwIJAgkCCQIHBAcEBwYFBgUGAwYDBgMGAQgBBgEIAAgABgIIAgYCBgQGBAYEBgYGBgQIBAgECAIKAgoCCgAMAJgBDUXqBC8RFS0A3wEUKzARBgAwEhYsAOABEy4xEgMA",
  ":":"BgACAWE0rAEADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsDCQELAAsBCwALAAsCCQALAgkECwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYQDqBAAOAg4CDgIOBAwECgYMBgoGCggICAoICAgGCgYKBgoGCgQMBAoEDAQKAgwADAIMAAwADAEKAAwBCgMMAwoDCgMKBQoFCAUKBQgHCAkGBwgJBgkGCwYJBAsCDQINAg0ADQANAQ0BDQELAw0DCQULBQkFCQcHBwkHBQcHCQUJBQkFCQMLAwkDCwEJAwsACwELAAsACwIJAAsECQILBAkECQQJBgkGBwYHCAkGBwoFCAcKBQoFDAUKAQ4DDAEOAQ4ADg==",
  "x":"BgABARHmAoAJMIMBNLUBNrYBMIQB1AIA9QG/BI4CvwTVAgA5hgFBwAFFxwE1fdUCAI4CwATzAcAE1AIA",
  ";":"BgACAWEslgYADgIOAg4CDgQMBAoGDAYKBgoICAgKCAgIBgoGCgYKBgoEDAQKBAwECgIMAAwCDAAMAAwBCgAMAQoDDAMKAwoDCgUKBQgFCgUIBwgJBgcICQYJBgsGCQQLAg0CDQINAA0ADQENAQ0BCwMNAwkFCwUJBQkHBwcJBwUHBwkFCQUJBQkDCwMJAwsBCQMLAAsBCwALAAsCCQALBAkCCwQJBAkECQYJBgcGBwgJBgcKBQgHCgUKBQwFCgEOAwwBDgEOAA4BYwjxBAAOAg4CDAIOBAwECgYMBgoGCggICAgICAgICgYKBgoECgQMBAoECgIMAgoCDAIKAAoADAAKAQwBCgEKAwwDCgMKBQoFCAUKBQgHBgkIBwYJBgkECwYJBAsCDQILAg0CDQADAAEAAwADAAMBAwADAAMAAwEFAAUBBwEHAQcDBwEJAwkBCwMLAwsDDQUNAw0FDwUPBREHEwUTCRMHFwkXCRezAQAgyAEJBgkGCQYHBgkIBwgFCAcKBQoFCgUMAQwDDAEOAQ4AEA==",
  "=":"BgACAQUawAUA5gHEBAAA5QHDBAABBQC5AgDsAcQEAADrAcMEAA==",
  "B":"BgABA2e2BMQLFgAUARQBFAEUAxIDEgUSBRIFEAcQBxAJDgkOCQ4LDgsMCwwNDA0KDQgNCg0IDwYPBg8GDwQRBBEEEQIRAhMAEwAHAAkABwEHAAkBCQAHAQkBCQEHAQkBCQMJAwcDCQMJAwkFBwUJAwkHCQUHBQkHCQcJBwcHBwkHBwcJBwsHCQUQBQ4FDgcOCQ4JDAkMCwoNCg0IDwgRBhMEFQQXAhcCGwDJAQEvAysFJwklDSMPHREbFRkXFRsTHw8fCyUJJwcrAy0B6wMAEhIAoAsREuYDAAiRAYEElgEAKioSSA1EOR6JAQAA0wEJkAGPBSwSEiwAzAETKikSjwEAAMUCkAEA",
  "A":"BgABAg/KBfIBqQIAN98BEhHzAgAWEuwCngsREvwCABMR8gKdCxIR8QIAFBI54AEFlwGCBk3TA6ABAE3UAwMA",
  "?":"BgACAe4BsgaYCAAZABkBFwEXBRUDEwUTBxEHEQcPCQ8JDQkNCQ0LCwsLCwsLCQsJCwcNBwsHDQcLBQsFDQULAwkFCwMLAwkDCQMBAAABAQABAAEBAQABAAEAAQABAAABAQAAAQEAEwcBAQABAAMBAwADAAUABQAFAAcABwAFAAcABwAFAgcABQAHAAUAW7cCAABcABgBFgAUAhQAFAISAhACEAIQBA4EDgQMBgwGDAYMBgoICgYKCAgKCggICAgKBgoICgYMCAwGDAgOBg4GEAYQBgIAAgIEAAICBAACAgQCBAIKBAoGCAQKBggIBgYICAYIBggGCgQIBAoECAQKAggCCgIKAAgACgAKAAgBCAEKAwgDCAMIAwgFBgMIBQYHBAUGBQQFBAcCBQQHAgcCCQIHAgkCBwAJAgkACQAJAAkBCQAJAQsACQELAQsDCwELAwsDCwMLAwsDCwULAwsFCwMLBV2YAgYECAQKBAwGDAQMBhAIEAYSBhIIEgYUBhIEFgYUBBYEFgQWAhgCFgIYABYAGAAYARgBGAMWBRYHFgcWCRYLFA0IBQYDCAUIBwYFCAcGBwgHBgcICQYJCAkGCQYJCAsGCwYLBgsGDQYNBA0GDQQNBA8EDwQPAg8EEQIRAhEAEQITAWGpBesGAA4CDgIOAg4EDAQKBgwGCgYKCAgICggICAYKBgoGCgYKBAwECgQMBAoCDAAMAgwADAAMAQoADAEKAwwDCgMKAwoFCgUIBQoFCAcICQYHCAkGCQYLBgkECwINAg0CDQANAA0BDQENAQsDDQMJBQsFCQUJBwcHCQcFBwcJBQkFCQUJAwsDCQMLAwkBCwALAQsACwALAgkACwIJBAsECQQJBAkGCQYHBgcICQYHCgUIBwoFCgUMBQoBDgMMAQ4BDgAO",
  "C":"BgABAWmmA4ADAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgDWAgAAwQLVAgATABMCEQITBBEEEQQRBhEIEQgPCA8KDwoNCg0MDQwNDAsOCw4LDgkOCxAHEAkQBxIHEgUSBRIDEgEUARIBFAAUAMIFABQCFAISBBQEEgQSBhIIEggSCBAKEAoQCg4MDgwODA4ODA4MDgwQDA4KEggQChIIEggSBhIGFAQSAhQCEgIUAMYCAADBAsUCAAUABwEFAAUBBQMDAQUDAwMDAwMFAQMDBQEFAAUBBwAFAMEF",
  "L":"BgABAQmcBhISEdkFABIQALQLwgIAAIEJ9AIAAK8C",
  "D":"BgABAkeyBMQLFAAUARIBFAESAxIDEgMSBRIFEAcQBxAHDgkOCQ4LDgsMCwwNDA0KDwoPCg8IDwgRCBEGEwQTBBMEEwIVAhUAFwDBBQAXARcBFwMTAxUDEwUTBxEHEQcPCQ8JDwkNCw0LCwsLDQsNCQ0JDQcPBw8HDwcRBREFEQMRAxEDEwERARMBEwDfAwASEgCgCxES4AMACT6BAxEuKxKLAQAAvwaMAQAsEhIsAMIF",
  "F":"BgABARGABoIJ2QIAAIECsgIAEhIA4QIRErECAACvBBIR5QIAEhIAsgucBQASEgDlAhES",
  "E":"BgABARRkxAuWBQAQEgDlAhES0QIAAP0BtgIAEhIA5wIRFLUCAAD/AfACABISAOUCERLDBQASEgCyCw==",
  "G":"BgABAZsBjgeIAgMNBQ8FDQUNBQ0HCwcNBwsHCwkLCQsJCwsJCwsLCQsJDQkLBw0HDwcNBw8FDwUPAw8DEQMPAxEBEQERARMBEQAXABUCFwIVAhMEFQQTBhMGEwYRCBEIDwoRCg8KDwwNDA0MDQ4LDgkQCRAJEAcQBxIFEgUUBRQDFAMUARYBFgEYAMoFABQCFAASBBQCEgQSBBIEEgYSBhAGEAgQCBAKDgoOCg4MDgwMDgwOChAKEAoSCBIIFAgUBhQEGAYWAhgEGAIaAOoCAAC3AukCAAcABwEFAQUBBQMFAwMFAwUDBQEFAQcBBQEFAQUABwAFAMUFAAUCBwIFAgUCBQQFBAMGBQYDBgUGAwgDBgMIAQgDCAEIAQoBCAEIAAgACgAIAAgCCAIIAggECgQGBAgECAYIBgC6AnEAAJwCmAMAAJcF",
  "H":"BgABARbSB7ILAQAAnwsSEeUCABISAOAE5QEAAN8EEhHlAgASEgCiCxEQ5gIAEREA/QPmAQAAgAQPEOYCABER",
  "I":"BgABAQmuA7ILAJ8LFBHtAgAUEgCgCxMS7gIAExE=",
  "J":"BgABAWuqB7ILALEIABEBEwERAREDEwMRAxEFEQURBw8HEQcPCQ0LDwsNCw0NDQ0LDwsPCxEJEQkTCRMJFQcVBxcFFwMZAxsBGwEbAB8AHQIbAhsEGQYXBhcGFQgTCBMKEwoRDA8KDwwNDA0OCw4LDgkQCRAJEAcQBRIFEgUSAxQDEgESARIBFAESABIAgAEREtoCABERAn8ACQIHBAcEBwYHBgUIBQoDCgMKAwoDDAEKAQwBCgEMAAwACgAMAgoCDAIKBAoECgYKBggGBgYGCAQGBAgCCgAIALIIERLmAgAREQ==",
  "M":"BgACAQRm1gsUABMAAAABE5wIAQDBCxIR5QIAEhIA6gIK5gLVAe0B1wHuAQztAgDhAhIR5QIAEhIAxAsUAPoDtwT4A7YEFgA=",
  "K":"BgABAVXMCRoLBQsDCQMLAwsDCwMLAwsBCwELAQsBCwELAQ0ACwELAAsADQALAg0ACwILAA0CCwILAgsCDQQLBAsECwYNBAsGCwYLCAsGCwgJCgsICQoJCgkMCQwJDAkOCRALEAkQCRKZAdICUQAAiwQSEecCABQSAKALExLoAgAREQC3BEIA+AG4BAEAERKCAwAREdkCzQXGAYUDCA0KDQgJCgkMBwoFDAUMAQwBDgAMAg4CDAQOBAwGDghmlQI=",
  "O":"BgABAoMBsATaCxwAHAEaARoDGgMYBRYFFgcWBxQJEgkSCRILEAsODQ4NDg0MDwoNDA8KDwgPCBEIDwYRBg8GEQQRAhMCEQITABMA0QUAEQETAREBEQMTBREFEQURBxEHDwcRCQ8LDQsPCw0NDQ0NDwsPCw8LEQkTCRMJEwkVBxUHFwUXAxkDGQEbARsAGwAZAhkCGQQXBhcGFQYVCBUIEwoRChEMEQoRDA8MDQ4NDg0OCxAJEAsQCRAHEgcSBxIFFAMSAxIDEgEUARIAEgDSBQASAhQCEgISBBIEEgYSBhIIEggQCBAKEgwODBAMEA4ODg4QDhIMEAwSChQKFAgUCBYIFgYYBBoGGgQcAh4CHgILggGLAylCWxZbFSlBANEFKklcGVwYKkwA0gU=",
  "N":"BgABAQ+YA/oEAOUEEhHVAgASEgC+CxQAwATnBQDIBRMS2AIAExEAzQsRAL8ElgU=",
  "P":"BgABAkqoB5AGABcBFQEVAxMDEwMTBREHEQcRBw8JDwkNCQ0LDQsNCwsNCw0JDQkNCQ8HDwcPBxEFEQURAxEDEQMTAREBEwETAH8AAIMDEhHlAgASEgCgCxES1AMAFAAUARIAFAESAxIDEgMSAxIFEAUQBRAHDgkOCQ4JDgsMCwwNDA0KDQoNCg8IDwgRCBEGEwQTBBUEFQIXAhkAGQCzAgnBAsoCESwrEn8AANUDgAEALBISLgDYAg==",
  "R":"BgABAj9msgsREvYDABQAFAESARQBEgESAxIDEgUSBRAFEAcQBw4JDgkOCQ4LDAsMDQwLCg0KDwoNCA8IDwgPBhEEEwYTAhMEFQIXABcAowIAEwEVARMDEwMTBRMFEQcTBxELEQsRDQ8PDREPEQ0VC8QB/QMSEfkCABQSiQGyA3EAALEDFBHnAgASEgCgCwnCAscFogEALhISLACqAhEsLRKhAQAApQM=",
  "Q":"BgABA4YBvAniAbkB8wGZAYABBQUFAwUFBQUHBQUDBwUFBQcFBQMHBQcDBwUJAwcDCQMJAwkDCQMJAQsDCwMLAQsDCwENAw0BDQEPAA8BDwAPABsAGwIZAhcEGQQXBBUGFQgVCBMIEQoTChEKDwwPDA8ODQ4NDgsQCxAJEAkQBxIHEgUSBRQFFAMUARQDFAEWABYAxgUAEgIUAhICEgQSBBIGEgYSCBIIEAgQChIMDgwQDBAODg4OEA4SDBAMEgoUChQIFAgWCBYGGAQaBhoEHAIeAh4CHAAcARoBGgMaAxgFFgUWBxYHFAkSCRIJEgsQCw4NDg0ODQwPCg0MDwoPCA8IEQgPBhEGDwYRBBECEwIRAhMAEwC7BdgBrwEImQSyAwC6AylAWxZbFSk/AP0BjAK7AQeLAoMCGEc4J0wHVBbvAaYBAEM=",
  "S":"BgABAYMC8gOEBxIFEgUQBxIFEgcSBxIJEgcSCRIJEAkQCRALEAsOCw4NDg0MDQ4PDA0KEQoPChEKEQgRCBMGFQQTBBcCFQAXABkBEwARAREBEQMPAQ8DDwMPAw0DDQUNAw0FCwULBwsFCwUJBwsFCQcHBQkHCQUHBwcHBwUHBwUFBQcHBwUHAwcFEQsRCxMJEwkTBxMFEwUVBRUDFQMVARMBFwEVABUAFQIVAhUCFQQVBBUEEwYVBhMIEwgTCBMIEwgRCBMKEQgRCmK6AgwFDgUMAw4FEAUOBRAFEAUQBRAFEAMSAw4DEAMQAxABEAEOAQ4AEAIMAg4CDgQMBAwGCggKCAoKBgwGDgYQBBACCgAMAAoBCAMKBQgFCAcIBwgJCAsGCQgLCA0IDQgNCA8IDQgPCA8IDwgPChEIDwgPCBEKDwoPDBEMDwwPDg8ODw4NEA0QCxALEgsSCRIHEgcUBRQFGAUYAxgBGgEcAR4CJAYkBiAIIAweDBwQHBAYEhgUFBYUFhQWEBoQGg4aDBwKHAoeBh4GIAQgAiACIgEiASIFIgUiBSAJIgkgCyINZ58CBwQJAgkECwQLAgsECwINBA0CDQQNAg0CDQALAg0ADQANAAsBCwELAQsDCwULBQkFCQcHBwcJBwkFCwMLAw0BDQENAAsCCwQLBAkGCQgJCAkKBwoJCgcMBQoHDAcMBQwF",
  "V":"BgABARG2BM4DXrYEbKwDERL0AgAVEesCnQsSEfsCABQS8QKeCxES8gIAExFuqwNgtQQEAA==",
  "T":"BgABAQskxAv0BgAAtQKVAgAA+wgSEeUCABISAPwImwIAALYC",
  "U":"BgABAW76B7ALAKMIABcBFwMXARUFFQUTBxMHEwkRCREJEQsPDQ0LDw0NDwsPCw8LEQkPCRMJEQcTBxMFEwUVBRUDEwMXARUBFQEXABUAEwIVAhMCFQQTBBUEEwYTBhMIEwgRChEIEQwRDA8MDw4PDg0OCxANEAsSCRIJEgcUBxQHFAMWBRYBGAEYARgApggBAREU9AIAExMAAgClCAALAgkECQQHBAcIBwgHCAUKBQoDCgMKAwwBCgEMAQwADAAMAgoCDAIKAgoECgQKBggGCAYICAYKBAgCCgIMAgwApggAARMU9AIAExM=",
  "X":"BgABARmsCBISEYkDABQSS54BWYICXYkCRZUBEhGJAwAUEtYCzgXVAtIFExKIAwATEVClAVj3AVb0AVKqAREShgMAERHXAtEF2ALNBQ==",
  "W":"BgABARuODcQLERHpAp8LFBHlAgASEnW8A2+7AxIR6wIAFBKNA6ALERKSAwATEdQB7wZigARZ8AIREugCAA8RaKsDYsMDXsoDaqYDExLqAgA=",
  "Y":"BgABARK4BcQLhgMAERHnAvMGAKsEEhHnAgAUEgCsBOkC9AYREoYDABERWOEBUJsCUqICVtwBERI=",
  "Z":"BgABAQmAB8QLnwOBCaADAADBAusGAMgDggmhAwAAwgLGBgA=",
  "`":"BgABAQfqAd4JkQHmAQAOlgJCiAGpAgALiwIA",
  "c":"BgABAW3UA84GBQAFAQUABQEFAwMBBQMDAwMDAwUBAwMFAQUABQEHAAUAnQMABQIFAAUCBQQFAgMEBQQDBAMGAwQBBgMGAQYABgEGAPABABoMAMsCGw7tAQATABMCEwARAhMEEQIPBBEEDwQPBg8IDwYNCA0KDQoNCgsMCwwLDAkOCRAHDgcQBxIFEgUUBRQDFAEWAxgBGAAYAKQDABQCFAISBBQCEgYSBhAGEggQCBAIEAoQCg4MDAwODAwODAwKDgwQCg4IEAgQCBAIEAYSBhIGEgQSAhQCFAIUAOABABwOAM0CGQzbAQA=",
  "a":"BgABApoB8AYCxwF+BwkHCQcJCQkHBwkHBwcJBQkFBwUJBQkFCQMHBQkDCQMJAwcDCQEHAQkBBwEJAQcABwAHAQcABQAHAAUBBQAFABMAEwITAhEEEwQPBBEGDwgPCA0IDwoLCg0KCwwLDAsMCQ4JDgkOBw4HEAcQBRAFEAUSAxADEgESAxIBFAESABQAFAISAhQCEgQSBBIEEgYSBhIIEAgQChAIDgwODA4MDg4MDgwODBAMEAoSCBIKEggUCBQGFgYWBBgEGAIaAhoAcgAADgEMAQoBCgEIAwgDBgUEBQQFBAcCBwIHAgkCCQAJAKsCABcPAMwCHAvCAgAUABYBEgAUARIDFAMQAxIDEAUSBQ4FEAcOCRAJDAkOCwwLDA0MCwoNCg8IDwgPCA8GEQYRBhMEEwIXAhUCFwAZAIMGFwAKmQLqA38ATxchQwgnGiMwD1AMUDYAdg==",
  "b":"BgABAkqmBIIJGAAYARYBFgEUAxQDEgUSBRIFEAcQCQ4HDgkOCw4LDAsMDQoNCg0KDQgPBg8GDwYRBBEEEQQTBBECEwIVAhMAFQD/AgAZARcBFwEXAxUDEwUTBREFEQcPBw8JDwkNCQ0LDQsLCwsNCQ0JDQcPBw8HDwURAxEDEQMTAxMBEwMVARUAFQHPAwAUEgCWCxEY5gIAERkAowKCAQAJOvECESwrEn8AAJsEgAEALBISLgCeAw==",
  "d":"BgABAkryBgDLAXAREQ8NEQ0PDREJDwkRBw8FDwURAw8DDwERAw8BEQEPACMCHwQfCB0MGw4bEhcUFxgVGhEeDSANJAkmBSgDKgEuAIADABYCFAIUAhQCFAQUBBIGEgYSBhAIEAgQCBAKDgoODAwMDAwMDgoOCg4KEAgQCBIGEgYSBhQEFgQWBBYCGAIYAHwAAKQCERrmAgARFwCnCxcADOsCugJGMgDmA3sAKxERLQCfAwolHBUmBSQKBAA=",
  "e":"BgABAqMBigP+AgAJAgkCCQQHBAcGBwYFCAUIBQgDCgMIAQoDCAEKAQoACgAKAAoCCAIKAggECgQIBAgGCAYGBgQIBAoECAIKAAyiAgAAGQEXARcBFwMVBRMFEwURBxEHDwcPCQ8LDQkNCwsNCw0LDQkNBw8JDwcPBQ8FEQURAxEDEwMTAxMBFQAVARcALwIrBCkIJwwlDiESHxQbGBkaFR4TIA0iCyQJKAMqASwAggMAFAIUABIEFAISBBIEEgQSBhIGEAgQCBAIEAoODA4MDgwODgwQDBAKEAoSChIIFAgUCBYGGAQYBhoCGgQcAh4ALgEqAygFJgkkDSANHhEaFRgXFBsSHQ4fDCUIJwQpAi0AGQEXAxcDFQcTBRMJEQkPCw8LDQ0PDQsNDQ8LEQsRCxEJEwkTCRMJEwcTBxUHFQUVBRUHFQUVBRUHFwcVBRUHCs4BkAMfOEUURxEfMwBvbBhAGBwaBiA=",
  "h":"BgABAUHYBJAGAAYBBgAGAQYDBgEEAwYDBAMEBQQDAgUEBQIFAAUCBQB1AAC5BhIT5wIAFhQAlAsRGOYCABEZAKMCeAAYABgBFgEWARQDFAMSBRIFEgUQBxAJDgcOCQ4LDgsMCwwNCg0KDQoNCA8GDwYPBhEEEQQRBBMEEQITAhUCEwAVAO0FFhPnAgAUEgD+BQ==",
  "g":"BgABArkBkAeACQCNCw8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRAhMCEQQRBBEEEQYRBg8IDwgPCA0KDQoNCg0MCwwLDgsOCQ4JDgkQBxAHEgcSBRIDFAMWAxQBFgEYABgA/gIAFgIWAhQEFgQUBBIGFAgSCBIIEAoSChAKDgwODA4MDg4MDgwODA4KEAgQCBAIEgYSBhIEEgYSBBQCEgIUAhQCOgAQABABDgEQAQ4BEAMOAw4FDgUOBQwFDgcMBQ4HDAkMB4oBUBgACbsCzQYAnAR/AC0RES0AnQMSKy4RgAEA",
  "f":"BgABAUH8A6QJBwAHAAUABwEFAQcBBQEFAwUDBQMDAwMDAwUDAwMFAQUAwQHCAQAWEgDZAhUUwQEAAOMEFhftAgAWFADKCQoSChIKEAoQCg4KDgwOCgwMDAoKDAwMCgwIDAgMCAwIDAYOCAwEDgYMBA4GDAIOBA4CDgQOAg4CDgAOAg4ADgC2AQAcDgDRAhkQowEA",
  "i":"BgACAQlQABISALoIERLqAgAREQC5CBIR6QIAAWELyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4=",
  "j":"BgACAWFKyAoADgIOAgwEDgIKBgwGCgYKCAoGCAgICggIBggGCgYKBAoECgQMBAoCDAIMAgwCDAAMAAwADAEMAQoBDAMKAwoDCgUKBQgFCgUIBwgHCAcICQgJBgkECwQJBA0CCwANAA0ADQELAQ0BCwMJBQsFCQUJBwkFBwcHBwcJBQcFCQUJBQkDCQMLAwkBCwELAQsACwALAAsCCwILAgkCCwIJBAkECQQJBgcGCQYHCAcIBwgHCgUKBQwFCgMMAQwBDgEMAA4BO+YCnwwJEQkRCQ8JDwsNCQ0LDQkLCwsJCQsLCQkLBwsHCwcLBwsFCwcNAwsFDQMLBQ0BDQMNAQ0DDQENAQ0ADQENAA0AVwAbDQDSAhoPQgAIAAgABgAIAgYCCAIGAgYEBgQGBAQEBAQEBgQEBAYCBgC4CRES6gIAEREAowo=",
  "k":"BgABARKoA/QFIAC0AYoD5gIAjwK5BJICwwTfAgDDAbIDFwAAnwMSEeUCABISAJILERLmAgAREQCvBQ==",
  "n":"BgABAW1yggmQAU8GBAgEBgQGBgYCCAQGBAYEBgQIAgYECAQGAggEBgIIBAgCCAQIAggCCAIIAgoACAIKAAgCCgAKAgoADAAKAgwAFgAWARQAFAEUAxQDFAMSAxIFEgUQBRIHEAkOBxAJDgsOCwwLDA0MDQoPCA8IEQgRBhEGEwYVBBUEFQIXAhkCGQDtBRQR5QIAFBAA/AUACAEIAQYBCAMGBQQFBgUEBwQFBAcCBwIHAgcCCQIHAAcACQAHAQcABwMHAQUDBwMFAwUFBQUDBQEFAwcBBwAHAPkFEhHjAgASEgDwCBAA",
  "m":"BgABAZoBfoIJigFbDAwMCg4KDggOCA4IDgYQBhAGEAQQBBAEEAISAhACEgAmASQDJAciCyANHhEcFRwXDg4QDBAKEAwQCBAKEggSBhIGEgYSBBQEEgIUAhICFAAUABQBEgEUARIDEgMSAxIFEgUQBxAHEAcQBw4JDgkOCw4LDAsMDQoNCg8KDwgPCBEIEQYRBBMEEwQTAhMCFQAVAP0FEhHlAgASEgCCBgAIAQgBBgEGAwYFBgUEBQQHBAUEBwIHAgcCBwIJAAcABwAJAAcBBwEHAQUBBwMFAwUDBQMDBQMFAwUBBQEHAQcAgQYSEeUCABISAIIGAAgBCAEGAQYDBgUGBQQFBAcEBQQHAgcCBwIHAgkABwAHAAkABwEHAQcBBQEHAwUDBQMFAwMFAwUDBQEFAQcBBwCBBhIR5QIAEhIA8AgYAA==",
  "l":"BgABAQnAAwDrAgASFgDWCxEa6gIAERkA0wsUFw==",
  "y":"BgABAZ8BogeNAg8ZERkRFxEVExMVERUPFQ8XDRcLGQkZBxsFGwUdAR0BDQALAA0ADQINAAsCDQANAg0CDQILAg0EDQINBA0GDQQNBg0EDQYNCA0GDwgNCA0IDQgPCg0KDwwNDA8MDw4PDqIB7gEQDRALEAkQCQ4JEAcOBw4FDgUOAwwFDgMMAQwBDAEMAQwACgEKAAoACAIIAAgCCAIGAggCBgIGBAYCBgQEAgYEAqIBAQADAAEBAwADAAMABQADAAUAAwAFAAMABQAFAAMABQA3ABMAEwIRABECEwQRAg8EEQQPBBEGDwgNCA8IDQgNCg0MDQwLDAkOCw4JDgcQBxAHEgUSBRQFFAMWARgDGAEaABwA9AUTEuQCABEPAP8FAAUCBQAFAgUEBQIDBAUEAwQDBgMEAQYDBgEGAAgBBgCAAQAAvAYREuICABMPAP0K",
  "q":"BgABAmj0A4YJFgAWARQAEgESAxADEAMOAw4FDgUMBQ4HDgcOBwwJDgmeAU4A2QwWGesCABYaAN4DAwADAAMBAwADAAUAAwADAAMABQAFAAUABwAHAQcACQAVABUCFQATAhUCEwQRAhMEEQQRBhEGDwgPCA8IDQoNDA0MCwwLDgkOCRAJEAkQBxIHEgUUBRYDFgMYARoBGgAcAP4CABYCFgIWBBYEFAQSBhQIEggSCBAKEgoQDA4MDgwODg4ODBAMDgwQChIIEAoSCBIGEgYUBhQEFAQWAhYCFgIWAApbkQYSKy4ReAAAjARTEjkRHykJMwDvAg==",
  "p":"BgABAmiCBIYJFgAWARYBFAEWAxQDEgUUBRIFEgcSBxAJEAkQCQ4LDgsOCwwNDA0KDwoPCg8IEQgRCBEGEwQTBhMCFQQVAhUAFQD9AgAbARkBFwMXAxcDEwUTBxMHEQcRCQ8JDQsNCw0LCw0LDQkPCQ0JDwURBxEFEQURAxMDEQMTARUBEwEVARUBFQAJAAcABwAFAAcABQAFAAMAAwADAAUAAwIDAAMAAwIDAADdAxYZ6wIAFhoA2gyeAU0OCgwIDgoMCA4GDgYMBg4GDgQQBBAEEgQUAhQCFgIWAApcoQMJNB8qNxJVEQCLBHgALhISLADwAg==",
  "o":"BgABAoMB8gOICRYAFgEWARQBFgMUAxIDFAUSBRIHEgcQBxAJEAkOCw4LDgsMDQwNCg8KDwoPCg8IEQgRBhMGEwQTBBMCFQIVABcAiwMAFwEVARUDEwMTAxMFEwcRBxEHDwkPCQ8LDQsNCw0NCw0LDwkNCw8HEQkPBxEHEQcRBRMFEwMTAxUDFQEVABUAFQAVAhUCFQITBBMEEwYTBhEGEQgRCA8KDwoPCg0KDQwNDAsOCw4JDgkQCRAJEgcSBxIFFAUUAxQDFgEWARYAFgCMAwAYAhYCFgQUBBQEFAYUCBIIEggQChAKEAwODA4MDg4MDgwQCg4KEgoQChIIEggSBhQGEgYUBBYEFAIWAhYCFgALYv0CHTZBFEMRHTcAjwMcNUITQhIiOACQAw==",
  "r":"BgACAQRigAkQAA8AAAABShAAhAFXDAwODAwKDgoOCBAIDgYQBhAEEAQQBBAEEAISABACEAAQAA4BEAAQARADEAEQAxADEAUSBRIHFAcUCxQLFA0WDVJFsQHzAQsMDQwLCgkICwgLCAkGCQYJBAkGBwIJBAcCBwQHAAcCBwAFAgcABQAHAQUABQEFAQUBBQEDAQUBAwMDAQMDAwEAmwYSEeMCABISAO4IEAA=",
  "u":"BgABAV2KBwGPAVANCQsHDQcNBw0FCwUNBQ0FDQMPAw8DEQMTARMBFQEVABUAFQITABMEEwITBBMEEQQRBhEGDwYRCA8KDQgPCg0MDQwLDAsOCRALDgcQBxIHEgUUBRQFFAMWAxgBGAEYARoA7gUTEuYCABMPAPsFAAcCBwIFBAcCBQYDBgUGAwgDBgMIAQgBCAEIAQoBCAAIAAoACAIIAggCCAIGBAgEBgQGBgYGBAYCBgQIAggACAD6BRES5AIAEREA7wgPAA==",
  "s":"BgABAasC/gLwBQoDCgMMBQ4DDgUOBRAFEAUSBRAHEgcQCRIJEAkSCxALEAsQDRANDg0ODw4PDA8MDwoRChEIEwYTBBcCFQIXABkBGQEXAxcFFQUTBRMHEwcRCREJDwkNCQ8LDQ0LCwsNCw0JDQkPBw8HDwUPBREDEQMRAREDEQETABEBEwARABMADwIRABECEQIRBBMCEwQVBBUEFQYVBhMIFwgVChUKFQxgsAIIAwYDCAMKAQgDCAMKAQoDCgEKAwoBCgMKAQwDCgEKAwoBDAMKAQoBCgEMAQoACgEKAAoBCgAKAQgACgAIAQgABgoECAIKAgoCCgAMAQoBDAUEBwIHBAcEBwIHBAkECQQJBAkECQYLBAkGCwYJBgsGCwYJCAsGCwgJBgsICQgLCAkICwgJCgkKCQoJCgcKCQwHDAcMBwwFDAcMAw4FDAMOAw4BDgMQARAAEAESABIAEgIQAg4CDgIOBA4CDgQMBAwEDAQMBgoECgYKBgoGCgYIBggGCAgIBggGBgYIBgYGBgYGBgYGBAgGBgQIBAYECAQQChIIEggSBhIEEgQSBBQCFAISABQAEgASABIAEgESARIBEAEQAxIDDgMQAxADDgUOBQwDDAMMAwoDCAMIAQYBe6cCAwIDAgUAAwIFAgUCBwIFAgcCBQIHAgUCBwIHAAUCBwIHAgUABwIHAgcABQIHAAcCBwAFAgUABQIFAAUABQIDAAEAAQABAQEAAQEBAQEBAQEBAQEDAQEAAwEBAQMAAwEDAAMBAwADAQMAAwABAQMAAwADAAEAAwIBAAMCAQQDAgE=",
  "t":"BgABAUe8BLACWAAaEADRAhsOaQANAA0ADwINAA0CDQANAg0CDQINBA0CCwYNBA0GCwYNBgsIDQgLCAsKCwgJDAsKCQwJDAkOCQ4HEAcSBxIHEgUUAOAEawAVEQDWAhYTbAAAygIVFOYCABUXAMUCogEAFhQA1QIVEqEBAADzAwIFBAMEBQQDBAMEAwYDBgMGAwYBCAEGAQgBBgEIAAgA",
  "w":"BgABARz8BsAEINYCKNgBERLuAgARD+8B3QgSEc0CABQSW7YCV7UCFBHJAgASEpMC3AgREvACABERmAHxBDDaAVeYAxES7gIAEREo1QE81wIIAA==",
  "z":"BgABAQ6cA9AGuQIAFw8AzAIaC9QFAAAr9wKjBuACABYQAMsCGQyZBgCaA9AG"
   }';
BEGIN

  IF font IS NULL THEN
    font := font_default;
END IF;

  -- For character spacing, use m as guide size
  geom := ST_GeomFromTWKB(decode(font->>'m', 'base64'));
  m_width := ST_XMax(geom) - ST_XMin(geom);
  spacing := m_width / 12;

  letterarray := regexp_split_to_array(replace(letters, ' ', E'\t'), E'');
  FOREACH letter IN ARRAY letterarray
  LOOP
    geom := ST_GeomFromTWKB(decode(font->>(letter), 'base64'));
    -- Chars are not already zeroed out, so do it now
    geom := ST_Translate(geom, -1 * ST_XMin(geom), 0.0);
    -- unknown characters are treated as spaces
    IF geom IS NULL THEN
      -- spaces are a "quarter m" in width
      width := m_width / 3.5;
ELSE
      width := (ST_XMax(geom) - ST_XMin(geom));
END IF;
    geom := ST_Translate(geom, position, 0.0);
    -- Tighten up spacing when characters have a large gap
    -- between them like Yo or To
    adjustment := 0.0;
    IF prevgeom IS NOT NULL AND geom IS NOT NULL THEN
      dist = ST_Distance(prevgeom, geom);
      IF dist > spacing THEN
        adjustment = spacing - dist;
        geom := ST_Translate(geom, adjustment, 0.0);
END IF;
END IF;
    prevgeom := geom;
position := position + width + spacing + adjustment;
    wordarr := array_append(wordarr, geom);
END LOOP;
  -- apply the start point and scaling options
  wordgeom := ST_CollectionExtract(ST_Collect(wordarr));
  wordgeom := ST_Scale(wordgeom,
                text_height/font_default_height,
                text_height/font_default_height);
return wordgeom;
END;
$$;

comment on function public.st_letters(text, json) is 'args:  letters,  font - Returns the input letters rendered as geometry with a default start position at the origin and default text height of 100.';

alter function public.st_letters(text, json) owner to postgres;

create function public.levenshtein(text, text) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.levenshtein(text, text) owner to postgres;

create function public.levenshtein(text, text, integer, integer, integer) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.levenshtein(text, text, integer, integer, integer) owner to postgres;

create function public.levenshtein_less_equal(text, text, integer) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.levenshtein_less_equal(text, text, integer) owner to postgres;

create function public.levenshtein_less_equal(text, text, integer, integer, integer, integer) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.levenshtein_less_equal(text, text, integer, integer, integer, integer) owner to postgres;

create function public.metaphone(text, integer) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.metaphone(text, integer) owner to postgres;

create function public.soundex(text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.soundex(text) owner to postgres;

create function public.text_soundex(text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.text_soundex(text) owner to postgres;

create function public.difference(text, text) returns integer
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.difference(text, text) owner to postgres;

create function public.dmetaphone(text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.dmetaphone(text) owner to postgres;

create function public.dmetaphone_alt(text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.dmetaphone_alt(text) owner to postgres;

create function public.daitch_mokotoff(text) returns text[]
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

alter function public.daitch_mokotoff(text) owner to postgres;

create operator public.= (procedure = public.geometry_eq, leftarg = geometry, rightarg = geometry, commutator = public.=, join = contjoinsel, restrict = contsel, hashes, merges);

alter operator public.=(geometry, geometry) owner to postgres;

create operator public.&& (procedure = public.geometry_overlaps, leftarg = geometry, rightarg = geometry, commutator = public.&&, join = public.gserialized_gist_joinsel_2d, restrict = public.gserialized_gist_sel_2d);

alter operator public.&&(geometry, geometry) owner to postgres;

create operator public.~= (procedure = public.geometry_same, leftarg = geometry, rightarg = geometry, join = contjoinsel, restrict = contsel);

alter operator public.~=(geometry, geometry) owner to postgres;

create operator public.<-> (procedure = public.geometry_distance_centroid, leftarg = geometry, rightarg = geometry, commutator = public.<->);

alter operator public.<->(geometry, geometry) owner to postgres;

create operator public.<#> (procedure = public.geometry_distance_box, leftarg = geometry, rightarg = geometry, commutator = public.<#>);

alter operator public.<#>(geometry, geometry) owner to postgres;

create operator public.&< (procedure = public.geometry_overleft, leftarg = geometry, rightarg = geometry, join = positionjoinsel, restrict = positionsel);

alter operator public.&<(geometry, geometry) owner to postgres;

create operator public.&<| (procedure = public.geometry_overbelow, leftarg = geometry, rightarg = geometry, join = positionjoinsel, restrict = positionsel);

alter operator public.&<|(geometry, geometry) owner to postgres;

create operator public.&> (procedure = public.geometry_overright, leftarg = geometry, rightarg = geometry, join = positionjoinsel, restrict = positionsel);

alter operator public.&>(geometry, geometry) owner to postgres;

create operator public.|&> (procedure = public.geometry_overabove, leftarg = geometry, rightarg = geometry, join = positionjoinsel, restrict = positionsel);

alter operator public.|&>(geometry, geometry) owner to postgres;

create operator public.&&& (procedure = public.geometry_overlaps_nd, leftarg = geometry, rightarg = geometry, commutator = public.&&&, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.&&&(geometry, geometry) owner to postgres;

create operator public.~~= (procedure = public.geometry_same_nd, leftarg = geometry, rightarg = geometry, commutator = public.~~=, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.~~=(geometry, geometry) owner to postgres;

create operator public.<<->> (procedure = public.geometry_distance_centroid_nd, leftarg = geometry, rightarg = geometry, commutator = public.<<->>);

alter operator public.<<->>(geometry, geometry) owner to postgres;

create operator public.|=| (procedure = public.geometry_distance_cpa, leftarg = geometry, rightarg = geometry, commutator = public.|=|);

alter operator public.|=|(geometry, geometry) owner to postgres;

create operator public.&& (procedure = public.geography_overlaps, leftarg = geography, rightarg = geography, commutator = public.&&, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.&&(geography, geography) owner to postgres;

create operator public.<-> (procedure = public.geography_distance_knn, leftarg = geography, rightarg = geography, commutator = public.<->);

alter operator public.<->(geography, geography) owner to postgres;

create operator public.&& (procedure = public.overlaps_geog, leftarg = gidx, rightarg = gidx, commutator = public.&&);

alter operator public.&&(gidx, gidx) owner to postgres;

create operator public.= (procedure = public.geography_eq, leftarg = geography, rightarg = geography, commutator = public.=, join = contjoinsel, restrict = contsel);

alter operator public.=(geography, geography) owner to postgres;

create operator public.&& (procedure = public.overlaps_2d, leftarg = box2df, rightarg = box2df, commutator = public.&&);

alter operator public.&&(box2df, box2df) owner to postgres;

create operator public.&&& (procedure = public.overlaps_nd, leftarg = gidx, rightarg = gidx, commutator = public.&&&);

alter operator public.&&&(gidx, gidx) owner to postgres;

create operator public.&/& (procedure = public.geometry_overlaps_3d, leftarg = geometry, rightarg = geometry, commutator = public.&/&, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.&/&(geometry, geometry) owner to postgres;

create operator public.~== (procedure = public.geometry_same_3d, leftarg = geometry, rightarg = geometry, commutator = public.~==, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.~==(geometry, geometry) owner to postgres;

create aggregate public.st_extent(geometry) (
    sfunc = public.st_combinebbox,
    stype = box3d,
    finalfunc = public.box2d,
    combinefunc = public.st_combinebbox,
    parallel = safe
    );

comment on aggregate public.st_extent(geometry) is 'args: geomfield - Aggregate function that returns the bounding box of geometries.';

alter aggregate public.st_extent(geometry) owner to postgres;

create aggregate public.st_3dextent(geometry) (
    sfunc = public.st_combinebbox,
    stype = box3d,
    combinefunc = public.st_combinebbox,
    parallel = safe
    );

comment on aggregate public.st_3dextent(geometry) is 'args: geomfield - Aggregate function that returns the 3D bounding box of geometries.';

alter aggregate public.st_3dextent(geometry) owner to postgres;

create aggregate public.st_memcollect(geometry) (
    sfunc = public.st_collect,
    stype = geometry,
    combinefunc = public.st_collect,
    parallel = safe
    );

alter aggregate public.st_memcollect(geometry) owner to postgres;

create aggregate public.st_memunion(geometry) (
    sfunc = public.st_union,
    stype = geometry,
    combinefunc = public.st_union,
    parallel = safe
    );

comment on aggregate public.st_memunion(geometry) is 'args: geomfield - Aggregate function which unions geometries in a memory-efficent but slower way';

alter aggregate public.st_memunion(geometry) owner to postgres;

create aggregate public.st_union(geometry) (
    sfunc = public.pgis_geometry_union_parallel_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_union_parallel_finalfn,
    combinefunc = public.pgis_geometry_union_parallel_combinefn,
    serialfunc = public.pgis_geometry_union_parallel_serialfn,
    deserialfunc = public.pgis_geometry_union_parallel_deserialfn,
    parallel = safe
    );

comment on aggregate public.st_union(geometry) is 'args: g1field - Computes a geometry representing the point-set union of the input geometries.';

alter aggregate public.st_union(geometry) owner to postgres;

create aggregate public.st_union(geometry, gridsize double precision) (
    sfunc = public.pgis_geometry_union_parallel_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_union_parallel_finalfn,
    combinefunc = public.pgis_geometry_union_parallel_combinefn,
    serialfunc = public.pgis_geometry_union_parallel_serialfn,
    deserialfunc = public.pgis_geometry_union_parallel_deserialfn,
    parallel = safe
    );

comment on aggregate public.st_union(geometry, double precision) is 'args: g1field, gridSize - Computes a geometry representing the point-set union of the input geometries.';

alter aggregate public.st_union(geometry, gridsize double precision) owner to postgres;

create aggregate public.st_collect(geometry) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_collect_finalfn,
    parallel = safe
    );

comment on aggregate public.st_collect(geometry) is 'args: g1field - Creates a GeometryCollection or Multi* geometry from a set of geometries.';

alter aggregate public.st_collect(geometry) owner to postgres;

create aggregate public.st_clusterintersecting(geometry) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_clusterintersecting_finalfn,
    parallel = safe
    );

comment on aggregate public.st_clusterintersecting(geometry) is 'args: g - Aggregate function that clusters input geometries into connected sets.';

alter aggregate public.st_clusterintersecting(geometry) owner to postgres;

create aggregate public.st_clusterwithin(geometry, double precision) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_clusterwithin_finalfn,
    parallel = safe
    );

comment on aggregate public.st_clusterwithin(geometry, double precision) is 'args: g, distance - Aggregate function that clusters geometries by separation distance.';

alter aggregate public.st_clusterwithin(geometry, double precision) owner to postgres;

create aggregate public.st_polygonize(geometry) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_polygonize_finalfn,
    parallel = safe
    );

comment on aggregate public.st_polygonize(geometry) is 'args: geomfield - Computes a collection of polygons formed from the linework of a set of geometries.';

alter aggregate public.st_polygonize(geometry) owner to postgres;

create aggregate public.st_makeline(geometry) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_makeline_finalfn,
    parallel = safe
    );

comment on aggregate public.st_makeline(geometry) is 'args: geoms - Creates a LineString from Point, MultiPoint, or LineString geometries.';

alter aggregate public.st_makeline(geometry) owner to postgres;

create aggregate public.st_coverageunion(geometry) (
    sfunc = public.pgis_geometry_accum_transfn,
    stype = internal,
    finalfunc = public.pgis_geometry_coverageunion_finalfn,
    parallel = safe
    );

comment on aggregate public.st_coverageunion(geometry) is 'args: geom - Computes the union of a set of polygons forming a coverage by removing shared edges.';

alter aggregate public.st_coverageunion(geometry) owner to postgres;

create aggregate public.st_asmvt(anyelement) (
    sfunc = public.pgis_asmvt_transfn,
    stype = internal,
    finalfunc = public.pgis_asmvt_finalfn,
    combinefunc = public.pgis_asmvt_combinefn,
    serialfunc = public.pgis_asmvt_serialfn,
    deserialfunc = public.pgis_asmvt_deserialfn,
    parallel = safe
    );

alter aggregate public.st_asmvt(anyelement) owner to postgres;

create aggregate public.st_asmvt(anyelement, text) (
    sfunc = public.pgis_asmvt_transfn,
    stype = internal,
    finalfunc = public.pgis_asmvt_finalfn,
    combinefunc = public.pgis_asmvt_combinefn,
    serialfunc = public.pgis_asmvt_serialfn,
    deserialfunc = public.pgis_asmvt_deserialfn,
    parallel = safe
    );

alter aggregate public.st_asmvt(anyelement, text) owner to postgres;

create aggregate public.st_asmvt(anyelement, text, integer) (
    sfunc = public.pgis_asmvt_transfn,
    stype = internal,
    finalfunc = public.pgis_asmvt_finalfn,
    combinefunc = public.pgis_asmvt_combinefn,
    serialfunc = public.pgis_asmvt_serialfn,
    deserialfunc = public.pgis_asmvt_deserialfn,
    parallel = safe
    );

alter aggregate public.st_asmvt(anyelement, text, integer) owner to postgres;

create aggregate public.st_asmvt(anyelement, text, integer, text) (
    sfunc = public.pgis_asmvt_transfn,
    stype = internal,
    finalfunc = public.pgis_asmvt_finalfn,
    combinefunc = public.pgis_asmvt_combinefn,
    serialfunc = public.pgis_asmvt_serialfn,
    deserialfunc = public.pgis_asmvt_deserialfn,
    parallel = safe
    );

alter aggregate public.st_asmvt(anyelement, text, integer, text) owner to postgres;

create aggregate public.st_asmvt(anyelement, text, integer, text, text) (
    sfunc = public.pgis_asmvt_transfn,
    stype = internal,
    finalfunc = public.pgis_asmvt_finalfn,
    combinefunc = public.pgis_asmvt_combinefn,
    serialfunc = public.pgis_asmvt_serialfn,
    deserialfunc = public.pgis_asmvt_deserialfn,
    parallel = safe
    );

alter aggregate public.st_asmvt(anyelement, text, integer, text, text) owner to postgres;

create aggregate public.st_asgeobuf(anyelement) (
    sfunc = public.pgis_asgeobuf_transfn,
    stype = internal,
    finalfunc = public.pgis_asgeobuf_finalfn,
    parallel = safe
    );

alter aggregate public.st_asgeobuf(anyelement) owner to postgres;

create aggregate public.st_asgeobuf(anyelement, text) (
    sfunc = public.pgis_asgeobuf_transfn,
    stype = internal,
    finalfunc = public.pgis_asgeobuf_finalfn,
    parallel = safe
    );

alter aggregate public.st_asgeobuf(anyelement, text) owner to postgres;

create aggregate public.st_asflatgeobuf(anyelement) (
    sfunc = public.pgis_asflatgeobuf_transfn,
    stype = internal,
    finalfunc = public.pgis_asflatgeobuf_finalfn,
    parallel = safe
    );

alter aggregate public.st_asflatgeobuf(anyelement) owner to postgres;

create aggregate public.st_asflatgeobuf(anyelement, boolean) (
    sfunc = public.pgis_asflatgeobuf_transfn,
    stype = internal,
    finalfunc = public.pgis_asflatgeobuf_finalfn,
    parallel = safe
    );

alter aggregate public.st_asflatgeobuf(anyelement, boolean) owner to postgres;

create aggregate public.st_asflatgeobuf(anyelement, boolean, text) (
    sfunc = public.pgis_asflatgeobuf_transfn,
    stype = internal,
    finalfunc = public.pgis_asflatgeobuf_finalfn,
    parallel = safe
    );

alter aggregate public.st_asflatgeobuf(anyelement, boolean, text) owner to postgres;

create operator family public.btree_geometry_ops using btree;

alter operator family public.btree_geometry_ops using btree add
    operator 2 public.<=(geometry, geometry),
    operator 5 public.>(geometry, geometry),
    operator 3 public.=(geometry, geometry),
    operator 4 public.>=(geometry, geometry),
    operator 1 public.<(geometry, geometry),
    function 2(geometry, geometry) public.geometry_sortsupport(internal),
    function 1(geometry, geometry) public.geometry_cmp(geom1 geometry, geom2 geometry);

alter operator family public.btree_geometry_ops using btree owner to postgres;

create operator class public.btree_geometry_ops default for type geometry using btree as
    operator 3 public.=(geometry, geometry),
    operator 4 public.>=(geometry, geometry),
    operator 5 public.>(geometry, geometry),
    operator 2 public.<=(geometry, geometry),
    operator 1 public.<(geometry, geometry),
    function 1(geometry, geometry) public.geometry_cmp(geom1 geometry, geom2 geometry);

alter operator class public.btree_geometry_ops using btree owner to postgres;

create operator family public.hash_geometry_ops using hash;

alter operator family public.hash_geometry_ops using hash add
    operator 1 public.=(geometry, geometry),
    function 1(geometry, geometry) public.geometry_hash(geometry);

alter operator family public.hash_geometry_ops using hash owner to postgres;

create operator class public.hash_geometry_ops default for type geometry using hash as
    operator 1 public.=(geometry, geometry),
    function 1(geometry, geometry) public.geometry_hash(geometry);

alter operator class public.hash_geometry_ops using hash owner to postgres;

create operator family public.gist_geometry_ops_2d using gist;

alter operator family public.gist_geometry_ops_2d using gist add
    operator 14 public.<#>(geometry, geometry) for order by float_ops,
    operator 1 public.<<(geometry, geometry),
    operator 2 public.&<(geometry, geometry),
    operator 3 public.&&(geometry, geometry),
    operator 4 public.&>(geometry, geometry),
    operator 5 public.>>(geometry, geometry),
    operator 6 public.~=(geometry, geometry),
    operator 7 public.~(geometry, geometry),
    operator 8 public.@(geometry, geometry),
    operator 9 public.&<|(geometry, geometry),
    operator 10 public.<<|(geometry, geometry),
    operator 11 public.|>>(geometry, geometry),
    operator 12 public.|&>(geometry, geometry),
    operator 13 public.<->(geometry, geometry) for order by float_ops,
    function 11(geometry, geometry) public.geometry_gist_sortsupport_2d(internal),
    function 8(geometry, geometry) public.geometry_gist_distance_2d(internal, geometry, integer),
    function 1(geometry, geometry) public.geometry_gist_consistent_2d(internal, geometry, integer),
    function 7(geometry, geometry) public.geometry_gist_same_2d(geom1 geometry, geom2 geometry, internal),
    function 6(geometry, geometry) public.geometry_gist_picksplit_2d(internal, internal),
    function 5(geometry, geometry) public.geometry_gist_penalty_2d(internal, internal, internal),
    function 4(geometry, geometry) public.geometry_gist_decompress_2d(internal),
    function 3(geometry, geometry) public.geometry_gist_compress_2d(internal),
    function 2(geometry, geometry) public.geometry_gist_union_2d(bytea, internal);

alter operator family public.gist_geometry_ops_2d using gist owner to postgres;

create operator class public.gist_geometry_ops_2d default for type geometry using gist as storage box2df function 5(geometry, geometry) public.geometry_gist_penalty_2d(internal, internal, internal),
	function 1(geometry, geometry) public.geometry_gist_consistent_2d(internal, geometry, integer),
	function 2(geometry, geometry) public.geometry_gist_union_2d(bytea, internal),
	function 7(geometry, geometry) public.geometry_gist_same_2d(geom1 geometry, geom2 geometry, internal),
	function 6(geometry, geometry) public.geometry_gist_picksplit_2d(internal, internal);

alter operator class public.gist_geometry_ops_2d using gist owner to postgres;

create operator family public.gist_geometry_ops_nd using gist;

alter operator family public.gist_geometry_ops_nd using gist add
    operator 8 public.@@(geometry, geometry),
    operator 20 public.|=|(geometry, geometry) for order by float_ops,
    operator 3 public.&&&(geometry, geometry),
    operator 6 public.~~=(geometry, geometry),
    operator 13 public.<<->>(geometry, geometry) for order by float_ops,
    operator 7 public.~~(geometry, geometry),
    function 7(geometry, geometry) public.geometry_gist_same_nd(geometry, geometry, internal),
    function 6(geometry, geometry) public.geometry_gist_picksplit_nd(internal, internal),
    function 4(geometry, geometry) public.geometry_gist_decompress_nd(internal),
    function 3(geometry, geometry) public.geometry_gist_compress_nd(internal),
    function 2(geometry, geometry) public.geometry_gist_union_nd(bytea, internal),
    function 1(geometry, geometry) public.geometry_gist_consistent_nd(internal, geometry, integer),
    function 8(geometry, geometry) public.geometry_gist_distance_nd(internal, geometry, integer),
    function 5(geometry, geometry) public.geometry_gist_penalty_nd(internal, internal, internal);

alter operator family public.gist_geometry_ops_nd using gist owner to postgres;

create operator class public.gist_geometry_ops_nd for type geometry using gist as storage gidx function 7(geometry, geometry) public.geometry_gist_same_nd(geometry, geometry, internal),
	function 5(geometry, geometry) public.geometry_gist_penalty_nd(internal, internal, internal),
	function 6(geometry, geometry) public.geometry_gist_picksplit_nd(internal, internal),
	function 1(geometry, geometry) public.geometry_gist_consistent_nd(internal, geometry, integer),
	function 2(geometry, geometry) public.geometry_gist_union_nd(bytea, internal);

alter operator class public.gist_geometry_ops_nd using gist owner to postgres;

create operator family public.gist_geography_ops using gist;

alter operator family public.gist_geography_ops using gist add
    operator 3 public.&&(geography, geography),
    operator 13 public.<->(geography, geography) for order by float_ops,
    function 4(geography, geography) public.geography_gist_decompress(internal),
    function 8(geography, geography) public.geography_gist_distance(internal, geography, integer),
    function 1(geography, geography) public.geography_gist_consistent(internal, geography, integer),
    function 2(geography, geography) public.geography_gist_union(bytea, internal),
    function 3(geography, geography) public.geography_gist_compress(internal),
    function 5(geography, geography) public.geography_gist_penalty(internal, internal, internal),
    function 6(geography, geography) public.geography_gist_picksplit(internal, internal),
    function 7(geography, geography) public.geography_gist_same(box2d, box2d, internal);

alter operator family public.gist_geography_ops using gist owner to postgres;

create operator class public.gist_geography_ops default for type geography using gist as storage gidx function 1(geography, geography) public.geography_gist_consistent(internal, geography, integer),
	function 6(geography, geography) public.geography_gist_picksplit(internal, internal),
	function 7(geography, geography) public.geography_gist_same(box2d, box2d, internal),
	function 2(geography, geography) public.geography_gist_union(bytea, internal),
	function 5(geography, geography) public.geography_gist_penalty(internal, internal, internal);

alter operator class public.gist_geography_ops using gist owner to postgres;

create operator family public.brin_geography_inclusion_ops using brin;

alter operator family public.brin_geography_inclusion_ops using brin add
    operator 3 public.&&(gidx, gidx),
    operator 3 public.&&(geography, geography),
    operator 3 public.&&(gidx, geography),
    operator 3 public.&&(geography, gidx),
    function 2(geography, geography) public.geog_brin_inclusion_add_value(internal, internal, internal, internal);

alter operator family public.brin_geography_inclusion_ops using brin owner to postgres;

create operator class public.brin_geography_inclusion_ops default for type geography using brin as storage gidx operator 3 public.&&(geography, gidx),
	operator 3 public.&&(gidx, gidx),
	operator 3 public.&&(gidx, geography),
	operator 3 public.&&(geography, geography),
	function 2(geography, geography) public.geog_brin_inclusion_add_value(internal, internal, internal, internal),
	function 4(geography, geography) brin_inclusion_union(internal,internal,internal),
	function 3(geography, geography) brin_inclusion_consistent(internal,internal,internal),
	function 1(geography, geography) brin_inclusion_opcinfo(internal);

alter operator class public.brin_geography_inclusion_ops using brin owner to postgres;

create operator family public.btree_geography_ops using btree;

alter operator family public.btree_geography_ops using btree add
    operator 5 public.>(geography, geography),
    operator 3 public.=(geography, geography),
    operator 1 public.<(geography, geography),
    operator 4 public.>=(geography, geography),
    operator 2 public.<=(geography, geography),
    function 1(geography, geography) public.geography_cmp(geography, geography);

alter operator family public.btree_geography_ops using btree owner to postgres;

create operator class public.btree_geography_ops default for type geography using btree as
    operator 3 public.=(geography, geography),
    operator 5 public.>(geography, geography),
    operator 1 public.<(geography, geography),
    operator 4 public.>=(geography, geography),
    operator 2 public.<=(geography, geography),
    function 1(geography, geography) public.geography_cmp(geography, geography);

alter operator class public.btree_geography_ops using btree owner to postgres;

create operator family public.brin_geometry_inclusion_ops_2d using brin;

alter operator family public.brin_geometry_inclusion_ops_2d using brin add
    operator 8 public.@(geometry, box2df),
    operator 7 public.~(geometry, geometry),
    operator 8 public.@(geometry, geometry),
    operator 7 public.~(geometry, box2df),
    operator 3 public.&&(box2df, box2df),
    operator 3 public.&&(box2df, geometry),
    operator 8 public.@(box2df, geometry),
    operator 8 public.@(box2df, box2df),
    operator 7 public.~(box2df, geometry),
    operator 7 public.~(box2df, box2df),
    operator 3 public.&&(geometry, geometry),
    operator 3 public.&&(geometry, box2df),
    function 2(geometry, geometry) public.geom2d_brin_inclusion_add_value(internal, internal, internal, internal);

alter operator family public.brin_geometry_inclusion_ops_2d using brin owner to postgres;

create operator class public.brin_geometry_inclusion_ops_2d default for type geometry using brin as storage box2df operator 3 public.&&(geometry, geometry),
	operator 8 public.@(box2df, box2df),
	operator 3 public.&&(geometry, box2df),
	operator 8 public.@(box2df, geometry),
	operator 3 public.&&(box2df, geometry),
	operator 8 public.@(geometry, box2df),
	operator 3 public.&&(box2df, box2df),
	operator 8 public.@(geometry, geometry),
	operator 7 public.~(geometry, geometry),
	operator 7 public.~(geometry, box2df),
	operator 7 public.~(box2df, geometry),
	operator 7 public.~(box2df, box2df),
	function 4(geometry, geometry) brin_inclusion_union(internal,internal,internal),
	function 3(geometry, geometry) brin_inclusion_consistent(internal,internal,internal),
	function 2(geometry, geometry) public.geom2d_brin_inclusion_add_value(internal, internal, internal, internal),
	function 1(geometry, geometry) brin_inclusion_opcinfo(internal);

alter operator class public.brin_geometry_inclusion_ops_2d using brin owner to postgres;

create operator family public.brin_geometry_inclusion_ops_3d using brin;

alter operator family public.brin_geometry_inclusion_ops_3d using brin add
    operator 3 public.&&&(geometry, geometry),
    operator 3 public.&&&(gidx, geometry),
    operator 3 public.&&&(geometry, gidx),
    operator 3 public.&&&(gidx, gidx),
    function 2(geometry, geometry) public.geom3d_brin_inclusion_add_value(internal, internal, internal, internal);

alter operator family public.brin_geometry_inclusion_ops_3d using brin owner to postgres;

create operator class public.brin_geometry_inclusion_ops_3d for type geometry using brin as storage gidx operator 3 public.&&&(geometry, gidx),
	operator 3 public.&&&(gidx, gidx),
	operator 3 public.&&&(gidx, geometry),
	operator 3 public.&&&(geometry, geometry),
	function 3(geometry, geometry) brin_inclusion_consistent(internal,internal,internal),
	function 4(geometry, geometry) brin_inclusion_union(internal,internal,internal),
	function 2(geometry, geometry) public.geom3d_brin_inclusion_add_value(internal, internal, internal, internal),
	function 1(geometry, geometry) brin_inclusion_opcinfo(internal);

alter operator class public.brin_geometry_inclusion_ops_3d using brin owner to postgres;

create operator family public.brin_geometry_inclusion_ops_4d using brin;

alter operator family public.brin_geometry_inclusion_ops_4d using brin add
    operator 3 public.&&&(gidx, gidx),
    operator 3 public.&&&(geometry, geometry),
    operator 3 public.&&&(geometry, gidx),
    operator 3 public.&&&(gidx, geometry),
    function 2(geometry, geometry) public.geom4d_brin_inclusion_add_value(internal, internal, internal, internal);

alter operator family public.brin_geometry_inclusion_ops_4d using brin owner to postgres;

create operator class public.brin_geometry_inclusion_ops_4d for type geometry using brin as storage gidx operator 3 public.&&&(gidx, gidx),
	operator 3 public.&&&(gidx, geometry),
	operator 3 public.&&&(geometry, geometry),
	operator 3 public.&&&(geometry, gidx),
	function 2(geometry, geometry) public.geom4d_brin_inclusion_add_value(internal, internal, internal, internal),
	function 3(geometry, geometry) brin_inclusion_consistent(internal,internal,internal),
	function 1(geometry, geometry) brin_inclusion_opcinfo(internal),
	function 4(geometry, geometry) brin_inclusion_union(internal,internal,internal);

alter operator class public.brin_geometry_inclusion_ops_4d using brin owner to postgres;

create operator family public.spgist_geometry_ops_2d using spgist;

alter operator family public.spgist_geometry_ops_2d using spgist add
    operator 1 public.<<(geometry, geometry),
    operator 2 public.&<(geometry, geometry),
    operator 3 public.&&(geometry, geometry),
    operator 4 public.&>(geometry, geometry),
    operator 5 public.>>(geometry, geometry),
    operator 6 public.~=(geometry, geometry),
    operator 7 public.~(geometry, geometry),
    operator 8 public.@(geometry, geometry),
    operator 9 public.&<|(geometry, geometry),
    operator 10 public.<<|(geometry, geometry),
    operator 11 public.|>>(geometry, geometry),
    operator 12 public.|&>(geometry, geometry),
    function 6(geometry, geometry) public.geometry_spgist_compress_2d(internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_2d(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_2d(internal, internal),
    function 3(geometry, geometry) public.geometry_spgist_picksplit_2d(internal, internal),
    function 2(geometry, geometry) public.geometry_spgist_choose_2d(internal, internal),
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_2d(internal, internal);

alter operator family public.spgist_geometry_ops_2d using spgist owner to postgres;

create operator class public.spgist_geometry_ops_2d default for type geometry using spgist as
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_2d(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_2d(internal, internal),
    function 2(geometry, geometry) public.geometry_spgist_choose_2d(internal, internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_2d(internal, internal),
    function 3(geometry, geometry) public.geometry_spgist_picksplit_2d(internal, internal);

alter operator class public.spgist_geometry_ops_2d using spgist owner to postgres;

create operator family public.spgist_geometry_ops_3d using spgist;

alter operator family public.spgist_geometry_ops_3d using spgist add
    operator 3 public.&/&(geometry, geometry),
    operator 6 public.~==(geometry, geometry),
    operator 7 public.@>>(geometry, geometry),
    operator 8 public.<<@(geometry, geometry),
    function 2(geometry, geometry) public.geometry_spgist_choose_3d(internal, internal),
    function 3(geometry, geometry) public.geometry_spgist_picksplit_3d(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_3d(internal, internal),
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_3d(internal, internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_3d(internal, internal),
    function 6(geometry, geometry) public.geometry_spgist_compress_3d(internal);

alter operator family public.spgist_geometry_ops_3d using spgist owner to postgres;

create operator class public.spgist_geometry_ops_3d for type geometry using spgist as
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_3d(internal, internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_3d(internal, internal),
    function 2(geometry, geometry) public.geometry_spgist_choose_3d(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_3d(internal, internal),
    function 3(geometry, geometry) public.geometry_spgist_picksplit_3d(internal, internal);

alter operator class public.spgist_geometry_ops_3d using spgist owner to postgres;

create operator family public.spgist_geometry_ops_nd using spgist;

alter operator family public.spgist_geometry_ops_nd using spgist add
    operator 3 public.&&&(geometry, geometry),
    operator 6 public.~~=(geometry, geometry),
    operator 7 public.~~(geometry, geometry),
    operator 8 public.@@(geometry, geometry),
    function 6(geometry, geometry) public.geometry_spgist_compress_nd(internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_nd(internal, internal),
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_nd(internal, internal),
    function 3(geometry, geometry) public.geometry_spgist_picksplit_nd(internal, internal),
    function 2(geometry, geometry) public.geometry_spgist_choose_nd(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_nd(internal, internal);

alter operator family public.spgist_geometry_ops_nd using spgist owner to postgres;

create operator class public.spgist_geometry_ops_nd for type geometry using spgist as
    function 3(geometry, geometry) public.geometry_spgist_picksplit_nd(internal, internal),
    function 2(geometry, geometry) public.geometry_spgist_choose_nd(internal, internal),
    function 1(geometry, geometry) public.geometry_spgist_config_nd(internal, internal),
    function 5(geometry, geometry) public.geometry_spgist_leaf_consistent_nd(internal, internal),
    function 4(geometry, geometry) public.geometry_spgist_inner_consistent_nd(internal, internal);

alter operator class public.spgist_geometry_ops_nd using spgist owner to postgres;

create operator family public.spgist_geography_ops_nd using spgist;

alter operator family public.spgist_geography_ops_nd using spgist add
    operator 3 public.&&(geography, geography),
    function 6(geography, geography) public.geography_spgist_compress_nd(internal),
    function 4(geography, geography) public.geography_spgist_inner_consistent_nd(internal, internal),
    function 1(geography, geography) public.geography_spgist_config_nd(internal, internal),
    function 2(geography, geography) public.geography_spgist_choose_nd(internal, internal),
    function 5(geography, geography) public.geography_spgist_leaf_consistent_nd(internal, internal),
    function 3(geography, geography) public.geography_spgist_picksplit_nd(internal, internal);

alter operator family public.spgist_geography_ops_nd using spgist owner to postgres;

create operator class public.spgist_geography_ops_nd default for type geography using spgist as
    function 1(geography, geography) public.geography_spgist_config_nd(internal, internal),
    function 2(geography, geography) public.geography_spgist_choose_nd(internal, internal),
    function 3(geography, geography) public.geography_spgist_picksplit_nd(internal, internal),
    function 4(geography, geography) public.geography_spgist_inner_consistent_nd(internal, internal),
    function 5(geography, geography) public.geography_spgist_leaf_consistent_nd(internal, internal);

alter operator class public.spgist_geography_ops_nd using spgist owner to postgres;

-- Cyclic dependencies found

create operator public.&&& (procedure = public.overlaps_nd, leftarg = geometry, rightarg = gidx, commutator = public.&&&);

alter operator public.&&&(geometry, gidx) owner to postgres;

create operator public.&&& (procedure = public.overlaps_nd, leftarg = gidx, rightarg = geometry, commutator = public.&&&);

alter operator public.&&&(gidx, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.&& (procedure = public.overlaps_2d, leftarg = box2df, rightarg = geometry, commutator = public.&&);

alter operator public.&&(box2df, geometry) owner to postgres;

create operator public.&& (procedure = public.overlaps_2d, leftarg = geometry, rightarg = box2df, commutator = public.&&);

alter operator public.&&(geometry, box2df) owner to postgres;

-- Cyclic dependencies found

create operator public.&& (procedure = public.overlaps_geog, leftarg = geography, rightarg = gidx, commutator = public.&&);

alter operator public.&&(geography, gidx) owner to postgres;

create operator public.&& (procedure = public.overlaps_geog, leftarg = gidx, rightarg = geography, commutator = public.&&);

alter operator public.&&(gidx, geography) owner to postgres;

-- Cyclic dependencies found

create operator public.<< (procedure = public.geometry_left, leftarg = geometry, rightarg = geometry, commutator = public.>>, join = positionjoinsel, restrict = positionsel);

alter operator public.<<(geometry, geometry) owner to postgres;

create operator public.>> (procedure = public.geometry_right, leftarg = geometry, rightarg = geometry, commutator = public.<<, join = positionjoinsel, restrict = positionsel);

alter operator public.>>(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.<<@ (procedure = public.geometry_contained_3d, leftarg = geometry, rightarg = geometry, commutator = public.@>>, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.<<@(geometry, geometry) owner to postgres;

create operator public.@>> (procedure = public.geometry_contains_3d, leftarg = geometry, rightarg = geometry, commutator = public.<<@, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.@>>(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.<<| (procedure = public.geometry_below, leftarg = geometry, rightarg = geometry, commutator = public.|>>, join = positionjoinsel, restrict = positionsel);

alter operator public.<<|(geometry, geometry) owner to postgres;

create operator public.|>> (procedure = public.geometry_above, leftarg = geometry, rightarg = geometry, commutator = public.<<|, join = positionjoinsel, restrict = positionsel);

alter operator public.|>>(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.@ (procedure = public.is_contained_2d, leftarg = box2df, rightarg = box2df, commutator = public.~);

alter operator public.@(box2df, box2df) owner to postgres;

create operator public.~ (procedure = public.contains_2d, leftarg = box2df, rightarg = box2df, commutator = public.@);

alter operator public.~(box2df, box2df) owner to postgres;

-- Cyclic dependencies found

create operator public.@ (procedure = public.is_contained_2d, leftarg = box2df, rightarg = geometry, commutator = public.~);

alter operator public.@(box2df, geometry) owner to postgres;

create operator public.~ (procedure = public.contains_2d, leftarg = geometry, rightarg = box2df, commutator = public.@);

alter operator public.~(geometry, box2df) owner to postgres;

-- Cyclic dependencies found

create operator public.@ (procedure = public.is_contained_2d, leftarg = geometry, rightarg = box2df, commutator = public.~);

alter operator public.@(geometry, box2df) owner to postgres;

create operator public.~ (procedure = public.contains_2d, leftarg = box2df, rightarg = geometry, commutator = public.@);

alter operator public.~(box2df, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.@ (procedure = public.geometry_within, leftarg = geometry, rightarg = geometry, commutator = public.~, join = public.gserialized_gist_joinsel_2d, restrict = public.gserialized_gist_sel_2d);

alter operator public.@(geometry, geometry) owner to postgres;

create operator public.~ (procedure = public.geometry_contains, leftarg = geometry, rightarg = geometry, commutator = public.@, join = public.gserialized_gist_joinsel_2d, restrict = public.gserialized_gist_sel_2d);

alter operator public.~(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.@@ (procedure = public.geometry_within_nd, leftarg = geometry, rightarg = geometry, commutator = public.~~, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.@@(geometry, geometry) owner to postgres;

create operator public.~~ (procedure = public.geometry_contains_nd, leftarg = geometry, rightarg = geometry, commutator = public.@@, join = public.gserialized_gist_joinsel_nd, restrict = public.gserialized_gist_sel_nd);

alter operator public.~~(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.< (procedure = public.geography_lt, leftarg = geography, rightarg = geography, commutator = public.>, negator = public.>=, join = contjoinsel, restrict = contsel);

alter operator public.<(geography, geography) owner to postgres;

-- Cyclic dependencies found

create operator public.> (procedure = public.geography_gt, leftarg = geography, rightarg = geography, commutator = public.<, negator = public.<=, join = contjoinsel, restrict = contsel);

alter operator public.>(geography, geography) owner to postgres;

-- Cyclic dependencies found

create operator public.<= (procedure = public.geography_le, leftarg = geography, rightarg = geography, commutator = public.>=, negator = public.>, join = contjoinsel, restrict = contsel);

alter operator public.<=(geography, geography) owner to postgres;

create operator public.>= (procedure = public.geography_ge, leftarg = geography, rightarg = geography, commutator = public.<=, negator = public.<, join = contjoinsel, restrict = contsel);

alter operator public.>=(geography, geography) owner to postgres;

-- Cyclic dependencies found

create operator public.< (procedure = public.geometry_lt, leftarg = geometry, rightarg = geometry, commutator = public.>, negator = public.>=, join = contjoinsel, restrict = contsel);

alter operator public.<(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.> (procedure = public.geometry_gt, leftarg = geometry, rightarg = geometry, commutator = public.<, negator = public.<=, join = contjoinsel, restrict = contsel);

alter operator public.>(geometry, geometry) owner to postgres;

-- Cyclic dependencies found

create operator public.<= (procedure = public.geometry_le, leftarg = geometry, rightarg = geometry, commutator = public.>=, negator = public.>, join = contjoinsel, restrict = contsel);

alter operator public.<=(geometry, geometry) owner to postgres;

create operator public.>= (procedure = public.geometry_ge, leftarg = geometry, rightarg = geometry, commutator = public.<=, negator = public.<, join = contjoinsel, restrict = contsel);

alter operator public.>=(geometry, geometry) owner to postgres;

