package kr.co.mp.mgr.sales;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class SalesMemoDAO {
  protected ArrayList<SalesMemoVO> SALES_MEMO_LIST_PER_CPY_ID_PROC(SalesMemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<SalesMemoVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SALES_MEMO_LIST_PER_CPY_ID_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, pvo.PAGE);
      ps.setInt(++i, pvo.ROW_CNT);
      ps.setInt(++i, pvo.CPY_ID);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          SalesMemoVO vo      = new SalesMemoVO();
          vo.RN               = rs.getInt("RN");
          vo.TOTAL_CNT        = rs.getInt("TOTAL_CNT");
          vo.MEMO_ID          = rs.getInt("MEMO_ID");
          vo.WRITE_ID         = StrUtil.nvl(rs.getString("WRITE_ID"));
          vo.WRITE_DATE       = StrUtil.nvl(rs.getString("WRITE_DATE"));
          vo.CONTENTS         = StrUtil.nvl(rs.getString("CONTENTS"));
          vo.CPY_ID           = rs.getInt("CPY_ID");
          vo.USER_NM          = StrUtil.nvl(rs.getString("USER_NM"));
          vo.CPY_NAME         = StrUtil.nvl(rs.getString("CPY_NAME"));
          vo.CPY_BUSINESS_NO  = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
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
  protected int SALES_MEMO_ADD_PROC(SalesMemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intMemoId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SALES_MEMO_ADD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(pvo.WRITE_ID));
      ps.setString(++i, StrUtil.nvl(pvo.CONTENTS));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intMemoId = rs.getInt("MEMO_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intMemoId;
  }
  protected int SALES_MEMO_MOD_PROC(SalesMemoVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intMemoId = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SALES_MEMO_MOD_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.MEMO_ID);
      ps.setString(++i, pvo.CONTENTS); // 수정호출: 내용, 삭제호출: null
      ps.setString(++i, pvo.DEL_DATE); // 삭제호출: 날짜(yyyy-MM-dd), 수정호출: null
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intMemoId = rs.getInt("MEMO_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intMemoId;
  }
}
