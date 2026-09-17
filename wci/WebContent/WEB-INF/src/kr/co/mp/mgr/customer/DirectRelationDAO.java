package kr.co.mp.mgr.customer;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class DirectRelationDAO {
	protected ArrayList<DirectRelationVO> M_DIRECT_RELATION_SEARCH_PROC(DirectRelationVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		ArrayList<DirectRelationVO> arr = new ArrayList<>();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_DIRECT_RELATION_SEARCH_PROC ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.PAGE);
			ps.setInt(++i, vo.ROW_CNT);
			ps.setString(++i, StrUtil.nvl(vo.SELL_COMPANY_NAME));
			ps.setString(++i, StrUtil.nvl(vo.BUY_COMPANY_NAME));
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null) {
				while(rs.next()) {
					DirectRelationVO v = new DirectRelationVO();
					v.RN                    = rs.getInt("RN");
			        v.TOTAL_CNT             = rs.getInt("TOTAL_CNT");
			        v.SELL_COMPANY			= rs.getInt("SELL_COMPANY");
			        v.SELL_COMPANY_NAME     = StrUtil.nvl(rs.getString("SELL_COMPANY_NAME"));
			        v.SELL_COMPANY_BIZNO    = StrUtil.nvl(rs.getString("SELL_COMPANY_BIZNO"));
			        v.SELL_COMPANY_CEO_NAME = StrUtil.nvl(rs.getString("SELL_COMPANY_CEO_NAME"));
			        v.BUY_COMPANY			= rs.getInt("BUY_COMPANY");
			        v.BUY_COMPANY_NAME      = StrUtil.nvl(rs.getString("BUY_COMPANY_NAME"));
			        v.BUY_COMPANY_BIZNO     = StrUtil.nvl(rs.getString("BUY_COMPANY_BIZNO"));
			        v.BUY_COMPANY_CEO_NAME  = StrUtil.nvl(rs.getString("BUY_COMPANY_CEO_NAME"));
			        v.CREATE_DATE           = StrUtil.nvl(rs.getString("CREATE_DATE"));
			        v.USE_YN				= StrUtil.nvl(rs.getString("USE_YN"));
			        arr.add(v);
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
	protected int M_DIRECT_RELATION_ADD_PROC(DirectRelationVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_DIRECT_RELATION_ADD_PROC ?, ?;");
		    int i = 0;
		    ps.setInt(++i, vo.SELL_COMPANY);
		    ps.setInt(++i, vo.BUY_COMPANY);
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
	protected DirectRelationVO M_DIRECT_RELATION_DETAIL_PROC(DirectRelationVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		DirectRelationVO dvo = new DirectRelationVO();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_DIRECT_RELATION_DETAIL_PROC ?, ?;");
			ps.setInt(1, vo.SELL_COMPANY);
			ps.setInt(2, vo.BUY_COMPANY);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
				dvo.SELL_COMPANY_NAME = StrUtil.nvl(rs.getString("SELL_COMPANY_NAME"));
				dvo.BUY_COMPANY_NAME  = StrUtil.nvl(rs.getString("BUY_COMPANY_NAME"));
				dvo.USE_YN 			  = StrUtil.nvl(rs.getString("USE_YN"));
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} 
		return dvo;
	}
	protected int M_DIRECT_RELATION_MOD_PROC(DirectRelationVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_DIRECT_RELATION_MOD_PROC ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.SELL_COMPANY);
			ps.setInt(++i, vo.BUY_COMPANY);
			ps.setString(++i, StrUtil.nvl(vo.USE_YN));
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
}
