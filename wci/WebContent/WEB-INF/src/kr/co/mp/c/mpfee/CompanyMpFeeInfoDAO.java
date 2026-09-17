package kr.co.mp.c.mpfee;

import java.sql.Connection;
import java.sql.ResultSet;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CompanyMpFeeInfoDAO {
  protected CompanyMpFeeInfoVO COMPANY_MPFEE_INFO_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CompanyMpFeeInfoVO mpvo = new CompanyMpFeeInfoVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MPFEE_INFO_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
    	mpvo.CPY_ID        = rs.getInt("CPY_ID");
    	mpvo.BIZNO         = StrUtil.nvl(rs.getString("BIZNO        ".trim()));
    	mpvo.BIZNM         = StrUtil.nvl(rs.getString("BIZNM        ".trim()));
    	mpvo.CEONM         = StrUtil.nvl(rs.getString("CEONM        ".trim()));
    	mpvo.BUSINESS_TYPE = StrUtil.nvl(rs.getString("BUSINESS_TYPE".trim()));
    	mpvo.INDUSTRY      = StrUtil.nvl(rs.getString("INDUSTRY     ".trim()));
    	mpvo.ZIPCODE       = StrUtil.nvl(rs.getString("ZIPCODE      ".trim()));
        mpvo.ADDR          = StrUtil.nvl(rs.getString("ADDR         ".trim()));
        mpvo.ADDR2         = StrUtil.nvl(rs.getString("ADDR2        ".trim()));
        mpvo.REG_ID        = StrUtil.nvl(rs.getString("REG_ID       ".trim()));
        mpvo.REG_DT        = StrUtil.nvl(rs.getString("REG_DT       ".trim()));
        mpvo.USE_YN        = StrUtil.nvl(rs.getString("USE_YN       ".trim()));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return mpvo;
  }
  protected int COMPANY_MPFEE_INFO_ADD_PROC(CompanyMpFeeInfoVO mpvo) {
	  Connection conn = ConnectionMgr.getInstance().getConnetion();
	  WrapPreparedStatementUtil ps = null;
	  Logger logger = Logger.getLogger(this.getClass());
	  int result = 0;
	  try {
	    String query = "EXEC DBO.COMPANY_MPFEE_INFO_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;";
	    ps = new WrapPreparedStatementUtil(conn, query);
	    int i = 0;       
	    ps.setInt(++i, mpvo.CPY_ID); 
	    ps.setString(++i, mpvo.BIZNO);        
	    ps.setString(++i, mpvo.BIZNM);        
	    ps.setString(++i, mpvo.CEONM);        
	    ps.setString(++i, mpvo.BUSINESS_TYPE);
	    ps.setString(++i, mpvo.INDUSTRY);     
	    ps.setString(++i, mpvo.ZIPCODE);
	    ps.setString(++i, mpvo.ADDR);         
	    ps.setString(++i, mpvo.ADDR2);   
	    ps.setString(++i, mpvo.REG_ID); 
	    ps.setString(++i, mpvo.USE_YN);            
	    
	    logger.debug(ps.getQueryString());
	    result = ps.executeUpdate();  
	  } catch (Exception e) {
	    logger.error(ps.getQueryString());
	    logger.error(e.toString());
	    result = -1;
	  } finally {
	    ConnectionMgr.getInstance().closeConnection(conn, ps, null);
	  }
	  return result;  
  }
  protected int COMPANY_MPFEE_INFO_MOD_PROC(CompanyMpFeeInfoVO mpvo) {
	  Connection conn = ConnectionMgr.getInstance().getConnetion();
	  WrapPreparedStatementUtil ps = null;
	  Logger logger = Logger.getLogger(this.getClass());
	  int result = 0;
	  try {
	    ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_MPFEE_INFO_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
	    int i = 0;
	    ps.setInt(++i, mpvo.CPY_ID);          
	    ps.setString(++i, mpvo.BIZNO);        
	    ps.setString(++i, mpvo.BIZNM);        
	    ps.setString(++i, mpvo.CEONM);        
	    ps.setString(++i, mpvo.BUSINESS_TYPE);
	    ps.setString(++i, mpvo.INDUSTRY);     
	    ps.setString(++i, mpvo.ZIPCODE);
	    ps.setString(++i, mpvo.ADDR);         
	    ps.setString(++i, mpvo.ADDR2);       
	    ps.setString(++i, mpvo.REG_ID);      
	    ps.setString(++i, mpvo.USE_YN);        
	    
	    logger.debug(ps.getQueryString());
	    
	    result = ps.executeUpdate();  
	  } catch (Exception e) {
	    logger.error(ps.getQueryString());
	    logger.error(e.toString());
	    result = -1;
	  } finally {
	    ConnectionMgr.getInstance().closeConnection(conn, ps, null);
	  }
	  return result;  
  }

}
