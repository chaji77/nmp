package kr.co.mp.mgr.memo;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.mp.common.CodeVO;

public class MemoDAO {
  protected ArrayList<MemoVO> ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC(MemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<MemoVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.PAGE);
      ps.setInt(++i, pvo.ROW_CNT);
      ps.setInt(++i, pvo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(pvo.TO_USER_ID));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          MemoVO vo      = new MemoVO();
          vo.RN          = rs.getInt("RN");
          vo.TOTAL_CNT   = rs.getInt("TOTAL_CNT");
          vo.ACTIVE_ID   = StrUtil.nvl(rs.getString("ACTIVE_ID   ".trim()));
          vo.ACTIVE_KIND = StrUtil.nvl(rs.getString("ACTIVE_KIND ".trim()));
          vo.WRITE_ID    = StrUtil.nvl(rs.getString("WRITE_ID    ".trim()));
          vo.WRITE_DATE  = StrUtil.nvl(rs.getString("WRITE_DATE  ".trim()));
          vo.CPY_ID      = rs.getInt("CPY_ID");
          vo.CALL_TYPE   = StrUtil.nvl(rs.getString("CALL_TYPE   ".trim()));
          vo.ACTIVE_DESC = StrUtil.nvl(rs.getString("ACTIVE_DESC ".trim()));
          vo.USER_NM     = StrUtil.nvl(rs.getString("USER_NM     ".trim()));
          vo.TO_USER_NM  = StrUtil.nvl(rs.getString("TO_USER_NM  ".trim()));
          vo.CPY_NAME    = StrUtil.nvl(rs.getString("CPY_NAME    ".trim()));
          vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
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
  protected int ACTIVE_MANAGEMENT_ADD_PROC(MemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intActiveId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_ADD_PROC ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(pvo.ACTIVE_KIND));
      ps.setString(++i, pvo.WRITE_ID);
      ps.setInt(++i, pvo.CPY_ID);
      ps.setString(++i, StrUtil.getParameter(pvo.CALL_TYPE, "1", 1));
      ps.setString(++i, pvo.ACTIVE_DESC);
      ps.setString(++i, pvo.TO_USER_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          intActiveId = rs.getInt("ACTIVE_ID");
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intActiveId;
  }
  protected int ACTIVE_MANAGEMENT_DROP_PROC(int intActiveId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_DROP_PROC ?;");
      int i = 0;
      ps.setInt(++i, intActiveId);
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
  protected MemoVO ACTIVE_MANAGEMENT_DETAIL_PROC(int intActiveId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    MemoVO vo = new MemoVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_DETAIL_PROC ?;");
      ps.setInt(1, intActiveId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.ACTIVE_ID   = StrUtil.nvl(rs.getString("ACTIVE_ID   ".trim()));
        vo.ACTIVE_KIND = StrUtil.nvl(rs.getString("ACTIVE_KIND ".trim()));
        vo.CPY_ID      = rs.getInt("CPY_ID");
        vo.CALL_TYPE   = StrUtil.nvl(rs.getString("CALL_TYPE   ".trim()));
          vo.ACTIVE_DESC = StrUtil.nvl(rs.getString("ACTIVE_DESC ".trim()));
          vo.TO_USER_ID  = StrUtil.nvl(rs.getString("TO_USER_ID  ".trim()));
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo; 
  }
  protected int ACTIVE_MANAGEMENT_MOD_PROC(MemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intActiveId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_MOD_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(pvo.ACTIVE_ID));
      ps.setInt(++i, Integer.parseInt(pvo.ACTIVE_KIND));
      ps.setString(++i, StrUtil.getParameter(pvo.CALL_TYPE, "1", 1));
      ps.setString(++i, pvo.ACTIVE_DESC);
      ps.setString(++i, pvo.TO_USER_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          intActiveId = rs.getInt("ACTIVE_ID");
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intActiveId;
  }
  protected ArrayList<CodeVO> M_COMPANY_MEMO_CATEGORY_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CodeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_MEMO_CATEGORY_LIST_PROC;");
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
      while(rs.next()) {
        CodeVO vo      = new CodeVO();
          vo.CODE_CD     = StrUtil.nvl(rs.getString("CODE_CD")).trim();
          vo.CODE_NM     = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.MEMO_CATEGORY = StrUtil.nvl(rs.getString("CATEGORY"));
          arr.add(vo);
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
  protected ArrayList<MemoVO> ACTIVE_MANAGEMENT_LIST_PROC(MemoVO pvo) {
      Connection conn = ConnectionMgr.getInstance().getConnetion();
      WrapPreparedStatementUtil ps = null;
      Logger logger = Logger.getLogger(this.getClass());
      ResultSet rs = null;
      ArrayList<MemoVO> arr = new ArrayList<>();
      try {
        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_MANAGEMENT_LIST_PROC ?, ?, ?, ?, ?, ?;");
        int i = 0;
        ps.setInt(++i, pvo.PAGE);
        ps.setInt(++i, pvo.ROW_CNT);
        ps.setInt(++i, pvo.CPY_ID);
        ps.setString(++i, StrUtil.nvl(pvo.TO_USER_ID));
        ps.setString(++i, StrUtil.cutString(pvo.ACTIVE_DESC, 50, ""));
        ps.setString(++i,  StrUtil.nvl(pvo.WRITE_ID));
        logger.debug(ps.getQueryString());
        rs = ps.executeQuery();
        if (rs!=null) {
          while(rs.next()) {
            MemoVO vo      = new MemoVO();
            vo.RN          = rs.getInt("RN");
            vo.TOTAL_CNT   = rs.getInt("TOTAL_CNT");
            vo.ACTIVE_ID   = StrUtil.nvl(rs.getString("ACTIVE_ID   ".trim()));
            vo.ACTIVE_KIND = StrUtil.nvl(rs.getString("ACTIVE_KIND ".trim()));
            vo.WRITE_ID    = StrUtil.nvl(rs.getString("WRITE_ID    ".trim()));
            vo.WRITE_DATE  = StrUtil.nvl(rs.getString("WRITE_DATE  ".trim()));
            vo.CPY_ID      = rs.getInt("CPY_ID");
            vo.CALL_TYPE   = StrUtil.nvl(rs.getString("CALL_TYPE   ".trim()));
            vo.ACTIVE_DESC = StrUtil.nvl(rs.getString("ACTIVE_DESC ".trim()));
            vo.USER_NM     = StrUtil.nvl(rs.getString("USER_NM     ".trim()));
            vo.TO_USER_NM  = StrUtil.nvl(rs.getString("TO_USER_NM  ".trim()));
            vo.CPY_NAME    = StrUtil.nvl(rs.getString("CPY_NAME    ".trim()));
            vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
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
}
