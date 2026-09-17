package kr.co.mp.mgr;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.IntegerCryptoUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class NotificationDAO {
  public static ArrayList<NotificationVO> NOTIFICATE_PROC(String strRegId, String strCheckOutDateTime) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("NOTIFICATE_PROC");
    ResultSet rs = null;
    ArrayList<NotificationVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.NOTIFICATE_PROC ?, ?;");
      ps.setString(1, strRegId);
      ps.setString(2, strCheckOutDateTime);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          NotificationVO vo = new NotificationVO();
          vo.GUBUN    = StrUtil.nvl(rs.getString("GUBUN   ".trim())).substring(2);
          vo.CPY_ID   = IntegerCryptoUtil.crypt(rs.getInt("CPY_ID"));
          vo.CONTENTS = StrUtil.nvl(rs.getString("CONTENTS".trim()));
          vo.REG_DT   = StrUtil.nvl(rs.getString("REG_DT  ".trim()));
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
