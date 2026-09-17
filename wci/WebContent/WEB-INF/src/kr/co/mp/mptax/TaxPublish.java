package kr.co.mp.mptax;

import java.util.ArrayList;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;

public class TaxPublish {

  public static int run(int intCtId) { // FOR SYSTEM-AUTO-PUBLISH
    return run(intCtId, 0);
  }
  public static int run(int intCtId, int intRegId) { // FOR MANAGER-PUBLISH
    BillReceiverVO r = new InvoiceDAO().T_BILL_RECEIVER_BY_CTID_PROC(intCtId);
    if (r==null) return 0; // 발행금액이 0, 월합세금계산서발행대상, 결제미완료건은 발행하지 않음

    InvoiceVO vo = new InvoiceVO();
    vo.intIssueDirection = 1; //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
    vo.intInvoiceType    = 1; //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
    vo.intTaxType        = 1; //intInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
    
    // 2025/03/18 : 1-영수(구매자금/일반자금), 2-청구(구매론/구매카드)
    vo.intPurposeType = r.PURPOSE_TYPE; // 1-영수, 2-청구
    
    vo.intTaxCalcType = 2; //세율계산방법 : 1-절상, 2-절사, 3-반올림
    vo.strModifyCode  = ""; //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
    vo.strAmountTotal = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT); //공급가액 총액
    vo.strTaxTotal    = StrUtil.extractInteger(r.MPFEE_TAXAMT); //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
    vo.strTotalAmount = StrUtil.extractInteger(r.MPFEE_TOTALAMT); //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
    vo.strCash        = "0"; //현금
    vo.strWriteDate   = DateTimeUtil.getCurrentDate(""); // StrUtil.nvl(r.TRADEDATE, DateTimeUtil.getCurrentDate("")); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
    vo.strSerialNum   = "";
    vo.strToBizNo     = StrUtil.nvl(r.CPY_BUSINESS_NO);
    vo.strToCorpNm    = StrUtil.nvl(r.CPY_NAME);
    vo.strToCeo       = StrUtil.nvl(r.CPY_CEO_NAME);
    vo.strToManager   = StrUtil.nvl(r.MPTAX_USER_NM, "담당자");
    vo.strToAddr      = StrUtil.nvl(r.CPY_ADDR) + " " + StrUtil.nvl(r.CPY_ADDR2);
    vo.strToBizType   = StrUtil.nvl(r.BUSINESS_TYPE);
    vo.strToBizClass  = StrUtil.nvl(r.INDUSTRY);
    vo.strToTel       = "";
    vo.strToEmail     = StrUtil.nvl(r.MPTAX_EMAIL);
    vo.strRemark      = "";
    
    ArrayList<InvoiceVO.TradeItem> arrTradeItem = new ArrayList<>();
    InvoiceVO.TradeItem t = vo.new TradeItem();
    t.strPurchaseExpiry = vo.strWriteDate;
    t.strName = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_ITEM_DEFAULT_NM") + " (" + r.CTNO + ")", "");
    t.strInformation = "-";
    t.strChargeableUnit = "1";
    t.strUnitPrice = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT);
    t.strAmount = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT);
    t.strTax = StrUtil.extractInteger(r.MPFEE_TAXAMT);
    t.strDescription = "";
    arrTradeItem.add(t);
    
    vo.BILL_SENDER_KEY = ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE");
    vo.CTIDS = Integer.toString(intCtId);
    vo.CPY_ID = r.CPY_ID;
    vo.REG_ID = intRegId;
    vo.arrTradeItem = arrTradeItem;
    return new InvoiceDAO().T_BILL_ADD_PROC(vo); // ISSUE SEQUENCE NUMBER
  }
  
  /* FILLING IN RECIPIENT INFORMATION WHEN ISSUING A MANUAL TAX INVOICE */
  public static BillReceiverVO T_BILL_FILL_BY_CPY_ID_PROC(int intCpyId) {
    return InvoiceDAO.T_BILL_FILL_BY_CPY_ID_PROC(intCpyId);
  }
  
  /* ISSUANCE OF MONTHLY TAX INVOICE */
  public static int runMonthly(String strYearMonth, int intRegId) {
    int intResult = 0;
    ArrayList<BillReceiverVO> arr = new InvoiceDAO().T_BILL_MONTH_TARGET_LIST_PROC(strYearMonth);
    if (arr==null || arr.size()==0) return 0;
    for (BillReceiverVO r : arr) {
      if (r.CPY_ID>0) {
        InvoiceVO vo = new InvoiceVO();
        vo.intIssueDirection = 1; //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
        vo.intInvoiceType    = 1; //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
        vo.intTaxType        = 1; //intInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
        
        vo.intTaxCalcType = 2; //세율계산방법 : 1-절상, 2-절사, 3-반올림
        vo.strModifyCode  = ""; //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
        vo.strAmountTotal = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT); //공급가액 총액
        vo.strTaxTotal    = StrUtil.extractInteger(r.MPFEE_TAXAMT); //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
        vo.strTotalAmount = StrUtil.extractInteger(r.MPFEE_TOTALAMT); //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
        vo.strCash        = "0"; //현금
        vo.strWriteDate   = StrUtil.nvl(r.TRADEDATE, DateTimeUtil.getCurrentDate("")); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
        vo.strSerialNum   = "";
        vo.strToBizNo     = StrUtil.nvl(r.CPY_BUSINESS_NO);
        vo.strToCorpNm    = StrUtil.nvl(r.CPY_NAME);
        vo.strToCeo       = StrUtil.nvl(r.CPY_CEO_NAME);
        vo.strToManager   = StrUtil.nvl(r.MPTAX_USER_NM, "담당자");
        vo.strToAddr      = StrUtil.nvl(r.CPY_ADDR) + " " + StrUtil.nvl(r.CPY_ADDR2);
        vo.strToBizType   = StrUtil.nvl(r.BUSINESS_TYPE);
        vo.strToBizClass  = StrUtil.nvl(r.INDUSTRY);
        vo.strToTel       = "";
        vo.strToEmail     = StrUtil.nvl(r.MPTAX_EMAIL);
        vo.strRemark      = "";
        ArrayList<InvoiceVO.TradeItem> arrTradeItem = new ArrayList<>();
        InvoiceVO.TradeItem t = vo.new TradeItem();
        t.strPurchaseExpiry = vo.strWriteDate;
        t.strName = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_ITEM_DEFAULT_NM") + " (" + r.CNT + "건)", "");
        t.strInformation = "-";
        t.strChargeableUnit = "1";
        t.strUnitPrice = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT);
        t.strAmount = StrUtil.extractInteger(r.MPFEE_SUPPLYAMT);
        t.strTax = StrUtil.extractInteger(r.MPFEE_TAXAMT);
        t.strDescription = "";
        arrTradeItem.add(t);
        vo.BILL_SENDER_KEY = ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE");
        vo.CTIDS  = "0";
        vo.CPY_ID = r.CPY_ID;
        vo.REG_ID = intRegId;
        vo.arrTradeItem = arrTradeItem;
        
        vo.strRemark = strYearMonth; // MONTHLY ISSUES FINGER PRINT
        
        intResult += new InvoiceDAO().T_BILL_ADD_PROC(vo);
      }
    }
    return intResult; // NUMBER OF ISSUES
  }

}
