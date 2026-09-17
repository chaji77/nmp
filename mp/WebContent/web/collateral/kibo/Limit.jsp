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
<title>보증서/한도관리</title>
<script>

function movePage(p) {
  showSpinner("데이터를 불러오고 있습니다.<br/>많은 시간이 소요될 수 있습니다.");
  $("#ResultSet").html("");
  $.post("https://w4.mp1.co.kr/guarantee_sys/yesb2b/secu_grt/kibo/grt_limit_buy_list_cross.jsp?cpy_id=<%=strCpyId%>&pageNumber="+p, {}, function(data) {
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
  <span class='title'>보증서/한도관리</span>
  <span class='more'>
  </span>
</div>

<div id='ResultSet'>

</div>

<%@ include file="../../includes/Footer.jsp" %>