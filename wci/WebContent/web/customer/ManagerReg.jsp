<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

String strPrsId    = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("pid")));
if (!StrUtil.isOnlyNumeric(strPrsId)) return;

CustomerBean bean = new CustomerBean();
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
PersonVO pvo = new PersonVO();
pvo.PRS_ID = "0";
String strBtnName = "등록";
if (arrPersons!=null || arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
    if (v.PRS_ID.equals(strPrsId)) {
      pvo = v;
      strBtnName = "수정";
    }
  }
}
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>계정 <%=strBtnName %></title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
span.bullet i {vertical-align:middle;font-size:3em;color:hotpink;margin-right:10px;}
span.alert {text-align:justify;padding-top:10px;}
@media only screen and (max-width:767px) {
  span.alert {padding-top:0;}
}
</style>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script>
function check() {
  <% if (pvo.PRS_ID.equals("0")) { %>
  if (document.frmEnt.checkDuplicated.value!="Y") {
    toast("아이디의 중복확인이 필요합니다.", 1000, function(){
      document.frmEnt.login_id.focus();
    });
    return false;
  }
  if (!isValidLoginId($("input[name='login_id']").val())) {
   toast("아이디는 영문자와 숫자 6~15자이어야 합니다.");
   $("input[name='login_id']").focus();
   return false;
  }
  if (!isValidLoginPw($("input[name='login_pw']").val())) {
    toast("비밀번호는 영문자와 숫자, 특수문자를 조합한 6~15자이어야 합니다.");
    $("input[name='login_pw']").focus();
    return false;
  }	
  <% } %>
  if (!validate("input[name='login_nm']", "length", [2,10], "담당자명을 입력하십시오.")) return false;
  if (!validate("input[name='login_cell_tel']", "length", [9,14], "휴대전화번호를 입력하십시오.")) return false;
  if ($.trim($("input[name='login_email']").val()).length > 0) {
    if (!isValidEmail(document.frmEnt.login_email.value)) {
      toast("올바른 메일주소를 입력하십시오.");
      document.frmEnt.login_email.focus();
      return false;
    }
  }
  return true;
}
function isValidLoginId(input) { // 아이디유효성검사
  const sanitizedInput = input.replace(/\s+/g, '');
  const regex = /^[a-zA-Z0-9]{6,15}$/;
  return regex.test(sanitizedInput) ? sanitizedInput : false;
}
function isValidLoginPw(input) { // 비밀번호유효성검사
  const sanitizedInput = input.replace(/\s+/g, '');
  const regex = /[a-zA-Z0-9!@#$%^&*(),.?:{}|<>\\/\[\]\-_+=;~]{6,15}$/;
  return regex.test(sanitizedInput) ? sanitizedInput : false;
}
function togglePassword() { // 비밀번호 열람여부
  var t = ($("input[name='login_pw']").attr("type")=="password") ? "text" : "password";
  $("input[name='login_pw']").attr("type", t);
}
function checkDuplicated(){ // 아이디중복확인버튼 클릭 이벤트
  var cid = $("input[name='login_id']").val();
  if (!isValidLoginId(cid)) {
   toast("아이디는 영문자와 숫자 6~15자이어야 합니다.");
   $("input[name='login_id']").focus();
   return false;
  }
  $.post("LoginIdCheck.jsp", {"login_id":cid}, function(data){
    var cno = $.trim(data);
    if (cno="N") {
      $("input[name='login_id']").prop("readonly", true);
      $("input[name='login_pw']").focus();
      $("#login-id-duplicate-check-btn a").remove();
      $("#login-id-duplicate-check-btn").html("<i class='fa-solid fa-check' style='color:#0096c6;font-size:1.6em;line-height:0;'></i>");
      document.frmEnt.checkDuplicated.value = 'Y';
      return false;
    } else if (cpyid=="E") {
      toast("아이디를 확인하십시오.", 1000, function(){
        $("input[name='login_id']").focus();
        return false;
      });
    }
    else {
      toast("이미 가입된 아이디입니다.", 1000, function(){
        $("input[name='login_id']").focus();
        return false;
      });
    }
  });
  return false;
}
var btnSubmitIsClicked = false;
function goSubmit() {
  var is = false;
  if (check()) {
    if (!btnSubmitIsClicked) {
      btnSubmitIsClicked = true;
      $("input[id='file']").each(function(){ // for upload
        this.checked = true;
      });
      showLoading();
      document.frmEnt.method = "post";
      document.frmEnt.action = "ManagerRegProc.jsp";
      document.frmEnt.target = "work";
      document.frmEnt.submit();
    } else {
      toast("등록중입니다. 잠시만 기다려 주세요.");
    }
  }
}
function callback() {
  location.href = "Managers.jsp";
}

$(document).ready(function(){
  <% if (pvo.PRS_ID.equals("0")) { %>
  $("input[name='login_id'], input[name='login_pw']").on('keydown keyup', function (e) { // check CapsLock
    if (e.originalEvent.getModifierState && e.originalEvent.getModifierState('CapsLock')) $('#CapsWarning').show();
    else $('#CapsWarning').hide();
  }); 
  $("input[name='login_id']").on("keyup", function(){
    $("input[name='login_id']").val($("input[name='login_id']").val().replace(/\s+/g, '').replace(/[^a-zA-Z0-9]/g, ''));
  });
  $("input[name='login_id']").on("focusout", function(){
    checkDuplicated();
  });
  $("input[name='login_pw']").on("keyup", function(){
    $("input[name='login_pw']").val($("input[name='login_pw']").val().replace(/\s+/g, '').replace(/[^a-zA-Z0-9!@#$%^&*(),.?:{}|<>\\/\[\]\-_+=;~'"]/g, ''));
  });
  <% } %>	
  fillData();
});
function fillData() {
  $("input[name='prs_id']").val("<%=IntegerCryptoUtil.crypt(pvo.PRS_ID)%>");
  $("input[name='login_id']").val("<%=StrUtil.input(pvo.PRS_LOGIN) %>");
  $("input[name='login_pw']").val("<%=CryptoDESUtil.decrypt(pvo.PRS_PASSWD)%>");
  <% if (!pvo.PRS_ID.equals("0")) { %>
  $("input[name='login_id']").prop("readonly", true);
  $("#login-id-duplicate-check-btn").remove();
  <% } %>
  $("input[name='login_nm']").val("<%=StrUtil.input(pvo.PRS_NAME)%>");
  $("input[name='login_tel']").val("<%=StrUtil.input(pvo.PRS_TEL)%>");
  $("input[name='login_cell_tel']").val("<%=StrUtil.input(pvo.PRS_MOBILE_NO)%>");
  $("input[name='sms_yn']").prop("checked", true);
  $("input[name='login_email']").val("<%=StrUtil.input(pvo.PRS_EMAIL)%>");
}
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>계정 <%=strBtnName %></span>
  <span class='more'>
    <a href='Managers.jsp' class='btn'>목록</a>
  </span>
</div>

<form name='frmEnt' autocomplete="off">
<input type='hidden' name='prs_id'>
<input type='hidden' name='checkDuplicated' value='N'>
<ul class='form'>
  <li>
    <label>로그인아이디 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='login_id' value='' maxlength='15' style='width:140px;' placeholder='로그인아이디 (6~15자)' autocomplete="new-password" required>
    <span id='login-id-duplicate-check-btn'><a onclick='checkDuplicated();' class='btn'>중복확인</a></span>
  </li>
  <li>
    <label>비밀번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='password' name='login_pw' value='' maxlength='15' style='width:140px;' placeholder='비밀번호 (6~15자)' autocomplete="new-password" required> &nbsp; 
    <i id='login-pw-toggle' class="fa-solid fa-eye" style='font-size:1.6em;cursor:pointer;line-height:0;' onclick='togglePassword()'></i>
  </li>
  <li id='CapsWarning' class='wide hint' style='display:none;'><i class="fa-solid fa-triangle-exclamation" style='color:#FF5733;'></i> Caps Lock이 활성화되어 있습니다.</li>
  <li>
    <label>담당자명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='login_nm' value='' maxlength='20' placeholder='담당자명' required>
  </li>
  <li>
    <label>일반전화(내선포함)</label>
    <input type='tel' name='login_tel' value='' maxlength='24' placeholder='일반전화(내선포함)' required>
  </li>
  <li>
    <label>휴대전화번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='tel' name='login_cell_tel' value='' maxlength='13' placeholder='휴대전화번호' required style='margin-bottom:5px;'><br/>
    <input type='checkbox' name='sms_yn' value='1' class='space-label' checked style='vertical-align:middle;'>거래진행 안내 문자(SMS) 수신
  </li>
  <li>
    <label>메일주소</label>
    <input type='email' name='login_email' value='' maxlength='30' placeholder='메일주소' pattern='[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$'>
  </li>
</ul>
</form>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='btns'>
  <a onclick='goSubmit();'><%=strBtnName %></a>
  <a href='Managers.jsp' class='cancel'>취소</a>
</div>

<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>

<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %> 