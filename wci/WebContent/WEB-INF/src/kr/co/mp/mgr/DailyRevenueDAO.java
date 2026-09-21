package kr.co.mp.mgr;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class DailyRevenueDAO {
  protected static ArrayList<DailyRevenueVO> DAILY_REVENUE_PROC(String strStartYm, String strEndYm) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("NOTIFICATE_PROC");
    ResultSet rs = null;
    ArrayList<DailyRevenueVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.DAILY_REVENUE_PROC ?, ?;");
      ps.setString(1, strStartYm);
      ps.setString(2, strEndYm);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          DailyRevenueVO vo = new DailyRevenueVO();
          vo.D = StrUtil.nvl(rs.getString("D"));
          vo.B = StrUtil.nvl(rs.getString("B"));
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
