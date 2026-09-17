<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");

ArrayList<String> parameterNames = new ArrayList<String>();
Enumeration<String> enumeration = request.getParameterNames();
while (enumeration.hasMoreElements()) {
  String strParameter = (String) enumeration.nextElement();
  System.out.println(strParameter + " : " + request.getParameter(strParameter));
}

String strSenderCode = StrUtil.nvl(request.getParameter("senderCode"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
String strCtId = StrUtil.nvl(request.getParameter("ctid"), "0");
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cpyid"), "0"));

InvoiceVO vo = new InvoiceVO();
vo.intIssueDirection = 1; //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
vo.intInvoiceType    = 1; //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서
vo.intTaxType        = 1; //intInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
                          //intInvoiceType 이 2,5 일 때 : 3-면세
if (request.getParameter("taxtype").equals("F")) {
  vo.intInvoiceType  = 2;
  vo.intTaxType      = 3;
}
if (request.getParameter("taxtype").equals("Z")) vo.intTaxType = 2;
vo.intPurposeType    = Integer.parseInt(StrUtil.nvl(request.getParameter("purposetype"), "2")); //1-영수, 2-청구


vo.intTaxCalcType = 2; //세율계산방법 : 1-절상, 2-절사, 3-반올림
vo.strModifyCode  = ""; //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
vo.strAmountTotal = StrUtil.nvl(request.getParameter("price_sum"), "0").replaceAll(",", ""); //공급가액 총액
vo.strTaxTotal    = StrUtil.nvl(request.getParameter("tax_sum"), "0").replaceAll(",", ""); //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
vo.strTotalAmount = StrUtil.nvl(request.getParameter("sum_sum"), "0").replaceAll(",", ""); //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
vo.strCash        = vo.strTotalAmount; //현금
vo.strWriteDate   = StrUtil.nvl(request.getParameter("write_ymd"), DateTimeUtil.getCurrentDate(ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"))).replaceAll(ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"), ""); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
vo.strSerialNum   = StrUtil.nvl(request.getParameter("serialnum"), "");
vo.strToBizNo     = StrUtil.nvl(request.getParameter("bizno"), "");
vo.strToCorpNm    = StrUtil.nvl(request.getParameter("comnm"), "");
vo.strToCeo       = StrUtil.nvl(request.getParameter("ceonm"), "");
vo.strToManager   = StrUtil.nvl(request.getParameter("manager"), "담당자");
vo.strToAddr      = StrUtil.nvl(request.getParameter("address"), "");
vo.strToBizType   = StrUtil.nvl(request.getParameter("uptae"), "");
vo.strToBizClass  = StrUtil.nvl(request.getParameter("upzong"), "");
vo.strToTel       = StrUtil.nvl(request.getParameter("phoneno"), "");
vo.strToEmail     = StrUtil.nvl(request.getParameter("tax_email"), "");
vo.strRemark      = StrUtil.nvl(request.getParameter("remark"), "");

String[] arrItemMonth = request.getParameterValues("item_m");
String[] arrItemDate  = request.getParameterValues("item_d");
String[] arrItemName  = request.getParameterValues("item_item");
String[] arrItemSpec  = request.getParameterValues("item_spec");
String[] arrItemCnt   = request.getParameterValues("item_cnt");
String[] arrItemUnit  = request.getParameterValues("item_unit");
String[] arrItemPrice = request.getParameterValues("item_price");
String[] arrItemTax   = request.getParameterValues("item_tax");

ArrayList<InvoiceVO.TradeItem> arrTradeItem = new ArrayList<>();

for (int i=0; i<arrItemMonth.length; i++) {
  InvoiceVO.TradeItem t = vo.new TradeItem();
  String ym = vo.strWriteDate.substring(0,6);
  t.strPurchaseExpiry = ym + ((StrUtil.nvl(arrItemDate[i], "1").length()==1) ? "0":"") + StrUtil.nvl(arrItemDate[i], "1");
  t.strName = StrUtil.nvl(arrItemName[i], "");
  t.strInformation = StrUtil.nvl(arrItemSpec[i], "");
  t.strChargeableUnit = StrUtil.nvl(arrItemCnt[i], "0").replaceAll(",", "");
  t.strUnitPrice = StrUtil.nvl(arrItemUnit[i], "0").replaceAll(",", "");
  t.strAmount = StrUtil.nvl(arrItemPrice[i], "0").replaceAll(",", "");
  t.strTax = StrUtil.nvl(arrItemTax[i], "0").replaceAll(",", "");
  t.strDescription = "";
  arrTradeItem.add(t);
}
vo.arrTradeItem = arrTradeItem;

try {
  vo.BILL_SENDER_KEY = strSenderCode;
  vo.CTIDS = strCtId;
  vo.CPY_ID = intCpyId;
  vo.REG_ID = Integer.parseInt(IntegerCryptoUtil.crypt(StrUtil.nvl((String)session.getAttribute("SESS_MAN_ID"), "0")));
  int intBillSeq = new InvoiceDAO().T_BILL_ADD_PROC(vo);
  if (intBillSeq>0) {
    out.println(intBillSeq);
  }
} catch (Exception e) {
  System.out.println(e.toString());
  out.println("-1");
}
%>