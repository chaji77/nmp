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
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>회원가입</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<style>
.login-box {
  padding:40px 45px;
  border-radius:10px; /* 150px 100px / 100px 150px; */
  /* background-color:rgba(47, 79, 79, 0.15); */
  min-height:160px;
}
ul.form-box {width:320px;margin-left:auto;margin-right:auto;}
ul.form-box li {text-align:center;padding: 10px 0;}
ul.form-box a.btn {padding:10px 25px;border-radius: 20px;}
ul.form-box input {text-align:center;border-radius:30px;border:5px solid #555;}
ul.step {height: 96px;}
ul.step li {display:none;padding:15px;}
@media only screen and (max-width:767px) {
  ul.form-box {font-size:1em;width:100%;border:0;padding:10px 0;}
}
</style>
<script type="text/javascript">
function check() {
  document.frmEnt.bizno.value = document.frmEnt.bizno.value.replace(/-/g, '');
  var is = isValidBusinessNumber(document.frmEnt.bizno.value);
  if (!is) {
    toast("올바른 사업자번호가 아닙니다.", 1000, function() {
      $("input[name='bizno']").focus();
    });
  }
  return is;
}
function goCheck() {
  <% if (!strCpyId.equals("0")) { %>
  toast('로그인되어 있습니다.<br/>진행할 수 없습니다.');
  return;
  <% } else { %>
  document.frmEnt.bizno.value = document.frmEnt.bizno.value.replace(/-/g, '');
  if (check()) {
    $.post("BizNoCheck.jsp", $("form[name='frmEnt']").serialize(), function(data){
      var cno = $.trim(data);
      if (cno!="Y") {
        document.frmEnt.bizno.value = cno;
        document.frmEnt.action = "RegistAgree.jsp";
        document.frmEnt.method = "post";
        document.frmEnt.target = "_self";
        document.frmEnt.submit();
      } else if (cno=="E") toast("사업자번호를 확인하십시오.");
      else showCustomConfirm("이미 가입되어 있습니다.<br/>로그인하시겠습니까?", function() {
        location.href = '<%=request.getContextPath()%>/web/Login.jsp';
      }, function() {});
    });
  }
  <% } %>
}
$(document).ready(function(){
  $("input[name='bizno']").focus();
  $("input[name='bizno']").keydown(function(key) {
    if (key.keyCode == 13) goCheck();
  });
  $("ul.step li").each(function(idx, item) {
    $(item).delay(500).slideDown(200*idx);
  });
  setTimeout(function(){
    $("ul.step li").eq(0).addClass("now");
    $("ul.step li").eq(1).addClass("now");
  }, 2000);
});
</script>

<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원가입</span>
  <span class='more'>
  </span>
</div>

<ul class='step'>
  <li><strong>STEP 1</strong><br/><br/>회원가입여부<br/>확인</li><li class='after'></li>
  <li><strong>STEP 2</strong><br/><br/>약관 및 개인정보<br/>처리방침 동의</li><li class='after'></li>
  <li><strong>STEP 3</strong><br/><br/>회원정보 입력</li><li class='after'></li>
  <li><strong>STEP 4</strong><br/><br/>회원가입 완료</li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<form name='frmEnt' autocomplete='off'>
<ul class='form-box login-box'>
  <li><strong style='font-size:1.4em;'>사업자번호</strong></li>
  <li><input type='text' name='bizno' maxlength='12' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='사업자번호 숫자 10자리' style='width:172px;padding:10px;'></li>
  <li><a onclick='goCheck();' class='btn darkred'>가입여부확인</a></li>
</ul>
</form>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %>