<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
String strStatus = StrUtil.nvl(request.getParameter("status"));
String strManagerId = (String)pageContext.getAttribute("SESS_LOGIN_ID");
new TradeBean().CT_HEADER_CHANGE_STATUS_PROC(intCtId, 0, strStatus, strManagerId, "Y");
%>
