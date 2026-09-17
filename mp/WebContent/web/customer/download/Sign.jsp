<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>전자서명도구 설치확인</title>
<style>
#element_to_pop_up {
    background-color:transparent;
    border-radius:15px;
    color:#000;
    display:none;
    padding:0px;
    padding-right:10px;
    min-width:400px;
    min-height: 180px;
    width:auto;
    height:auto;
}
.b-close{
    cursor:pointer;
    position:absolute;
    right:10px;
    top:5px;
}
#ifrm_cert {width:500px;height:650px;border:0;}
#result-msg i {font-size:8em;margin-bottom:20px;}
</style>

<script src="<%=request.getContextPath() %>/static/js/pop.js" type="text/javascript"></script>
<script>
/* 팝업창 감추기 */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  // $("#element_to_pop_up").empty();
}
/* 전자서명창 호출 */
function loadCert() {
  var url = '<%=request.getContextPath()%>/static/programs/cert/?ssn='+$("#SSN").val();
  console.log(url);
  $("#signdata").val("");
  $('#ifrm_cert').attr('src', url);
  $('#element_to_pop_up').bPopup({});
  document.getElementById("ifrm_cert").contentWindow.postMessage("CALL", "*");
  $("#result-msg").text("");
}
/* 전자서명창에서 호출 */
window.addEventListener("message", function(e) {
  $("#sgn_id").val("");
  $("#signdata").val("");
  if (e.data=="CLOSE") { // 취소버튼클릭
    $('#element_to_pop_up').bPopup().close();
    document.getElementById("progress").style.display = 'none';
    return;
  } else if (e.data=="CLOSE_FAIL_SSN") { // 사업자번호불일치
    $('#element_to_pop_up').bPopup().close();
    $("#result-msg").html("<i class='fa-solid fa-thumbs-up'></i><br/>전자서명도구가 성공적으로 설치되어 있습니다.");
    return;
  }
  if (e.data.length>30) { // 결과값정상수신
    $("#sgn_id").val("0000");
    var k = (e.data.split("$data")[0]).replace("$dn=", "");
    $("#signdata").val(k);
    $('#element_to_pop_up').bPopup().close();
    $("#result-msg").html("<i class='fa-solid fa-thumbs-up'></i><br/>전자서명도구가 성공적으로 설치되어 있습니다.");
  }
  return;
});
$(document).ready(function() {
  loadCert();
});
</script>
<!-- ****************************************************** 전자서명 *********************************************************** -->

<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>전자서명도구 설치확인</span>
</div>

<div id='result-msg' style='text-align:center;margin-top:150px;margin-bottom:50px;'>aaa</div>
<div class='btns'><a onclick='loadCert();' class='btn'>재실행</a></div>

<input type="hidden" id="SSN" name="SSN" value='6078621116'><!-- 검증할 사업자번호 -->
<input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
<input type='hidden' id='signdata' name='signdata'><!-- 결과값 -->

<div id="element_to_pop_up"><iframe id='ifrm_cert'></iframe></div><!-- 전자서명호출팝업창 -->

<%@ include file="../../includes/Footer.jsp" %>



