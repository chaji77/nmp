package kr.co.mp.kakaotalk;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class BlockDAO {
  protected static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_LIST_PROC(BlockVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ArrayList<BlockVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.COMPANY_SMS_MAIL_BLOCK_LIST_PROC ?, ?, ?, ?, ?, ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 0;
      ps.setInt(++i, pvo.PAGE);
      ps.setInt(++i, pvo.ROW_CNT);
      ps.setString(++i, pvo.CPY_ID);
      ps.setString(++i, pvo.CPY_NAME);
      ps.setString(++i, pvo.PHONE_NO);
      ps.setString(++i, pvo.EMAIL);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        BlockVO vo = new BlockVO();
        vo.CPY_ID    = rs.getString("CPY_ID");
        vo.CPY_NAME  = rs.getString("CPY_NAME");
        vo.CPY_BUSINESS_NO    = rs.getString("CPY_BUSINESS_NO");
//        vo.EMAIL = rs.getString("EMAIL");
//        vo.PHONE_NO = rs.getString("PHONE_NO");
        vo.REG_DT    = StrUtil.nvl(rs.getString("REG_DT"));
        vo.REG_NM    = StrUtil.nvl(rs.getString("REG_NM"));
        vo.TOTAL_CNT = rs.getInt("TOTAL_CNT");
        arr.add(vo);
      }
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_ADD_PROC(BlockVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    try {
      String query = "EXEC DBO.COMPANY_SMS_MAIL_BLOCK_ADD_PROC ?, ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 0;
      ps.setString(++i, pvo.CPY_ID);
      ps.setString(++i, pvo.REG_NM);
      System.out.println(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    pvo.CPY_NAME = "";
    return COMPANY_SMS_MAIL_BLOCK_LIST_PROC(pvo);
  }
  protected static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_DROP_PROC(BlockVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    try {
      String query = "EXEC DBO.COMPANY_SMS_MAIL_BLOCK_DROP_PROC ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 0;
      ps.setString(++i, pvo.CPY_ID);
      System.out.println(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    pvo.CPY_ID   = "";
    pvo.CPY_NAME = "";
    return COMPANY_SMS_MAIL_BLOCK_LIST_PROC(pvo);
  }
}
