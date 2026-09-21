package kr.co.mp.mgr.memo;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CommentDAO {
  protected ArrayList<CommentVO> ACTIVE_COMMENT_LIST_PROC(int intActiveId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CommentVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_COMMENT_LIST_PROC ?;");
      ps.setInt(1, intActiveId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          CommentVO vo    = new CommentVO();
          vo.COMMENT_ID   = rs.getInt("COMMENT_ID");
          vo.ACTIVE_ID    = rs.getInt("ACTIVE_ID");
          vo.COMMENT_DESC = StrUtil.nvl(rs.getString("COMMENT_DESC"));
          vo.WRITE_ID     = StrUtil.nvl(rs.getString("WRITE_ID"));
          vo.WRITE_DATE   = StrUtil.nvl(rs.getString("WRITE_DATE"));
          vo.USER_NM      = StrUtil.nvl(rs.getString("USER_NM"));
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
  protected int ACTIVE_COMMENT_ADD_PROC(CommentVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCommentId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_COMMENT_ADD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.ACTIVE_ID);
      ps.setString(++i, pvo.WRITE_ID);
      ps.setString(++i, pvo.COMMENT_DESC);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          intCommentId = rs.getInt("COMMENT_ID");
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCommentId;
  }
  protected int ACTIVE_COMMENT_MOD_PROC(CommentVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intCommentId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_COMMENT_MOD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.COMMENT_ID);
      ps.setString(++i, pvo.WRITE_ID);
      ps.setString(++i, pvo.COMMENT_DESC);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          intCommentId = rs.getInt("COMMENT_ID");
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCommentId;
  }
  protected int ACTIVE_COMMENT_DROP_PROC(int intCommentId, String strWriteId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.ACTIVE_COMMENT_DROP_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, intCommentId);
      ps.setString(++i, strWriteId);
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
}
