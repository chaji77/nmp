<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.trade.AbnormalConfiguration" %>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>abnormaltransaction.properties</title>
<style>
h1 {margin-bottom:30px;}
div.et {color:darkred;font-size:1.1em;font-weight:bold;line-height:1.4em;margin-bottom: 10px;}
</style>
<!-- // page head block -->
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>abnormaltransaction.properties</h1>

<table class='detail' style='width:auto;'>
<thead>
  <tr>
    <th class='left'>키</th>
    <th class='left'>값</th>
  </tr>
</thead>
<tbody>
<%=AbnormalConfiguration.getInstance().showPropertiesForWeb() %>
</tbody>
</table>


</body>
</html>