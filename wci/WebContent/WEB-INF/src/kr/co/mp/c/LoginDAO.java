package kr.co.mp.c;

import java.sql.Connection;
import java.sql.ResultSet;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class LoginDAO {
  protected LoginVO C_LOGIN_PROC(String strLoginId, String strLoginPw) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    LoginVO vo = new LoginVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_LOGIN_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strLoginId), "", 16));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strLoginPw), "", 32));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CPY_ID            = StrUtil.nvl(rs.getString("CPY_ID"));
        vo.CPY_GUBUN         = StrUtil.nvl(rs.getString("CPY_GUBUN"));
        vo.CPY_BIZ_NO        = StrUtil.nvl(rs.getString("CPY_BIZ_NO"));
        vo.CPY_NM            = StrUtil.nvl(rs.getString("CPY_NM"));
        vo.PRS_ID            = StrUtil.nvl(rs.getString("PRS_ID"));
        vo.USER_LOGIN        = StrUtil.nvl(rs.getString("USER_LOGIN"));
   	    vo.CU_USE_YN         = StrUtil.nvl(rs.getString("CU_USE_YN"), "N");
   	    vo.CONFIRM_SETTLE_YN = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN"), "N");
   	    vo.REVERSE_YN        = StrUtil.nvl(rs.getString("REVERSE_YN"), "N");
   	    vo.MOBILE_YN         = StrUtil.nvl(rs.getString("MOBILE_YN"), "N");
        vo.SIGN_EXCLUDE_YN   = StrUtil.nvl(rs.getString("SIGN_EXCLUDE_YN"), "N");
        vo.CRG_ID            = StrUtil.nvl(rs.getString("CRG_ID"), "1");
        vo.PAPER_BILL_YN     = StrUtil.nvl(rs.getString("PAPER_BILL_YN"), "N");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  protected LoginVO C_LOGIN_VIA_CERT_PROC(String strSSN) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    LoginVO vo = new LoginVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_LOGIN_VIA_CERT_PROC ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strSSN), "", 13));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
          vo.CPY_ID            = StrUtil.nvl(rs.getString("CPY_ID"));
          vo.CPY_GUBUN         = StrUtil.nvl(rs.getString("CPY_GUBUN"));
          vo.CPY_BIZ_NO        = StrUtil.nvl(rs.getString("CPY_BIZ_NO"));
          vo.CPY_NM            = StrUtil.nvl(rs.getString("CPY_NM"));
          vo.PRS_ID            = StrUtil.nvl(rs.getString("PRS_ID"));
          vo.USER_LOGIN        = StrUtil.nvl(rs.getString("USER_LOGIN"));
          vo.CU_USE_YN         = StrUtil.nvl(rs.getString("CU_USE_YN"), "N");
          vo.CONFIRM_SETTLE_YN = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN"), "N");
          vo.REVERSE_YN        = StrUtil.nvl(rs.getString("REVERSE_YN"), "N");
          vo.MOBILE_YN         = StrUtil.nvl(rs.getString("MOBILE_YN"), "N");
          vo.SIGN_EXCLUDE_YN   = StrUtil.nvl(rs.getString("SIGN_EXCLUDE_YN"), "N");
          vo.CRG_ID            = StrUtil.nvl(rs.getString("CRG_ID"), "1");
          vo.PAPER_BILL_YN     = StrUtil.nvl(rs.getString("PAPER_BILL_YN"), "N");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  /******************************* SEARCH ID/PASSWORD ******************************/
  
  protected String C_ACCOUNT_SEARCH_ID_PROC(String strBizNo, String strUserNm) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String strUserId = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_ACCOUNT_SEARCH_ID_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strBizNo), "", 10));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strUserNm), "", 24));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        strUserId = rs.getString("PRS_LOGIN");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strUserId;
  }
  protected String[] C_ACCOUNT_EMAIL_PROC(String strBizNo, String strUserId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] strUserEmail = {"", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_ACCOUNT_EMAIL_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strBizNo), "", 10));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strUserId), "", 16));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        strUserEmail[0] = rs.getString("PRS_EMAIL");
        strUserEmail[1] = rs.getString("CPY_NAME");        
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strUserEmail;
  }
  protected String C_ACCOUNT_CHANGE_PASSWD_PROC(String strBizNo, String strUserId, String strEmail, String strNewPassword) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String strUserPassword = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_ACCOUNT_CHANGE_PASSWD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strBizNo), "", 10));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strUserId), "", 16));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strEmail), "", 32));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strNewPassword), "", 32));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        strUserPassword = rs.getString("PRS_PASSWD");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strUserPassword;
  }
}
