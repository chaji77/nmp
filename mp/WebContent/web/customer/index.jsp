<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>고객센터</title>
<style>
div.footer-nav {margin-top:0;}
main {min-height:1200px;background:url('');background-size: contain;background-repeat: no-repeat;background-position:bottom;}

div.searchbox {text-align:center;background-color:transparent;margin-bottom:20px;}
div.searchbox input {width:170px;border-radius:20px 0 0 20px;padding:20px;border:3px solid #555;border-right:0;background-color:transparent;vertical-align:top;}
div.searchbox i.fa {font-size:2em;vertical-align:top;cursor:pointer;color:#555;padding:7px;border-radius:0 20px 20px 0;border:3px solid #555;border-left:0;}

ul.direct-links {clear:both;display:flex;flex-flow:row wrap;justify-content:center;}
ul.direct-links>li {position:relative;width:96px;margin:5px;padding:0px 40px 30px 40px;text-align:center;transition:color .2s ease-in-out;border:3px solid #ddd;background-color:#fff;border-radius:20px;transition:border-radius .6s ease-in-out;}
ul.direct-links>li:hover {border-radius:0px;background-color:#fafafa;}
ul.direct-links>li i {font-size:4em;line-height:1.6em;margin-top:21px;transition:font-size .3s, margin-top .3s;}
ul.direct-links>li>a:hover {color:#246CEB;}
ul.direct-links>li i:hover {font-size:5em;margin-top:0;}
@media only screen and (max-width:767px) {
  ul.direct-links>li {width:76px;font-size:0.9em;}
  ul.direct-links>li i {font-size:3em;}
}
</style>
<script>
function search() {
  document.frmSearch.cat.value  = 0;
  document.frmSearch.action = "<%=request.getContextPath()%>/web/customer/faq/index.jsp";
  document.frmSearch.submit();
}
$(document).ready(function(){
  $("input[name='searchWord']").keydown(function(key) {
    if (key.keyCode == 13) search();
  });
  $("input[name='searchWord']").focus();
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div style='margin-top:240px;margin-bottom:80px;text-align:center;font-size:2em;font-weight:bold;'>도움이 필요하세요?</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='1'>
<input type='hidden' name='cat' value='0'>
<div class='searchbox'>
  <input type='search' name='searchWord' value='' maxlength='10' placeholder='검색어'><i class="fa fa-search" aria-hidden="true" onclick='javascript:search();'></i>
</div>
</form>

<div style='margin-top:30px;max-width:1100px;margin-left:auto;margin-right:auto;'>
<ul class='direct-links'>
  <li><a href='<%=request.getContextPath()%>/web/customer/faq/'><i class="fa-solid fa-person-circle-question"></i><br/>자주 묻는 질문을 모았어요</a></li>
  <li><a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><i class="fa-solid fa-square-phone"></i><br/>전화상담<br/><strong><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></strong></a></li>
  <li><a href='<%=request.getContextPath()%>/web/customer/guide/Sales.jsp'><i class="fa-solid fa-face-grin-hearts"></i><br/>영업담당자와<br/>상의해보세요</a></li>
  <li class='mobile_hide'><a href="<%=ConfigurationMgr.getInstance().getString("REMOTE_SUPPORT_URL") %>" target="_blank"><i class="fa-solid fa-desktop"></i><br/>원격지원을 받아보세요</a></li>
  <li><a href='<%=request.getContextPath()%>/web/customer/qna/index.jsp'><i class="fa-solid fa-comments"></i><br/>1:1 문의를 남길 수 있어요</a></li>
</ul>
<div style='text-align:center;padding:70px 0 30px 0;font-weight:bold;font-size:1.6em;'>미리 알아두고 준비하면 편해요</div>
<ul class='direct-links'>
  <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/guide/Service.jsp'><i class="fa-solid fa-book"></i><br/>서비스 이해하기</a></li>
  <li><a href='<%=request.getContextPath()%>/web/customer/guide/BankWorkTime.jsp'><i class="fa-solid fa-clock"></i><br/>인터넷뱅킹시간 미리 확인</a></li>
  <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/download/Downloads.jsp'><i class="fa-solid fa-cloud-arrow-down"></i><br/>필수 프로그램<br/>다운로드</a></li>
  <li class='mobile_hide'><a href='<%=request.getContextPath()%>/web/customer/download/Sign.jsp'><i class="fa-solid fa-address-card"></i><br/>인증서 테스트</a></li>
  <li><a href='<%=request.getContextPath()%>/web/customer/notice/Notices.jsp'><i class="fa-solid fa-chalkboard"></i><br/>새로운 소식</a></li>
</ul>
</div>

<%@ include file="../includes/Footer.jsp" %>