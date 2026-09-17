package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class GuaranteeDAO {
  protected ArrayList<PayMethodVO> CT_MY_PAYMETHOD_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<PayMethodVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_MY_PAYMETHOD_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          PayMethodVO t    = new PayMethodVO();
          t.CPY_ID         = rs.getInt("CPY_ID");
          t.BNK_CD         = StrUtil.nvl(rs.getString("BNK_CD"));
          t.PAY_ID         = StrUtil.nvl(rs.getString("PAY_ID"));
          t.PAY_DESC       = StrUtil.nvl(rs.getString("PAY_DESC"));
          t.PAY_SDESC      = StrUtil.nvl(rs.getString("PAY_SDESC"));
          t.BNK_NAME       = StrUtil.nvl(rs.getString("BNK_NAME"));
          t.GUAR_GUBUN     = StrUtil.nvl(rs.getString("GUAR_GUBUN"));
          t.GUAR_STATUS    = StrUtil.nvl(rs.getString("GUAR_STATUS"));
          arr.add(t);
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
  protected ArrayList<PayMethodVO> M_CT_MY_PAYMETHOD_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<PayMethodVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_CT_MY_PAYMETHOD_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          PayMethodVO t    = new PayMethodVO();
          t.CPY_ID         = rs.getInt("CPY_ID");
          t.BNK_CD         = StrUtil.nvl(rs.getString("BNK_CD"));
          t.PAY_ID         = StrUtil.nvl(rs.getString("PAY_ID"));
          t.PAY_DESC       = StrUtil.nvl(rs.getString("PAY_DESC"));
          t.PAY_SDESC      = StrUtil.nvl(rs.getString("PAY_SDESC"));
          t.BNK_NAME       = StrUtil.nvl(rs.getString("BNK_NAME"));
          t.GUAR_GUBUN     = StrUtil.nvl(rs.getString("GUAR_GUBUN"));
          t.GUAR_STATUS    = StrUtil.nvl(rs.getString("GUAR_STATUS"));
          
          t.GUAR_CRA_DATE  = StrUtil.nvl(rs.getString("GUAR_CRA_DATE ".trim()));
          t.GUAR_EXP_DATE  = StrUtil.nvl(rs.getString("GUAR_EXP_DATE ".trim()));
          t.GUAR_VAL_DATE  = StrUtil.nvl(rs.getString("GUAR_VAL_DATE ".trim()));
          t.GUAR_TOTAL_AMT = StrUtil.nvl(rs.getString("GUAR_TOTAL_AMT".trim()));
          t.MEMO           = StrUtil.nvl(rs.getString("MEMO          ".trim()));
          t.WRITE_DATE     = StrUtil.nvl(rs.getString("WRITE_DATE    ".trim()));
          t.WRITE_ID       = StrUtil.nvl(rs.getString("WRITE_ID      ".trim()));
          t.MODIFY_DATE    = StrUtil.nvl(rs.getString("MODIFY_DATE   ".trim()));
          t.MODIFY_ID      = StrUtil.nvl(rs.getString("MODIFY_ID     ".trim()));
          t.CHANGE_AMT     = StrUtil.nvl(rs.getString("CHANGE_AMT    ".trim()));
          t.CPY_GUAR_SEQ   = rs.getInt("CPY_GUAR_SEQ");
          arr.add(t);
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
  protected int GUARANTEE_MASTER_INFO_DROP_PROC(PayMethodVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_DROP_PROC ?, ?, ?, ?, ?");
      int i = 0;
      ps.setInt(++i, vo.CPY_ID);
	  ps.setString(++i, vo.BNK_CD);
	  ps.setInt(++i, Integer.parseInt(vo.PAY_ID));
	  ps.setInt(++i, vo.CPY_GUAR_SEQ);
	  ps.setString(++i, vo.WRITE_ID);
	  logger.debug(ps.getQueryString());
	  ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected int GUARANTEE_MASTER_INFO_EXTEND_PROC(PayMethodVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_EXTEND_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, vo.CPY_ID);
      ps.setString(++i, vo.BNK_CD);
      ps.setInt(++i, Integer.parseInt(vo.PAY_ID));
      ps.setInt(++i, vo.CPY_GUAR_SEQ);
      ps.setString(++i, vo.WRITE_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) intResult = rs.getInt("SEQ");
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    } 
    return intResult;
  }
  protected int GUARANTEE_MASTER_INFO_ADD_PROC(PayMethodVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, vo.CPY_ID);
      ps.setString(++i, vo.BNK_CD);
      ps.setInt(++i, Integer.parseInt(vo.PAY_ID));
      ps.setInt(++i, vo.GUAR_LOC);
      ps.setString(++i, vo.GUAR_STATUS);
      ps.setString(++i, vo.GUAR_CRA_DATE);
      ps.setString(++i, vo.GUAR_EXP_DATE);
      ps.setString(++i, vo.GUAR_VAL_DATE);
      ps.setString(++i, vo.GUAR_TOTAL_AMT);
      ps.setString(++i, vo.MEMO);
      ps.setString(++i, vo.WRITE_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) intResult = rs.getInt("SEQ");
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return intResult;
  }
  protected int GUARANTEE_MASTER_INFO_MOD_PROC(PayMethodVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, vo.CPY_ID);
      ps.setString(++i, vo.BNK_CD);
      ps.setInt(++i, Integer.parseInt(vo.PAY_ID));
      ps.setInt(++i, vo.CPY_GUAR_SEQ);
      ps.setInt(++i, 0);
      ps.setString(++i, vo.GUAR_STATUS);
      ps.setString(++i, vo.GUAR_CRA_DATE);
      ps.setString(++i, vo.GUAR_EXP_DATE);
      ps.setString(++i, vo.GUAR_VAL_DATE);
      ps.setString(++i, vo.GUAR_TOTAL_AMT);
      ps.setString(++i, vo.MEMO);
      ps.setString(++i, vo.WRITE_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) intResult = rs.getInt("SEQ");
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return intResult;
  }
  protected ArrayList<PayMethodVO> BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC(String strGuarGubun, String strBankCode) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<PayMethodVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, strGuarGubun);
      ps.setString(++i, strBankCode);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          PayMethodVO t    = new PayMethodVO();
          t.BNK_CD         = StrUtil.nvl(rs.getString("BNK_CD"));
          t.PAY_ID         = StrUtil.nvl(rs.getString("PAY_ID"));
          t.PAY_SDESC      = StrUtil.nvl(rs.getString("PAY_SDESC"));
          arr.add(t);
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
  protected PayMethodVO GUARANTEE_MASTER_INFO_DETAIL_PROC(PayMethodVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    PayMethodVO t = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_DETAIL_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.CPY_ID);
      ps.setString(++i, pvo.BNK_CD);
      ps.setString(++i, pvo.PAY_ID);
      ps.setInt(++i, pvo.CPY_GUAR_SEQ);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        t = new PayMethodVO();
        t.BNK_CD         = StrUtil.nvl(rs.getString("BNK_CD"));
        t.BNK_NAME       = StrUtil.nvl(rs.getString("BNK_NAME"));
        t.PAY_ID         = StrUtil.nvl(rs.getString("PAY_ID"));
        t.PAY_SDESC      = StrUtil.nvl(rs.getString("PAY_SDESC"));
        t.GUAR_LOC_DESC  = StrUtil.nvl(rs.getString("GUAR_LOC_DESC"));
        t.GUAR_GUBUN     = StrUtil.nvl(rs.getString("GUAR_GUBUN    ".trim()));
        t.GUAR_STATUS    = StrUtil.nvl(rs.getString("GUAR_STATUS   ".trim()));
        t.GUAR_CRA_DATE  = StrUtil.nvl(rs.getString("GUAR_CRA_DATE ".trim())+"          ").substring(0, 10);
        t.GUAR_EXP_DATE  = StrUtil.nvl(rs.getString("GUAR_EXP_DATE ".trim())+"          ").substring(0, 10);
        t.GUAR_VAL_DATE  = StrUtil.nvl(rs.getString("GUAR_VAL_DATE ".trim())+"          ").substring(0, 10);
        t.GUAR_TOTAL_AMT = StrUtil.nvl(rs.getString("GUAR_TOTAL_AMT".trim()));
        t.MEMO           = StrUtil.nvl(rs.getString("MEMO          ".trim()));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return t;
  }
  protected ArrayList<PayMethodVO> M_GUARANTEE_LIST_PROC(PayMethodVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<PayMethodVO> arr = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_GUARANTEE_LIST_PROC ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.CPY_ID);
      ps.setString(++i, pvo.BNK_CD);
      ps.setString(++i, pvo.PAY_ID);
      ps.setString(++i, pvo.GUAR_GUBUN);
      ps.setInt(++i, pvo.PAGE);
      ps.setInt(++i, pvo.ROW_CNT);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        arr = new ArrayList<>();
        while (rs.next()) {
          PayMethodVO t = new PayMethodVO();
          t.RN             = rs.getInt("RN");
          t.TOTAL_CNT      = rs.getInt("TOTAL_CNT");
          t.SUM_AMT        = rs.getLong("SUM_AMT");
          t.CPY_ID         = rs.getInt("CPY_ID");
          t.BNK_CD         = StrUtil.nvl(rs.getString("BNK_CD"));
          t.BNK_NAME       = StrUtil.nvl(rs.getString("BNK_NAME"));
          t.PAY_ID         = StrUtil.nvl(rs.getString("PAY_ID"));
          t.PAY_SDESC      = StrUtil.nvl(rs.getString("PAY_SDESC"));
          t.GUAR_STATUS    = StrUtil.nvl(rs.getString("GUAR_STATUS"));
          t.GUAR_GUBUN     = StrUtil.nvl(rs.getString("GUAR_GUBUN"));
          t.GUAR_CRA_DATE  = StrUtil.nvl(rs.getString("GUAR_CRA_DATE ".trim()));
          t.GUAR_EXP_DATE  = StrUtil.nvl(rs.getString("GUAR_EXP_DATE ".trim()));
          t.GUAR_VAL_DATE  = StrUtil.nvl(rs.getString("GUAR_VAL_DATE ".trim()));
          t.GUAR_TOTAL_AMT = StrUtil.nvl(rs.getString("GUAR_TOTAL_AMT".trim()));
          t.MEMO           = StrUtil.nvl(rs.getString("MEMO          ".trim()));
          t.WRITE_DATE     = StrUtil.nvl(rs.getString("WRITE_DATE    ".trim()));
          t.WRITE_ID       = StrUtil.nvl(rs.getString("WRITE_ID      ".trim()));
          t.MODIFY_DATE    = StrUtil.nvl(rs.getString("MODIFY_DATE   ".trim()));
          t.MODIFY_ID      = StrUtil.nvl(rs.getString("MODIFY_ID     ".trim()));
          t.CHANGE_AMT     = StrUtil.nvl(rs.getString("CHANGE_AMT    ".trim()));
          t.CPY_GUAR_SEQ   = rs.getInt("CPY_GUAR_SEQ");
          t.GUAR_TOTAL_AMT = StrUtil.nvl(rs.getString("GUAR_TOTAL_AMT"));
          t.CHANGE_AMT     = StrUtil.nvl(rs.getString("CHANGE_AMT"));
          t.CPY_NAME       = StrUtil.nvl(rs.getString("CPY_NAME"));
          t.CPY_BUSINESS_NO= StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
          arr.add(t);
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
  protected ArrayList<PayMethodVO> GUARANTEE_LOCATION_SEARCH_PROC(PayMethodVO pvo) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	ResultSet rs = null;
	ArrayList<PayMethodVO> arr = new ArrayList<>();
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_LOCATION_SEARCH_PROC ?, ?, ?;");
	  int i = 0;
	  ps.setInt(++i, pvo.PAGE);
	  ps.setInt(++i, pvo.ROW_CNT);
	  ps.setString(++i, pvo.GUAR_LOC_DESC);
	  logger.debug(ps.getQueryString());
	  rs = ps.executeQuery();
	  if (rs!=null) {
		while(rs.next()) {
		  PayMethodVO vo = new PayMethodVO();
	      vo.RN = rs.getInt("RN");
	      vo.TOTAL_CNT = rs.getInt("TOTAL_CNT");
	      vo.GUAR_LOC = rs.getInt("GUAR_LOC");
	      vo.GUAR_LOC_DESC = rs.getString("GUAR_LOC_DESC");
	      vo.GUAR_LOC_GUBUN = rs.getString("GUAR_LOC_GUBUN");
	      arr.add(vo);
		}
	  }
	} catch(Exception e) {
	    logger.error(ps.getQueryString());
	    logger.error(e.toString());
	} finally {
		ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	} return arr;
  }
  protected int GUARANTEE_MASTER_INFO_EXTEND_ALL_PROC(String date, String managerId) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	ResultSet rs = null;
	int intResult = -1;
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_MASTER_INFO_EXTEND_ALL_PROC ?, ?;");
	  ps.setString(1, date);
	  ps.setString(2, managerId);
	  logger.debug(ps.getQueryString());
	  rs = ps.executeQuery();
	  if (rs!=null && rs.next()) intResult = rs.getInt("intResult");
	} catch(Exception e) {
	  logger.error(ps.getQueryString());
	  logger.error(e.toString());
	} finally {
	  ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	} return intResult;
  }
}
