package kr.co.mp.sms;

import java.sql.Connection;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class SendSMS {
  public static int SEND_SMS_PROC(String to, String msg, int intMessageMaxSize) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CustomerDAO");
    int intCnt = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SEND_SMS_PROC ?, ? , ?;");
      ps.setString(1, to.replaceAll("-", ""));
      ps.setString(2, ConfigurationMgr.getInstance().getString("OWNER_TEL").replaceAll("-", ""));
      ps.setString(3, StrUtil.cutString(msg, intMessageMaxSize, ""));
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intCnt;
  }
}
