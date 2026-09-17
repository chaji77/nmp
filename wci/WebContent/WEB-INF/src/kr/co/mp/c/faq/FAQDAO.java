package kr.co.mp.c.faq;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class FAQDAO {

	protected ArrayList<FAQVO> C_FAQ_CAT_LIST_PROC() {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		ArrayList<FAQVO> arr = new ArrayList<>();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_FAQ_CAT_LIST_PROC;");
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null) {
				while(rs.next()) {
					FAQVO vo  = new FAQVO();
					vo.CAT_ID = rs.getInt("CAT_ID");
					vo.CAT_NM = StrUtil.nvl(rs.getString("CAT_NM"));
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
	
	protected int C_FAQ_ADD_PROC(FAQVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_FAQ_ADD_PROC ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.CAT_ID);
			ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.TITLE), "", 100));
			ps.setString(++i, StrUtil.xss(vo.CONTENTS));
			ps.setInt(++i, vo.REG_ID);
			logger.debug(ps.getQueryString());
			ps.executeUpdate();
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
			intResult = -1;
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps);
		}
		return intResult;
	}
	
	protected FAQVO C_FAQ_DETAIL_PROC(int intSeq) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		FAQVO vo = new FAQVO();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_FAQ_DETAIL_PROC ?;");
			ps.setInt(1, intSeq);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
				vo.SEQ = intSeq;
				vo.CAT_ID = rs.getInt("CAT_ID");
				vo.TITLE = StrUtil.nvl(rs.getString("TITLE"));
				vo.CONTENTS = StrUtil.xss(rs.getString("CONTENTS"));
				vo.REG_ID = rs.getInt("REG_ID");
				vo.USER_NM = StrUtil.nvl(rs.getString("USER_NM"));
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} return vo;
	}
	
	protected int C_FAQ_DROP_PROC(FAQVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_FAQ_DROP_PROC ?, ?;");
			ps.setInt(1, vo.SEQ);
			ps.setInt(2, vo.REG_ID);
			logger.debug(ps.getQueryString());
			ps.executeUpdate();
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
			intResult = -1;
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps);
		} return intResult;
	}
	
	protected ArrayList<FAQVO> C_FAQ_LIST_PROC(FAQVO p, String strSearchWord) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		ArrayList<FAQVO> arr = new ArrayList<>();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_FAQ_LIST_PROC ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, p.CAT_ID);
			ps.setString(++i, strSearchWord);
			ps.setInt(++i, p.PAGE);
			ps.setInt(++i, p.ROW_CNT);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null) {
				while(rs.next()) {
					FAQVO vo = new FAQVO();
					vo.RN        = rs.getInt("RN");
					vo.TOTAL_CNT = rs.getInt("TOTAL_CNT");
					vo.SEQ       = rs.getInt("SEQ");
					vo.TITLE     = StrUtil.nvl(rs.getString("TITLE"));
					vo.CONTENTS  = StrUtil.nvl(rs.getString("CONTENTS"));
					vo.USER_NM   = StrUtil.nvl(rs.getString("USER_NM"));
					vo.CAT_NM    = StrUtil.nvl(rs.getString("CAT_NM"));
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
	
	protected int C_FAQ_MOD_PROC(FAQVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC C_FAQ_MOD_PROC ?, ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.SEQ);
			ps.setInt(++i, vo.CAT_ID);
			ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.TITLE), "", 100));
			ps.setString(++i, StrUtil.xss(vo.CONTENTS));
			ps.setInt(++i, vo.REG_ID);
			logger.debug(ps.getQueryString());
			ps.executeUpdate();
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
			intResult = -1;
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps);
		} return intResult;
	}

}
