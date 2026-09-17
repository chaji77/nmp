package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class TransactionDAO {
  protected static ArrayList<TransactionResultVO> SEND_XML_B311_LIST_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("TransactionDAO.SEND_XML_B311_LIST_BY_CTID_PROC");
    ResultSet rs = null;
    ArrayList<TransactionResultVO> arr = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SEND_XML_B311_LIST_BY_CTID_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        arr = new ArrayList<>();
        while (rs.next()) {
          TransactionResultVO vo = new TransactionResultVO();
          vo.DOCNUM          = StrUtil.nvl(rs.getString("DOCNUM"));
          vo.CTID            = rs.getInt("CTID");
          vo.ORDERNO         = StrUtil.nvl(rs.getString("ORDERNO        ".trim()));
          vo.FUND            = StrUtil.nvl(rs.getString("FUND           ".trim()));
          vo.TRANSACTIONDATE = StrUtil.nvl(rs.getString("TRANSACTIONDATE".trim()));
          vo.TRANSACTIONTIME = StrUtil.nvl(rs.getString("TRANSACTIONTIME".trim()));
          vo.RESRESPONSECODE = StrUtil.nvl(rs.getString("RESRESPONSECODE".trim()));
          vo.RESRESPONSEMSG  = StrUtil.nvl(rs.getString("RESRESPONSEMSG ".trim()));
          vo.SEQNO           = StrUtil.nvl(rs.getString("SEQNO          ".trim()));
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
