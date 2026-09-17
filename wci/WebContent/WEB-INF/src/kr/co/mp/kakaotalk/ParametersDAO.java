package kr.co.mp.kakaotalk;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class ParametersDAO {
  protected ArrayList<ParametersVO> TALK_FOR_SETTLED_PROC(int intBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ArrayList<ParametersVO> arr = null;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.TALK_FOR_SETTLED_PROC ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setInt(1, intBillSeq);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        arr = new ArrayList<>();
        while(rs.next()) {
          ParametersVO vo = new ParametersVO();
          vo.CPY_ID           = rs.getString("CPY_ID");
          vo.CPY_NAME         = rs.getString("CPY_NAME");
          vo.MOBILE_NO        = rs.getString("MOBILE_NO");
          vo.MPPAYCPY          = rs.getString("MPPAYCPY");
          vo.BUYER_NM         = rs.getString("BUYER_NM");
          vo.SELLER_NM        = rs.getString("SELLER_NM");
          vo.BUYER_MOBILE_NO  = rs.getString("BUYER_MOBILE_NO");
          vo.SELLER_MOBILE_NO = rs.getString("SELLER_MOBILE_NO");
          vo.BUYER_EMAIL      = rs.getString("BUYER_EMAIL");
          vo.SELLER_EMAIL      = rs.getString("SELLER_EMAIL");
          arr.add(vo);
        }
      }
    } catch (Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  
  protected ParametersVO TALK_FOR_RESET_PASSWORD_PROC(String strLoginId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ParametersVO vo = new ParametersVO();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.TALK_FOR_RESET_PASSWORD_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setString(1, strLoginId);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CPY_NAME     = rs.getString("CPY_NAME");
        vo.PRS_LOGIN     = rs.getString("PRS_LOGIN");
        vo.PRS_PASSWD     = rs.getString("PRS_PASSWD");
        vo.MOBILE_NO     = rs.getString("MOBILE_NO");
      }
    } catch(Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected ParametersVO TALK_FOR_CANCEL_CONTRACT_PROC(int intCtid) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ParametersVO vo = new ParametersVO();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.TALK_FOR_CANCEL_CONTRACT_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setInt(1, intCtid);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.BUYER_NM         = StrUtil.nvl(rs.getString("BUYER_NM"));
        vo.SELLER_NM        = StrUtil.nvl(rs.getString("SELLER_NM"));
        vo.TOTALCONTRACTAMT = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT"));
        vo.BUYER_MOBILE_NO  = StrUtil.nvl(rs.getString("BUYER_MOBILE_NO"));
        vo.SELLER_MOBILE_NO = StrUtil.nvl(rs.getString("SELLER_MOBILE_NO"));
        vo.BUYER_EMAIL      = StrUtil.nvl(rs.getString("BUYER_EMAIL"));
        vo.SELLER_EMAIL     = StrUtil.nvl(rs.getString("SELLER_EMAIL"));
      }
    } catch(Exception e) {
        System.out.println(e.toString());
    } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
  protected ParametersVO TALK_FOR_TRANSACTION_INFO_PROC(int intCtid) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ParametersVO vo = new ParametersVO();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.TALK_FOR_TRANSACTION_INFO_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setInt(1, intCtid);
      System.out.println(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.SELLER_NM        = rs.getString("SELLER_NM");
        vo.BUYER_NM         = rs.getString("BUYER_NM");
        vo.SELLER_MOBILE_NO = rs.getString("SELLER_MOBILE_NO");
        vo.BUYER_MOBILE_NO  = rs.getString("BUYER_MOBILE_NO");
        vo.BNK_SNAME        = rs.getString("BNK_SNAME");
        vo.TOTALCONTRACTAMT = rs.getString("TOTALCONTRACTAMT");
        vo.BUYER_EMAIL      = StrUtil.nvl(rs.getString("BUYER_EMAIL"));
        vo.SELLER_EMAIL     = StrUtil.nvl(rs.getString("SELLER_EMAIL"));
      }
    } catch(Exception e) {
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
}
