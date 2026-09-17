<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>개인정보처리방침</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>

</style>

<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>개인정보처리방침</span>
</div>

<div style='text-align:justify;line-height:1.8em;'><%=StrUtil.templateToString("privacy.htm") %></div>

<%@ include file="../includes/Footer.jsp" %>