<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.GlobalEnv" %>
<%
ArrayList<String> arrPaths = new ArrayList<>();
arrPaths.add("web/");
arrPaths.add("web/customer/");
arrPaths.add("web/trade/");
arrPaths.add("static/");
arrPaths.add("mgr/customer/");
arrPaths.add("mgr/trade/");
arrPaths.add("mgr/mpfee/");
arrPaths.add("firstbill/");

StringBuffer sb = new StringBuffer();
for (String path : arrPaths) {
	String s = StrUtil.fileToString(GlobalEnv.getWebRootDir() + path, "readme.htm");
	if (s.contains("<tbody>")) s = s.split("<tbody>")[1];
	if (s.contains("</tbody>")) s = s.split("</tbody>")[0];
	sb.append(s);
}

%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>프로그램목록</title>
<style>
th {text-align:left;}
</style>
<!-- // page head block -->
<style>
h1 {margin-bottom:30px;}
div.et {color:darkred;font-size:1.1em;font-weight:bold;line-height:1.4em;margin-bottom: 10px;}
</style>
<!-- // page head block -->
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>프로그램목록</h1>

<table class='detail' style='width:auto;'>
<thead>
  <tr><th>경로</th><th>파일명</th><th>분류</th><th>설명</th></tr>
</thead>
<tbody>
  <%=sb.toString()%>
</tbody>
</table>


</body>
</html>