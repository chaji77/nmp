<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="legacy.SysSelect"%>
<%
String strId = StrUtil.nvl(request.getParameter("id"));
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->

</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<div style='margin-top:20px;text-align:center;'>
  <form name='frmEnt' method='get'>
  <strong>LEGACY SYS_SELECT SEARCH</strong> : <input type='text' name='id' value='<%=strId%>' style='width:200px;'>
  <input type='submit' style='width:100px;'>
  </form>
</div>

<table>
  <tr>
<%
if (!strId.equals("")) {
  Map<String, String> vo = SysSelect.GetSysSelect(strId);
  out.println("<td><pre>" + vo.get("QUERY") + "</pre></td>");
  out.println("<td><pre>" + vo.get("DEF") + "</pre></td>");
}
%>
  </tr>
</table>

</body>
</html>

