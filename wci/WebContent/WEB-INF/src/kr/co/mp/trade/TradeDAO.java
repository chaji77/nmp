package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class TradeDAO {
  protected int SIGNINFO_ADD_PROC(String str) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SIGNINFO_ADD_PROC ?;");
      int i = 0;
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(str), "", 150));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intSeq = rs.getInt("SGN_ID");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  protected CtHeaderVO CT_HEADER_ADD_PROC(CtHeaderVO vo, String strItemXml) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    try {
      String q = "";
      for (int i=0; i<23; i++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_ADD_PROC "+q+";");
      int i = 0;
      ps.setString(++i, vo.CTTYPE           );
      ps.setString(++i, vo.TRADEDATE        );
      ps.setString(++i, vo.CONTRACTDATE     );
      ps.setString(++i, vo.CPYBUYER         );
      ps.setString(++i, vo.CPYSELLER        );
      
      ps.setString(++i, vo.TAXBIZTYPE       );
      ps.setString(++i, vo.SUPPLYAMT        );
      ps.setString(++i, vo.TAXAMT           );
      ps.setString(++i, vo.TOTALCONTRACTAMT );
      ps.setString(++i, vo.MPPAYCPY         );
      
      ps.setString(++i, vo.PAY_ID           );
      ps.setString(++i, vo.BNK_CD           );
      ps.setString(++i, vo.MTYDATE          );
      ps.setString(++i, vo.REGUSER          );
      ps.setString(++i, vo.SGN_ID           );
      
      ps.setString(++i, vo.SBILL_SEQ        );
      ps.setString(++i, vo.TAXAPPROVALNO    );
      ps.setString(++i, vo.BUYER_IP         );
      ps.setString(++i, vo.SELLER_IP        );
      ps.setString(++i, vo.SELLER_APP_SGN_ID);
      
      ps.setString(++i, vo.CU_USE_YN        );
      ps.setString(++i, vo.BILL_DT          );
      ps.setString(++i, strItemXml          );
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CTID    = rs.getString("CTID");
        vo.DIRTYPE = rs.getString("DIRTYPE");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected void CT_HEADER_MPFEE_ADD_PROC(CtHeaderVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_MPFEE_ADD_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setString(++i, vo.CTID             );
      ps.setString(++i, vo.MPFEERATE        );
      ps.setString(++i, vo.MPFEE_SUPPLYAMT  );
      ps.setString(++i, vo.MPFEE_TAXAMT     );
      ps.setString(++i, vo.MPFEE_TOTALAMT   );
      
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  protected CtHeaderVO CT_HEADER_MOD_PROC(CtHeaderVO vo, String strItemXml) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    try {
      String q = "";
      for (int i=0; i<27; i++) {
        q += ", ?";
      }
      q = q.substring(1);
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_MOD_PROC "+q+";");
      int i = 0;
      ps.setString(++i, vo.CTID             );
      ps.setString(++i, vo.CTTYPE           );
      ps.setString(++i, vo.CONTRACTDATE     );
      ps.setString(++i, vo.CPYBUYER         );
      ps.setString(++i, vo.CPYSELLER        );
      
      ps.setString(++i, vo.TAXBIZTYPE       );
      ps.setString(++i, vo.SUPPLYAMT        );
      ps.setString(++i, vo.TAXAMT           );
      ps.setString(++i, vo.TOTALCONTRACTAMT );
      ps.setString(++i, vo.MPPAYCPY         );
      
      ps.setString(++i, vo.PAY_ID           );
      ps.setString(++i, vo.BNK_CD           );
      ps.setString(++i, vo.MTYDATE          );
      ps.setString(++i, vo.REGUSER          );
      ps.setString(++i, vo.SGN_ID           );
      
      ps.setString(++i, vo.SBILL_SEQ        );
      ps.setString(++i, vo.TAXAPPROVALNO    );
      ps.setString(++i, vo.BUYER_IP         );
      ps.setString(++i, vo.SELLER_IP        );
      ps.setString(++i, vo.SELLER_APP_SGN_ID);
      
      ps.setString(++i, vo.CU_USE_YN        );
      ps.setString(++i,  vo.BILL_DT         );
      ps.setString(++i, strItemXml          );
      
      ps.setString(++i, vo.MPFEERATE        );
      ps.setString(++i, vo.MPFEE_SUPPLYAMT  );
      ps.setString(++i, vo.MPFEE_TAXAMT     );
      ps.setString(++i, vo.MPFEE_TOTALAMT   );
      
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CTID    = rs.getString("CTID");
        vo.DIRTYPE = rs.getString("DIRTYPE");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected int CT_HEADER_CHANGE_STATUS_PROC(int intCtId, int intCpyId, String strStatus, String strLoginId, String strManagerYn) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_CHANGE_STATUS_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      ps.setInt(++i, intCpyId);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strStatus), "010", 3));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strLoginId), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strManagerYn), "N", 1));
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected CtHeaderVO CT_HEADER_CONFIRM_PROC(int intCtId, int intCpyId, String strLoginId, String strRemoteIP, int intSignId, String strManagerYn, CtHeaderVO hvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CtHeaderVO vo = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_CONFIRM_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      ps.setInt(++i, intCpyId);
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strLoginId), "", 20));
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strRemoteIP), "", 20));
      ps.setInt(++i, intSignId);
      ps.setString(++i, hvo.MPFEERATE      );
      ps.setString(++i, hvo.MPFEE_SUPPLYAMT);
      ps.setString(++i, hvo.MPFEE_TAXAMT   );
      ps.setString(++i, hvo.MPFEE_TOTALAMT );
      ps.setString(++i, StrUtil.getParameter(StrUtil.xss(strManagerYn), "N", 1));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo = new CtHeaderVO();
        vo.CTID    = StrUtil.nvl(rs.getString("CTID"));
        vo.CTNO    = StrUtil.nvl(rs.getString("CTNO"));
        vo.STATUS  = StrUtil.nvl(rs.getString("STATUS"));
        vo.DIRTYPE = StrUtil.nvl(rs.getString("DIRTYPE"));
        vo.CONFIRM_SETTLE_YN = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN"));
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
   * 세금계산서 승인번호로 발행금액과 매매계약서의 결제금액 합계액의 차액을 가져온다. 
   * @param strTaxAppNo
   * @return
   */
  protected long CHECK_SETTLED_SUM_PROC(String strTaxAppNo, int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    long lngLimitSum = -1L;
    try {
        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CHECK_SETTLED_SUM_PROC ?, ?;");
        int i = 0;
        ps.setString(++i, strTaxAppNo);
        ps.setInt(   ++i, intCtId);
        logger.debug(ps.getQueryString());
        rs = ps.executeQuery();
        if (rs!=null && rs.next()) {
          lngLimitSum = rs.getLong("LIMIT_SUM");
        }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return lngLimitSum;
  }
  
  protected long[] CT_HEADER_CONTRACT_AMT_PROC(int intBuyerId, int intSellerId, int intMonth) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    long[] lngAmount = {0L, 0L};
    try {
        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_CONTRACT_AMT_PROC ?, ?, ?;");
        int i = 0;
        ps.setInt(++i, intBuyerId);
        ps.setInt(++i, intSellerId);
        ps.setInt(++i, intMonth);
        logger.debug(ps.getQueryString());
        rs = ps.executeQuery();
        if (rs!=null && rs.next()) {
          lngAmount[0] = rs.getLong("SUM_TOTALCONTRACTAMT");
          lngAmount[1] = rs.getLong("AVG_TOTALCONTRACTAMT");
        }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return lngAmount;
  }
  
  protected CtHeaderVO CT_HEADER_SEND_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    CtHeaderVO vo = new CtHeaderVO();
    vo.CTID = "0";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_SEND_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CTID    = rs.getString("CTID");
        vo.CTNO    = rs.getString("CTNO");
        vo.STATUS  = rs.getString("STATUS");
        vo.DIRTYPE = rs.getString("DIRTYPE");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  protected ArrayList<CtHeaderVO> CT_HEADER_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd, int intTargetCpyId, String strPageCode, int intPrsId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CtHeaderVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, pvo.STATUS);
      ps.setString(++i, strStartYmd);
      ps.setString(++i, strEndYmd);
      ps.setInt(   ++i, intTargetCpyId);
      ps.setString(++i, strPageCode);
      ps.setString(++i, StrUtil.nvl(pvo.SBDATE, "C"));
      ps.setString(++i, StrUtil.nvl(pvo.CTNO));
      ps.setInt(   ++i, intPrsId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CtHeaderVO vo = new CtHeaderVO();
          vo.TOTAL_CNT        = rs.getInt("TOTAL_CNT");
          vo.CTID             = StrUtil.nvl(rs.getString("CTID"));
          vo.CTNO             = StrUtil.nvl(rs.getString("CTNO"));
          vo.CTTYPE           = StrUtil.nvl(rs.getString("CTTYPE"));
          vo.BNK_CD           = StrUtil.nvl(rs.getString("BNK_CD"));
          vo.PAY_ID           = StrUtil.nvl(rs.getString("PAY_ID"));
          vo.REGDATE          = StrUtil.nvl(rs.getString("REGDATE"));
          vo.TRADEDATE        = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.CONTRACTDATE     = StrUtil.nvl(rs.getString("CONTRACTDATE"));
          vo.SETTLEDUEDATE    = StrUtil.nvl(rs.getString("SETTLEDUEDATE"));
          vo.SETTLEDATE       = StrUtil.nvl(rs.getString("SETTLEDATE"));
          vo.TOTALCONTRACTAMT = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT"));
          vo.CPYBUYER         = StrUtil.nvl(rs.getString("CPYBUYER"));
          vo.CPYSELLER        = StrUtil.nvl(rs.getString("CPYSELLER"));
          vo.REGTIME          = StrUtil.nvl(rs.getString("REGTIME"));
          vo.APPRTIME         = StrUtil.nvl(rs.getString("APPRTIME"));
          vo.STATUS           = StrUtil.nvl(rs.getString("STATUS"));
          vo.BUYER_NM         = StrUtil.nvl(rs.getString("BUYER_NM"));
          vo.BUYER_BIZ_NO     = StrUtil.nvl(rs.getString("BUYER_BIZ_NO"));
          vo.SELLER_NM        = StrUtil.nvl(rs.getString("SELLER_NM"));
          vo.SELLER_BIZ_NO    = StrUtil.nvl(rs.getString("SELLER_BIZ_NO"));
          vo.BNK_NAME         = StrUtil.nvl(rs.getString("BNK_NAME"));
          vo.PAY_SDESC        = StrUtil.nvl(rs.getString("PAY_SDESC"));
          vo.CODE_NM          = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.MPPAYCPY         = StrUtil.nvl(rs.getString("MPPAYCPY"));
          vo.MTYDATE          = StrUtil.nvl(rs.getString("MTYDATE"));
          vo.MPFEE_TOTALAMT   = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"));
          vo.SBILL_SEQ        = StrUtil.nvl(rs.getString("SBILL_SEQ"));
          vo.TAXAPPROVALNO    = StrUtil.nvl(rs.getString("TAXAPPROVALNO"));
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
  protected ArrayList<CtHeaderVO> CT_HEADER_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd, int intTargetCpyId, String strPageCode, int intPrsId, String strGuarInstCd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CtHeaderVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, pvo.STATUS);
      ps.setString(++i, strStartYmd);
      ps.setString(++i, strEndYmd);
      ps.setInt(   ++i, intTargetCpyId);
      ps.setString(++i, strPageCode);
      ps.setString(++i, StrUtil.nvl(pvo.SBDATE, "C"));
      ps.setString(++i, StrUtil.nvl(pvo.CTNO));
      ps.setInt(   ++i, intPrsId);
      ps.setString(++i, StrUtil.nvl(strGuarInstCd));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CtHeaderVO vo = new CtHeaderVO();
          vo.TOTAL_CNT        = rs.getInt("TOTAL_CNT");
          vo.CTID             = StrUtil.nvl(rs.getString("CTID"));
          vo.CTNO             = StrUtil.nvl(rs.getString("CTNO"));
          vo.CTTYPE           = StrUtil.nvl(rs.getString("CTTYPE"));
          vo.BNK_CD           = StrUtil.nvl(rs.getString("BNK_CD"));
          vo.PAY_ID           = StrUtil.nvl(rs.getString("PAY_ID"));
          vo.REGDATE          = StrUtil.nvl(rs.getString("REGDATE"));
          vo.TRADEDATE        = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.CONTRACTDATE     = StrUtil.nvl(rs.getString("CONTRACTDATE"));
          vo.SETTLEDUEDATE    = StrUtil.nvl(rs.getString("SETTLEDUEDATE"));
          vo.SETTLEDATE       = StrUtil.nvl(rs.getString("SETTLEDATE"));
          vo.TOTALCONTRACTAMT = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT"));
          vo.CPYBUYER         = StrUtil.nvl(rs.getString("CPYBUYER"));
          vo.CPYSELLER        = StrUtil.nvl(rs.getString("CPYSELLER"));
          vo.REGTIME          = StrUtil.nvl(rs.getString("REGTIME"));
          vo.APPRTIME         = StrUtil.nvl(rs.getString("APPRTIME"));
          vo.STATUS           = StrUtil.nvl(rs.getString("STATUS"));
          vo.BUYER_NM         = StrUtil.nvl(rs.getString("BUYER_NM"));
          vo.BUYER_BIZ_NO     = StrUtil.nvl(rs.getString("BUYER_BIZ_NO"));
          vo.SELLER_NM        = StrUtil.nvl(rs.getString("SELLER_NM"));
          vo.SELLER_BIZ_NO    = StrUtil.nvl(rs.getString("SELLER_BIZ_NO"));
          vo.BNK_NAME         = StrUtil.nvl(rs.getString("BNK_NAME"));
          vo.PAY_SDESC        = StrUtil.nvl(rs.getString("PAY_SDESC"));
          vo.CODE_NM          = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.MPPAYCPY         = StrUtil.nvl(rs.getString("MPPAYCPY"));
          vo.MTYDATE          = StrUtil.nvl(rs.getString("MTYDATE"));
          vo.MPFEE_TOTALAMT   = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"));
          vo.SBILL_SEQ        = StrUtil.nvl(rs.getString("SBILL_SEQ"));
          vo.TAXAPPROVALNO    = StrUtil.nvl(rs.getString("TAXAPPROVALNO"));
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

  protected CtHeaderVO CT_HEADER_DETAIL_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs  = null;
    CtHeaderVO vo = new CtHeaderVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_DETAIL_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        vo.CTID               = StrUtil.nvl(rs.getString("CTID              ".trim()));
        vo.CTNO               = StrUtil.nvl(rs.getString("CTNO              ".trim()));
        vo.CTTYPE             = StrUtil.nvl(rs.getString("CTTYPE            ".trim()));
        vo.DIRTYPE            = StrUtil.nvl(rs.getString("DIRTYPE           ".trim()));
        vo.TRADEDATE          = StrUtil.nvl(rs.getString("TRADEDATE         ".trim()));
        vo.CONTRACTDATE       = StrUtil.nvl(rs.getString("CONTRACTDATE      ".trim()));
        vo.CPYBUYER           = StrUtil.nvl(rs.getString("CPYBUYER          ".trim()));
        vo.CPYSELLER          = StrUtil.nvl(rs.getString("CPYSELLER         ".trim()));
        vo.TAXBIZTYPE         = StrUtil.nvl(rs.getString("TAXBIZTYPE        ".trim()));
        vo.SUPPLYAMT          = StrUtil.nvl(rs.getString("SUPPLYAMT         ".trim()));
        vo.TAXAMT             = StrUtil.nvl(rs.getString("TAXAMT            ".trim()));
        vo.TOTALCONTRACTAMT   = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT  ".trim()));
        vo.MPPAYCPY           = StrUtil.nvl(rs.getString("MPPAYCPY          ".trim()));
        vo.MPFEERATE          = StrUtil.nvl(rs.getString("MPFEERATE         ".trim()));
        vo.MPFEE_SUPPLYAMT    = StrUtil.nvl(rs.getString("MPFEE_SUPPLYAMT   ".trim()));
        vo.MPFEE_TAXAMT       = StrUtil.nvl(rs.getString("MPFEE_TAXAMT      ".trim()));
        vo.MPFEE_TOTALAMT     = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT    ".trim()));
        vo.PAY_ID             = StrUtil.nvl(rs.getString("PAY_ID            ".trim()));
        vo.BNK_CD             = StrUtil.nvl(rs.getString("BNK_CD            ".trim()));
        vo.MTYDATE            = StrUtil.nvl(rs.getString("MTYDATE           ".trim()));
        vo.TRADETYPE          = StrUtil.nvl(rs.getString("TRADETYPE         ".trim()));
        vo.STATUS             = StrUtil.nvl(rs.getString("STATUS            ".trim()));
        vo.REGUSER            = StrUtil.nvl(rs.getString("REGUSER           ".trim()));
        vo.REGTIME            = StrUtil.nvl(rs.getString("REGTIME           ".trim()));
        vo.SENDUSER           = StrUtil.nvl(rs.getString("SENDUSER          ".trim()));
        vo.SENDTIME           = StrUtil.nvl(rs.getString("SENDTIME          ".trim()));
        vo.LASTTIME           = StrUtil.nvl(rs.getString("LASTTIME          ".trim()));
        vo.CHGREQ             = StrUtil.nvl(rs.getString("CHGREQ            ".trim()));
        vo.CHGREQUSER         = StrUtil.nvl(rs.getString("CHGREQUSER        ".trim()));
        vo.CHGREQTIME         = StrUtil.nvl(rs.getString("CHGREQTIME        ".trim()));
        vo.CHGUSER            = StrUtil.nvl(rs.getString("CHGUSER           ".trim()));
        vo.CHGTIME            = StrUtil.nvl(rs.getString("CHGTIME           ".trim()));
        vo.CANUSER            = StrUtil.nvl(rs.getString("CANUSER           ".trim()));
        vo.CANTIME            = StrUtil.nvl(rs.getString("CANTIME           ".trim()));
        vo.APRUSER            = StrUtil.nvl(rs.getString("APRUSER           ".trim()));
        vo.APPRTIME           = StrUtil.nvl(rs.getString("APPRTIME          ".trim()));
        vo.SGN_ID             = StrUtil.nvl(rs.getString("SGN_ID            ".trim()));
        vo.SETTLEDATE         = StrUtil.nvl(rs.getString("SETTLEDATE        ".trim()));
        vo.SETTLEAMT          = StrUtil.nvl(rs.getString("SETTLEAMT         ".trim()));
        vo.SETTLEDUEDATE      = StrUtil.nvl(rs.getString("SETTLEDUEDATE     ".trim()));
        vo.CONFIRM_SETTLE_YN  = StrUtil.nvl(rs.getString("CONFIRM_SETTLE_YN ".trim()));
        vo.TAXAPPROVALNO      = StrUtil.nvl(rs.getString("TAXAPPROVALNO     ".trim()));
        vo.BUYER_IP           = StrUtil.nvl(rs.getString("BUYER_IP          ".trim()));
        vo.SELLER_IP          = StrUtil.nvl(rs.getString("SELLER_IP         ".trim()));
        vo.SELLER_APP_SGN_ID  = StrUtil.nvl(rs.getString("SELLER_APP_SGN_ID ".trim()));
        vo.CU_USE_YN          = StrUtil.nvl(rs.getString("CU_USE_YN         ".trim()));
        vo.SBILL_SEQ          = StrUtil.nvl(rs.getString("SBILL_SEQ         ".trim()));
        vo.BUYER_BIZ_NO       = StrUtil.nvl(rs.getString("BUYER_BIZ_NO      ".trim()));
        vo.BUYER_NM           = StrUtil.nvl(rs.getString("BUYER_NM          ".trim()));
        vo.BUYER_CEO_NM       = StrUtil.nvl(rs.getString("BUYER_CEO_NM      ".trim()));
        vo.SELLER_BIZ_NO      = StrUtil.nvl(rs.getString("SELLER_BIZ_NO     ".trim()));
        vo.SELLER_NM          = StrUtil.nvl(rs.getString("SELLER_NM         ".trim()));
        vo.SELLER_CEO_NM      = StrUtil.nvl(rs.getString("SELLER_CEO_NM     ".trim()));
        vo.BNK_NAME           = StrUtil.nvl(rs.getString("BNK_NAME          ".trim()));
        vo.PAY_SDESC          = StrUtil.nvl(rs.getString("PAY_SDESC         ".trim()));
        vo.CODE_NM            = StrUtil.nvl(rs.getString("CODE_NM           ".trim()));
        vo.TAXTYPE_NM         = StrUtil.nvl(rs.getString("TAXTYPE_NM        ".trim()));
        vo.REG_NM             = StrUtil.nvl(rs.getString("REG_NM            ".trim()));
        vo.APR_NM             = StrUtil.nvl(rs.getString("APR_NM            ".trim()));
        vo.BUYER_SGN          = StrUtil.nvl(rs.getString("BUYER_SGN         ".trim()));
        vo.SELLER_SGN         = StrUtil.nvl(rs.getString("SELLER_SGN        ".trim()));
        vo.BILL_DT            = StrUtil.nvl(rs.getString("BILL_DT           ".trim()));
        vo.BILL_SUM           = StrUtil.nvl(rs.getString("BILL_SUM          ".trim()));
        logger.debug(vo.toString());
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  protected ArrayList<CtItemVO> CT_ITEM_LIST_PROC (int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CtItemVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_ITEM_LIST_PROC ?;");
      int i = 0;
      ps.setInt(   ++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CtItemVO vo  = new CtItemVO();
          vo.CTID      = StrUtil.nvl(rs.getString("CTID     ".trim()));
          vo.SEQNO     = StrUtil.nvl(rs.getString("SEQNO    ".trim()));
          vo.ITEMNAME  = StrUtil.nvl(rs.getString("ITEMNAME ".trim()));
          vo.QTY       = StrUtil.nvl(rs.getString("QTY      ".trim()));
          vo.UNITPRICE = StrUtil.nvl(rs.getString("UNITPRICE".trim()));
          vo.UNIT      = StrUtil.nvl(rs.getString("UNIT     ".trim()));
          vo.SIZE      = StrUtil.nvl(rs.getString("SIZE     ".trim()));
          vo.SUPPLYAMT = StrUtil.nvl(rs.getString("SUPPLYAMT".trim()));
          vo.TAXAMT    = StrUtil.nvl(rs.getString("TAXAMT   ".trim()));
          vo.TOTALAMT  = StrUtil.nvl(rs.getString("TOTALAMT ".trim()));
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
  protected ArrayList<UnusualTransactionVO> UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(String strCtIds, String strWithReleased) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<UnusualTransactionVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, strCtIds);
      ps.setString(++i, StrUtil.nvl(strWithReleased, "N"));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          UnusualTransactionVO vo  = new UnusualTransactionVO();
          vo.CTID     = StrUtil.nvl(rs.getString("CTID".trim()));
          vo.SEQ      = StrUtil.nvl(rs.getString("SEQ".trim()));
          vo.SECTION  = StrUtil.nvl(rs.getString("SECTION".trim()));
          vo.CONTENT  = StrUtil.nvl(rs.getString("CONTENT".trim()));
          vo.USE_YN   = StrUtil.nvl(rs.getString("USE_YN".trim()));
          vo.USE_ID   = StrUtil.nvl(rs.getString("USE_ID".trim()));
          vo.USE_TIME = StrUtil.nvl(rs.getString("USE_TIME".trim()));
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
  protected ArrayList<SignVO> SIGNINFO_LIST_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<SignVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SIGNINFO_LIST_BY_CTID_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          SignVO vo      = new SignVO();
          vo.SGN_ID      = StrUtil.nvl(rs.getString("SGN_ID".trim()));
          vo.SGN_DESC    = StrUtil.nvl(rs.getString("SGN_DESC".trim()));
          vo.SGN_CREDATE = StrUtil.nvl(rs.getString("SGN_CREDATE".trim()));
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
  protected int UNUSUAL_TRANSACTION_RELEASE_PROC(UnusualTransactionVO pvo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 1;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_RELEASE_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, Integer.parseInt(pvo.SEQ));
      ps.setString(++i, StrUtil.nvl(pvo.USE_YN, "Y"));
      ps.setString(++i, StrUtil.nvl(pvo.USE_ID, ""));
      ps.setString(++i, StrUtil.nvl(pvo.CONTENT, ""));
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      intResult = 0;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return intResult;
  }
  protected long GUARANTEE_LIMIT_PROC(int intCpyId, String strBankCd, int intPayId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    long lngLimit = 0;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GUARANTEE_LIMIT_PROC ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, strBankCd);
      ps.setInt(   ++i, intPayId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) lngLimit = rs.getLong("GUAR_TOTAL_AMT");
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return lngLimit;
  }
  protected static String HOLIDAY_PERMIT_INVOICE_DAY_PROC(String str30PlusDate, int intPlusOption) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("HOLIDAY_PERMIT_INVOICE_DAY_PROC");
    ResultSet rs = null;
    String strDate = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.HOLIDAY_PERMIT_INVOICE_DAY_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, str30PlusDate);
      ps.setInt(   ++i, intPlusOption);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) strDate = rs.getString("YMD");
    } catch (Exception e) {
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strDate;
  }
  protected ArrayList<CtHeaderVO> CT_HEADER_COMING_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<CtHeaderVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_COMING_LIST_PROC ?, ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, pvo.PAGE);
      ps.setInt(   ++i, pvo.ROW_CNT);
      ps.setInt(   ++i, intCpyId);
      ps.setString(++i, StrUtil.nvl(strStartYmd, "20200101"));
      ps.setString(++i, StrUtil.nvl(strEndYmd, "20801231"));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CtHeaderVO vo = new CtHeaderVO();
          vo.TOTAL_CNT        = rs.getInt("TOTAL_CNT");
          vo.CTID             = StrUtil.nvl(rs.getString("CTID"));
          vo.CTNO             = StrUtil.nvl(rs.getString("CTNO"));
          vo.CTTYPE           = StrUtil.nvl(rs.getString("CTTYPE"));
          vo.BNK_CD           = StrUtil.nvl(rs.getString("BNK_CD"));
          vo.PAY_ID           = StrUtil.nvl(rs.getString("PAY_ID"));
          vo.TRADEDATE        = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.CONTRACTDATE     = StrUtil.nvl(rs.getString("CONTRACTDATE"));
          vo.TOTALCONTRACTAMT = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT"));
          vo.CPYBUYER         = StrUtil.nvl(rs.getString("CPYBUYER"));
          vo.CPYSELLER        = StrUtil.nvl(rs.getString("CPYSELLER"));
          vo.REGTIME          = StrUtil.nvl(rs.getString("REGTIME"));
          vo.APPRTIME         = StrUtil.nvl(rs.getString("APPRTIME"));
          vo.STATUS           = StrUtil.nvl(rs.getString("STATUS"));
          vo.BUYER_NM         = StrUtil.nvl(rs.getString("BUYER_NM"));
          vo.SELLER_NM        = StrUtil.nvl(rs.getString("SELLER_NM"));
          vo.BNK_NAME         = StrUtil.nvl(rs.getString("BNK_NAME"));
          vo.PAY_SDESC        = StrUtil.nvl(rs.getString("PAY_SDESC"));
          vo.CODE_NM          = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.MPPAYCPY         = StrUtil.nvl(rs.getString("MPPAYCPY"));
          vo.MTYDATE          = StrUtil.nvl(rs.getString("MTYDATE"));
          vo.REGDATE          = StrUtil.nvl(rs.getString("REGDATE"));
          
          vo.TOTAL_SUM        = StrUtil.nvl(rs.getString("TOTAL_SUM"));
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
  protected ArrayList<UnusualListVO> UNUSUAL_TRANSACTION_LIST_PROC(int intPage, int intPageSize, String strWithReleasedYN, String guar_gubun) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<UnusualListVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.UNUSUAL_TRANSACTION_LIST_PROC ?, ?, ?, ?;");
      int i = 0;
      ps.setInt(   ++i, intPage);
      ps.setInt(   ++i, intPageSize);
      ps.setString(++i, strWithReleasedYN);
      ps.setString(++i, guar_gubun);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          UnusualListVO vo = new UnusualListVO();
          vo.TOTAL_CNT        = rs.getInt("TOTAL_CNT");
          vo.CTID             = StrUtil.nvl(rs.getString("CTID"));
          vo.CTNO             = StrUtil.nvl(rs.getString("CTNO"));
          vo.CTTYPE           = StrUtil.nvl(rs.getString("CTTYPE"));
          vo.BNK_CD           = StrUtil.nvl(rs.getString("BNK_CD"));
          vo.PAY_ID           = StrUtil.nvl(rs.getString("PAY_ID"));
          vo.TRADEDATE        = StrUtil.nvl(rs.getString("TRADEDATE"));
          vo.CONTRACTDATE     = StrUtil.nvl(rs.getString("CONTRACTDATE"));
          vo.TOTALCONTRACTAMT = StrUtil.nvl(rs.getString("TOTALCONTRACTAMT"));
          vo.CPYBUYER         = StrUtil.nvl(rs.getString("CPYBUYER"));
          vo.CPYSELLER        = StrUtil.nvl(rs.getString("CPYSELLER"));
          vo.REGTIME          = StrUtil.nvl(rs.getString("REGTIME"));
          vo.APPRTIME         = StrUtil.nvl(rs.getString("APPRTIME"));
          vo.STATUS           = StrUtil.nvl(rs.getString("STATUS"));
          vo.BUYER_NM         = StrUtil.nvl(rs.getString("BUYER_NM"));
          vo.SELLER_NM        = StrUtil.nvl(rs.getString("SELLER_NM"));
          vo.BNK_NAME         = StrUtil.nvl(rs.getString("BNK_NAME"));
          vo.PAY_SDESC        = StrUtil.nvl(rs.getString("PAY_SDESC"));
          vo.CODE_NM          = StrUtil.nvl(rs.getString("CODE_NM"));
          vo.MPPAYCPY         = StrUtil.nvl(rs.getString("MPPAYCPY"));
          vo.MTYDATE          = StrUtil.nvl(rs.getString("MTYDATE"));
          vo.MPFEE_TOTALAMT   = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"));
          vo.SEQ              = StrUtil.nvl(rs.getString("SEQ"));
          vo.SECTION          = StrUtil.nvl(rs.getString("SECTION"));
          vo.USE_YN           = StrUtil.nvl(rs.getString("USE_YN"));
          vo.USE_ID           = StrUtil.nvl(rs.getString("USE_ID"));
          vo.USE_TIME         = StrUtil.nvl(rs.getString("USE_TIME"));
          vo.CONTENT          = StrUtil.nvl(rs.getString("CONTENT"));
          vo.SBILL_SEQ        = StrUtil.nvl(rs.getString("SBILL_SEQ"));
          vo.TAXAPPROVALNO    = StrUtil.nvl(rs.getString("TAXAPPROVALNO"));
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
  protected ArrayList<TodayStatVO> DAILY_STAT_PROC(String strDate) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<TodayStatVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.DAILY_STAT_PROC ?;");
      int i = 0;
      ps.setString(++i, strDate);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          TodayStatVO vo = new TodayStatVO();
          vo.A           = StrUtil.nvl(rs.getString("A"));
          vo.B           = StrUtil.nvl(rs.getString("B"));
          vo.C           = StrUtil.nvl(rs.getString("C"));
          vo.D           = StrUtil.nvl(rs.getString("D"));
          vo.GUBUN       = StrUtil.nvl(rs.getString("GUBUN"));
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
  
  protected ArrayList<String[]> CT_HEADER_STATUS_CHANGE_LIST_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<String[]> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_STATUS_CHANGE_LIST_BY_CTID_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          String[] vo    = new String[4];
          vo[0]          = StrUtil.nvl(rs.getString("FROM_STATUS"));
          vo[1]          = StrUtil.nvl(rs.getString("TO_STATUS"));
          vo[2]          = StrUtil.nvl(rs.getString("REG_ID"));
          vo[3]          = StrUtil.nvl(rs.getString("REG_DT"));
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
  
  protected TradeEntitiesVO CT_HEADER_ENTITIES_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    TradeEntitiesVO vo    = new TradeEntitiesVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_ENTITIES_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          vo.BUYER_CPY_ID  = rs.getInt(   "BUYER_CPY_ID ".trim()); 
          vo.BUYER_ID      = rs.getString("BUYER_ID     ".trim());
          vo.BUYER_BIZ_NO  = rs.getString("BUYER_BIZ_NO ".trim());
          vo.BUYER_NM      = rs.getString("BUYER_NM     ".trim());
          vo.BUYER_CEO_NM  = rs.getString("BUYER_CEO_NM ".trim());
          vo.SELLER_CPY_ID = rs.getInt(   "SELLER_CPY_ID".trim());
          vo.SELLER_ID     = rs.getString("SELLER_ID    ".trim());
          vo.SELLER_BIZ_NO = rs.getString("SELLER_BIZ_NO".trim());
          vo.SELLER_NM     = rs.getString("SELLER_NM    ".trim());
          vo.SELLER_CEO_NM = rs.getString("SELLER_CEO_NM".trim());
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
  protected ArrayList<TransactionResultVO> RECEIVE_XML_K311_LIST_BY_CTNO_PROC(String strCtNos) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    ArrayList<TransactionResultVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K311_LIST_BY_CTNO_PROC ?;");
      int i = 0;
      ps.setString(++i, strCtNos);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          TransactionResultVO vo  = new TransactionResultVO();
          vo.ORDERNO         = StrUtil.nvl(rs.getString("ORDERNO".trim()));
          vo.TRANSACTIONDATE = StrUtil.nvl(rs.getString("TRANSACTIONDATE".trim()));
          vo.TRANSACTIONTIME = StrUtil.nvl(rs.getString("TRANSACTIONTIME".trim()));
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
  // CT_HEADER_ADD_SGN_PROC
  protected void CT_HEADER_ADD_SGN_PROC(int intCtId, int intSgnId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CT_HEADER_ADD_SGN_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      ps.setInt(++i, intSgnId);
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
}
