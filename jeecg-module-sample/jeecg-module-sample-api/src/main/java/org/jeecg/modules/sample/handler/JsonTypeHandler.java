package org.jeecg.modules.sample.handler;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.postgresql.util.PGobject;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

public class JsonTypeHandler extends BaseTypeHandler<Map<Integer, Map<String, Integer>>> {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Map<Integer, Map<String, Integer>> parameter, JdbcType jdbcType) throws SQLException {
        if (parameter == null || parameter.isEmpty()) {
            ps.setObject(i, null);
        } else {
            PGobject jsonObject = new PGobject();
            jsonObject.setType("json");
            try {
                jsonObject.setValue(objectMapper.writeValueAsString(parameter));
            } catch (JsonProcessingException e) {
                throw new SQLException("Error converting map to JSON", e);
            }
            ps.setObject(i, jsonObject);
        }
    }

    @Override
    public Map<Integer, Map<String, Integer>> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String json = rs.getString(columnName);
        return parseJson(json);
    }

    @Override
    public Map<Integer, Map<String, Integer>> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String json = rs.getString(columnIndex);
        return parseJson(json);
    }

    @Override
    public Map<Integer, Map<String, Integer>> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String json = cs.getString(columnIndex);
        return parseJson(json);
    }

    private Map<Integer, Map<String, Integer>> parseJson(String json) throws SQLException {
        try {
            return json == null ? null : objectMapper.readValue(json, new com.fasterxml.jackson.core.type.TypeReference<Map<Integer, Map<String, Integer>>>() {});
        } catch (IOException e) {
            throw new SQLException("Error converting JSON to map", e);
        }
    }
}
