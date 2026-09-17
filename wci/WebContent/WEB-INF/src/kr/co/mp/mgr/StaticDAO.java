package kr.co.mp.mgr;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class StaticDAO {
  protected static ArrayList<StaticVO> STAT_PROC(String strStartYm, String strEndYm) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("NOTIFICATE_PROC");
    ResultSet rs = null;
    ArrayList<StaticVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.STAT_PROC ?, ?;");
      ps.setString(1, strStartYm);
      ps.setString(2, strEndYm);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          StaticVO vo = new StaticVO();
          vo.GUBUN = StrUtil.nvl(rs.getString("GUBUN")).substring(2);
          vo.Y     = StrUtil.nvl(rs.getString("Y"));
          vo.A     = StrUtil.nvl(rs.getString("A"));
          vo.B     = StrUtil.nvl(rs.getString("B"));
          arr.add(vo);
        }
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return arr;
  }
}
