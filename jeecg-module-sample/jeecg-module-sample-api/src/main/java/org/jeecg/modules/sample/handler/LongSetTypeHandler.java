package org.jeecg.modules.sample.handler;

import org.apache.ibatis.type.BaseTypeHandler;

import java.util.Collection;
import org.apache.ibatis.type.JdbcType;

import java.sql.*;
import java.util.HashSet;
import java.util.Set;


public class LongSetTypeHandler extends BaseTypeHandler<Set<Long>> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Set<Long> parameter, JdbcType jdbcType) throws SQLException {
        // 将 Set 转换为数组
        Long[] array = parameter.toArray(new Long[0]);
        // 创建 PostgreSQL 的 BIGINT[] 数组
        Array sqlArray = ps.getConnection().createArrayOf("BIGINT", array);
        ps.setArray(i, sqlArray);
    }

    @Override
    public Set<Long> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        Array array = rs.getArray(columnName);
        return toSet(array);
    }

    @Override
    public Set<Long> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        Array array = rs.getArray(columnIndex);
        return toSet(array);
    }

    @Override
    public Set<Long> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        Array array = cs.getArray(columnIndex);
        return toSet(array);
    }

    // 将 PostgreSQL 数组转换为 Set<Long>
    private Set<Long> toSet(Array array) throws SQLException {
        if (array == null) {
            return null;
        }
        Long[] javaArray = (Long[]) array.getArray();
        Set<Long> resultSet = new HashSet<>();
        for (Long value : javaArray) {
            resultSet.add(value);
        }
        return resultSet;
    }
}
