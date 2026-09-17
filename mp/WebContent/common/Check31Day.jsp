<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.common.BankVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
String strWriteDate   = StrUtil.extractInteger(StrUtil.nvl(request.getParameter("date")));
String strBankCd      = StrUtil.nvl(request.getParameter("bank"));

ArrayList<BankVO> banks = CodeBean.BANK_LIST_PROC();
String strBankName = "";
if (banks!=null && banks.size()>0) {
  for (BankVO vo : banks) if (vo.BNK_CD.equals(strBankCd)) strBankName = vo.BNK_NAME;
}

String strCapableDate = TradeBean.getPermittedDateOfTaxInvoice(strWriteDate, strBankCd);
out.print("{\"d\":\""+strCapableDate+"\",\"nm\":\""+strBankName+"\"}");
%>