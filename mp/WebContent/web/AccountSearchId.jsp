<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String strBizNo  = StrUtil.xss(request.getParameter("bizno")).replaceAll("-", "");
String strUserNm = StrUtil.xss(request.getParameter("usernm"));
out.print(new LoginBean().C_ACCOUNT_SEARCH_ID_PROC(strBizNo, strUserNm));
%>