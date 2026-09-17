<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginBean"%>
<%
String ref = StrUtil.nvl(request.getHeader("Referer"));
if (ref.contains(request.getScheme()) && ref.contains(request.getServerName())) {
  LoginBean.removeToken(request, response);
}
%>
<script>
location.href = "../index.jsp";
</script>