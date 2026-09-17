<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String csrf_token = StrUtil.nvl(request.getParameter("csrf_token"));
String strLoginId = StrUtil.nvl(request.getParameter("login_id")).trim();
String strLoginPw = StrUtil.nvl(request.getParameter("login_pw")).trim();

int intResult = -1;
/*
System.out.println(request.getMethod());
System.out.println(csrf_token);
System.out.println(session.getAttribute("csrf_token"));
System.out.println(strLoginId);
System.out.println(strLoginPw);
*/
if (request.getMethod().equals("POST") && !csrf_token.equals("") && StrUtil.nvl((String)session.getAttribute("csrf_token")).equals(csrf_token)) {
  String s = new LoginBean().C_LOGIN_PROC(strLoginId, strLoginPw, request, response);
  if (!s.equals("0")) {
    intResult = 1;
    session.removeAttribute("csrf_token");
  }
  else intResult = 0;
}
out.print(intResult);
%>

