package kr.co.mp.mgr.sales;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CommissionDAO {
  protected int INFO_COMMISSION_ADD_PROC(CommissionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCommId = 0;
    try {
      String s = "";
      for (int i=0; i<19; i++) s += ", ?";
      s = s.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_ADD_PROC "+s+";");
      int i = 0;
      ps.setString(++i, StrUtil.nvl(pvo.CPY_BUYER, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_SELLER, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.PAY_CPY, "B"));
      ps.setString(++i, StrUtil.nvl(pvo.PAY_GUBUN, "10"));
      ps.setString(++i, StrUtil.nvl(pvo.COMM_METHOD, "A10"));
      
      ps.setString(++i, StrUtil.nvl(pvo.STD_DAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.MTY_STDAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.MTY_ENDDAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE1, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE2, "0"));
      
      ps.setString(++i, StrUtil.nvl(pvo.DISCOUNT_RATE, "0"));
      ps.setString(++i, StrUtil.xss(pvo.COMM_DESC));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.RECEIVE_MONEY, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.OFFLINE_YN, "N"));
      
      ps.setString(++i, StrUtil.nvl(pvo.MAX_YN, "N"));
      ps.setString(++i, StrUtil.nvl(pvo.MODID, ""));
      ps.setString(++i, StrUtil.nvl(pvo.START_DT));
      ps.setString(++i, StrUtil.nvl(pvo.END_DT));

      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCommId = rs.getInt("COMM_ID");
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCommId;
  }
  protected int INFO_COMMISSION_MOD_PROC(CommissionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCommId = 0;
    try {
      String s = "";
      for (int i=0; i<20; i++) s += ", ?";
      s = s.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_MOD_PROC "+s+";");
      int i = 0;
      ps.setInt(++i,  pvo.COMM_ID);

      ps.setString(++i, StrUtil.nvl(pvo.CPY_BUYER, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_SELLER, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.PAY_CPY, "B"));
      ps.setString(++i, StrUtil.nvl(pvo.PAY_GUBUN, "10"));
      ps.setString(++i, StrUtil.nvl(pvo.COMM_METHOD, "A10"));
      
      ps.setString(++i, StrUtil.nvl(pvo.STD_DAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.MTY_STDAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.MTY_ENDDAYS, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE1, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE2, "0"));
      
      ps.setString(++i, StrUtil.nvl(pvo.DISCOUNT_RATE, "0"));
      ps.setString(++i, StrUtil.xss(pvo.COMM_DESC));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_COMMISSION_RATE, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.RECEIVE_MONEY, "0"));
      ps.setString(++i, StrUtil.nvl(pvo.OFFLINE_YN, "N"));
      
      ps.setString(++i, StrUtil.nvl(pvo.MAX_YN, "N"));
      ps.setString(++i, StrUtil.nvl(pvo.MODID, ""));
      ps.setString(++i, StrUtil.nvl(pvo.START_DT, ""));
      ps.setString(++i, StrUtil.nvl(pvo.END_DT, ""));

      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCommId = rs.getInt("COMM_ID");
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCommId;
  }
  protected CommissionVO INFO_COMMISSION_DETAIL_PROC(int intCommId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CommissionVO vo = new CommissionVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCommId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.COMM_ID              = rs.getInt("COMM_ID");
        vo.CPY_BUYER            = StrUtil.nvl(rs.getString("CPY_BUYER           ".trim()));
        vo.CPY_SELLER           = StrUtil.nvl(rs.getString("CPY_SELLER          ".trim()));
        vo.PAY_CPY              = StrUtil.nvl(rs.getString("PAY_CPY             ".trim()));
        vo.PAY_GUBUN            = StrUtil.nvl(rs.getString("PAY_GUBUN           ".trim()));
        vo.COMM_METHOD          = StrUtil.nvl(rs.getString("COMM_METHOD         ".trim()));
        vo.STD_DAYS             = StrUtil.nvl(rs.getString("STD_DAYS            ".trim()));
        vo.MTY_STDAYS           = StrUtil.nvl(rs.getString("MTY_STDAYS          ".trim()));
        vo.MTY_ENDDAYS          = StrUtil.nvl(rs.getString("MTY_ENDDAYS         ".trim()));
        vo.CPY_COMMISSION_RATE1 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE1".trim()));
        vo.CPY_COMMISSION_RATE2 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE2".trim()));
        vo.DISCOUNT_RATE        = StrUtil.nvl(rs.getString("DISCOUNT_RATE       ".trim()));
        vo.COMM_DESC            = StrUtil.nvl(rs.getString("COMM_DESC           ".trim()));
        vo.CREDATE              = StrUtil.nvl(rs.getString("CREDATE             ".trim()));
        vo.CPY_COMMISSION_RATE  = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE ".trim()));
        vo.RECEIVE_MONEY        = StrUtil.nvl(rs.getString("RECEIVE_MONEY       ".trim()));
        vo.OFFLINE_YN           = StrUtil.nvl(rs.getString("OFFLINE_YN          ".trim()));
        vo.MAX_YN               = StrUtil.nvl(rs.getString("MAX_YN              ".trim()));
        vo.MODDATE              = StrUtil.nvl(rs.getString("MODDATE             ".trim()));
        vo.MODID                = StrUtil.nvl(rs.getString("MODID               ".trim()));
        vo.BUYER_NM             = StrUtil.nvl(rs.getString("BUYER_NM            ".trim()));
        vo.BUYER_BIZ_NO         = StrUtil.nvl(rs.getString("BUYER_BIZ_NO        ".trim()));
        vo.SELLER_NM            = StrUtil.nvl(rs.getString("SELLER_NM           ".trim()));
        vo.SELLER_BIZ_NO        = StrUtil.nvl(rs.getString("SELLER_BIZ_NO       ".trim()));
        vo.END_MONEY            = StrUtil.nvl(rs.getString("END_MONEY           ".trim()), "0");
        vo.START_DT             = StrUtil.nvl(rs.getString("START_DT            ".trim()));
        vo.END_DT               = StrUtil.nvl(rs.getString("END_DT              ".trim()));
        logger.debug(vo.toString());
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected ArrayList<CommissionVO> INFO_COMMISSION_LIST_PER_CPY_ID_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CommissionVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_LIST_PER_CPY_ID_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          CommissionVO vo = new CommissionVO();
          vo.COMM_ID              = rs.getInt("COMM_ID");
          vo.CPY_BUYER            = StrUtil.nvl(rs.getString("CPY_BUYER           ".trim()));
          vo.CPY_SELLER           = StrUtil.nvl(rs.getString("CPY_SELLER          ".trim()));
          vo.PAY_CPY              = StrUtil.nvl(rs.getString("PAY_CPY             ".trim()));
          vo.PAY_GUBUN            = StrUtil.nvl(rs.getString("PAY_GUBUN           ".trim()));
          vo.COMM_METHOD          = StrUtil.nvl(rs.getString("COMM_METHOD         ".trim()));
          vo.STD_DAYS             = StrUtil.nvl(rs.getString("STD_DAYS            ".trim()));
          vo.MTY_STDAYS           = StrUtil.nvl(rs.getString("MTY_STDAYS          ".trim()));
          vo.MTY_ENDDAYS          = StrUtil.nvl(rs.getString("MTY_ENDDAYS         ".trim()));
          vo.CPY_COMMISSION_RATE1 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE1".trim()));
          vo.CPY_COMMISSION_RATE2 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE2".trim()));
          vo.DISCOUNT_RATE        = StrUtil.nvl(rs.getString("DISCOUNT_RATE       ".trim()));
          vo.COMM_DESC            = StrUtil.nvl(rs.getString("COMM_DESC           ".trim()));
          vo.CREDATE              = StrUtil.nvl(rs.getString("CREDATE             ".trim()));
          vo.CPY_COMMISSION_RATE  = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE ".trim()));
          vo.RECEIVE_MONEY        = StrUtil.nvl(rs.getString("RECEIVE_MONEY       ".trim()));
          vo.OFFLINE_YN           = StrUtil.nvl(rs.getString("OFFLINE_YN          ".trim()));
          vo.MAX_YN               = StrUtil.nvl(rs.getString("MAX_YN              ".trim()));
          vo.MODDATE              = StrUtil.nvl(rs.getString("MODDATE             ".trim()));
          vo.MODID                = StrUtil.nvl(rs.getString("MODID               ".trim()));
          vo.BUYER_NM             = StrUtil.nvl(rs.getString("BUYER_NM            ".trim()));
          vo.BUYER_BIZ_NO         = StrUtil.nvl(rs.getString("BUYER_BIZ_NO        ".trim()));
          vo.SELLER_NM            = StrUtil.nvl(rs.getString("SELLER_NM           ".trim()));
          vo.SELLER_BIZ_NO        = StrUtil.nvl(rs.getString("SELLER_BIZ_NO       ".trim()));
          vo.END_MONEY            = StrUtil.nvl(rs.getString("END_MONEY           ".trim()), "0");
          vo.START_DT             = StrUtil.nvl(rs.getString("START_DT            ".trim()));
          vo.END_DT               = StrUtil.nvl(rs.getString("END_DT              ".trim()));
          arr.add(vo);
        }
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected int INFO_COMMISSION_DROP_PROC(int intCommId, String strManagerId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intSuccess = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, intCommId);
      ps.setString(++i, strManagerId);
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
      intSuccess = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intSuccess;
  }
  
  protected ArrayList<MastOffCommissionVO> MAST_OFF_COMMISSION_LIST_PER_CPY_ID_PROC(int intCpyId, int intPage, int intRowCnt) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<MastOffCommissionVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.MAST_OFF_COMMISSION_LIST_PER_CPY_ID_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, intCpyId);
      ps.setInt(++i, intPage);
      ps.setInt(++i, intRowCnt);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          MastOffCommissionVO vo = new MastOffCommissionVO();
          vo.RN           = rs.getInt("RN");
          vo.TOTAL_CNT    = rs.getInt("TOTAL_CNT");
          vo.CPY_ID       = StrUtil.nvl(rs.getString("CPY_ID      ".trim()));
          vo.SEQNO        = StrUtil.nvl(rs.getString("SEQNO       ".trim()));
          vo.END_MONEY    = StrUtil.nvl(rs.getString("END_MONEY   ".trim()));
          vo.RECEIVE_DATE = StrUtil.nvl(rs.getString("RECEIVE_DATE".trim()));
          vo.WRITE_ID     = StrUtil.nvl(rs.getString("WRITE_ID    ".trim()));
          vo.WRITE_DATE   = StrUtil.nvl(rs.getString("WRITE_DATE  ".trim()));
          vo.MODIFY_ID    = StrUtil.nvl(rs.getString("MODIFY_ID   ".trim()));
          vo.MODIFY_DATE  = StrUtil.nvl(rs.getString("MODIFY_DATE ".trim()));
          vo.DEL_YN       = StrUtil.nvl(rs.getString("DEL_YN      ".trim()));
          vo.START_DT     = StrUtil.nvl(rs.getString("START_DT    ".trim()));
          vo.END_DT       = StrUtil.nvl(rs.getString("END_DT      ".trim()));
          vo.COMM_ID      = rs.getInt("COMM_ID");
          vo.COMM_METHOD  = StrUtil.nvl(rs.getString("COMM_METHOD ".trim()));
          vo.CTNO         = StrUtil.nvl(rs.getString("CTNO        ".trim()));
          vo.CTID         = rs.getInt("CTID");
          arr.add(vo);
        }
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected ArrayList<CommissionVO> INFO_COMMISSION_LIST_PROC(int intCpyId, CommissionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CommissionVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, pvo.PAY_GUBUN);
      ps.setString(++i, pvo.COMM_METHOD);
      ps.setString(++i, pvo.MAX_YN);
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setString(++i, StrUtil.nvl(pvo.SBDATE, ""));
      ps.setString(++i, StrUtil.nvl(pvo.START_DT, "").replaceAll("-", ""));
      ps.setString(++i, StrUtil.nvl(pvo.END_DT, "").replaceAll("-", ""));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          CommissionVO vo = new CommissionVO();
          vo.COMM_ID              = rs.getInt("COMM_ID");
          vo.CPY_BUYER            = StrUtil.nvl(rs.getString("CPY_BUYER           ".trim()));
          vo.CPY_SELLER           = StrUtil.nvl(rs.getString("CPY_SELLER          ".trim()));
          vo.PAY_CPY              = StrUtil.nvl(rs.getString("PAY_CPY             ".trim()));
          vo.PAY_GUBUN            = StrUtil.nvl(rs.getString("PAY_GUBUN           ".trim()));
          vo.COMM_METHOD          = StrUtil.nvl(rs.getString("COMM_METHOD         ".trim()));
          vo.STD_DAYS             = StrUtil.nvl(rs.getString("STD_DAYS            ".trim()));
          vo.MTY_STDAYS           = StrUtil.nvl(rs.getString("MTY_STDAYS          ".trim()));
          vo.MTY_ENDDAYS          = StrUtil.nvl(rs.getString("MTY_ENDDAYS         ".trim()));
          vo.CPY_COMMISSION_RATE1 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE1".trim()));
          vo.CPY_COMMISSION_RATE2 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE2".trim()));
          vo.DISCOUNT_RATE        = StrUtil.nvl(rs.getString("DISCOUNT_RATE       ".trim()));
          vo.COMM_DESC            = StrUtil.nvl(rs.getString("COMM_DESC           ".trim()));
          vo.CREDATE              = StrUtil.nvl(rs.getString("CREDATE             ".trim()));
          vo.CPY_COMMISSION_RATE  = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE ".trim()));
          vo.RECEIVE_MONEY        = StrUtil.nvl(rs.getString("RECEIVE_MONEY       ".trim()));
          vo.OFFLINE_YN           = StrUtil.nvl(rs.getString("OFFLINE_YN          ".trim()));
          vo.MAX_YN               = StrUtil.nvl(rs.getString("MAX_YN              ".trim()));
          vo.MODDATE              = StrUtil.nvl(rs.getString("MODDATE             ".trim()));
          vo.MODID                = StrUtil.nvl(rs.getString("MODID               ".trim()));
          vo.BUYER_NM             = StrUtil.nvl(rs.getString("BUYER_NM            ".trim()));
          vo.BUYER_BIZ_NO         = StrUtil.nvl(rs.getString("BUYER_BIZ_NO        ".trim()));
          vo.SELLER_NM            = StrUtil.nvl(rs.getString("SELLER_NM           ".trim()));
          vo.SELLER_BIZ_NO        = StrUtil.nvl(rs.getString("SELLER_BIZ_NO       ".trim()));
          vo.END_MONEY            = StrUtil.nvl(rs.getString("END_MONEY           ".trim()), "0");
          vo.START_DT             = StrUtil.nvl(rs.getString("START_DT            ".trim()));
          vo.END_DT               = StrUtil.nvl(rs.getString("END_DT              ".trim()));
          vo.RN                   = rs.getInt("RN");
          vo.TOTAL_CNT            = rs.getInt("TOTAL_CNT");
          arr.add(vo);
        }
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected int MAST_OFF_COMMISSION_ADD_PROC(MastOffCommissionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.MAST_OFF_COMMISSION_ADD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.COMM_ID);
      ps.setInt(++i,  pvo.CTID);
      ps.setString(++i, StrUtil.extractInteger(pvo.END_MONEY));
      ps.setString(++i, StrUtil.nvl(pvo.WRITE_ID, "SYSTEM"));

      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
          intSeq = rs.getInt("SEQ");
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  protected int MAST_OFF_COMMISSION_DROP_PROC(MastOffCommissionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.MAST_OFF_COMMISSION_DROP_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, pvo.SEQNO);
      ps.setString(++i, StrUtil.nvl(pvo.WRITE_ID, "SYSTEM"));

      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected CommissionVO CHECK_COMM_METHOD_D10_PERIOD(int intCtid) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CommissionVO vo = new CommissionVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CHECK_COMM_METHOD_D10_PERIOD ?;");
      ps.setInt(1, intCtid);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.COMM_ID = rs.getInt("COMM_ID");
        vo.START_DT = rs.getString("START_DT");
        vo.END_DT = rs.getString("END_DT");
      }  
    } catch(Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
  protected CommissionVO CHECK_MPFEE_TOTALAMT_SUM_PROC(String strCpyBuyer) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CommissionVO vo = new CommissionVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CHECK_MPFEE_TOTALAMT_SUM_PROC ?;");
      ps.setInt(1, Integer.parseInt(strCpyBuyer));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.MPFEE_TOTALAMT = rs.getString("MPFEE_TOTALAMT");
        vo.TOTAL_CNT = rs.getInt("CNT");
      }
    } catch(Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
  protected int INFO_COMMISSION_RENEW_PROC(int intCommId, String strWriterLoginId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.INFO_COMMISSION_RENEW_PROC ?, ?;");
      ps.setInt(1, intCommId);
      ps.setString(2, strWriterLoginId);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch(Exception e) {
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
}
