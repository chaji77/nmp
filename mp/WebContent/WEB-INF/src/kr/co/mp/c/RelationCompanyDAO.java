package kr.co.mp.c;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class RelationCompanyDAO {
  protected ArrayList<RelationCompanyVO> RELATION_COMPANY_DETAIL_PROC(int intCpyId, String strContainSelfYn) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<RelationCompanyVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RELATION_COMPANY_DETAIL_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, strContainSelfYn);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          RelationCompanyVO vo = new RelationCompanyVO();
          vo.SEQNO         = StrUtil.nvl(rs.getString("SEQNO        ".trim()));
          vo.CPY_ID        = StrUtil.nvl(rs.getString("CPY_ID       ".trim()));
          vo.RELATIONBIZNO = StrUtil.nvl(rs.getString("RELATIONBIZNO".trim()));
          vo.CRETIME       = StrUtil.nvl(rs.getString("CRETIME      ".trim()));
          vo.CREUSER       = StrUtil.nvl(rs.getString("CREUSER      ".trim()));
          vo.LASTTIME      = StrUtil.nvl(rs.getString("LASTTIME     ".trim()));
          vo.LASTUSER      = StrUtil.nvl(rs.getString("LASTUSER     ".trim()));
          vo.UNUSUAL_SEQNO = StrUtil.nvl(rs.getString("UNUSUAL_SEQNO".trim()));
          vo.PRO_RESULT    = StrUtil.nvl(rs.getString("PRO_RESULT   ".trim()));
          vo.LOANTYPE      = StrUtil.nvl(rs.getString("LOANTYPE     ".trim()));
          vo.ETC           = StrUtil.nvl(rs.getString("ETC          ".trim()));
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
  protected int COMPANY_RELATION_EXCEPT_PROC(int intBuyerId, int intSellerCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs  = null;
    int intCnt    = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_RELATION_EXCEPT_PROC ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intBuyerId);
      ps.setInt(   ++i, intSellerCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intCnt = rs.getInt("ACCEPT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCnt;
  }

}
