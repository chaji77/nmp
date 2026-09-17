<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String strLoginId = StrUtil.nvl(request.getParameter("login_id"));
if (strLoginId.length()>5 && strLoginId.length()<16) {
  int intPrsId = new CustomerBean().COMPANY_LOGIN_ID_CHECK_PROC(strLoginId);
  if (intPrsId>0) out.print("Y");
  else out.print("N");
}
else out.print("E");
%>