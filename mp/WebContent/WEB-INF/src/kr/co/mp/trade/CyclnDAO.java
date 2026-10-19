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
   * 거래당사자 기준 주문 목록.
   * pvo.ROLE 이 B 면 구매기업(발주계약서), S 면 판매기업(납품내역관리) 기준으로 찾는다.
   * A 면 구매·판매 구분 없이 그 회사가 끼어있는 거래를 모두 찾는다.
   */
  protected ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PER_CPY_ID_PROC(CyclnOrderVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnOrderVO> arr = new ArrayList<CyclnOrderVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_LIST_PER_CPY_ID_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setInt(   ++i, pvo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(pvo.ROLE, CyclnOrderVO.ROLE_BUYER));
      ps.setString(++i, StrUtil.nvl(pvo.ORDERNO_COND));
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_START));
      ps.setString(++i, StrUtil.nvl(pvo.TRADEDATE_END));
      ps.setString(++i, StrUtil.nvl(pvo.STATUS_COND));
      ps.setString(++i, StrUtil.nvl(pvo.CPY_NAME_COND));
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
          vo.BC_NAME      = StrUtil.nvl(rs.getString("BC_NAME"));
          vo.SC_NAME      = StrUtil.nvl(rs.getString("SC_NAME"));
          vo.REQDLVDATE   = StrUtil.nvl(rs.getString("REQDLVDATE"));
          vo.PURC_PRIC    = StrUtil.nvl(rs.getString("PURC_PRIC"));
          vo.SETL_PLN_PRIC= StrUtil.nvl(rs.getString("SETL_PLN_PRIC"));
          vo.SETL_PRIC    = StrUtil.nvl(rs.getString("SETL_PRIC"));
          vo.MTR_YMD      = StrUtil.nvl(rs.getString("MTR_YMD"));
          vo.REGTIME      = StrUtil.nvl(rs.getString("REGTIME"));
          vo.PAYTIME      = StrUtil.nvl(rs.getString("PAYTIME"));
          vo.STATUS       = StrUtil.nvl(rs.getString("STATUS"));
          vo.CODE_NM      = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.TRX_CLS      = StrUtil.nvl(rs.getString("TRX_CLS"));
          vo.CQ090_STATUS = StrUtil.nvl(rs.getString("CQ090_STATUS"));
          vo.CQ100_STATUS = StrUtil.nvl(rs.getString("CQ100_STATUS"));
          vo.TMSG_FAIL_YN = StrUtil.nvl(rs.getString("TMSG_FAIL_YN"));
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
   * 발주계약서 등록. 계약기본정보와 제품정보를 한 프로시저(=한 트랜잭션)에서 넣는다.
   * 제품정보는 매매계약서와 같은 방식으로 XML 문자열에 실어 보낸다.
   * @return 새 주문번호. 실패하면 빈 문자열.
   */
  protected String CYCLN_ORDER_REG_PROC(CyclnOrderRegVO vo, String strItemXml) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String strOrderNo = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_REG_PROC ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, vo.CPYBUYER);
      ps.setInt(   ++i, vo.CPYSELLER);
      ps.setString(++i, StrUtil.nvl(vo.ORDERNAME));
      ps.setString(++i, StrUtil.nvl(vo.REQDLVDATE));
      ps.setString(++i, StrUtil.nvl(vo.DLVADDRESS));
      ps.setString(++i, StrUtil.nvl(vo.ESTIMATE_TYPE, "1"));
      ps.setString(++i, StrUtil.nvl(vo.CREUSER));
      ps.setString(++i, StrUtil.nvl(strItemXml));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) strOrderNo = StrUtil.nvl(rs.getString("ORDERNO"));
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      strOrderNo = "";
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strOrderNo;
  }

  protected ArrayList<CyclnOrderVO> CYCLN_ORDER_LIST_PROC(CyclnOrderVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnOrderVO> arr = new ArrayList<CyclnOrderVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
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
      ps.setString(++i, StrUtil.nvl(pvo.STATUS3));
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
          vo.CODE_NM        = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.TRX_CLS        = StrUtil.nvl(rs.getString("TRX_CLS"));
          vo.CQ090_STATUS   = StrUtil.nvl(rs.getString("CQ090_STATUS"));
          vo.CQ100_STATUS   = StrUtil.nvl(rs.getString("CQ100_STATUS"));
          vo.TMSG_FAIL_YN   = StrUtil.nvl(rs.getString("TMSG_FAIL_YN"));
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
        vo.STATUS        = StrUtil.nvl(rs.getString("STATUS"));
        vo.ESTIMATE_TYPE = StrUtil.nvl(rs.getString("ESTIMATE_TYPE"));
        vo.TRX_CLS       = StrUtil.nvl(rs.getString("TRX_CLS"));
        vo.CQ090_STATUS  = StrUtil.nvl(rs.getString("CQ090_STATUS"));
        vo.CQ100_STATUS  = StrUtil.nvl(rs.getString("CQ100_STATUS"));
        vo.ROLE          = StrUtil.nvl(rs.getString("ROLE"));
        vo.CODE_NM       = StrUtil.nvl(rs.getString("CODE_NM"));
        vo.TMSG_FAIL_YN  = StrUtil.nvl(rs.getString("TMSG_FAIL_YN"));
        vo.CAN_CANCEL    = StrUtil.nvl(rs.getString("CAN_CANCEL"));
        vo.CAN_CONFIRM   = StrUtil.nvl(rs.getString("CAN_CONFIRM"));
        vo.CAN_CHGREQ    = StrUtil.nvl(rs.getString("CAN_CHGREQ"));
        vo.CAN_CANREQ    = StrUtil.nvl(rs.getString("CAN_CANREQ"));
        vo.CAN_CHGCFM    = StrUtil.nvl(rs.getString("CAN_CHGCFM"));
        vo.CAN_CANCFM    = StrUtil.nvl(rs.getString("CAN_CANCFM"));
        vo.C080_TRX_CLS  = StrUtil.nvl(rs.getString("C080_TRX_CLS")).trim();
        vo.CQ080_STATUS  = StrUtil.nvl(rs.getString("CQ080_STATUS")).trim();
        vo.C090_TRX_CLS  = StrUtil.nvl(rs.getString("C090_TRX_CLS")).trim();
        vo.HAS_CL100     = StrUtil.nvl(rs.getString("HAS_CL100"));
        vo.CHG_PENDING   = StrUtil.nvl(rs.getString("CHG_PENDING"));
        // 결제정보
        vo.REGTIME        = StrUtil.nvl(rs.getString("REGTIME"));
        vo.PAYTIME        = StrUtil.nvl(rs.getString("PAYTIME"));
        vo.PURC_PRIC      = StrUtil.nvl(rs.getString("PURC_PRIC"));
        vo.SETL_PLN_PRIC  = StrUtil.nvl(rs.getString("SETL_PLN_PRIC"));
        vo.SETL_PLN_YMD   = StrUtil.nvl(rs.getString("SETL_PLN_YMD"));
        vo.TAX_ISSU_YMD   = StrUtil.nvl(rs.getString("TAX_ISSU_YMD"));
        vo.SETL_PRIC      = StrUtil.nvl(rs.getString("SETL_PRIC"));
        vo.SFCP_SETL_PRIC = StrUtil.nvl(rs.getString("SFCP_SETL_PRIC"));
        vo.BYCA_LOAN_PRIC = StrUtil.nvl(rs.getString("BYCA_LOAN_PRIC"));
        vo.MTR_YMD        = StrUtil.nvl(rs.getString("MTR_YMD"));
      }
      if (vo==null) return null;

      // (2) 제품정보
      if (ps.getMoreResults()) {
        rs = ps.getResultSet();
        while (rs.next()) {
          CyclnOrderDetailVO.ItemVO r = new CyclnOrderDetailVO.ItemVO();
          r.SEQNO       = StrUtil.nvl(rs.getString("SEQNO"));
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

  /**
   * CL080(매매계약정보) 전문 등록. 제품정보 반영·상태변경·전문등록을 한 프로시저에서 한다.
   * 거래구분은 01-등록(판매기업 승인), 02-변경, 03-취소다.
   * 처리할 수 없는 상태이거나 거래당사자가 아니면 프로시저가 사유를 담아 예외를 던진다.
   *
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  protected String[] CYCLN_CL080_PROC(CyclnOrderActVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = {"error", "", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_CL080_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.nvl(vo.ORDERNO));
      ps.setInt(   ++i, vo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(vo.STATUS_NOW));
      ps.setString(++i, StrUtil.nvl(vo.PURC_ITEM));
      ps.setString(++i, StrUtil.nvl(vo.PURC_PRIC));
      ps.setString(++i, StrUtil.nvl(vo.USERID));
      ps.setString(++i, StrUtil.nvl(vo.TRX_CLS, CyclnOrderVO.TRX_REGIST));
      ps.setString(++i, StrUtil.nvl(vo.ITEM_XML));
      ps.setString(++i, StrUtil.nvl(vo.REQDLVDATE)); // 빈값이면 프로시저가 지금 값을 그대로 둔다
      ps.setString(++i, StrUtil.nvl(vo.STATUS_CF));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        arrResult[0] = "ok";
        arrResult[1] = StrUtil.nvl(rs.getString("TMSG_SEQ"));
        arrResult[2] = StrUtil.nvl(rs.getString("REQ_YMD"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      arrResult[0] = "error";
      arrResult[1] = firstLine(e.getMessage()); // 프로시저가 RAISERROR 로 넘긴 사유
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * CL090(결제예정정보) 전문 등록. 구매기업이 은행에 결제를 접수한다.
   * 같은 건이 두 번 접수되면 프로시저가 사유를 담아 예외를 던진다.
   *
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  protected String[] CYCLN_CL090_PROC(CyclnOrderActVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = {"error", "", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_CL090_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.nvl(vo.ORDERNO));
      ps.setInt(   ++i, vo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(vo.STATUS_NOW));
      ps.setString(++i, StrUtil.nvl(vo.PURC_ITEM));
      ps.setString(++i, StrUtil.nvl(vo.PURC_PRIC));
      ps.setString(++i, StrUtil.nvl(vo.SETL_PLN_PRIC));
      ps.setString(++i, StrUtil.nvl(vo.SETL_PLN_YMD));
      ps.setString(++i, StrUtil.nvl(vo.TAX_ISSU_YMD));
      ps.setString(++i, StrUtil.nvl(vo.USERID));
      ps.setString(++i, StrUtil.nvl(vo.TRX_CLS, CyclnOrderVO.TRX_REGIST));
      ps.setString(++i, StrUtil.nvl(vo.STATUS_CF)); // 취소요청이면 취소요청 상태코드
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        arrResult[0] = "ok";
        arrResult[1] = StrUtil.nvl(rs.getString("TMSG_SEQ"));
        arrResult[2] = StrUtil.nvl(rs.getString("REQ_YMD"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      arrResult[0] = "error";
      arrResult[1] = firstLine(e.getMessage()); // 프로시저가 RAISERROR 로 넘긴 사유
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * 실패한 CL080·CL090 전문 재전송. 주문의 마지막 전문이 실패일 때만 같은 내용을 새 일련번호로 다시 등록한다.
   *
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  protected String[] CYCLN_TMSG_RESEND_PROC(String strOrderNo, String strKncd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = {"error", "", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_TMSG_RESEND_PROC ?, ?;");
      ps.setString(1, StrUtil.nvl(strOrderNo));
      ps.setString(2, StrUtil.nvl(strKncd));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        arrResult[0] = "ok";
        arrResult[1] = StrUtil.nvl(rs.getString("TMSG_SEQ"));
        arrResult[2] = StrUtil.nvl(rs.getString("REQ_YMD"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      arrResult[0] = "error";
      arrResult[1] = firstLine(e.getMessage()); // 프로시저가 RAISERROR 로 넘긴 사유
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * CL120(한도조회) 전문 등록. 응답은 CYCLN_CL120_RESULT_PROC 로 따로 읽는다.
   *
   * @return [0] "ok" 또는 "error", [1] 성공하면 전문 일련번호, 실패하면 보여줄 사유, [2] 요청일 yyyyMMdd
   */
  protected String[] CYCLN_CL120_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = {"error", "", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_CL120_PROC ?;");
      ps.setInt(1, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        arrResult[0] = "ok";
        arrResult[1] = StrUtil.nvl(rs.getString("TMSG_SEQ"));
        arrResult[2] = StrUtil.nvl(rs.getString("REQ_YMD"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      arrResult[0] = "error";
      arrResult[1] = firstLine(e.getMessage()); // 프로시저가 RAISERROR 로 넘긴 사유
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * CL120(한도조회) 응답 읽기. 응답 전이면 STATUS 만 채워진 한 줄이 온다.
   * 전문이 없으면 빈 목록이다.
   */
  protected ArrayList<CyclnLimitVO> CYCLN_CL120_RESULT_PROC(String strTmsgSeq, String strReqYmd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnLimitVO> arr = new ArrayList<CyclnLimitVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_CL120_RESULT_PROC ?, ?;");
      ps.setString(1, StrUtil.nvl(strTmsgSeq));
      ps.setString(2, StrUtil.nvl(strReqYmd));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CyclnLimitVO vo = new CyclnLimitVO();
          vo.STATUS    = StrUtil.nvl(rs.getString("STATUS")).trim();
          vo.RESP_CD   = StrUtil.nvl(rs.getString("RESP_CD")).trim();
          vo.RES_MSG   = StrUtil.nvl(rs.getString("RES_MSG")).trim();
          vo.TRX_CLS   = StrUtil.nvl(rs.getString("TRX_CLS")).trim();
          vo.NEW_YMD   = StrUtil.nvl(rs.getString("NEW_YMD"));
          vo.MTR_YMD   = StrUtil.nvl(rs.getString("MTR_YMD"));
          vo.LIMIT_AMT = rs.getLong("LIMIT_AMT");
          vo.LOAN_AMT  = rs.getLong("LOAN_AMT");
          vo.SPARE_AMT = rs.getLong("SPARE_AMT");
          vo.ETC       = StrUtil.nvl(rs.getString("ETC"));
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
   * CL080(매매계약정보)·CL090(결제예정정보) 응답 읽기.
   * 프로시저는 CYCLN_CL080_RESULT_PROC / CYCLN_CL090_RESULT_PROC 를 전문종류로 골라 부른다.
   *
   * @param strKncd CL080 또는 CL090
   * @return [0] STATUS(0·1-대기, 2-정상, 9-오류), [1] RESP_CD, [2] RES_MSG, [3] ORDERNO, [4] TRX_CLS.
   *         전문이 없으면 null
   */
  protected String[] CYCLN_TMSG_RESULT_PROC(String strKncd, String strTmsgSeq, String strReqYmd) {
    if (!"CL080".equals(strKncd) && !"CL090".equals(strKncd)) return null;
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_" + strKncd + "_RESULT_PROC ?, ?;");
      ps.setString(1, StrUtil.nvl(strTmsgSeq));
      ps.setString(2, StrUtil.nvl(strReqYmd));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        arrResult = new String[] {
          StrUtil.nvl(rs.getString("STATUS")).trim(),
          StrUtil.nvl(rs.getString("RESP_CD")).trim(),
          StrUtil.nvl(rs.getString("RES_MSG")).trim(),
          StrUtil.nvl(rs.getString("ORDERNO")).trim(),
          StrUtil.nvl(rs.getString("TRX_CLS")).trim()
        };
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * 발주계약서 수정·취소. 전문이 나가지 않는 변경만 다룬다.
   * 채워 넘긴 값만 바뀐다. 취소는 STATUS_CF 에 취소 상태코드를 넣어 부른다.
   *
   * @return [0] "ok" 또는 "error", [1] 실패하면 보여줄 사유
   */
  protected String[] CYCLN_ORDER_MOD_PROC(CyclnOrderActVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    String[] arrResult = {"error", ""};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_ORDER_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, StrUtil.nvl(vo.ORDERNO));
      ps.setInt(   ++i, vo.CPY_ID);
      ps.setString(++i, StrUtil.nvl(vo.STATUS_NOW));
      ps.setString(++i, StrUtil.nvl(vo.USERID));
      ps.setString(++i, StrUtil.nvl(vo.ORDERNAME));
      ps.setString(++i, StrUtil.nvl(vo.REQDLVDATE));
      ps.setString(++i, StrUtil.nvl(vo.DLVADDRESS));
      ps.setString(++i, StrUtil.nvl(vo.ESTIMATE_TYPE));
      ps.setString(++i, StrUtil.nvl(vo.STATUS_CF));
      ps.setString(++i, StrUtil.nvl(vo.ITEM_XML));
      ps.setString(++i, StrUtil.nvl(vo.DLV_ITEM_XML));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) arrResult[0] = "ok";
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      arrResult[0] = "error";
      arrResult[1] = firstLine(e.getMessage()); // 프로시저가 RAISERROR 로 넘긴 사유
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arrResult;
  }

  /**
   * 발주계약서 작성 화면의 판매기업 목록.
   * 이 회사가 구매기업으로 발주한 적이 있는 판매기업을 최근 거래순으로 돌려준다.
   */
  protected ArrayList<CyclnSellerVO> CYCLN_SELLER_LIST_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CyclnSellerVO> arr = new ArrayList<CyclnSellerVO>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_SELLER_LIST_PROC ?;");
      ps.setInt(1, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CyclnSellerVO vo = new CyclnSellerVO();
          vo.CPY_ID          = rs.getInt("CPY_ID");
          vo.CPY_NAME        = StrUtil.nvl(rs.getString("CPY_NAME"));
          vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"));
          vo.LAST_TRADEDATE  = StrUtil.nvl(rs.getString("LAST_TRADEDATE"));
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

  /** 예외 메시지 첫 줄만 남긴다. JDBC 가 뒤에 붙이는 설명까지 화면에 보일 필요는 없다. */
  private String firstLine(String strMsg) {
    strMsg = StrUtil.nvl(strMsg).trim();
    int intLf = strMsg.indexOf('\n');
    if (intLf>0) strMsg = strMsg.substring(0, intLf).trim();
    return strMsg;
  }
}
