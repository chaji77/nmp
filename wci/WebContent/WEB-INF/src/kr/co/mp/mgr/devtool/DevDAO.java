package kr.co.mp.mgr.devtool;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class DevDAO {
  public static ArrayList<Map<String, String>> getScheme(String strQuery) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    ArrayList<Map<String, String>> arr = new ArrayList<>();
    try {
      System.out.println(strQuery);
      ps = new WrapPreparedStatementUtil(conn, strQuery);
      rs = ps.executeQuery();
      if (rs!=null) {
        ResultSetMetaData md = rs.getMetaData();
        Map<String, String> cvo  = new HashMap<>();
        cvo.put("COL_CNT", Integer.toString(md.getColumnCount()));
        for (int i=1; i<=md.getColumnCount(); i++) {
          cvo.put(Integer.toString(i), md.getColumnName(i));
        }
        arr.add(cvo);
        while(rs.next()) {
          Map<String, String> vo = new HashMap<>();
          for (int i=1; i<=md.getColumnCount(); i++) {
            vo.put(md.getColumnName(i), StrUtil.nvl(rs.getString(md.getColumnName(i))));
          }
          arr.add(vo);
        }
      }
    } catch(Exception e) {
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return arr;
  }
}
