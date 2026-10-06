<%@ page contentType="text/html;charset=utf-8"%>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>거래 상세관리</title>
<style>
/* 넓은 화면에서만 본문 폭을 60% 로 줄인다. 모바일은 style.css 기본값 유지. */
@media only screen and (min-width:1101px) {
  main {width:60%;margin-left:auto;margin-right:auto;padding-left:0;padding-right:0;}
}
table.detail {font-size:110%;}
table.detail td {line-height:1.7em;vertical-align:top;}
table.detail tr.sum td {font-weight:bold;color:#c00;}
table.summary th {background:#f3f3f3;}
table.summary a {text-decoration:underline;}
h3 {margin-top:25px;}
</style>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래 상세관리</span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<%@ include file="./CyclnOrderDetailInc.jsp" %>
<%@ include file="../Footer.jsp" %>
