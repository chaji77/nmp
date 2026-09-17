<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String date = StrUtil.nvl(request.getParameter("date"));
if (date == "") return;
String writeId = (String)session.getAttribute("SESS_LOGIN_ID");
int intResult = -1;
intResult = new GuaranteeBean().GUARANTEE_MASTER_INFO_EXTEND_ALL_PROC(date, writeId);
out.print(intResult);
%>