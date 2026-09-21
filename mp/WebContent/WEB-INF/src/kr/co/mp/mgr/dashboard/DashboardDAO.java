package kr.co.mp.mgr.dashboard;

import java.sql.Connection;
import java.sql.ResultSet;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class DashboardDAO {

	protected DashboardVO DASHBOARD_EXIST_CHECK_PROC() {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		DashboardVO vo = new DashboardVO();

		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.DASHBOARD_EXIST_CHECK_PROC;");
			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs != null && rs.next()) {
				vo.QNA_EXIST     = rs.getBoolean("QNA_EXIST");
				vo.REG_REQ_EXIST = rs.getBoolean("REG_REQ_EXIST");
			}
		} catch (Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		}
		return vo;
	}
}
