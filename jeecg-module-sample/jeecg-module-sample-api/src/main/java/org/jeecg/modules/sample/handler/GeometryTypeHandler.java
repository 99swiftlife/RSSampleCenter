package org.jeecg.modules.sample.handler;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedTypes;
import org.jeecg.modules.sample.entity.BoundingBox;
import org.postgis.Geometry;
import org.postgis.PGgeometry;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * @program: RSSampleCenter
 * @description: Geometry转化为PostGis Geometry的TypeHandler
 * @author: swiftlife
 * @create: 2023-12-15 10:09
 **/
@MappedTypes(BoundingBox.class)
public class GeometryTypeHandler extends BaseTypeHandler<BoundingBox> {

    @Override
    public void setNonNullParameter(PreparedStatement preparedStatement, int i, BoundingBox boundingBox, JdbcType jdbcType) throws SQLException {
        String polygonCode = boundingBox.toPolygonCode();
        if(polygonCode == null){
            preparedStatement.setObject(i, null);
            return;
        }
        PGgeometry pGgeometry = new PGgeometry(polygonCode);
        Geometry geometry = pGgeometry.getGeometry();
        geometry.setSrid(4326);
        preparedStatement.setObject(i, pGgeometry);
    }

    @Override
    public BoundingBox getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String string = rs.getString(columnName);
        return getResult(string);
    }

    @Override
    public BoundingBox getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String string = rs.getString(columnIndex);
        return getResult(string);
    }

    @Override
    public BoundingBox getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String string = cs.getString(columnIndex);
        return getResult(string);
    }

    private BoundingBox getResult(String string) throws SQLException {
        if(string == null) return null;
        PGgeometry pGgeometry = new PGgeometry(string);
        String s = pGgeometry.toString();
        return new BoundingBox(s.replace("SRID=4326;", ""));
    }
}
