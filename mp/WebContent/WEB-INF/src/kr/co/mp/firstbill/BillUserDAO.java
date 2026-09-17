package kr.co.mp.firstbill;

import java.sql.Connection;
import java.sql.ResultSet;
import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.CryptoDESUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class BillUserDAO {

  public static BillUserVO BILL_USER_DETAIL_PROC(int intUserSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_USER_DETAIL_PROC");
    BillUserVO vo = new BillUserVO();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_USER_DETAIL_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++, intUserSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo.CPY_ID     = rs.getInt("CPY_ID");
        vo.CORPNUM    = StrUtil.nvl(rs.getString("CORPNUM"));
        vo.CORPNAME   = StrUtil.nvl(rs.getString("CORPNAME"));
        vo.CEONAME    = StrUtil.nvl(rs.getString("CEONAME"));
        vo.ADDR1      = StrUtil.nvl(rs.getString("ADDR1"));
        vo.ADDR2      = StrUtil.nvl(rs.getString("ADDR2"));
        vo.USER_SEQ   = StrUtil.nvl(rs.getString("USER_SEQ"));
        vo.ID         = StrUtil.nvl(rs.getString("ID"));
        vo.PWD        = CryptoDESUtil.decrypt(StrUtil.nvl(rs.getString("PWD")));
        vo.BIZTYPE    = StrUtil.nvl(rs.getString("BIZTYPE"));
        vo.BIZCLASS   = StrUtil.nvl(rs.getString("BIZCLASS"));
        vo.MEMBERNAME = StrUtil.nvl(rs.getString("MEMBERNAME"));
        vo.TEL        = StrUtil.nvl(rs.getString("TEL"));
        vo.EMAIL      = StrUtil.nvl(rs.getString("EMAIL"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  public static BillUserVO BILL_USER_LOGIN_PROC(String id, String pwd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_USER_LOGIN_PROC");
    BillUserVO vo = new BillUserVO();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_USER_LOGIN_PROC ?, ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, id);
      ps.setString(i++, CryptoDESUtil.encrypt(pwd));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo.CPY_ID     = rs.getInt("CPY_ID");
        vo.CORPNUM    = StrUtil.nvl(rs.getString("CORPNUM"));
        vo.CORPNAME   = StrUtil.nvl(rs.getString("CORPNAME"));
        vo.CEONAME    = StrUtil.nvl(rs.getString("CEONAME"));
        vo.ADDR1      = StrUtil.nvl(rs.getString("ADDR1"));
        vo.ADDR2      = StrUtil.nvl(rs.getString("ADDR2"));
        vo.USER_SEQ   = StrUtil.nvl(rs.getString("USER_SEQ"));
        vo.ID         = StrUtil.nvl(rs.getString("ID"));
        vo.PWD        = CryptoDESUtil.decrypt(StrUtil.nvl(rs.getString("PWD")));
        vo.BIZTYPE    = StrUtil.nvl(rs.getString("BIZTYPE"));
        vo.BIZCLASS   = StrUtil.nvl(rs.getString("BIZCLASS"));
        vo.MEMBERNAME = StrUtil.nvl(rs.getString("MEMBERNAME"));
        vo.TEL        = StrUtil.nvl(rs.getString("TEL"));
        vo.EMAIL      = StrUtil.nvl(rs.getString("EMAIL"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  public static int BILL_CORPNUM_CHECK_PROC(String strBizNo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_CORPNUM_CHECK_PROC");
    int intCnt = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_CORPNUM_CHECK_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strBizNo);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
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
  public static int BILL_ID_CHECK_PROC(String strId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_ID_CHECK_PROC");
    int intCnt = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_ID_CHECK_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
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

  public static int BILL_USER_ADD_PROC(BillUserVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_USER_ADD_PROC");
    int intUserSeq = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_USER_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, vo.CORPNUM);
      ps.setString(i++, vo.CORPNAME);
      ps.setString(i++, vo.CEONAME);
      ps.setString(i++, vo.BIZTYPE);
      ps.setString(i++, vo.BIZCLASS);
      ps.setString(i++, vo.ADDR1);
      ps.setString(i++, vo.ADDR2);
      ps.setString(i++, vo.MEMBERNAME);
      ps.setString(i++, vo.ID);
      ps.setString(i++, CryptoDESUtil.encrypt(vo.PWD));
      ps.setString(i++, vo.TEL);
      ps.setString(i++, vo.EMAIL);
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        intUserSeq = rs.getInt("USER_SEQ");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intUserSeq;
  }
  
  
  public static void BILL_USER_DROP_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BillUserDAO.BILL_USER_DROP_PROC");
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_USER_DROP_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++, intCpyId);
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
}
