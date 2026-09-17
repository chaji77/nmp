<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.UnusualTransactionVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
UnusualTransactionVO pvo = new UnusualTransactionVO();
pvo.SEQ     = StrUtil.nvl(request.getParameter("seq"));
pvo.CONTENT = StrUtil.nvl(request.getParameter("contents"));
pvo.USE_YN  = StrUtil.nvl(request.getParameter("use_yn"), "Y");
pvo.USE_ID  = (String) pageContext.getAttribute("SESS_LOGIN_ID");
int intResult = new TradeBean().UNUSUAL_TRANSACTION_RELEASE_PROC(pvo);
out.print(intResult);
%>