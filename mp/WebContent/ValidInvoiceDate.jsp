<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%!
String getKoreanDateFormat(String strDate) {
  if (strDate.length()==8) return strDate.substring(0, 4) + "년 " + strDate.substring(4, 6) + "월 " + strDate.substring(6) + "일";
  return strDate;
}
%>
<%
request.setCharacterEncoding("utf-8");
String strBankCd = "XX";
String strTodayBaseYN = StrUtil.nvl(request.getParameter("today"), "N");
String strLastMonthEndDate = "";

DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyyMMdd");
LocalDate today     = LocalDate.now();
if (!strTodayBaseYN.equals("Y")) {
  LocalDate t = LocalDate.now();
  int intMinusMonth   = (t.getDayOfMonth()<3) ? 2 : 1;
  YearMonth pym       = YearMonth.of(today.getYear(), today.getMonthValue()).minusMonths(intMinusMonth);
  LocalDate ld        = pym.atEndOfMonth();
  strLastMonthEndDate = ld.format(f);
} else {
  strLastMonthEndDate = today.format(f);
}
String strPlusOneDayBank = ConfigurationMgr.getInstance().getString("BANK_31DAY_ADD_DATE_WHEN_HOLIDAY");
if (strPlusOneDayBank.indexOf(",")>-1) strBankCd = strPlusOneDayBank.split(",")[0];
String strPlusCapableDate  = TradeBean.getPermittedDateOfTaxInvoice(strLastMonthEndDate, strBankCd);
String strMinusCapableDate = TradeBean.getPermittedDateOfTaxInvoice(strLastMonthEndDate, "XX");
%>
    <h1 class='hide_in_invoice_page'>B2B 구매자금 (세금)계산서 가능일자 안내</h1>
    <h2><span class='due-date'><%=getKoreanDateFormat(strLastMonthEndDate) %></span> 작성한 세금계산서의 은행별 마감일은 아래와 같습니다.</h2>
    <p><i class="fa-solid fa-asterisk"></i> 계약승인 완료 : 경남, 국민, 기업, 농협, IM뱅크, 부산, 신한, 우리, 하나, SC제일 <span class='due-date'><%=getKoreanDateFormat(strPlusCapableDate) %></span></p>
    <p><i class="fa-solid fa-asterisk"></i> 결제 완료 : 수협, 씨티(뱅킹 결제까지), 광주, 전북 <span class='due-date'><%=getKoreanDateFormat(strMinusCapableDate) %></span></p>
    <p class='hide_in_invoice_page'>&nbsp;</p>
    <p class='hide_in_invoice_page' style='opacity:0.5;'>한국은행에서 규정한 금융기관 기업구매자금대출 취급세칙 제6조 3항에 따라<br/>판매대금추심의뢰서는 세금계산서의 발급일로부터 31일 이내에 추심의뢰하거나 전송한 것이어야 합니다.</p>
    <p class='hide_in_invoice_page'>&nbsp;</p>