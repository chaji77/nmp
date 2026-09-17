<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("MpFeeDropProc.jsp");

int intCommId  = Integer.parseInt(StrUtil.nvl(request.getParameter("commid"), "0"));
int intSuccess = new CommissionBean().INFO_COMMISSION_DROP_PROC(intCommId, (String) pageContext.getAttribute("SESS_LOGIN_ID"));
out.print(intSuccess);
%>