package kr.co.mp.mgr.manager;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.CryptoDESUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class ManagerDAO {
  protected int M_MANAGER_ADD_PROC(ManagerVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intId = -1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_ADD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.LOGIN_ID), "", 20));
      ps.setString(++i, CryptoDESUtil.encrypt(vo.LOGIN_PW));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.USER_NM), "", 30));
      ps.setInt   (++i, vo.REG_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intId = rs.getInt("MAN_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intId;
  }
  protected ManagerVO M_MANAGER_DETAIL_PROC(int intManId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ManagerVO v = new ManagerVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(++i, intManId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        v.MAN_ID = rs.getInt("MAN_ID");
        v.LOGIN_ID = StrUtil.input(rs.getString("LOGIN_ID"));
        v.LOGIN_PW = CryptoDESUtil.decrypt(rs.getString("LOGIN_PW"));
        v.USER_NM = StrUtil.input(rs.getString("USER_NM"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return v;
  }
  protected int M_MANAGER_MOD_PROC(ManagerVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_MOD_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt   (++i, vo.MAN_ID);
      ps.setString(++i, CryptoDESUtil.encrypt(vo.LOGIN_PW));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.USER_NM), "", 30));
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
  protected int M_MANAGER_DROP_PROC(ManagerVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt   (++i, vo.MAN_ID);
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
  protected ArrayList<ManagerVO> M_MANAGER_LIST_PROC(ManagerVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<ManagerVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_LIST_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, vo.PAGE);
      ps.setInt(++i, vo.ROW_CNT);
      ps.setString(++i, vo.USER_NM);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          ManagerVO v = new ManagerVO();
          v.RN = rs.getInt("RN");
          v.TOTAL_CNT = rs.getInt("TOTAL_CNT");
          v.MAN_ID = rs.getInt("MAN_ID");
          v.LOGIN_ID = rs.getString("LOGIN_ID");
          v.USER_NM = StrUtil.input(rs.getString("USER_NM"));
          v.REG_ID = rs.getInt("REG_ID");
          v.REG_NM = StrUtil.input(rs.getString("REG_NM"));
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
  protected ManagerVO M_MANAGER_LOGIN_PROC(ManagerVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ManagerVO v = new ManagerVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_MANAGER_LOGIN_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, vo.LOGIN_ID);
      ps.setString(++i, CryptoDESUtil.encrypt(vo.LOGIN_PW));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        v.MAN_ID = rs.getInt("MAN_ID");
        v.USER_NM = StrUtil.input(rs.getString("USER_NM"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return v;
  }
}
