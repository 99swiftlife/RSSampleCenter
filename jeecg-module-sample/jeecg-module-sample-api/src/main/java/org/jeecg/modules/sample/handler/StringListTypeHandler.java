package com.example.typehandler;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import java.sql.*;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class StringListTypeHandler extends BaseTypeHandler<List<String>> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<String> parameter, JdbcType jdbcType) throws SQLException {
        // 将 List<String> 转换为 PostgreSQL 的 text[]
        String[] array = parameter.toArray(new String[0]);
        Array sqlArray = ps.getConnection().createArrayOf("text", array);
        ps.setArray(i, sqlArray);
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        // 将 PostgreSQL 的 text[] 转换为 List<String>
        Array sqlArray = rs.getArray(columnName);
        if (sqlArray == null) {
            return null;
        }
        return Arrays.asList((String[]) sqlArray.getArray());
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        // 将 PostgreSQL 的 text[] 转换为 List<String>
        Array sqlArray = rs.getArray(columnIndex);
        if (sqlArray == null) {
            return null;
        }
        return Arrays.asList((String[]) sqlArray.getArray());
    }

    @Override
    public List<String> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        // 将 PostgreSQL 的 text[] 转换为 List<String>
        Array sqlArray = cs.getArray(columnIndex);
        if (sqlArray == null) {
            return null;
        }
        return Arrays.asList((String[]) sqlArray.getArray());
    }
}
