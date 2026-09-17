<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String strBizNo  = StrUtil.nvl(request.getParameter("bizno"));
String strUserId = StrUtil.nvl(request.getParameter("uid"));
String strEmail  = StrUtil.nvl(request.getParameter("email"));
String strPasswd = CryptoDESUtil.encrypt((UUID.randomUUID().toString()).substring(0,6));
strPasswd = CryptoDESUtil.decrypt(new LoginBean().C_ACCOUNT_CHANGE_PASSWD_PROC(strBizNo, strUserId, strEmail, strPasswd));
out.println(strPasswd);
%>


