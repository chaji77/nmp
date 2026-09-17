package kr.co.mp.common;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CodeDAO {
  protected static ArrayList<CodeVO> C_CODE_PROC(String strCodeGrpCd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CodeDAO");
    ResultSet rs = null;
    ArrayList<CodeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_CODE_PROC ?;");
      int i = 0;
      ps.setString(++i, strCodeGrpCd);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CodeVO vo      = new CodeVO();
          vo.CODE_CD     = StrUtil.nvl(rs.getString("CODE_CD")).trim();
          vo.CODE_NM     = StrUtil.nvl(rs.getString("CODE_NM"));
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
  protected static ArrayList<CodeVO> C_CODE_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CodeDAO");
    ResultSet rs = null;
    ArrayList<CodeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_CODE_LIST_PROC;");
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CodeVO vo      = new CodeVO();
          vo.CODE_GRP_CD = StrUtil.nvl(rs.getString("CODE_GRP_CD"));
          vo.CODE_CD     = StrUtil.nvl(rs.getString("CODE_CD"));
          vo.CODE_NM     = StrUtil.nvl(rs.getString("CODE_NM"));
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
  protected static ArrayList<BankVO> BANK_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CodeDAO");
    ResultSet rs = null;
    ArrayList<BankVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.BANK_LIST_PROC;");
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          BankVO vo    = new BankVO();
          vo.BNK_CD    = StrUtil.nvl(rs.getString("BNK_CD"));
          vo.BNK_NAME  = StrUtil.nvl(rs.getString("BNK_NAME"));
          vo.BNK_SNAME = StrUtil.nvl(rs.getString("BNK_SNAME"));
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
