<%@ page contentType="text/html;charset=utf-8"%>
<%
  session.invalidate();
  String url = request.getContextPath() + "/mgr/index.jsp";
%>
<script>
function goLoginPage() {
  parent.top.location.href = "<%=url%>";
}
</script>
<body onload="goLoginPage();">
</body>