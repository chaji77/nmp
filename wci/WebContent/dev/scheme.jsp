<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.devtool.DevDAO" %>
<%
ArrayList<Map<String, String>> arr = DevDAO.getScheme("EXEC DBO.DEV_COLUMNS_PROC;");
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>테이블정의서</title>
<style>
th {text-align:left;}
</style>
<!-- // page head block -->
<style>
h1 {margin-bottom:30px;}
</style>
<!-- // page head block -->
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>테이블정의서</h1>
<table class='detail' style='width:auto;'>
<%
if (arr!=null && arr.size()>0) {
  System.out.println(arr.size());
  Map<String, String> hRow = arr.remove(0);
  out.println("<tbody>");
  String strTableName = "";
  for (Map<String, String> row : arr) {
    if (!strTableName.equals(row.get("TABLE_NAME"))) {
      strTableName = row.get("TABLE_NAME");
      out.println("<tr><th colspan='3' style='background-color:#fee;'>"+strTableName+"</th><th colspan='3' style='background-color:white;'>"+row.get("TABLE_DESCRIPTION")+"</th></tr>");
      out.println("<tr>");
      for (int i=3; i<Integer.parseInt(hRow.get("COL_CNT")); i++) {
        out.println("<th>"+hRow.get(Integer.toString(i))+"</th>");
      }
      out.println("</tr>");
    }
    out.println("<tr>");
    for (int i=3; i<Integer.parseInt(hRow.get("COL_CNT")); i++) {
      out.println("<td>"+row.get(hRow.get(Integer.toString(i)))+"</td>");
    }
    out.println("</tr>");
  }
  out.println("</tbody>");
}
%>
</table>
