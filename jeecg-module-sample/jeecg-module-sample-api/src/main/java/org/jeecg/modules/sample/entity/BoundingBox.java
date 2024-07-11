package org.jeecg.modules.sample.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static java.lang.Math.max;
import static java.lang.Math.min;

/**
 * @program: RSSampleCenter
 * @description: 样本空间边界框
 * @author: swiftlife
 * @create: 2023-12-13 20:49
 **/
@Data
@AllArgsConstructor
@NoArgsConstructor
public class BoundingBox implements Serializable {
    private List<Double> ll;
    private List<Double> lr;
    private List<Double> ul;
    private List<Double> ur;

    public BoundingBox (String polygonCode) {
        String [] temp = polygonCode.split(",");
        String [] ur  = temp[2].trim().split(" ");
        String [] ll = temp[4].trim().substring(0,temp[4].indexOf("))")-1).split(" ");
        Double lat_max = Double.valueOf(ur[0]);
        Double lat_min = Double.valueOf(ll[0]);
        Double lon_max = Double.valueOf(ur[1]);
        Double lon_min = Double.valueOf(ll[1]);
        this.ll = new ArrayList<>(Arrays.asList(lat_min,lon_min));
        this.lr = new ArrayList<>(Arrays.asList(lat_min,lon_max));
        this.ul = new ArrayList<>(Arrays.asList(lat_max,lon_min));
        this.ur = new ArrayList<>(Arrays.asList(lat_max,lon_max));
    }

    public String toPolygonCode(){
        if(this.ll == null||this.lr == null||this.ul == null||this.ur == null) return null;
        return "POLYGON(("+ll.get(1)+" "+ll.get(0)+", "+ul.get(1)+" "+ul.get(0)+", "+ur.get(1)+" "+ur.get(0)+", "+lr.get(1)+" "+lr.get(0)+", "+ll.get(1)+" "+ll.get(0)+"))";
    }
}
