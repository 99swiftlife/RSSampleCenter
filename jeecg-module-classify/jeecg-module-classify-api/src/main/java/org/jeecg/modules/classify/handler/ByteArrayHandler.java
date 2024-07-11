package org.jeecg.modules.classify.handler;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedTypes;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * @program: RSSampleCenter
 * @description: 字节序列数组Mybatis类型处理对象
 * @author: swiftlife
 * @create: 2024-04-06 10:58
 **/
@MappedTypes(List.class) // 更新映射类型为List
public class ByteArrayHandler extends BaseTypeHandler<List<byte[]>> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<byte[]> parameter, JdbcType jdbcType) throws SQLException {
        // 将List<byte[]>转换为PostgreSQL的bytea[]并设置到PreparedStatement中
        Connection conn = ps.getConnection();
        // 将List转换为数组，因为createArrayOf需要数组作为输入
        byte[][] arrayParam = parameter.toArray(new byte[0][]);
        Array array = conn.createArrayOf("bytea", arrayParam);
        ps.setArray(i, array);
    }

    @Override
    public List<byte[]> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        // 从ResultSet中获取bytea[]并转换为List<byte[]>
        return toByteArrayList(rs.getArray(columnName));
    }

    @Override
    public List<byte[]> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return toByteArrayList(rs.getArray(columnIndex));
    }

    @Override
    public List<byte[]> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return toByteArrayList(cs.getArray(columnIndex));
    }

    private List<byte[]> toByteArrayList(Array array) throws SQLException {
        if (array == null) {
            return null;
        }
        // 将Array转换为byte[][],再转换为List<byte[]>
        byte[][] byteArray = (byte[][]) array.getArray();
        List<byte[]> byteList = new ArrayList<>();
        for (byte[] bytes : byteArray) {
            byteList.add(bytes);
        }
        return byteList;
    }
}
