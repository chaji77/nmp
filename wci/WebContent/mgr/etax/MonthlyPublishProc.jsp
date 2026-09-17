<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.BillReceiverVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strYearMonth = StrUtil.nvl(request.getParameter("ym"), DateTimeUtil.getCurrentDate("").substring(0, 6));
YearMonth yearMonth = YearMonth.of(Integer.parseInt(strYearMonth.substring(0, 4)), Integer.parseInt(strYearMonth.substring(4, 6)));
String strWriteDate = yearMonth.atEndOfMonth().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

ArrayList<BillReceiverVO> arr = new InvoiceDAO().T_BILL_MONTH_TARGET_LIST_PROC(strYearMonth);
int intTotalPubished = 0;
if (arr!=null && arr.size()>0) {
  for (BillReceiverVO r : arr) {
    if (r.CPY_ID>0) {
      String strItemName = "";
      if (StrUtil.nvl(r.CTNO).contains(",")) strItemName = StrUtil.nvl(r.CTNO).split(",")[StrUtil.nvl(r.CTNO).split(",").length-1];
      else strItemName = StrUtil.nvl(r.CTNO);
      strItemName = strYearMonth.substring(0, 4)+"년"+strYearMonth.substring(4, 6)+"월 MP수수료 (" + strItemName;
      if ((r.CNT-1)>0) strItemName += " 등 " + Integer.toString(r.CNT) + "건";
      strItemName += ")";

      String strSenderCode = StrUtil.nvl(request.getParameter("senderCode"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
      String strCtId = StrUtil.nvl(request.getParameter("ctid"), "0");
      int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cpyid"), "0"));
      
      InvoiceVO vo = new InvoiceVO();
      vo.intIssueDirection = 1; //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
      vo.intInvoiceType    = 1; //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
      vo.intTaxType        = 1; //intInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
      vo.intPurposeType    = 1; //1-영수, 2-청구
      
      vo.intTaxCalcType = 2; //세율계산방법 : 1-절상, 2-절사, 3-반올림
      vo.strModifyCode  = ""; //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
      vo.strAmountTotal = r.MPFEE_SUPPLYAMT; //공급가액 총액
      vo.strTaxTotal    = r.MPFEE_TAXAMT; //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
      vo.strTotalAmount = r.MPFEE_TOTALAMT; //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
      vo.strCash        = vo.strTotalAmount; //현금
      vo.strWriteDate   = strWriteDate; // DateTimeUtil.getCurrentDate(""); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
      vo.strSerialNum   = "";
      vo.strToBizNo     = r.CPY_BUSINESS_NO;
      vo.strToCorpNm    = r.CPY_NAME;
      vo.strToCeo       = r.CPY_CEO_NAME;
      vo.strToManager   = StrUtil.nvl(r.MPTAX_USER_NM);
      vo.strToAddr      = StrUtil.nvl(r.CPY_ADDR)  + " " + StrUtil.nvl(r.CPY_ADDR2);
      vo.strToBizType   = StrUtil.nvl(r.BUSINESS_TYPE);
      vo.strToBizClass  = StrUtil.nvl(r.INDUSTRY);
      vo.strToTel       = "";
      vo.strToEmail     = StrUtil.nvl(r.MPTAX_EMAIL);
      vo.strRemark      = "";
      
      ArrayList<InvoiceVO.TradeItem> arrTradeItem = new ArrayList<>();
      InvoiceVO.TradeItem t = vo.new TradeItem();
//      String ym = vo.strWriteDate.substring(0,6);
      t.strPurchaseExpiry = vo.strWriteDate;
      t.strName = strItemName;
      t.strInformation = "-";
      t.strChargeableUnit = "1";
      t.strUnitPrice = vo.strAmountTotal;
      t.strAmount = vo.strAmountTotal;
      t.strTax = vo.strTaxTotal;
      t.strDescription = "";
      arrTradeItem.add(t);
      vo.arrTradeItem = arrTradeItem;
      
      try {
        vo.BILL_SENDER_KEY = strSenderCode;
        vo.CTIDS = strCtId;
        vo.CPY_ID = intCpyId;
        vo.REG_ID = Integer.parseInt(IntegerCryptoUtil.crypt(StrUtil.nvl((String)session.getAttribute("SESS_MAN_ID"), "0")));
        int intBillSeq = new InvoiceDAO().T_BILL_ADD_PROC(vo);
        if (intBillSeq>0) {
          intTotalPubished++;
        }
      } catch (Exception e) {
        System.out.println(e.toString());
      }
    }
  }
}
out.print(intTotalPubished);
%>
