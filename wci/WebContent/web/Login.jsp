<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="./includes/LoginCheck.jsp" %>
<%@ include file="./includes/Header.jsp" %>
<!-- page head block -->
<title>로그인</title>
<style>
div.center-icon {margin-top:140px;margin-bottom:60px;text-align:center;font-weight:bold;}
div.center-icon i {color:#246CEB;font-size:6em;}
@media only screen and (max-width:767px) {
  div.center-icon {margin-top:100px;margin-bottom:30px;}
  div.center-icon i {font-size:3em;}
}
</style>
<script type="text/javascript">
$(document).ready(function(){
  $("#LoginBox").load("LoginBox.jsp");
});
</script>
<!-- // page head block -->
<%@ include file="./includes/Navigation.jsp" %>

<div class='center-icon'><i class="fa-solid fa-unlock"></i></div>

<div id='LoginBox'></div>

<p style='height:80px;'></p>

<%@ include file="./includes/Footer.jsp" %>