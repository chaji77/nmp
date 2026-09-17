package kr.co.mp.firstbill;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class InvoiceDAO extends BaroBill {

  public InvoiceDAO(BillUserVO v) {
    super(v);
  }

  private static String getItemXML(InvoiceVO vo) {
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


  public int BILL_ADD_PROC(InvoiceVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intBillSeq = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_ADD_PROC ?";
      for (int q=0; q<30; q++) {
        query += ", ?";
      }
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, vo.BILL_SENDER_KEY);
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

  public static int BILL_UPDATE_PROC(InvoiceVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("FIRSTBILL.DBO.BILL_UPDATE_PROC");
    int intBillSeq = 0;
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_UPDATE_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(i++,  Integer.parseInt(vo.BILL_SEQ));
      ps.setInt(i++, vo.intIssueDirection);     //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
      ps.setInt(i++, vo.intInvoiceType);      //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
      ps.setInt(i++, vo.intTaxType);
      ps.setInt(i++, vo.intPurposeType);       //1-영수, 2-청구
      
      ps.setString(i++, vo.strModifyCode);
      ps.setString(i++, vo.strAmountTotal);
      ps.setString(i++, vo.strTaxTotal);
      ps.setString(i++, vo.strTotalAmount);
      ps.setString(i++, vo.strWriteDate); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
      
      ps.setString(i++, vo.INVOICER_CONTACT_NAME);
      ps.setString(i++, vo.INVOICER_TEL);
      ps.setString(i++, vo.INVOICER_EMAIL);
      ps.setString(i++, vo.strToBizNo);    //필수입력
      ps.setString(i++, vo.strToCorpNm);    //필수입력
      
      ps.setString(i++, vo.strToCeo);      //필수입력
      ps.setString(i++, vo.strToAddr);
      ps.setString(i++, vo.strToBizType);
      ps.setString(i++, vo.strToBizClass);
      ps.setString(i++, StrUtil.nvl(vo.strToManager, "담당자")); //필수입력
      
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

  public static ArrayList<InvoiceVO> BILL_STANDBY_PROC(int intPage, int intCpyId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_STANDBY_PROC");
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_STANDBY_PROC ?, ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intPage);
      ps.setInt(   i++, intCpyId);
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
        vo.strSerialNum = rs.getString("BILL_NO");
        vo.strRemark    = rs.getString("REMARK");
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

  public static InvoiceVO BILL_DETAIL_PROC(int intBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_DETAIL_PROC");
    InvoiceVO vo = new InvoiceVO();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_DETAIL_PROC ? ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intBillSeq);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        vo.BILL_SEQ              = rs.getString("BILL_SEQ");
        vo.BILL_SENDER_KEY       = rs.getString("BILL_SENDER_KEY");
        vo.BILL_STATUS           = rs.getInt("BILL_STATUS");
        vo.strWriteDate          = rs.getString("WRITE_DATE");
        vo.intInvoiceType        = rs.getInt("INVOICE_TYPE");
        vo.intTaxType            = rs.getInt("TAX_TYPE");
        vo.intPurposeType        = rs.getInt("PURPOSE_TYPE");
        vo.strModifyCode         = rs.getString("MODIFY_CODE");
        vo.strSerialNum          = rs.getString("BILL_NO");

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
      vo.arrTradeItem = InvoiceDAO.BILL_ITEM_PROC(intBillSeq);
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  private static ArrayList<InvoiceVO.TradeItem> BILL_ITEM_PROC(int intBillSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_ITEM_PROC");
    ArrayList<InvoiceVO.TradeItem> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_ITEM_PROC ?";
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

  public static boolean BILL_DROP_PROC(String strBillSeqs, int intRegId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_DROP_PROC");
    boolean is = true;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_DROP_PROC ?, ? ";
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
  public static void BILL_UPDATE_STATUS_PROC(int seq, int status) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_UPDATE_STATUS_PROC");
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXECUTE FIRSTBILL.DBO.BILL_UPDATE_STATUS_PROC ?, ?; ");
      int i = 1;
      ps.setInt(   i++, seq);
      ps.setInt(   i++, status);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  public static void BILL_UPDATE_STATUS_AND_AUTH_PROC(String strBillNo, int status, String strAuthNo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_UPDATE_STATUS_AND_AUTH_PROC");
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXECUTE FIRSTBILL.DBO.BILL_UPDATE_STATUS_AND_AUTH_PROC ?, ?, ?; ");
      int i = 1;
      ps.setString(   i++, strBillNo);
      ps.setInt(   i++, status);
      ps.setString(   i++, strAuthNo);
      logger.debug(ps.getQueryString());
      ps.executeUpdate();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }

  public static ArrayList<InvoiceVO> BILL_STATUS_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_STATUS_PROC");
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_STATUS_PROC; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        InvoiceVO vo         = new InvoiceVO();
        vo.strSerialNum      = rs.getString("BILL_NO");
        vo.INVOICER_CORP_NUM = rs.getString("INVOICER_CORP_NUM");
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

  public static ArrayList<InvoiceVO> BILL_LIST_BY_CPY_ID_PROC(int intPage, int inCpyId, String strStartDate, String strEndDate, String strCompanyName) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BILL_LIST_BY_CPY_ID_PROC");
    ArrayList<InvoiceVO> arr = new ArrayList<>();
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BILL_LIST_BY_CPY_ID_PROC ?, ?, ?, ?, ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setInt(   i++, intPage);
      ps.setInt(   i++, inCpyId);
      ps.setString(i++, StrUtil.nvl(strStartDate));
      ps.setString(i++, StrUtil.nvl(strEndDate));
      ps.setString(i++, StrUtil.nvl(strCompanyName));
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
        vo.strSerialNum     = StrUtil.nvl(rs.getString("BILL_NO"));
        vo.strRemark        = StrUtil.nvl(rs.getString("REMARK"));
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
  
  public static int BAT_LOAD_BILL_PROC(String strDate) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("BAT_LOAD_BILL_PROC");
    int intCnt = 0;
    
    ResultSet rs = null;
    try {
      String query = "EXEC FIRSTBILL.DBO.BAT_LOAD_BILL_PROC ?; ";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setString(1, strDate);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs.next()) intCnt = rs.getInt("CNT");
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intCnt;
  }

}
