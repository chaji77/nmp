<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>거래내역</title>
<script>
function movePage(p) {
  document.frmSearch.pageNumber.value = p;
  showSpinner("데이터를 불러오고 있습니다.");
  $("#ResultSet").html("");
  $.post("https://w4.mp1.co.kr/guarantee_sys/yesb2b/secu_grt/kibo/grt_limit_buy_view_cross.jsp", $("form[name='frmSearch']").serialize(), function(data) {
    $("#ResultSet").html(data);
    hideSpinner();
  });
}
$(document).ready(function(){
  movePage(1);
});
</script>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>
<%@ include file="tab.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래내역</span>
  <span class='more'>
  </span>
</div>

<form name='frmSearch'>
  <input type='hidden' name='pageNumber' value=''>
  <input type='hidden' name='grtno' value='<%=StrUtil.nvl(request.getParameter("grtno"))%>'>
  <input type='hidden' name='strdate' value='<%=StrUtil.nvl(request.getParameter("strdate"))%>'>
  <input type='hidden' name='enddate' value='<%=StrUtil.nvl(request.getParameter("enddate"))%>'>
</form>

<div id='ResultSet'>

</div>

<%@ include file="../../includes/Footer.jsp" %>


