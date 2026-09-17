package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class TaxDAO {

  protected int CT_BILL_ADD_PROC(TaxVO vo, String strXmlData) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_BILL_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.BILL_NO), "", 24));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.APP_NO), "", 24));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.BILL_DT), "", 8));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.BILL_TYPE), "", 2));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.BILL_GUBUN), "", 2));
      
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_VENDERNO), "", 13));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_NAME), "", 70));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_CEO), "", 35));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_ADDRESS), "", 250));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_TYPE), "", 150));
      
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.SCOMP_CLASS), "", 150));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_VENDERNO), "", 13));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_NAME), "", 70));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_CEO), "", 30));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_ADDRESS), "", 250));
      
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_TYPE), "", 100));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.RCOMP_CLASS), "", 100));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.PAY_SUM_AMOUNT), "", 18));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.PAY_SUM_TAX), "", 18));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.ITEM_NAME), "", 100));
      
      ps.setInt(++i, vo.CPY_ID);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.PAY_TAX_RATE), "", 2));
      ps.setString(++i, strXmlData);
      
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intSeq = rs.getInt("SBILL_SEQ");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  
  protected ArrayList<TaxVO> CT_BILL_FOR_TRADE_LIST_PROC(int intPage, int intRowCnt, int intCpyId, int intTargetCpyId, String strStartYmd, String strEndYmd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<TaxVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_BILL_FOR_TRADE_LIST_PROC ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intPage);
      ps.setInt(   ++i, intRowCnt);
      ps.setInt(   ++i, intCpyId);
      ps.setInt(   ++i, intTargetCpyId);
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strStartYmd).replaceAll("-", ""), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-").replaceAll("-", ""), 8));
      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strEndYmd).replaceAll("-", ""), DateTimeUtil.getCurrentDate(""), 8));
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          TaxVO t          = new TaxVO();
          t.TOTAL_CNT      = rs.getInt("TOTAL_CNT");
          t.SBILL_SEQ      = rs.getString("SBILL_SEQ");
          t.APP_NO         = rs.getString("APP_NO");
          t.BILL_DT        = rs.getString("BILL_DT");
          t.SCOMP_NAME     = rs.getString("SCOMP_NAME");
          t.SCOMP_VENDERNO = rs.getString("SCOMP_VENDERNO");
          t.RCOMP_NAME     = rs.getString("RCOMP_NAME");
          t.RCOMP_VENDERNO = rs.getString("RCOMP_VENDERNO");
          t.PAY_SUM_AMOUNT = rs.getString("PAY_SUM_AMOUNT");
          t.PAY_SUM_TAX    = rs.getString("PAY_SUM_TAX");
          t.SETTLED_AMOUNT = rs.getString("SETTLED_AMOUNT");
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

  protected TaxVO CT_BILL_MASTER_DETAIL_PROC(String strBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    TaxVO vo = new TaxVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_BILL_MASTER_DETAIL_PROC ?;");
      int i = 0;
      ps.setString(++i, strBillSeq);
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          vo.SBILL_SEQ      = StrUtil.nvl(rs.getString("SBILL_SEQ     ".trim()));
          vo.BILL_NO        = StrUtil.nvl(rs.getString("BILL_NO       ".trim()));
          vo.APP_NO         = StrUtil.nvl(rs.getString("APP_NO        ".trim()));
          vo.BILL_DT        = StrUtil.nvl(rs.getString("BILL_DT       ".trim()));
          vo.BILL_TYPE      = StrUtil.nvl(rs.getString("BILL_TYPE     ".trim()));
          vo.BILL_GUBUN     = StrUtil.nvl(rs.getString("BILL_GUBUN    ".trim()));
          vo.SCOMP_VENDERNO = StrUtil.nvl(rs.getString("SCOMP_VENDERNO".trim()));
          vo.SCOMP_NAME     = StrUtil.nvl(rs.getString("SCOMP_NAME    ".trim()));
          vo.SCOMP_CEO      = StrUtil.nvl(rs.getString("SCOMP_CEO     ".trim()));
          vo.SCOMP_ADDRESS  = StrUtil.nvl(rs.getString("SCOMP_ADDRESS ".trim()));
          vo.SCOMP_TYPE     = StrUtil.nvl(rs.getString("SCOMP_TYPE    ".trim()));
          vo.SCOMP_CLASS    = StrUtil.nvl(rs.getString("SCOMP_CLASS   ".trim()));
          vo.RCOMP_VENDERNO = StrUtil.nvl(rs.getString("RCOMP_VENDERNO".trim()));
          vo.RCOMP_NAME     = StrUtil.nvl(rs.getString("RCOMP_NAME    ".trim()));
          vo.RCOMP_CEO      = StrUtil.nvl(rs.getString("RCOMP_CEO     ".trim()));
          vo.RCOMP_ADDRESS  = StrUtil.nvl(rs.getString("RCOMP_ADDRESS ".trim()));
          vo.RCOMP_TYPE     = StrUtil.nvl(rs.getString("RCOMP_TYPE    ".trim()));
          vo.RCOMP_CLASS    = StrUtil.nvl(rs.getString("RCOMP_CLASS   ".trim()));
          vo.PAY_SUM_AMOUNT = StrUtil.nvl(rs.getString("PAY_SUM_AMOUNT".trim()));
          vo.PAY_SUM_TAX    = StrUtil.nvl(rs.getString("PAY_SUM_TAX   ".trim()));
          vo.ITEM_NAME      = StrUtil.nvl(rs.getString("ITEM_NAME     ".trim()));
          vo.DEL_YN         = StrUtil.nvl(rs.getString("DEL_YN        ".trim()));
          vo.DEL_DATE       = StrUtil.nvl(rs.getString("DEL_DATE      ".trim()));
          vo.CPY_ID         = rs.getInt("CPY_ID");
          vo.REG_DATE       = StrUtil.nvl(rs.getString("REG_DATE      ".trim()));
          vo.PAY_TAX_RATE   = StrUtil.nvl(rs.getString("PAY_TAX_RATE  ".trim()));
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  protected ArrayList<TaxItemVO> CT_BILL_ITEM_DETAIL_PROC(String strBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<TaxItemVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_BILL_ITEM_DETAIL_PROC ?;");
      int i = 0;
      ps.setString(++i, strBillSeq);
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          TaxItemVO vo = new TaxItemVO();
          vo.ITEM_SEQ    = StrUtil.nvl(rs.getString("ITEM_SEQ   ".trim()));
          vo.SBILL_SEQ   = StrUtil.nvl(rs.getString("SBILL_SEQ  ".trim()));
          vo.ITEM_NAME   = StrUtil.nvl(rs.getString("ITEM_NAME  ".trim()));
          vo.ITEM_PRICE  = StrUtil.nvl(rs.getString("ITEM_PRICE ".trim()));
          vo.ITEM_CNT    = StrUtil.nvl(rs.getString("ITEM_CNT   ".trim()));
          vo.ITEM_UNIT   = StrUtil.nvl(rs.getString("ITEM_UNIT  ".trim()));
          vo.ITEM_AMOUNT = StrUtil.nvl(rs.getString("ITEM_AMOUNT".trim()));
          vo.ITEM_TAX    = StrUtil.nvl(rs.getString("ITEM_TAX   ".trim()));
          vo.ITEM_DT     = StrUtil.nvl(rs.getString("ITEM_DT    ".trim()));
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
  protected String CT_BILL_DROP_PROC(String strBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String strDelYn = "N";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_BILL_DROP_PROC ?;");
      int i = 0;
      ps.setString(++i, strBillSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        strDelYn = rs.getString("DEL_YN");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strDelYn;
  }
}
