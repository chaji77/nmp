package kr.co.mp.mgr.salesrep;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class SalesrepDAO {
  protected int M_SALESREP_ADD_PROC(SalesrepVO vo) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	ResultSet rs = null;
	int intId = -1;
	try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_SALESREP_ADD_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.NM), "", 30));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.PHONE_NO), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.FAX_NO), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.EMAIL), "", 100));
      ps.setInt   (++i, vo.REG_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intId = rs.getInt("SALESREP_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intId;
  }
  
  protected SalesrepVO M_SALESREP_DETAIL_PROC(int mid) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    SalesrepVO v = new SalesrepVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_SALESREP_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(++i, mid);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
    	v.SALESREP_ID = rs.getInt("SALESREP_ID");
        v.NM = StrUtil.input(rs.getString("NM"));
        v.PHONE_NO = StrUtil.input(rs.getString("PHONE_NO"));
        v.FAX_NO = StrUtil.input(rs.getString("FAX_NO"));
        v.EMAIL = StrUtil.input(rs.getString("EMAIL"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return v;
  }
  
  protected int M_SALESREP_MOD_PROC(SalesrepVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_SALESREP_MOD_PROC ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt   (++i, vo.SALESREP_ID);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.NM), "", 30));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.PHONE_NO), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.FAX_NO), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.EMAIL), "", 100));
      ps.setInt   (++i, vo.REG_ID);
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
  
  protected int M_SALESREP_DROP_PROC(SalesrepVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_SALESREP_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt   (++i, vo.SALESREP_ID);
      ps.setInt   (++i, vo.REG_ID);
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
  
  protected ArrayList<SalesrepVO> M_SALESREP_LIST_PROC(SalesrepVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<SalesrepVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_SALESREP_LIST_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, vo.PAGE);
      ps.setInt(++i, vo.ROW_CNT);
      ps.setString(++i, vo.NM);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          SalesrepVO v = new SalesrepVO();
          v.RN = rs.getInt("RN");
          v.TOTAL_CNT = rs.getInt("TOTAL_CNT");
          v.SALESREP_ID = rs.getInt("SALESREP_ID");
          v.NM = StrUtil.input(rs.getString("NM"));
          v.PHONE_NO = StrUtil.input(rs.getString("PHONE_NO"));
          v.FAX_NO = StrUtil.input(rs.getString("FAX_NO"));
          v.EMAIL = StrUtil.input(rs.getString("EMAIL"));
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
}


