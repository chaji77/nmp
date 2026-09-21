package kr.co.mp.c.regreq;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class RegReqDAO {

	protected int COMPANY_REG_REQ_ADD_PROC(RegReqVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		int intSeq = 0;

		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_REG_REQ_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.BUY_CPY_ID);
			ps.setString(++i, StrUtil.xss(vo.SELL_CPY_NAME));
			ps.setString(++i, StrUtil.xss(vo.SELL_PHONE));
			ps.setString(++i, StrUtil.xss(vo.SELL_PRS_NAME));
			ps.setString(++i, StrUtil.xss(vo.SELL_FAX));
			ps.setString(++i, StrUtil.xss(vo.SELL_EMAIL));
			ps.setString(++i, StrUtil.xss(vo.SELL_CPY_BUSINESS_NO));
			setNullableDate(ps, ++i, vo.TRADE_DATE);
			ps.setInt(++i, vo.FEE_PAY);
			ps.setString(++i, StrUtil.xss(StrUtil.nvl(vo.MEMO).replace("\r\n", "<br>")));
			ps.setInt(++i, vo.REQ_STATUS);

			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs != null && rs.next()) {
				intSeq = rs.getInt("NEW_SEQ");
			}
		} catch (Exception e) {
			logger.error(ps.getQueryString());
			logger.error(e.toString());
		} finally {
			ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
		}
		return intSeq;
	}

	protected int COMPANY_REG_REQ_MOD_PROC(RegReqVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		int intSeq = 0;

		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_REG_REQ_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.SEQ);
			ps.setString(++i, StrUtil.xss(vo.SELL_CPY_NAME));
			ps.setString(++i, StrUtil.xss(vo.SELL_PHONE));
			ps.setString(++i, StrUtil.xss(vo.SELL_PRS_NAME));
			ps.setString(++i, StrUtil.xss(vo.SELL_FAX));
			ps.setString(++i, StrUtil.xss(vo.SELL_EMAIL));
			ps.setString(++i, StrUtil.xss(vo.SELL_CPY_BUSINESS_NO));
			setNullableDate(ps, ++i, vo.TRADE_DATE);
			ps.setInt(++i, vo.FEE_PAY);
			ps.setString(++i, StrUtil.xss(StrUtil.nvl(vo.MEMO).replace("\r\n", "<br>")));
			ps.setInt(++i, vo.REQ_STATUS);
			setNullableDate(ps, ++i, vo.DEL_DATE);

			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs != null && rs.next()) {
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

	protected ArrayList<RegReqVO> COMPANY_REG_REQ_LIST_PROC(RegReqVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		WrapPreparedStatementUtil ps = null;
		Logger logger = Logger.getLogger(this.getClass());
		ResultSet rs = null;
		ArrayList<RegReqVO> arr = new ArrayList<>();

		try {
			ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_REG_REQ_LIST_PROC ?, ?, ?, ?, ?, ?, ?;");
			int i = 0;
			ps.setInt(++i, vo.PAGE);
			ps.setInt(++i, vo.ROW_CNT);
			setNullableDate(ps, ++i, vo.START_DATE);
			setNullableDate(ps, ++i, vo.END_DATE);
			ps.setString(++i, StrUtil.nvl(vo.SEARCH_NM));
			ps.setInt(++i, vo.REQ_STATUS);
			ps.setInt(++i, vo.BUY_CPY_ID);

			logger.debug(ps.getQueryString());
			rs = ps.executeQuery();
			if (rs != null) {
				while (rs.next()) {
					RegReqVO v = new RegReqVO();
					v.RN                    = rs.getInt("RN");
					v.TOTAL_CNT             = rs.getInt("TOTAL_CNT");
					v.SEQ                   = rs.getInt("SEQ");
					v.BUY_CPY_ID            = rs.getInt("BUY_CPY_ID");
					v.BUY_CPY_NAME          = StrUtil.nvl(rs.getString("BUY_CPY_NAME"));
					v.SELL_CPY_NAME         = StrUtil.nvl(rs.getString("SELL_CPY_NAME"));
					v.SELL_PHONE            = StrUtil.nvl(rs.getString("SELL_PHONE"));
					v.SELL_PRS_NAME         = StrUtil.nvl(rs.getString("SELL_PRS_NAME"));
					v.SELL_FAX              = StrUtil.nvl(rs.getString("SELL_FAX"));
					v.SELL_EMAIL            = StrUtil.nvl(rs.getString("SELL_EMAIL"));
					v.SELL_CPY_BUSINESS_NO  = StrUtil.nvl(rs.getString("SELL_CPY_BUSINESS_NO"));
					v.TRADE_DATE            = StrUtil.nvl(rs.getString("TRADE_DATE"));
					v.FEE_PAY               = rs.getInt("FEE_PAY");
					v.MEMO                  = StrUtil.nvl(rs.getString("MEMO"));
					v.REQ_STATUS            = rs.getInt("REQ_STATUS");
					v.REG_DATE              = StrUtil.nvl(rs.getString("REG_DATE"));
					v.DEL_DATE              = StrUtil.nvl(rs.getString("DEL_DATE"));
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

	private void setNullableDate(WrapPreparedStatementUtil ps, int index, String value) throws java.sql.SQLException {
		if (StrUtil.isEmpty(value)) {
			ps.setNull(index, Types.TIMESTAMP);
		} else {
			ps.setString(index, value);
		}
	}
}
