<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="com.baroservice.api.BarobillApiProfile" %>
<%@ page import="com.baroservice.api.BarobillApiService" %>
<%@ page import="kr.co.mp.mptax.BaroBill" %>
<%
request.setCharacterEncoding("utf-8");
int intErrorCode = Integer.parseInt(StrUtil.nvl(request.getParameter("e"), "0"));
BarobillApiProfile bbp = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? BarobillApiProfile.TESTBED : BarobillApiProfile.RELEASE;
BarobillApiService barobillApiService = new BarobillApiService(bbp);
String strErrorMsg = barobillApiService.taxInvoice.getErrString(ConfigurationMgr.getInstance().getString("ETAX_KEY"), intErrorCode);
%>
<%=strErrorMsg%>