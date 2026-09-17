package kr.co.mp.c;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CustomerDAO {
  protected static int COMPANY_CNT_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CustomerDAO");
    ResultSet rs = null;
    int intCnt = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_CNT_PROC;");
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
  protected int COMPANY_BIZNO_CHECK_PROC(String strBizNo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCpyId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_BIZNO_CHECK_PROC ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strBizNo), "", 10));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCpyId = rs.getInt("CPY_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCpyId;
  }
  protected int COMPANY_LOGIN_ID_CHECK_PROC(String strLoginId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intPrsId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_LOGIN_ID_CHECK_PROC ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strLoginId), "", 16));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intPrsId = rs.getInt("PRS_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intPrsId;
  }
  protected int COMPANY_ADD_PROC(CompanyVO cvo, PersonVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCpyId = 0;
    try {
      String q = "";
      for (int a=0; a<26; a++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_ADD_PROC "+ q +";");
      int i = 0;
      ps.setString(++i, cvo.CPY_BUSINESS_NO);
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_NAME, "", 50));
      ps.setString(++i, cvo.CPY_GUBUN);
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_CEO_NAME, "", 30));
      ps.setString(++i, cvo.CRG_ID);
      ps.setString(++i, cvo.CPY_INCORPORATE_NO);
      ps.setString(++i, StrUtil.getParameter(cvo.BUSINESS_TYPE, "", 50));
      ps.setString(++i, StrUtil.getParameter(cvo.INDUSTRY, "", 50));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ZIPCODE, "", 7));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ADDR, "", 255));
      
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ADDR2, "", 255));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_FAX, "", 15));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_BUSINESS_DESC, "", 122));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_FOUNDYEAR, "", 8));
      ps.setString(++i, StrUtil.getParameter(cvo.MPTAX_USER_NM, "", 30));
      ps.setString(++i, StrUtil.getParameter(cvo.MPTAX_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(cvo.BIZ_DOC_FILE_URL, "", 255));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_NAME, "", 25));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_TEL, "", 30));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_LOGIN, "", 16));
      
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_PASSWD, "", 32));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_MOBILE_NO, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_SMS, "0", 1));
      ps.setString(++i, StrUtil.nvl(cvo.MP_CODE, ConfigurationMgr.getInstance().getString("OWNER_MPCODE")));
      ps.setString(++i, StrUtil.nvl(cvo.SALES_AMT, "0"));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCpyId = rs.getInt("CPY_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCpyId;
  }
  protected int COMPANY_MOD_PROC(CompanyVO cvo, PersonVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCpyId = 0;
    try {
      String q = "";
      for (int a=0; a<25; a++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MOD_PROC "+ q +";");
      int i = 0;
      ps.setInt(   ++i, cvo.CPY_ID);
      ps.setString(++i, pvo.PRS_ID);
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_NAME, "", 50));
      ps.setString(++i, cvo.CPY_GUBUN);
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_CEO_NAME, "", 30));
      ps.setString(++i, cvo.CRG_ID);
      ps.setString(++i, cvo.CPY_INCORPORATE_NO);
      ps.setString(++i, StrUtil.getParameter(cvo.BUSINESS_TYPE, "", 50));
      ps.setString(++i, StrUtil.getParameter(cvo.INDUSTRY, "", 50));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ZIPCODE, "", 7));

      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ADDR, "", 255));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_ADDR2, "", 255));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_FAX, "", 15));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_BUSINESS_DESC, "", 122));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_BUSINESS_NO, "", 10));
      ps.setString(++i, StrUtil.getParameter(cvo.CPY_FOUNDYEAR, "", 8));
      ps.setString(++i, StrUtil.getParameter(cvo.MPTAX_USER_NM, "", 30));
      ps.setString(++i, StrUtil.getParameter(cvo.MPTAX_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(cvo.BIZ_DOC_FILE_URL, "", 255));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_NAME, "", 25));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_TEL, "", 30));

      ps.setString(++i, StrUtil.getParameter(pvo.PRS_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_MOBILE_NO, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_SMS, "0", 1));
      ps.setString(++i, StrUtil.nvl(cvo.SALES_AMT, "0"));

      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCpyId = rs.getInt("CPY_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCpyId;
  }
  protected CompanyVO COMPANY_DETAIL_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CompanyVO vo = new CompanyVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CPY_ID              = rs.getInt("CPY_ID");
        vo.CRG_ID              = StrUtil.nvl(rs.getString("CRG_ID            ".trim()));
        vo.CST_ID              = StrUtil.nvl(rs.getString("CST_ID            ".trim()));
        vo.CPY_NAME            = StrUtil.nvl(rs.getString("CPY_NAME          ".trim()));
        vo.BUSINESS_TYPE       = StrUtil.nvl(rs.getString("BUSINESS_TYPE     ".trim()));
        vo.INDUSTRY            = StrUtil.nvl(rs.getString("INDUSTRY          ".trim()));
        vo.CPY_FAX             = StrUtil.nvl(rs.getString("CPY_FAX           ".trim()));
        vo.CPY_BUSINESS_DESC   = StrUtil.nvl(rs.getString("CPY_BUSINESS_DESC ".trim()));
        vo.CPY_BUSINESS_NO     = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO   ".trim()));
        vo.CPY_INCORPORATE_NO  = StrUtil.nvl(rs.getString("CPY_INCORPORATE_NO".trim()));
        if (vo.CPY_INCORPORATE_NO.length()!=13) vo.CPY_INCORPORATE_NO = "";
        vo.CPY_CEO_NAME        = StrUtil.nvl(rs.getString("CPY_CEO_NAME      ".trim()));
        vo.CPY_CREDATE         = StrUtil.nvl(rs.getString("CPY_CREDATE       ".trim()));
        vo.CPY_VALIDATE        = StrUtil.nvl(rs.getString("CPY_VALIDATE      ".trim()));
        vo.CPY_FOUNDYEAR       = StrUtil.nvl(rs.getString("CPY_FOUNDYEAR     ".trim()));
        vo.CPY_GUBUN           = StrUtil.nvl(rs.getString("CPY_GUBUN         ".trim()));
        vo.MP_CODE             = StrUtil.nvl(rs.getString("MP_CODE           ".trim()));
        vo.CPY_DISHONOR        = StrUtil.nvl(rs.getString("CPY_DISHONOR      ".trim()));
        vo.CONFIRM_SETTLE_YN   = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN ".trim()));
        vo.CPY_ZIPCODE         = StrUtil.nvl(rs.getString("CPY_ZIPCODE       ".trim()));
        vo.CPY_ADDR            = StrUtil.nvl(rs.getString("CPY_ADDR          ".trim()));
        vo.CPY_ADDR2           = StrUtil.nvl(rs.getString("CPY_ADDR2         ".trim()));
        vo.MPTAX_MONTH_USE_YN  = StrUtil.nvl(rs.getString("MPTAX_MONTH_USE_YN".trim()));
        vo.MPTAX_MONTH_USE_ID  = StrUtil.nvl(rs.getString("MPTAX_MONTH_USE_ID".trim()));
        vo.MPTAX_MONTH_USE_DT  = StrUtil.nvl(rs.getString("MPTAX_MONTH_USE_DT".trim()));
        vo.MPTAX_USER_NM       = StrUtil.nvl(rs.getString("MPTAX_USER_NM     ".trim()));
        vo.MPTAX_EMAIL         = StrUtil.nvl(rs.getString("MPTAX_EMAIL       ".trim()));
        vo.BIZ_DOC_FILE_URL    = StrUtil.nvl(rs.getString("BIZ_DOC_FILE_URL  ".trim()));
        vo.CU_USE_YN           = StrUtil.nvl(rs.getString("CU_USE_YN         ".trim()));
        vo.LAST_LOGIN_DT       = StrUtil.nvl(rs.getString("LAST_LOGIN_DT     ".trim()));
        vo.MOBILE_YN           = StrUtil.nvl(rs.getString("MOBILE_YN         ".trim()));
        vo.REVERSE_YN          = StrUtil.nvl(rs.getString("REVERSE_YN        ".trim()));
        vo.SALES_AMT           = StrUtil.nvl(rs.getString("SALES_AMT         ".trim()));
        vo.SIGN_EXCLUDE_YN     = StrUtil.nvl(rs.getString("SIGN_EXCLUDE_YN   ".trim()));
        vo.CPY_MEMO            = "";
        vo.SELLER_CLEAR_YN     = StrUtil.nvl(rs.getString("SELLER_CLEAR_YN   ".trim()));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected ArrayList<CompanyVO> COMPANY_SEARCH_PROC(CompanyVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CompanyVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_SEARCH_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, cvo.PAGE);
      ps.setInt(   ++i, cvo.ROW_CNT);
      ps.setString(++i, StrUtil.nvl(cvo.CPY_BUSINESS_NO));
      ps.setString(++i, StrUtil.nvl(cvo.CPY_NAME));
      ps.setString(++i, StrUtil.nvl(cvo.CU_USE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.MOBILE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.REVERSE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.SIGN_EXCLUDE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.CONFIRM_SETTLE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.MPTAX_MONTH_USE_YN, "X"));
      ps.setString(++i, StrUtil.nvl(cvo.CPY_GUBUN, "0"));
      ps.setInt(   ++i, Integer.parseInt(StrUtil.nvl(cvo.CST_ID, "0")));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CompanyVO v = new CompanyVO();
          v.RN                 = rs.getInt("RN");
          v.TOTAL_CNT          = rs.getInt("TOTAL_CNT");
          v.CPY_ID             = rs.getInt("CPY_ID");
          v.CPY_NAME           = StrUtil.nvl(rs.getString("CPY_NAME"));
          v.CPY_BUSINESS_NO    = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
          v.CPY_CEO_NAME       = StrUtil.nvl(rs.getString("CPY_CEO_NAME"));
          v.CPY_GUBUN          = StrUtil.nvl(rs.getString("CPY_GUBUN"));
          v.CPY_CREDATE        = StrUtil.nvl(rs.getString("CPY_CREDATE"));
          v.CPY_VALIDATE       = StrUtil.nvl(rs.getString("CPY_VALIDATE"));
          v.CONFIRM_SETTLE_YN  = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN"));
          v.CU_USE_YN          = StrUtil.nvl(rs.getString("CU_USE_YN"));
          v.MOBILE_YN          = StrUtil.nvl(rs.getString("MOBILE_YN"));
          v.REVERSE_YN         = StrUtil.nvl(rs.getString("REVERSE_YN"));
          v.SIGN_EXCLUDE_YN    = StrUtil.nvl(rs.getString("SIGN_EXCLUDE_YN"));
          v.CPY_ADDR           = StrUtil.nvl(rs.getString("CPY_ADDR"));
          v.MPTAX_MONTH_USE_YN = StrUtil.nvl(rs.getString("MPTAX_MONTH_USE_YN"));
          arr.add(v);
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
  protected ArrayList<CompanyVO> CT_MYCOMPANY_LIST_PROC(int intCpyId, int intPrsId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CompanyVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_MYCOMPANY_LIST_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, intPrsId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CompanyVO v = new CompanyVO();
          v.CPY_ID          = rs.getInt("CPY_ID");
          v.CPY_NAME        = StrUtil.nvl(rs.getString("CPY_NAME"));
          v.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
          v.CPY_CEO_NAME    = StrUtil.nvl(rs.getString("CPY_CEO_NAME"));
          v.CU_USE_YN       = StrUtil.nvl(rs.getString("CU_USE_YN"), "N");
          v.CPY_ADDR        = StrUtil.nvl(rs.getString("CPY_ADDR"));
          v.PAY_CPY         = StrUtil.nvl(rs.getString("PAY_CPY"), "B");
          v.CRG_ID          = StrUtil.nvl(rs.getString("CRG_ID"));
          arr.add(v);
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
  protected ArrayList<CompanyVO> CT_MYCOMPANY_ADD_PROC(int intCpyId, int intTargetCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CompanyVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_MYCOMPANY_ADD_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, intTargetCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CompanyVO v = new CompanyVO();
          v.CPY_ID          = rs.getInt("CPY_ID");
          v.CPY_NAME        = rs.getString("CPY_NAME");
          v.CPY_BUSINESS_NO = rs.getString("CPY_BUSINESS_NO");
          v.CPY_CEO_NAME    = rs.getString("CPY_CEO_NAME");
          arr.add(v);
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
  protected int CT_MYCOMPANY_DROP_PROC(int intCpyId, int intTargetCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_MYCOMPANY_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, intTargetCpyId);
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected ArrayList<PersonVO> PERSON_LIST_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<PersonVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.PERSON_LIST_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          PersonVO vo = new PersonVO();
          vo.PRS_ID        = StrUtil.nvl(rs.getString("PRS_ID       ".trim()));
          vo.CPY_ID        = StrUtil.nvl(rs.getString("CPY_ID       ".trim()));
          vo.PRS_NAME      = StrUtil.nvl(rs.getString("PRS_NAME     ".trim()));
          vo.PRS_PASSWD    = StrUtil.nvl(rs.getString("PRS_PASSWD   ".trim()));
          vo.PRS_TEL       = StrUtil.nvl(rs.getString("PRS_TEL      ".trim()));
          vo.PRS_LOGIN     = StrUtil.nvl(rs.getString("PRS_LOGIN    ".trim()));
          vo.PRS_EMAIL     = StrUtil.nvl(rs.getString("PRS_EMAIL    ".trim()));
          vo.PRS_MOBILE_NO = StrUtil.nvl(rs.getString("PRS_MOBILE_NO".trim()));
          vo.PRS_SMS       = StrUtil.nvl(rs.getString("PRS_SMS      ".trim()));
          arr.add(vo);
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
  protected int PERSON_ADD_PROC(int intCpyId, PersonVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intPrsId = 0;
    try {
      String q = "";
      for (int a=0; a<8; a++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.PERSON_ADD_PROC "+ q +";");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_LOGIN, "", 16));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_PASSWD, "", 32));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_NAME, "", 25));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_TEL, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_MOBILE_NO, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_SMS, "0", 1));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intPrsId = rs.getInt("PRS_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intPrsId;
  }
  protected int PERSON_MOD_PROC(int intCpyId, PersonVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intPrsId = 0;
    try {
      String q = "";
      for (int a=0; a<8; a++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.PERSON_MOD_PROC "+ q +";");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, Integer.parseInt(pvo.PRS_ID));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_PASSWD, "", 32));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_NAME, "", 25));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_TEL, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_EMAIL, "", 40));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_MOBILE_NO, "", 13));
      ps.setString(++i, StrUtil.getParameter(pvo.PRS_SMS, "0", 1));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intPrsId = rs.getInt("PRS_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intPrsId;
  }
  protected int PERSON_DROP_PROC(int intCpyId, PersonVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intPrsId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.PERSON_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, Integer.parseInt(pvo.PRS_ID));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intPrsId = rs.getInt("CNT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intPrsId;
  }
  
  
  protected ArrayList<CompanySalesVO> COMPANY_SALES_LIST_PROC(CompanySalesVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<CompanySalesVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_SALES_LIST_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, cvo.CPY_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
    	  while(rs.next()) {
    		  CompanySalesVO vo = new CompanySalesVO();
    		  vo.YYYY      = StrUtil.nvl(rs.getString("YYYY"));
    		  vo.SALES_AMT = StrUtil.nvl(rs.getString("SALES_AMT"));
    		  vo.CREUSER   = StrUtil.nvl(rs.getString("CREUSER"));
    		  vo.CREDATE   = StrUtil.nvl(rs.getString("CREDATE"));
    		  arr.add(vo);
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
  
  protected int COMPANY_SALES_ADD_PROC(CompanySalesVO cvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_SALES_ADD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, cvo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(cvo.YYYY));
      ps.setString(++i, StrUtil.nvl(cvo.SALES_AMT));
      ps.setString(++i, StrUtil.nvl(cvo.CREUSER));
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }

  protected CompanyVO COMPANY_SALEAMT_CHECK_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs  = null;
    Logger logger = Logger.getLogger(this.getClass());
    CompanyVO vo  = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_SALEAMT_CHECK_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
    	vo = new CompanyVO();
        vo.CPY_ID              = rs.getInt("CPY_ID");
        vo.CPY_NAME            = StrUtil.nvl(rs.getString("CPY_NAME          ".trim()));
        vo.BUSINESS_TYPE       = StrUtil.nvl(rs.getString("BUSINESS_TYPE     ".trim()));
        vo.INDUSTRY            = StrUtil.nvl(rs.getString("INDUSTRY          ".trim()));
        vo.CPY_BUSINESS_NO     = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO   ".trim()));
        vo.CPY_CEO_NAME        = StrUtil.nvl(rs.getString("CPY_CEO_NAME      ".trim()));
        vo.CPY_ZIPCODE         = StrUtil.nvl(rs.getString("CPY_ZIPCODE       ".trim()));
        vo.CPY_ADDR            = StrUtil.nvl(rs.getString("CPY_ADDR          ".trim()));
        vo.CPY_ADDR2           = StrUtil.nvl(rs.getString("CPY_ADDR2         ".trim()));
        vo.YYYY                = StrUtil.nvl(rs.getString("YYYY              ".trim()));
        vo.SALES_AMT           = StrUtil.nvl(rs.getString("SALES_AMT         ".trim()));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected void COMPANY_MOD_NOT_CHANGE_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MOD_NOT_CHANGE_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  
  protected int COMPANY_MOD_SELLER_CLEAR_YN_PROC(int intSellerCpyId, String strSellerClearYN) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MOD_SELLER_CLEAR_YN_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intSellerCpyId);
      ps.setString(++i, StrUtil.nvl(strSellerClearYN, "N"));
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  
  protected String COMPANY_MEMO_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String strCpyMemo = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MEMO_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        strCpyMemo = StrUtil.nvl(rs.getString("CPY_MEMO"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strCpyMemo;
  }
  
  protected int TOBE_COMPANY_TO_LEGACY_COMPANY_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCnt = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC [DOB2B-SERVER].[DOB2B].DBO.TOBE_COMPANY_TO_LEGACY_COMPANY_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
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
