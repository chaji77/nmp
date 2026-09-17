<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.common.*" %>
<%
ArrayList<CodeVO> arr = CodeBean.C_CODE_LIST_PROC();
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>common codes</title>
<!-- // page head block -->
<style>
th {text-align:left;}
h1 {margin-bottom:30px;}
div.et {color:darkred;font-size:1.1em;font-weight:bold;line-height:1.4em;margin-bottom: 10px;}
</style>
<!-- // page head block -->
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>공통코드</h1>

<table class='detail' style='width:auto;'>
<thead>
  <tr>
    <th>코드그룹</th>
    <th>코드</th>
    <th>명칭</th>
  </tr>
</thead>
<tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CodeVO v : arr) {
%>
  <tr>
    <td><%=v.CODE_GRP_CD %></td>
    <td><%=v.CODE_CD %></td>
    <td><%=v.CODE_NM %></td>
  </tr>
<%
  }
}
%>
  <tr>
</tbody>
</table>


</body>
</html>