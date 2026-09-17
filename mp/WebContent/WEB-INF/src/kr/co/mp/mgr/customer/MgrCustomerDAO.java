package kr.co.mp.mgr.customer;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.mp.c.CompanyVO;
import kr.co.mp.c.RelationCompanyVO;

public class MgrCustomerDAO {    
  protected int M_COMPANY_DISHONOR_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_DISHONOR_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setInt(++i, Integer.parseInt(cvo.CPY_DISHONOR));
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_COMPANY_CONFIRM_SETTLE_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_CONFIRM_SETTLE_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.CONFIRM_SETTLE_YN);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_COMPANY_MPTAX_MONTH_USE_YN_MOD_PROC(CompanyVO cvo) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	int intResult = 0;
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_MPTAX_MONTH_USE_YN_MOD_PROC ?, ?, ?;");
	  int i = 0;
	  ps.setInt(++i, cvo.CPY_ID);
	  ps.setString(++i, cvo.MPTAX_MONTH_USE_YN);
	  ps.setInt(++i, Integer.parseInt(cvo.MPTAX_MONTH_USE_ID));
	  logger.debug(ps.getQueryString());
	  ps.executeUpdate();
	} catch(Exception e) {
	  logger.error(ps.getQueryString());
	  logger.error(e.toString());
	  intResult = -1;
	} finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
	} 
	return intResult;
  }
  protected int M_COMPANY_CU_USE_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_CU_USE_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.CU_USE_YN);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_RELATION_COMPANY_ADD_PROC(RelationCompanyVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_RELATION_COMPANY_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(vo.CPY_ID));
      ps.setString(++i, vo.RELATIONBIZNO);
      ps.setString(++i, vo.USE_YN);
      ps.setString(++i, vo.CRETIME);
      ps.setString(++i, vo.CREUSER);
      ps.setString(++i, vo.LASTTIME);
      ps.setString(++i, vo.LASTUSER);
      ps.setString(++i, vo.PRO_RESULT);
      ps.setString(++i, vo.LOANTYPE);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected ArrayList<RelationCompanyVO> M_RELATION_COMPANY_LIST_PROC(RelationCompanyVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<RelationCompanyVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_RELATION_COMPANY_LIST_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(vo.CPY_ID));
      ps.setString(++i, vo.USE_YN);
      ps.setInt(++i, vo.PAGE);
      ps.setInt(++i, vo.ROW_CNT);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
      while(rs.next()) {
        RelationCompanyVO rvo = new RelationCompanyVO();
        rvo.RN       = rs.getInt("RN");
        rvo.TOTAL_CNT   = rs.getInt("TOTAL_CNT");
        rvo.SEQNO     = rs.getString("SEQNO");
        rvo.RELATIONBIZNO = StrUtil.nvl(rs.getString("RELATIONBIZNO"));
        rvo.LOANTYPE     = StrUtil.nvl(rs.getString("LOANTYPE"));
        rvo.CPY_NAME     = StrUtil.nvl(rs.getString("CPY_NAME"));
        rvo.PRO_RESULT   = StrUtil.nvl(rs.getString("PRO_RESULT"));
        rvo.LASTUSER     = StrUtil.nvl(rs.getString("LASTUSER"));
        rvo.LASTTIME     = StrUtil.nvl(rs.getString("LASTTIME"));
        rvo.USE_YN     = StrUtil.nvl(rs.getString("USE_YN"));
        arr.add(rvo);
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
  public RelationCompanyVO M_RELATION_COMPANY_DETAIL_PROC(int seq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    RelationCompanyVO vo = new RelationCompanyVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_RELATION_COMPANY_DETAIL_PROC ?;");
      ps.setInt(1, seq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if(rs!=null && rs.next()) {
      vo.CPY_NAME = StrUtil.nvl(rs.getString("CPY_NAME"));
      vo.CPY_BIZ_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
      vo.RELATIONBIZNO = StrUtil.nvl(rs.getString("RELATIONBIZNO"));
      vo.LOANTYPE = StrUtil.nvl(rs.getString("LOANTYPE"));
      vo.USE_YN = StrUtil.nvl(rs.getString("USE_YN"));
      vo.PRO_RESULT = StrUtil.nvl(rs.getString("PRO_RESULT"));
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
  protected int M_RELATION_COMPANY_MOD_PROC(RelationCompanyVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_RELATION_COMPANY_MOD_PROC ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(vo.SEQNO));
      ps.setString(++i, vo.LOANTYPE);
      ps.setString(++i, vo.USE_YN);
      ps.setString(++i, vo.LASTTIME);
      ps.setString(++i, vo.LASTUSER);
      ps.setString(++i, vo.PRO_RESULT);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return intResult;
  }
  protected int M_COMPANY_MOBILE_YN_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_MOBILE_YN_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.MOBILE_YN);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_COMPANY_REVERSE_YN_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_REVERSE_YN_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.REVERSE_YN);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_COMPANY_MPTAX_REG_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	int intResult = 0;
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_MPTAX_REG_PROC ?, ?, ?;");
	  int i = 0;
	  ps.setInt(++i, cvo.CPY_ID);
	  ps.setString(++i, cvo.MPTAX_USER_NM);
	  ps.setString(++i, cvo.MPTAX_EMAIL);
	  logger.debug(ps.getQueryString());
	  logger.debug("EXEC DBO.M_COMPANY_MPTAX_REG_PROC " + ps.getQueryString());
	  ps.executeUpdate();
	} catch(Exception e) {
	  logger.error(ps.getQueryString());
	  logger.error(e.toString());
	  intResult = -1;
	} finally {
	  ConnectionMgr.getInstance().closeConnection(conn, ps);
	} 
	return intResult;
  }
  protected int M_COMPANY_SIGN_EXCLUDE_YN_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_SIGN_EXCLUDE_YN_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.SIGN_EXCLUDE_YN);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
    }
  protected int M_COMPANY_APPROVE_REGISTRATION(int cpyId) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	int intResult = 0;
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_APPROVE_REGISTRATION ?;");
	  ps.setInt(1, cpyId);
	  logger.debug(ps.getQueryString());
	  ps.executeUpdate();
	} catch(Exception e) {
	  logger.error(ps.getQueryString());
	  logger.error(e.toString());
	  intResult = -1;
	} finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
	} 
	return intResult;
  }
  protected int M_COMPANY_MEMO_MOD_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_MEMO_MOD_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setString(++i, cvo.CPY_MEMO);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected ArrayList<BusinessPersonVO> M_BUSINESS_PERSON_LIST_PROC(BusinessPersonVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<BusinessPersonVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_BUSINESS_PERSON_LIST_PROC ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        BusinessPersonVO v = new BusinessPersonVO();
        v.CPY_ID        = rs.getInt(   "CPY_ID       ".trim());
        v.BUY_CPY_ID    = rs.getInt(   "BUY_CPY_ID   ".trim());
        v.PRS_ID        = rs.getInt(   "PRS_ID       ".trim());
        v.PRS_NAME      = rs.getString("PRS_NAME     ".trim());
        v.PRS_LOGIN     = rs.getString("PRS_LOGIN    ".trim());
        v.PRS_TEL       = rs.getString("PRS_TEL      ".trim());
        v.PRS_MOBILE_NO = rs.getString("PRS_MOBILE_NO".trim());
        v.PRS_EMAIL     = rs.getString("PRS_EMAIL    ".trim());
        v.BUY_COMPANY   = rs.getString("BUY_COMPANY  ".trim());
        arr.add(v);
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return arr;
  }
  protected int M_BUSINESS_PERSON_ADD_PROC(BusinessPersonVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_BUSINESS_PERSON_ADD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setInt(++i, cvo.BUY_CPY_ID);
      ps.setInt(++i, cvo.PRS_ID);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_BUSINESS_PERSON_MOD_PROC(BusinessPersonVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_BUSINESS_PERSON_MOD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setInt(++i, cvo.ORIGIN_BUY_CPY_ID);
      ps.setInt(++i, cvo.BUY_CPY_ID);
      ps.setInt(++i, cvo.PRS_ID);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int M_BUSINESS_PERSON_DROP_PROC(BusinessPersonVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_BUSINESS_PERSON_DROP_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, cvo.CPY_ID);
      ps.setInt(++i, cvo.BUY_CPY_ID);
      ps.setInt(++i, cvo.PRS_ID);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
}