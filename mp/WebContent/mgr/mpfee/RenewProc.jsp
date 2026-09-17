<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.sales.MastOffCommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intCommId     = Integer.parseInt(StrUtil.nvl(request.getParameter("commid"), "0"));
String strWriteId = (String) pageContext.getAttribute("SESS_LOGIN_ID");
int intSuccess    = new CommissionBean().INFO_COMMISSION_RENEW_PROC(intCommId, strWriteId);
out.print(intSuccess);
%>