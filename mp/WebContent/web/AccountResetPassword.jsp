<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String strUserId = "";
String strPasswd = "";
try {
  //
  String[] strKey  = CryptoDESUtil.decrypt(StrUtil.xss(request.getParameter("key").replace(" ", "+"))).split("____");
  String strBizNo  = strKey[0];
  strUserId        = strKey[1];
  String strEmail  = strKey[2];
  strPasswd = CryptoDESUtil.encrypt((UUID.randomUUID().toString()).substring(0,6));
  strPasswd = CryptoDESUtil.decrypt(new LoginBean().C_ACCOUNT_CHANGE_PASSWD_PROC(strBizNo, strUserId, strEmail, strPasswd));
} catch (Exception e) {

}
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="./includes/LoginCheck.jsp" %>
<%@ include file="./includes/Header.jsp" %>
<!-- page head block -->
<title>비밀번호 재발급</title>
<!-- // page head block -->
<%@ include file="./includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>비밀번호 재발급</span>
  <span class='more'>
  </span>
</div>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<h3 style='width:100%;text-align:center;line-height:1.5em;font-weight:normal;'><font style='font-size:2em;'><%=strUserId %>님!</font><br/><br/>새로운 비밀번호는 <strong style='color:red;'><%=strPasswd %></strong>입니다.<br/><br/><br/><a href='Login.jsp' class='btn'>로그인</a></h3>

<p>&nbsp;</p>
<p>&nbsp;</p>

<%@ include file="./includes/Footer.jsp" %>