<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
request.setCharacterEncoding("utf-8");
String key = StrUtil.nvl((String)session.getAttribute("csrf_token"));
int intResult = -1;

if (!key.equals("") && request.getMethod().equals("POST")) {
  String strSSN = StrUtil.nvl(request.getParameter(key)).trim();
  if (StrUtil.isOnlyNumeric(strSSN) && strSSN.length()==10) {
    String s = new LoginBean().C_LOGIN_VIA_CERT_PROC(strSSN, request, response);
    if (!s.equals("0")) {
      intResult = 1;
      session.removeAttribute("csrf_token");
    }
    else intResult = 0;
  }
}
out.print(intResult);
%>

