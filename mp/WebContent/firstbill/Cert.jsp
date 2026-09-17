<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
if (strUserSeq.equals("0")) {
  response.sendRedirect("index.jsp");
  return;
}
%>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>인증서관리-처음빌</title>
<style>
.ul-body li {margin-bottom:16px;}
</style>
<script>
$(function(){ 
  $.ajax({
    url: 'CertInc.jsp',
    async: true,
    type: 'POST', 
    data: {}, 
    dataType: 'html', 
    beforeSend: function(jqXHR) {
      showSpinner("인증서 정보를<br/>불러오고 있습니다.");
    },
    success: function(data) {
      $(".ul-body").html(data);
    }, 
    error: function(jqXHR) {}, 
    complete: function(jqXHR) {
      hideSpinner();
    }
  });

});
</script>
<!-- // page head block -->
<%@ include file="Navigation.jsp" %>

    <div class='page-title-block'>
      <span class='title'>인증서관리</span>
      <span class='more'>
      </span>
    </div>
    
    <ul class='ul-body'>

    </ul>

<%@ include file="../web/includes/Footer.jsp" %>