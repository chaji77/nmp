<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
// String strCpyId = "8063"; // TEST MODE
String strCpyId = (String)pageContext.getAttribute("CPY_ID"); // TEST MODE
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>조건변경서</title>
<script>
function go_view(applNo,seqNo,sellerName) {
    $("input[name='applNo']").val( applNo );
    $("input[name='seqNo']").val( seqNo );
    $("input[name='sellerName']").val( sellerName );
    document.frmSearch.action = "ConditionView.jsp";
    document.frmSearch.submit();
  }
function movePage(p) {
  document.frmSearch.pageNumber.value = p;
  showSpinner("데이터를 불러오고 있습니다.");
  $("#ResultSet").html("");
  $.post("https://w4.mp1.co.kr/guarantee_sys/yesb2b/secu_grt/kibo/grt_condition_buy_list_cross.jsp", $("form[name='frmSearch']").serialize(), function(data) {
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
  <span class='title'>조건변경서</span>
  <span class='more'>
  </span>
</div>

<form name='frmSearch' method='post'>
  <input type='hidden' name='pageNumber' value=''>
  <input type='hidden' name='sellerName' value=''>
  <input type='hidden' name='cpy_id' value='<%=StrUtil.nvl(strCpyId)%>'>
  <input type='hidden' name='applNo' value=''>
  <input type='hidden' name='seqNo'  value=''>
  
</form>

<div id='ResultSet'>

</div>

<%@ include file="../../includes/Footer.jsp" %>


