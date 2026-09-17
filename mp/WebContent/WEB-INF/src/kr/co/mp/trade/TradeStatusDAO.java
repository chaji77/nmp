package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class TradeStatusDAO {
  protected ArrayList<TradeStatusVO> CT_HEADER_STATUS_PER_CPY_ID_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<TradeStatusVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_STATUS_PER_CPY_ID_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          TradeStatusVO vo = new TradeStatusVO();
          vo.CTTYPE      = StrUtil.nvl(rs.getString("CTTYPE     ".trim()));
          vo.COM_TYPE    = StrUtil.nvl(rs.getString("COM_TYPE   ".trim()));
          vo.WAIT_TYPE   = StrUtil.nvl(rs.getString("WAIT_TYPE  ".trim()));
          vo.WAIT_COUNT  = rs.getInt("WAIT_COUNT");
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
  protected String[] CT_HEADER_PID_STATUS_PER_CTID_PROC(int intCtid) {
	Connection conn = ConnectionMgr.getInstance().getConnetion();
	WrapPreparedStatementUtil ps = null;
	Logger logger = Logger.getLogger(this.getClass());
	ResultSet rs = null;
	String[] result = new String[2];
	try {
	  ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_PID_STATUS_PER_CTID_PROC ?;");
	  ps.setInt(1, intCtid);
	  logger.debug(ps.getQueryString());
	  rs = ps.executeQuery();
	  if (rs!=null && rs.next()) {
		 result[0] = StrUtil.nvl(rs.getString("PAY_ID"));
		 result[1] = StrUtil.nvl(rs.getString("STATUS"));
	  }
	} catch(Exception e) {
	  logger.error(ps.getQueryString());
	  logger.error(e.toString());
	} finally {
	  ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	} 
	return result;
  }
}
