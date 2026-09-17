<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
//String strCpyId = "8063"; // TEST MODE
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>발급내용</title>
<script>

function movePage(p) {
  document.frmSearch.pageNumber.value = p;
  showSpinner("데이터를 불러오고 있습니다.");
  $("#ResultSet").html("");
  $.post("https://w4.mp1.co.kr/guarantee_sys/yesb2b/secu_grt/kodit/grt_limit_buy_issue_view_cross.jsp", $("form[name='frmSearch']").serialize(), function(data) {
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
  <span class='title'>발급내용</span>
  <span class='more'>
    <a onclick='history.go(-1);' class='btn'>목록</a>
  </span>
</div>

<form name='frmSearch'>
  <input type='hidden' name='pageNumber' value=''>
  <input type='hidden' name='applNO' value='<%=StrUtil.nvl(request.getParameter("applNO"))%>'>
  <input type='hidden' name='cpy_id' value='<%=StrUtil.nvl(strCpyId)%>'>
</form>

<div id='ResultSet'>

</div>

<%@ include file="../../includes/Footer.jsp" %>


