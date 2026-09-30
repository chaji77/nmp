package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class CyclnDAO {
  /**
   * 거래당사자(구매사) 기준 주문 목록. pvo.BC_ID 를 @CPY_ID 로 넘긴다.
   */
  protected ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PER_CPY_ID_PROC(CyclnOrderVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnOrderVO> arr = new ArrayList<CyclnOrderVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_LIST_PER_CPY_ID_PROC ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setInt(   ++i, pvo.BC_ID);
      ps.setString(++i, StrUtil.nvl(pvo.ORDERNO_COND));
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_START));
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_END));
      ps.setString(++i, StrUtil.nvl(pvo.STATUS_COND));
      ps.setString(++i, StrUtil.nvl(pvo.SC_NAME_COND));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CyclnOrderVO vo = new CyclnOrderVO();
          vo.TOTAL_CNT    = rs.getInt("TOTAL_CNT");
          vo.RN           = rs.getInt("RN");
          vo.ORDERNO      = StrUtil.nvl(rs.getString("ORDERNO"));
          vo.TRADEDATE    = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.ORDERNAME    = StrUtil.nvl(rs.getString("ORDERNAME"));
          vo.SC_NAME      = StrUtil.nvl(rs.getString("SC_NAME"));
          vo.REQDLVDATE   = StrUtil.nvl(rs.getString("REQDLVDATE"));
          vo.PURC_PRIC    = StrUtil.nvl(rs.getString("PURC_PRIC"));
          vo.CRETIME      = StrUtil.nvl(rs.getString("CRETIME"));
          vo.STATUS       = StrUtil.nvl(rs.getString("STATUS"));
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

  /**
   * 거래당사자용 발주내역 상세. 프로시저가 계약기본정보와 제품정보 2개를 순서대로 돌려준다.
   * 주문이 없거나 해당 회사의 거래가 아니면 null 을 돌려준다.
   */
  protected CyclnOrderDetailVO CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(String strOrderNo, int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CyclnOrderDetailVO vo = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC ?, ?;");
      ps.setString(1, StrUtil.nvl(strOrderNo));
      ps.setInt(   2, intCpyId);
      logger.debug(ps.getQueryString());
      ps.execute();

      // (1) 계약기본정보
      rs = ps.getResultSet();
      if (rs!=null && rs.next()) {
        vo = new CyclnOrderDetailVO();
        vo.ORDERNO    = StrUtil.nvl(rs.getString("ORDERNO"));
        vo.TRADEDATE  = StrUtil.nvl(rs.getString("TRADEDATE"));
        vo.ORDERNAME  = StrUtil.nvl(rs.getString("ORDERNAME"));
        vo.REQDLVDATE = StrUtil.nvl(rs.getString("REQDLVDATE"));
        vo.CPYBUYER   = StrUtil.nvl(rs.getString("CPYBUYER"));
        vo.BC_NAME    = StrUtil.nvl(rs.getString("BC_NAME"));
        vo.CPYSELLER  = StrUtil.nvl(rs.getString("CPYSELLER"));
        vo.SC_NAME    = StrUtil.nvl(rs.getString("SC_NAME"));
        vo.DLVADDRESS   = StrUtil.nvl(rs.getString("DLVADDRESS"));
        vo.STATUS       = StrUtil.nvl(rs.getString("STATUS"));
        vo.TRX_CLS      = StrUtil.nvl(rs.getString("TRX_CLS"));
        vo.CQ100_STATUS = StrUtil.nvl(rs.getString("CQ100_STATUS"));
      }
      if (vo==null) return null;

      // (2) 제품정보
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.ItemVO r = new CyclnOrderDetailVO.ItemVO();
          r.PRD_ID      = StrUtil.nvl(rs.getString("PRD_ID"));
          r.PRD_TITLE   = StrUtil.nvl(rs.getString("PRD_TITLE"));
          r.REQQTY      = StrUtil.nvl(rs.getString("REQQTY"));
          r.UNIT        = StrUtil.nvl(rs.getString("UNIT"));
          r.REQPRICE    = StrUtil.nvl(rs.getString("REQPRICE"));
          r.QTY         = StrUtil.nvl(rs.getString("QTY"));
          r.PRICE       = StrUtil.nvl(rs.getString("PRICE"));
          r.SUPPLYAMT   = StrUtil.nvl(rs.getString("SUPPLYAMT"));
          r.TAXAMT      = StrUtil.nvl(rs.getString("TAXAMT"));
          r.TOTALAMT    = StrUtil.nvl(rs.getString("TOTALAMT"));
          r.DESCRIPTION = StrUtil.nvl(rs.getString("DESCRIPTION"));
          vo.ITEMS.add(r);
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      vo = null;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  /**
   * 결제전송관리 상세. 프로시저가 결과셋 5개를 순서대로 돌려준다.
   * 주문이 없으면 null 을 돌려준다.
   */
  protected CyclnOrderDetailVO CYCLN_ORDER_DETAIL_PROC(String strOrderNo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CyclnOrderDetailVO vo = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_DETAIL_PROC ?;");
      ps.setString(1, StrUtil.nvl(strOrderNo));
      logger.debug(ps.getQueryString());
      ps.execute();

      // (1) 발주계약서정보
      rs = ps.getResultSet();
      if (rs!=null && rs.next()) {
        vo = new CyclnOrderDetailVO();
        vo.ORDERNO    = StrUtil.nvl(rs.getString("ORDERNO"));
        vo.TRADEDATE  = StrUtil.nvl(rs.getString("TRADEDATE"));
        vo.ORDERNAME  = StrUtil.nvl(rs.getString("ORDERNAME"));
        vo.REQDLVDATE = StrUtil.nvl(rs.getString("REQDLVDATE"));
        vo.CPYBUYER   = StrUtil.nvl(rs.getString("CPYBUYER"));
        vo.BC_NAME    = StrUtil.nvl(rs.getString("BC_NAME"));
        vo.CPYSELLER  = StrUtil.nvl(rs.getString("CPYSELLER"));
        vo.SC_NAME    = StrUtil.nvl(rs.getString("SC_NAME"));
        vo.DLVADDRESS = StrUtil.nvl(rs.getString("DLVADDRESS"));
        vo.STATUS     = StrUtil.nvl(rs.getString("STATUS"));
      }
      if (vo==null) return null;

      // (2) 제품 목록
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.ItemVO r = new CyclnOrderDetailVO.ItemVO();
          r.PRD_ID    = StrUtil.nvl(rs.getString("PRD_ID"));
          r.PRD_TITLE = StrUtil.nvl(rs.getString("PRD_TITLE"));
          r.REQQTY    = StrUtil.nvl(rs.getString("REQQTY"));
          r.REQPRICE  = StrUtil.nvl(rs.getString("REQPRICE"));
          r.QTY       = StrUtil.nvl(rs.getString("QTY"));
          r.PRICE     = StrUtil.nvl(rs.getString("PRICE"));
          r.TAXAMT    = StrUtil.nvl(rs.getString("TAXAMT"));
          r.TOTALAMT  = StrUtil.nvl(rs.getString("TOTALAMT"));
          vo.ITEMS.add(r);
        }
      }

      // (3) 매매계약정보 CL080
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.Cl080VO r = new CyclnOrderDetailVO.Cl080VO();
          r.REQ_YMD   = StrUtil.nvl(rs.getString("REQ_YMD"));
          r.PURC_ITEM = StrUtil.nvl(rs.getString("PURC_ITEM"));
          r.DLVR_YMD  = StrUtil.nvl(rs.getString("DLVR_YMD"));
          r.PURC_PRIC = StrUtil.nvl(rs.getString("PURC_PRIC"));
          r.LOAN_YN   = StrUtil.nvl(rs.getString("LOAN_YN"));
          r.TRX_CLS   = StrUtil.nvl(rs.getString("TRX_CLS"));
          r.STATUS    = StrUtil.nvl(rs.getString("STATUS"));
          vo.CL080.add(r);
        }
      }

      // (4) 결제예정정보 CL090
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.Cl090VO r = new CyclnOrderDetailVO.Cl090VO();
          r.REQ_YMD       = StrUtil.nvl(rs.getString("REQ_YMD"));
          r.PURC_PRIC     = StrUtil.nvl(rs.getString("PURC_PRIC"));
          r.SETL_PLN_YMD  = StrUtil.nvl(rs.getString("SETL_PLN_YMD"));
          r.SETL_PLN_PRIC = StrUtil.nvl(rs.getString("SETL_PLN_PRIC"));
          r.TAX_ISSU_YMD  = StrUtil.nvl(rs.getString("TAX_ISSU_YMD"));
          r.TRX_CLS       = StrUtil.nvl(rs.getString("TRX_CLS"));
          r.STATUS        = StrUtil.nvl(rs.getString("STATUS"));
          vo.CL090.add(r);
        }
      }

      // (5) 결제통보 CL100
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.Cl100VO r = new CyclnOrderDetailVO.Cl100VO();
          r.REQ_YMD        = StrUtil.nvl(rs.getString("REQ_YMD"));
          r.MTR_YMD        = StrUtil.nvl(rs.getString("MTR_YMD"));
          r.SETL_PRIC      = StrUtil.nvl(rs.getString("SETL_PRIC"));
          r.SFCP_SETL_PRIC = StrUtil.nvl(rs.getString("SFCP_SETL_PRIC"));
          r.BYCA_LOAN_PRIC = StrUtil.nvl(rs.getString("BYCA_LOAN_PRIC"));
          r.FEE_AMT        = StrUtil.nvl(rs.getString("FEE_AMT"));
          r.TRX_CLS        = StrUtil.nvl(rs.getString("TRX_CLS"));
          r.STATUS         = StrUtil.nvl(rs.getString("STATUS"));
          vo.CL100.add(r);
        }
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
