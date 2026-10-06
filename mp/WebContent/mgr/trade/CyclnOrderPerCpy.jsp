<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

// 회원정보 안에서 보는 거래 상세. 상단에 회사정보(CompanyHeader)를 띄운다.
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(strCpyId));
else return;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>싸이클론거래 상세</title>
<style>
/* style.css 의 main>div 가 float:left 라 그대로 두면 가운데로 안 가고 푸터가 본문 위로 올라온다. */
.order-detail {float:none;}
/* 회사정보는 전체폭으로 두고 상세 본문만 좁힌다. 모바일은 전체폭 그대로. */
@media only screen and (min-width:1101px) {
  .order-detail {width:60%;margin-left:auto;margin-right:auto;}
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
  <span class='title'>싸이클론거래 상세</span>
  <span class='more'>
    <a href='CyclnOrdersPerCpy.jsp?cpy_id=<%=strCpyId%>' class='btn'>목록</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="12" />
</jsp:include>

<div class='order-detail'>
<%@ include file="./CyclnOrderDetailInc.jsp" %>
</div>
<%@ include file="../Footer.jsp" %>
