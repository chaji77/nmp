<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.devtool.DevDAO" %>
<%
ArrayList<Map<String, String>> arr = DevDAO.getScheme("EXEC DBO.DEV_PROCEDURE_LIST_PROC;");
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>프로시저목록</title>
<style>
th {text-align:left;}
h1 {margin-bottom:30px;}
</style>
<script>
function showProcedure(sp) {
  window.open("ProcedureView.jsp?sp=DBO."+sp, "_procedure_", "width=500,height=500");
}
</script>
<!-- // page head block -->
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>프로시저목록</h1>
<table class='detail' style='width:auto;'>
<%
if (arr!=null && arr.size()>0) {
  System.out.println(arr.size());
  Map<String, String> hRow = arr.remove(0);
  out.println("<thead><tr>");
  for (int i=1; i<=Integer.parseInt(hRow.get("COL_CNT")); i++) {
    out.println("<th>"+hRow.get(Integer.toString(i))+"</th>");
  }
  out.println("</tr></thead>");
  out.println("<tbody>");
  for (Map<String, String> row : arr) {
    out.println("<tr>");
    for (int i=1; i<=Integer.parseInt(hRow.get("COL_CNT")); i++) {
      String sp = row.get(hRow.get(Integer.toString(i)));
      if (i==1) {
        out.println("<td><a onclick='showProcedure(\""+sp+"\");'>"+sp+"</a></td>");
      } else out.println("<td>"+sp+"</td>");
    }
    out.println("</tr>");
  }
  out.println("</tbody>");
}
%>
</table>
