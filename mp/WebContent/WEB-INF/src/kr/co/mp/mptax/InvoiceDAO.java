package kr.co.mp.mptax;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class InvoiceDAO extends BaroBill {

  private String getItemXML(InvoiceVO vo) {
    StringBuffer xml = new StringBuffer();
    if (vo.arrTradeItem!=null && vo.arrTradeItem.size()>0) {
      for (InvoiceVO.TradeItem ti : vo.arrTradeItem) {
        xml.append("<N>");
        xml.append("<E>"+ ti.strPurchaseExpiry + "</E>");      //YYYYMMDD
        xml.append("<NM>"+ ti.strName + "</NM>");
        xml.append("<I>"+ ti.strInformation + "</I>");
        xml.append("<U>"+ ti.strChargeableUnit + "</U>");
        xml.append("<P>"+ ti.strUnitPrice + "</P>");
        xml.append("<A>"+ ti.strAmount + "</A>");
        xml.append("<T>"+ ti.strTax + "</T>");
        xml.append("<D>"+ StrUtil.nvl(ti.strDescription) + "</D>");
        xml.append("</N>");
      }
    }
    return xml.toString();
  }


  public int T_BILL_ADD_PROC(InvoiceVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intBillSeq = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_ADD_PROC ?";
      for (int q=0; q<31; q++) {
        query += ", ?";
      }
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, vo.BILL_SENDER_KEY);
      ps.setString(i++, vo.CTIDS);
      ps.setInt(i++, vo.CPY_ID);
      ps.setInt(i++, vo.REG_ID);
      ps.setInt(i++, vo.intIssueDirection);     //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
      ps.setInt(i++, vo.intInvoiceType);      //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
      ps.setInt(i++, vo.intTaxType);

      ps.setInt(i++, vo.intPurposeType);       //1-영수, 2-청구
      ps.setString(i++, vo.strModifyCode);
      ps.setString(i++, vo.strAmountTotal);
      ps.setString(i++, vo.strTaxTotal);
      ps.setString(i++, vo.strTotalAmount);

      ps.setString(i++, vo.strWriteDate); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
      ps.setString(i++, super.cn);      //필수입력 - 연계사업자 사업자번호 ('-' 제외, 10자리)
      ps.setString(i++, super.cnm);      //필수입력
      ps.setString(i++, super.ceo);      //필수입력
      ps.setString(i++, super.p_addr1);

      ps.setString(i++, super.p_bizType);
      ps.setString(i++, super.p_bizClass);
      ps.setString(i++, super.p_memberName);    //필수입력
      ps.setString(i++, super.p_email);      //필수입력
      ps.setString(i++, vo.strToBizNo);    //필수입력

      ps.setString(i++, vo.strToCorpNm);    //필수입력
      ps.setString(i++, vo.strToCeo);      //필수입력
      ps.setString(i++, vo.strToAddr);
      ps.setString(i++, vo.strToBizType);
      ps.setString(i++, vo.strToBizClass);

      ps.setString(i++, vo.strToManager); //필수입력
      ps.setString(i++, vo.strToTel);
      ps.setString(i++, vo.strToEmail);
      ps.setString(i++, getItemXML(vo));
      ps.setString(i++, vo.strRemark);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        intBillSeq = rs.getInt("RESULT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intBillSeq;
  }


  public ArrayList<InvoiceVO> T_BILL_STANDBY_PROC(String strSenderKey, int intPage, String strWriteDate, String strInvoiceeCorpNum, String strEmpId, String strInvoiceeCorpName) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_STANDBY_PROC ?, ?, ?, ?, ?, ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strSenderKey);
      ps.setInt(   i++, intPage);
      ps.setString(i++, strWriteDate);
      ps.setString(i++, strInvoiceeCorpNum);
      ps.setString(i++, strEmpId);
      ps.setString(i++, strInvoiceeCorpName);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO vo = new InvoiceVO();
        vo.BILL_SEQ       = rs.getString("BILL_SEQ");
        vo.BILL_SENDER_KEY    = rs.getString("BILL_SENDER_KEY");
        vo.BILL_STATUS      = rs.getInt("BILL_STATUS");
        vo.strWriteDate     = rs.getString("WRITE_DATE");
        vo.intInvoiceType     = rs.getInt("INVOICE_TYPE");
        vo.intTaxType       = rs.getInt("TAX_TYPE");
        vo.intPurposeType     = rs.getInt("PURPOSE_TYPE");
        vo.strModifyCode    = rs.getString("MODIFY_CODE");
        vo.strAmountTotal     = rs.getString("AMT");
        vo.strTaxTotal      = rs.getString("TAX");
        vo.strTotalAmount     = rs.getString("TOTAL_AMT");
        vo.INVOICER_CORP_NAME = rs.getString("INVOICER_CORP_NAME");
        vo.strToCorpNm      = rs.getString("INVOICEE_CORP_NAME");
        vo.strToBizNo       = rs.getString("INVOICEE_CORP_NUM");
        vo.REG_ID       = rs.getInt("REG_ID");
        vo.DEP_NM       = StrUtil.nvl(rs.getString("DEP_NM"));
        vo.EMP_NM       = StrUtil.nvl(rs.getString("EMP_NM"));
        vo.TCNT         = rs.getInt("TCNT");
        vo.CTIDS        = rs.getString("CTID");
        arr.add(vo);
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }

  public InvoiceVO T_BILL_DETAIL_PROC(int intBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    InvoiceVO vo = new InvoiceVO();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_DETAIL_PROC ? ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intBillSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo.BILL_SEQ              = rs.getString("BILL_SEQ");
        vo.BILL_SENDER_KEY       = rs.getString("BILL_SENDER_KEY");
        vo.BILL_STATUS           = rs.getInt("BILL_STATUS");
        vo.CTIDS                 = rs.getString("CTID");

        vo.strWriteDate          = rs.getString("WRITE_DATE");
        vo.intInvoiceType        = rs.getInt("INVOICE_TYPE");
        vo.intTaxType            = rs.getInt("TAX_TYPE");
        vo.intPurposeType        = rs.getInt("PURPOSE_TYPE");
        vo.strModifyCode         = rs.getString("MODIFY_CODE");
        vo.strSerialNum          = rs.getString("BILL_SENDER_KEY") + rs.getString("BILL_SEQ");

        vo.strAmountTotal        = rs.getString("AMT");
        vo.strTaxTotal           = rs.getString("TAX");
        vo.strTotalAmount        = rs.getString("TOTAL_AMT");
        vo.strCash               = vo.strTotalAmount;

        vo.INVOICER_CORP_NUM     = rs.getString("INVOICER_CORP_NUM");
        vo.INVOICER_CORP_NAME    = rs.getString("INVOICER_CORP_NAME");
        vo.INVOICER_CEO_NAME     = rs.getString("INVOICER_CEO_NAME");
        vo.INVOICER_ADDR         = rs.getString("INVOICER_ADDR");
        vo.INVOICER_BIZ_TYPE     = rs.getString("INVOICER_BIZ_TYPE");
        vo.INVOICER_BIZ_CLASS    = rs.getString("INVOICER_BIZ_CLASS");
        vo.INVOICER_CONTACT_NAME = rs.getString("INVOICER_CONTACT_NAME");
        vo.INVOICER_TEL          = StrUtil.nvl(rs.getString("INVOICER_TEL"));
        vo.INVOICER_HP           = rs.getString("INVOICER_HP");
        vo.INVOICER_EMAIL        = rs.getString("INVOICER_EMAIL");

        vo.strToCorpNm           = rs.getString("INVOICEE_CORP_NAME");
        vo.strToBizNo            = rs.getString("INVOICEE_CORP_NUM");
        vo.strToCeo              = rs.getString("INVOICEE_CEO_NAME");
        vo.strToAddr             = rs.getString("INVOICEE_ADDR");
        vo.strToBizType          = rs.getString("INVOICEE_BIZ_TYPE");
        vo.strToBizClass         = rs.getString("INVOICEE_BIZ_CLASS");
        vo.strToManager          = rs.getString("INVOICEE_CONTACT_NAME");
        vo.strToTel              = StrUtil.nvl(rs.getString("INVOICEE_TEL"));
        vo.strToEmail            = rs.getString("INVOICEE_EMAIL");

        vo.REG_ID                = rs.getInt("REG_ID");
        vo.EMP_NM                = rs.getString("EMP_NM");
        vo.strRemark             = StrUtil.nvl(rs.getString("REMARK"));
      }
      vo.arrTradeItem = this.T_BILL_ITEM_PROC(intBillSeq);
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  private ArrayList<InvoiceVO.TradeItem> T_BILL_ITEM_PROC(int intBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<InvoiceVO.TradeItem> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_ITEM_PROC ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intBillSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO.TradeItem vo = new InvoiceVO().new TradeItem();
        vo.strPurchaseExpiry = rs.getString("PURCHASEEXPIRY");
        vo.strName = rs.getString("ITEM_NM");
        vo.strInformation = rs.getString("INFORMATION");
        vo.strChargeableUnit = rs.getString("UNIT");
        vo.strUnitPrice = rs.getString("UNIT_PRICE");
        vo.strAmount = rs.getString("AMOUNT");
        vo.strTax = rs.getString("TAX");
        vo.strDescription = StrUtil.nvl(rs.getString("DESCRIPTION"));
        arr.add(vo);
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }

  public boolean T_BILL_DROP_PROC(String strBillSeqs, int intRegId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    boolean is = true;
    try {
      String query = "EXEC DBO.T_BILL_DROP_PROC ?, ? ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strBillSeqs);
      ps.setInt(   i++, intRegId);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
      is = false;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
    return is;
  }
  public void T_BILL_UPDATE_STATUS_PROC(int seq, int status, String strInvoiceKey) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXECUTE DBO.T_BILL_UPDATE_STATUS_PROC ?, ?, ? ");
      int i = 1;
      ps.setInt(   i++, seq);
      ps.setInt(   i++, status);
      ps.setString(i++,  strInvoiceKey);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }

  public ArrayList<InvoiceVO> T_BILL_LIST_PROC(String strSenderKey, int intPage, String startDate, String endDate, String strInvoiceeCorpNum, int intStatus, String strEmpId, String strInvoiceeCorpName) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_LIST_PROC ?, ?, ?, ?, ?, ?, ?, ? ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strSenderKey);
      ps.setInt(   i++, intPage);
     /* ps.setString(i++, strWriteDate);*/
      ps.setString(i++, startDate);
      ps.setString(i++, endDate);
      ps.setString(i++, strInvoiceeCorpNum);
      ps.setInt(   i++, intStatus);
      ps.setString(i++, strEmpId);
      ps.setString(i++, strInvoiceeCorpName);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO vo = new InvoiceVO();
        vo.BILL_SEQ       = rs.getString("BILL_SEQ");
        vo.BILL_SENDER_KEY    = rs.getString("BILL_SENDER_KEY");
        vo.BILL_STATUS      = rs.getInt("BILL_STATUS");
        vo.strWriteDate     = rs.getString("WRITE_DATE");
        vo.intInvoiceType     = rs.getInt("INVOICE_TYPE");
        vo.intTaxType       = rs.getInt("TAX_TYPE");
        vo.intPurposeType     = rs.getInt("PURPOSE_TYPE");
        vo.strModifyCode    = rs.getString("MODIFY_CODE");
        vo.strAmountTotal     = rs.getString("AMT");
        vo.strTaxTotal      = rs.getString("TAX");
        vo.strTotalAmount     = rs.getString("TOTAL_AMT");
        vo.INVOICER_CORP_NAME = rs.getString("INVOICER_CORP_NAME");
        vo.strToCorpNm      = rs.getString("INVOICEE_CORP_NAME");
        vo.strToBizNo       = rs.getString("INVOICEE_CORP_NUM");
        vo.REG_ID       = rs.getInt("REG_ID");
        vo.DEP_NM       = StrUtil.nvl(rs.getString("DEP_NM"));
        vo.EMP_NM       = StrUtil.nvl(rs.getString("EMP_NM"));
        vo.TCNT         = rs.getInt("TCNT");
        vo.CTIDS         = rs.getString("CTIDS");
        vo.SUM_TOTAL = rs.getString("SUM_TOTAL");
        arr.add(vo);
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }

  public ArrayList<InvoiceVO> T_BILL_STATUS_PROC(String strSenderKey) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_STATUS_PROC ? ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strSenderKey);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO vo = new InvoiceVO();
        vo.BILL_SEQ       = rs.getString("BILL_SEQ");
        vo.BILL_SENDER_KEY    = rs.getString("BILL_SENDER_KEY");
        arr.add(vo);
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }

  public int T_BILL_READD_PROC(int obillseq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intBillSeq = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_READD_PROC ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++, obillseq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        intBillSeq = rs.getInt("RESULT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intBillSeq;
  }

  public BillReceiverVO T_BILL_RECEIVER_BY_CTID_PROC(int ctid) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    BillReceiverVO vo = null;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_RECEIVER_BY_CTID_PROC ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++, ctid);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo = new BillReceiverVO();
        vo.CPY_ID = rs.getInt("CPY_ID");
        vo.CTNO = StrUtil.nvl(rs.getString("CTNO"), "");
        vo.TRADEDATE = StrUtil.nvl(rs.getString("TRADEDATE"), DateTimeUtil.getCurrentDate(""));
        vo.MPFEE_SUPPLYAMT = StrUtil.nvl(rs.getString("MPFEE_SUPPLYAMT"), "0");
        vo.MPFEE_TAXAMT = StrUtil.nvl(rs.getString("MPFEE_TAXAMT"), "0");
        vo.MPFEE_TOTALAMT = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"), "0");
        vo.CPY_NAME = StrUtil.nvl(rs.getString("CPY_NAME"), "");
        vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"), "");
        vo.CPY_CEO_NAME = StrUtil.nvl(rs.getString("CPY_CEO_NAME"), "");
        vo.BUSINESS_TYPE = StrUtil.nvl(rs.getString("BUSINESS_TYPE"), "");
        vo.INDUSTRY = StrUtil.nvl(rs.getString("INDUSTRY"), "");
        vo.CPY_ADDR = StrUtil.nvl(rs.getString("CPY_ADDR"), "");
        vo.CPY_ADDR2 = StrUtil.nvl(rs.getString("CPY_ADDR2"), "");
        vo.MPTAX_USER_NM = StrUtil.nvl(rs.getString("MPTAX_USER_NM"), "");
        vo.MPTAX_EMAIL = StrUtil.nvl(rs.getString("MPTAX_EMAIL"), "");
        vo.PURPOSE_TYPE = rs.getInt("PURPOSE_TYPE");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  protected static BillReceiverVO T_BILL_FILL_BY_CPY_ID_PROC(int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("T_BILL_FILL_BY_CPY_ID_PROC");
    BillReceiverVO vo = null;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_FILL_BY_CPY_ID_PROC ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo = new BillReceiverVO();
        vo.CPY_ID = rs.getInt("CPY_ID");
        vo.CTNO = StrUtil.nvl(rs.getString("CTNO"), "");
        vo.TRADEDATE = StrUtil.nvl(rs.getString("TRADEDATE"), DateTimeUtil.getCurrentDate(""));
        vo.MPFEE_SUPPLYAMT = StrUtil.nvl(rs.getString("MPFEE_SUPPLYAMT"), "0");
        vo.MPFEE_TAXAMT = StrUtil.nvl(rs.getString("MPFEE_TAXAMT"), "0");
        vo.MPFEE_TOTALAMT = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"), "0");
        vo.CPY_NAME = StrUtil.nvl(rs.getString("CPY_NAME"), "");
        vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"), "");
        vo.CPY_CEO_NAME = StrUtil.nvl(rs.getString("CPY_CEO_NAME"), "");
        vo.BUSINESS_TYPE = StrUtil.nvl(rs.getString("BUSINESS_TYPE"), "");
        vo.INDUSTRY = StrUtil.nvl(rs.getString("INDUSTRY"), "");
        vo.CPY_ADDR = StrUtil.nvl(rs.getString("CPY_ADDR"), "");
        vo.CPY_ADDR2 = StrUtil.nvl(rs.getString("CPY_ADDR2"), "");
        vo.MPTAX_USER_NM = StrUtil.nvl(rs.getString("MPTAX_USER_NM"), "");
        vo.MPTAX_EMAIL = StrUtil.nvl(rs.getString("MPTAX_EMAIL"), "");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  public ArrayList<InvoiceVO> T_BILL_LIST_BY_CPY_ID_PROC(String strSenderKey, int intPage, int inCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_LIST_BY_CPY_ID_PROC ?, ?, ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strSenderKey);
      ps.setInt(   i++, intPage);
      ps.setInt(   i++, inCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO vo = new InvoiceVO();
        vo.BILL_SEQ         = rs.getString("BILL_SEQ");
        vo.INVOICE_KEY      = rs.getString("INVOICE_KEY");
        vo.BILL_SENDER_KEY  = rs.getString("BILL_SENDER_KEY");
        vo.BILL_STATUS      = rs.getInt("BILL_STATUS");
        vo.strWriteDate     = rs.getString("WRITE_DATE");
        vo.intInvoiceType   = rs.getInt("INVOICE_TYPE");
        vo.intTaxType       = rs.getInt("TAX_TYPE");
        vo.intPurposeType   = rs.getInt("PURPOSE_TYPE");
        vo.strModifyCode    = rs.getString("MODIFY_CODE");
        vo.strAmountTotal   = rs.getString("AMT");
        vo.strTaxTotal      = rs.getString("TAX");
        vo.strTotalAmount   = rs.getString("TOTAL_AMT");
        vo.INVOICER_CORP_NAME = rs.getString("INVOICER_CORP_NAME");
        vo.strToCorpNm      = rs.getString("INVOICEE_CORP_NAME");
        vo.strToBizNo       = rs.getString("INVOICEE_CORP_NUM");
        vo.TCNT             = rs.getInt("TCNT");
        vo.CTIDS            = rs.getString("CTIDS");
        arr.add(vo);
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
  
  public static InvoiceVO T_BILL_BY_CTID_PROC(int intCtId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("T_BILL_BY_CTID_PROC");
    InvoiceVO vo = new InvoiceVO();
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_BY_CTID_PROC ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo.BILL_SEQ       = rs.getString("BILL_SEQ");
        vo.BILL_STATUS    = rs.getInt("BILL_STATUS");
        vo.INVOICE_KEY    = rs.getString("INVOICE_KEY");
        vo.strAmountTotal = rs.getString("TOTAL_AMT");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }
  
  public ArrayList<BillReceiverVO> T_BILL_MONTH_TARGET_LIST_PROC(String strYearMonth) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<BillReceiverVO> arr = null;
    ResultSet rs = null;
    try {
      String query = "EXEC DBO.T_BILL_MONTH_TARGET_LIST_PROC ?";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strYearMonth);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) arr = new ArrayList<>();
      while(rs.next()) {
        BillReceiverVO vo = new BillReceiverVO();
        vo.CPY_ID = rs.getInt("CPY_ID");
        vo.CTNO = StrUtil.nvl(rs.getString("CTNO"), "");
        vo.TRADEDATE = StrUtil.nvl(rs.getString("TRADEDATE"), DateTimeUtil.getCurrentDate(""));
        vo.MPFEE_SUPPLYAMT = StrUtil.nvl(rs.getString("MPFEE_SUPPLYAMT"), "0");
        vo.MPFEE_TAXAMT = StrUtil.nvl(rs.getString("MPFEE_TAXAMT"), "0");
        vo.MPFEE_TOTALAMT = StrUtil.nvl(rs.getString("MPFEE_TOTALAMT"), "0");
        vo.CPY_NAME = StrUtil.nvl(rs.getString("CPY_NAME"), "");
        vo.CPY_BUSINESS_NO = StrUtil.nvl(rs.getString("CPY_BUSINESS_NO"), "");
        vo.CPY_CEO_NAME = StrUtil.nvl(rs.getString("CPY_CEO_NAME"), "");
        vo.BUSINESS_TYPE = StrUtil.nvl(rs.getString("BUSINESS_TYPE"), "");
        vo.INDUSTRY = StrUtil.nvl(rs.getString("INDUSTRY"), "");
        vo.CPY_ADDR = StrUtil.nvl(rs.getString("CPY_ADDR"), "");
        vo.CPY_ADDR2 = StrUtil.nvl(rs.getString("CPY_ADDR2"), "");
        vo.MPTAX_USER_NM = StrUtil.nvl(rs.getString("MPTAX_USER_NM"), "");
        vo.MPTAX_EMAIL = StrUtil.nvl(rs.getString("MPTAX_EMAIL"), "");
        vo.CNT = rs.getInt("CNT");
        arr.add(vo);
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
