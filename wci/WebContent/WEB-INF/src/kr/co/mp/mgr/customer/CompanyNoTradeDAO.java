package kr.co.mp.mgr.customer;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CompanyNoTradeDAO {
	protected ArrayList<CompanyNoTradeVO> M_COMPANY_NO_TRADE_LIST_PROC(int intCpyId, int seqNo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		ArrayList<CompanyNoTradeVO> arr = new ArrayList<>();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_NO_TRADE_LIST_PROC ?,?;");
			ps.setInt(1, intCpyId);
			ps.setInt(2, seqNo);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null) {
				while(rs.next()) {
					CompanyNoTradeVO vo = new CompanyNoTradeVO();
					vo.BUYER_BIZ_NO  = StrUtil.nvl(rs.getString("BUYER_BIZ_NO ".trim()));
					vo.SEQNO   		 = StrUtil.nvl(rs.getString("SEQNO        ".trim()));
					vo.BUYER_NAME    = StrUtil.nvl(rs.getString("BUYER_NAME   ".trim()));
					vo.SELLER_BIZ_NO = StrUtil.nvl(rs.getString("SELLER_BIZ_NO".trim()));
					vo.SELLER_NAME	 = StrUtil.nvl(rs.getString("SELLER_NAME  ".trim()));
					vo.ETC			 = StrUtil.nvl(rs.getString("ETC          ".trim()));
					vo.DEL_YN		 = StrUtil.nvl(rs.getString("DEL_YN       ".trim()));
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
	
	protected CompanyNoTradeVO M_COMPANY_BUYER_CHECK_PROC(int intCpyId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		CompanyNoTradeVO vo = new CompanyNoTradeVO();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_BUYER_CHECK_PROC ?;");
			ps.setInt(1,  intCpyId);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
				vo.BUYER_NAME = StrUtil.nvl(rs.getString("CPY_NAME".trim()));
				vo.BUYER_BIZ_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} 
		return vo;
	}
	protected String M_COMPANY_SELLER_NAME_CHECK_PROC(int intCpyId, String cpyBizNo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		String sellerName = "";
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_SELLER_NAME_CHECK_PROC ?,?;");
			ps.setInt(1, intCpyId);
			ps.setString(2,  cpyBizNo);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) sellerName = StrUtil.nvl(rs.getString("CPY_NAME".trim()));
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} 
		return sellerName;
	}
	protected int M_COMPANY_NO_TRADE_ADD_PROC(CompanyNoTradeVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_NO_TRADE_ADD_PROC ?,?,?,?,?,?;");
			int i = 0;
			ps.setString(++i, vo.BUYER_BIZ_NO);
			ps.setString(++i, vo.BUYER_NAME);
			ps.setString(++i, vo.SELLER_BIZ_NO);
			ps.setString(++i, vo.SELLER_NAME);
			ps.setString(++i, vo.ETC);
			ps.setString(++i, vo.DEL_YN);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
		    	intResult = rs.getInt("INTRESULT");
		    }
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
			intResult = -1;
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps);
		} 
		return intResult;
	}
	protected int M_COMPANY_NO_TRADE_MOD_PROC(CompanyNoTradeVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_COMPANY_NO_TRADE_MOD_PROC ?,?,?,?;");
			int i= 0;
			ps.setString(++i, vo.BUYER_BIZ_NO);
			ps.setInt(++i, Integer.parseInt(vo.SEQNO));
			ps.setString(++i, vo.ETC);
			ps.setString(++i, vo.DEL_YN);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) intResult = rs.getInt("INTRESULT");
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
			intResult = -1;
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps);
		} 
		return intResult;
	}
}
