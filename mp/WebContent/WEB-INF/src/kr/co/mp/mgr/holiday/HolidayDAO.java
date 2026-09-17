package kr.co.mp.mgr.holiday;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class HolidayDAO {
	protected int M_HOLIDAY_ADD_PROC(HolidayVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_ADD_PROC ?, ?;");
		    int i = 0;
		    ps.setString(++i, vo.DATE);
		    ps.setString(++i, StrUtil.getParameter(StrUtil.xss(vo.DATE_NAME), "", 30));
		    logger.debug(ps.getQueryString());
		    rs = ps.executeQuery();
		    if (rs!=null && rs.next()) {
		    	intResult = rs.getInt("INTRESULT");
		    }
		} catch (Exception e) {
		    logger.error(ps.getQueryString());
		    logger.error(e.toString());
		    intResult = -1;
		} finally {
		    ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		}
		return intResult;
	}
	
	protected int M_HOLIDAY_MOD_PROC(HolidayVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 1;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_MOD_PROC ?, ?, ?;");
			ps.setString(1, vo.DATE);
			ps.setString(2, vo.DATE_NAME);
			ps.setString(3, vo.MOD_DATE);
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
	
	protected int M_HOLIDAY_DROP_PROC(String date) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_DROP_PROC ?;");
			ps.setString(1, date);
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
	  
	protected HolidayVO M_HOLIDAY_DETAIL_PROC(String date) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		HolidayVO vo = new HolidayVO();
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_DETAIL_PROC ?;");
			ps.setString(1, date);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null&& rs.next()) {
				vo.DATE = rs.getString("DATE");
				vo.DATE_NAME = rs.getString("DATE_NAME");
			}
		} catch(Exception e) {
			
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		}
		return vo;
	}
	
	protected int M_HOLIDAY_DATES_EXIST_CHECK_PROC(String year) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int result = 0;
		ResultSet rs = null;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_DATES_EXIST_CHECK_PROC ?;");
			ps.setString(1, year);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null&& rs.next()) {
				result = rs.getInt("MissingDates");	
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		}
		return result;
	}
	  
	protected ArrayList<HolidayVO> M_HOLIDAY_LIST_PROC(HolidayVO vo, String year) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    ArrayList<HolidayVO> arr = new ArrayList<>();
	    try {
	        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_LIST_PROC ?, ?, ?;");
	        int i = 0;
	        ps.setInt(++i, vo.PAGE);
	        ps.setInt(++i, vo.ROW_CNT);
	        ps.setString(++i, year);
	        logger.debug(ps.getQueryString());
	        rs = ps.executeQuery();
	        if (rs!=null) {
	          while(rs.next()) {
	            HolidayVO v = new HolidayVO();
	            v.RN = rs.getInt("RN");
	            v.TOTAL_CNT = rs.getInt("TOTAL_CNT");
	            v.DATE = rs.getString("DATE");
	            v.DATE_KIND = rs.getString("DATE_KIND");
	            v.DATE_NAME = StrUtil.input(rs.getString("DATE_NAME"));
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
	

	protected int M_HOLIDAY_TB_YEARLY_ADD_PROC(String xml) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		int intResult = 0;
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_TB_YEARLY_ADD_PROC ?;");
			ps.setString(1, xml);
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
	
	public static String[] M_HOLIDAY_MATURITY_DATE_RETURN_PROC(String date) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(HolidayDAO.class);
		ResultSet rs = null;
		String[] maturityDate = new String[2];
		
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_MATURITY_DATE_RETURN_PROC ?;");
			ps.setString(1, date);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
				maturityDate[0] = rs.getString("MATURITY_DATE");
				maturityDate[1] = rs.getString("MATURITY_CNT");
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} 
		return maturityDate;
	}

	public static HolidayVO M_HOLIDAY_MATURITY_PROC(String date) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(HolidayDAO.class);
		ResultSet rs = null;
		HolidayVO vo = new HolidayVO();
		
		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.M_HOLIDAY_MATURITY_PROC ?;");
			ps.setString(1, date);
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs!=null && rs.next()) {
				vo.DATE_KIND = rs.getString("DATE_KIND");
				vo.DATE      = rs.getString("DATE");
				vo.DATE_NAME = rs.getString("DATE_NAME");
				vo.CNT       = rs.getInt("CNT");
			}
		} catch(Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		} 
		return vo;
	}
}
