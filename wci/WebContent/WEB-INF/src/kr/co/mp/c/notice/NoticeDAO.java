package kr.co.mp.c.notice;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class NoticeDAO {

  protected int C_NOTICE_ADD_PROC(NoticeVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.TITLE), "", 100));
      ps.setInt   (++i, vo.REG_ID);
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_YN, "N", 1));
      ps.setInt   (++i, vo.POPUP_WIDTH);
      ps.setInt   (++i, vo.POPUP_HEIGHT);
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_START_YMDHM, "20150101", 12));
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_END_YMDHM,   "20991231", 12));
      ps.setString(++i, vo.FILES);
      ps.setString(++i, StrUtil.xss(vo.CONTENTS));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intSeq = rs.getInt("SEQ");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  protected int C_NOTICE_MOD_PROC(NoticeVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, vo.SEQ);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.TITLE), "", 100));
      ps.setInt   (++i, vo.REG_ID);
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_YN, "N", 1));
      ps.setInt   (++i, vo.POPUP_WIDTH);
      ps.setInt   (++i, vo.POPUP_HEIGHT);
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_START_YMDHM, "", 12));
      ps.setString(++i, StrUtil.getParameter(vo.POPUP_END_YMDHM,   "", 12));
      ps.setString(++i, StrUtil.nvl(vo.USE_YN, "Y"));
      ps.setString(++i, vo.FILES);
      ps.setString(++i, StrUtil.xss(vo.CONTENTS));
      logger.debug(ps.getQueryString());
      intResult = ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected NoticeVO C_NOTICE_DETAIL_PROC(int intSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    NoticeVO vo = new NoticeVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(++i, intSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.SEQ               = intSeq;
        vo.TITLE             = StrUtil.nvl(rs.getString("TITLE"));
        vo.REG_ID            = rs.getInt("REG_ID");
        vo.REG_DT            = StrUtil.nvl(rs.getString("REG_DT"));
        vo.POPUP_YN          = StrUtil.nvl(rs.getString("POPUP_YN"));
        vo.POPUP_WIDTH       = rs.getInt("POPUP_WIDTH");
        vo.POPUP_HEIGHT      = rs.getInt("POPUP_HEIGHT");
        vo.POPUP_START_YMDHM = StrUtil.nvl(rs.getString("POPUP_START_YMDHM"));
        vo.POPUP_END_YMDHM   = StrUtil.nvl(rs.getString("POPUP_END_YMDHM"));
        vo.CONTENTS          = StrUtil.nvl(rs.getString("CONTENTS"));
        vo.USER_NM           = StrUtil.nvl(rs.getString("USER_NM"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected ArrayList<NoticeAttachVO> C_NOTICE_ATTACH_LIST_PROC(int intSeq) {
	    Connection conn = ConnectionMgr.getInstance().getConnetion();
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    ArrayList<NoticeAttachVO> arr = new ArrayList<>();
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_ATTACH_LIST_PROC ?;");
	      int i = 0;
	      ps.setInt   (++i, intSeq);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null) {
	        while (rs.next()) {
	          NoticeAttachVO vo  = new NoticeAttachVO();
	          vo.FILE_NM   = StrUtil.nvl(rs.getString("FILE_NM"));
	          vo.FILE_URL  = StrUtil.nvl(rs.getString("FILE_URL"));
	          vo.FILE_SIZE = StrUtil.nvl(rs.getString("FILE_SIZE"));
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
  protected ArrayList<NoticeVO> C_NOTICE_LIST_PROC(NoticeVO p, String strIncludeDroppedArticle) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<NoticeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_LIST_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt   (++i, p.PAGE);
      ps.setInt(++i, p.ROW_CNT);
      ps.setString(++i, strIncludeDroppedArticle);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          NoticeVO vo  = new NoticeVO();
          vo.RN        = rs.getInt("RN");
          vo.TOTAL_CNT = rs.getInt("TOTAL_CNT");
          vo.SEQ       = rs.getInt("SEQ");
          vo.TITLE     = StrUtil.nvl(rs.getString("TITLE"));
          vo.REG_DT    = StrUtil.nvl(rs.getString("REG_DT"));
          vo.USER_NM   = StrUtil.nvl(rs.getString("USER_NM"));
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
  protected ArrayList<NoticeVO> C_NOTICE_POPUPLIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<NoticeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_NOTICE_POPUPLIST_PROC;");
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          NoticeVO vo     = new NoticeVO();
          vo.SEQ          = rs.getInt("SEQ");
          vo.TITLE        = StrUtil.nvl(rs.getString("TITLE"));
          vo.POPUP_WIDTH  = rs.getInt("POPUP_WIDTH");
          vo.POPUP_HEIGHT = rs.getInt("POPUP_HEIGHT");
          vo.CONTENTS     = StrUtil.nvl(rs.getString("CONTENTS"));
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
