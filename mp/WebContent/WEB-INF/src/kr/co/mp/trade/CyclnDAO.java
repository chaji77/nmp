package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CyclnDAO {
  protected ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PROC(CyclnOrderVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnOrderVO> arr = new ArrayList<CyclnOrderVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_START));
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_END));
      ps.setString(++i, StrUtil.nvl(pvo.STATUS1));
      ps.setString(++i, StrUtil.nvl(pvo.STATUS2));
      ps.setString(++i, StrUtil.nvl(pvo.TRX_CLS_COND));
      ps.setString(++i, StrUtil.nvl(pvo.ORDERNO_COND));
      ps.setInt(   ++i, pvo.BC_ID);
      ps.setInt(   ++i, pvo.SC_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CyclnOrderVO vo   = new CyclnOrderVO();
          vo.TOTAL_CNT      = rs.getInt("TOTAL_CNT");
          vo.RN             = rs.getInt("RN");
          vo.ORDERNO        = StrUtil.nvl(rs.getString("ORDERNO"));
          vo.TRADEDATE      = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.ORDERNAME      = StrUtil.nvl(rs.getString("ORDERNAME"));
          vo.REQDLVDATE     = StrUtil.nvl(rs.getString("REQDLVDATE"));
          vo.BC_NAME        = StrUtil.nvl(rs.getString("BC_NAME"));
          vo.SC_NAME        = StrUtil.nvl(rs.getString("SC_NAME"));
          vo.PURC_PRIC      = StrUtil.nvl(rs.getString("PURC_PRIC"));
          vo.FEE_RATE       = StrUtil.nvl(rs.getString("FEE_RATE"));
          vo.SETL_PLN_YMD   = StrUtil.nvl(rs.getString("SETL_PLN_YMD"));
          vo.TAX_ISSU_YMD   = StrUtil.nvl(rs.getString("TAX_ISSU_YMD"));
          vo.STATUS         = StrUtil.nvl(rs.getString("STATUS"));
          vo.TRX_CLS        = StrUtil.nvl(rs.getString("TRX_CLS"));
          vo.CQ100_STATUS   = StrUtil.nvl(rs.getString("CQ100_STATUS"));
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
