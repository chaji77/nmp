<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("seq")));
String strDelYn   = new TaxBean().CT_BILL_DROP_PROC(strBillSeq);
out.print(strDelYn);
%>