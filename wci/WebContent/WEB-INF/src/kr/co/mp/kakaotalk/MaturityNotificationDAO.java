package kr.co.mp.kakaotalk;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class MaturityNotificationDAO {
  protected ArrayList<MaturityNotificationVO> BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ArrayList<MaturityNotificationVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        MaturityNotificationVO vo = new MaturityNotificationVO();
        vo.CPYBUYER  = rs.getString("CPYBUYER");
        vo.CPY_NAME  = rs.getString("CPY_NAME");
        vo.BNK_CD    = rs.getString("BNK_CD");
        vo.BNK_SNAME = rs.getString("BNK_SNAME");
        vo.MTYDATE   = rs.getString("MTYDATE");
        vo.PRS_MOBILE_NO = rs.getString("PRS_MOBILE_NO");
        vo.CNT = rs.getString("CNT");
        vo.AMT = rs.getString("AMT");
        arr.add(vo);
      }
      System.out.println("TARGET....." + arr.size());
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  protected ArrayList<MaturityNotificationVO> BAT_0_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ArrayList<MaturityNotificationVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.BAT_0_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        MaturityNotificationVO vo = new MaturityNotificationVO();
        vo.CPYBUYER  = rs.getString("CPYBUYER");
        vo.CPY_NAME  = rs.getString("CPY_NAME");
        vo.BNK_CD    = rs.getString("BNK_CD");
        vo.BNK_SNAME = rs.getString("BNK_SNAME");
        vo.MTYDATE   = rs.getString("MTYDATE");
        vo.PRS_MOBILE_NO = rs.getString("PRS_MOBILE_NO");
        vo.CNT = rs.getString("CNT");
        vo.AMT = rs.getString("AMT");
        arr.add(vo);
      }
      System.out.println("TARGET....." + arr.size());
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
}
