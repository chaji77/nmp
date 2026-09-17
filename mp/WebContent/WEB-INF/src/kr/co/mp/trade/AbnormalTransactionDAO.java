package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class AbnormalTransactionDAO {
  protected static int UNUSUAL_TRANSACTION_ADD_PROC(int intCtId, String strErrorCode) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("AbnormalTransactionDAO.UNUSUAL_TRANSACTION_ADD_PROC");
    ResultSet rs = null;
    int intSeq = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_ADD_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      ps.setString(++i, strErrorCode);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intSeq = rs.getInt("SEQ");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  protected static ArrayList<String> UNUSUAL_TRANSACTION_BLOCKED_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("AbnormalTransactionDAO.UNUSUAL_TRANSACTION_BLOCKED_BY_CTID_PROC");
    ResultSet rs = null;
    ArrayList<String> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_BLOCKED_BY_CTID_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
        	arr.add(rs.getString("SECTION"));
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected static ArrayList<String> UNUSUAL_TRANSACTION_RELEASED_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("AbnormalTransactionDAO.UNUSUAL_TRANSACTION_RELEASED_BY_CTID_PROC");
    ResultSet rs = null;
    ArrayList<String> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_RELEASED_BY_CTID_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
        	arr.add(rs.getString("SECTION"));
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  //
  public static int UNUSUAL_TRANSACTION_KD001_RELEASE_ADD_PROC(int intCtId, String strGubun, String strSignData) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("AbnormalTransactionDAO.UNUSUAL_TRANSACTION_KD001_RELEASE_ADD_PROC");
    ResultSet rs = null;
    int intCnt = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_KD001_RELEASE_ADD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      ps.setString(++i, strGubun);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strSignData), "", 150));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCnt = rs.getInt("CNT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCnt;
  }
  public static int CT_HEADER_CNT_BY_BILL_DT_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("AbnormalTransactionDAO.CT_HEADER_CNT_BY_BILL_DT_PROC");
    ResultSet rs = null;
    int intCnt = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_CNT_BY_BILL_DT_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCnt = rs.getInt("CNT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCnt;
  }
}
