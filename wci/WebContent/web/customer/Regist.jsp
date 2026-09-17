<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
String strBizNo = StrUtil.nvl(request.getParameter("bizno"));

String referer = request.getHeader( "REFERER");
String strErrorReturn = "<script>alert('사업자번호를 확인할 수 없습니다. 다시 시작하십시오.');location.href='"+request.getContextPath()+"/web/customer/Registration.jsp';</script>";
if (!IntegerCryptoUtil.isEncrypted(strBizNo)) {
  out.println(strErrorReturn);
  return;
}
if(referer == null || referer.length()==0 || !referer.contains("/web/customer/Regist")) {
  out.println(strErrorReturn);
  return;
}

%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>회원가입</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
ul.step {height: 96px;}
ul.step li {display:none;padding:15px;}

#ul_attached_files>li {width:100%;}
#ul_attached_files>li>input[type='checkbox'] {width:0;height:0;}
#ul_attached_files>li>a {display:inline-block;max-width:calc(100% - 180px);overflow:hidden;white-space:nowrap;text-overflow:ellipsis;vertical-align:middle;}
#ul_attached_files>li>i {display:inline-block;}
</style>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/uploader.js?<%=DateTimeUtil.getCurrentResourceVersion() %>1"></script>
<script>
var oFiles;
var urlUpload = "UploadFileProc.jsp";
var urlDragDrop = "DragUploadFileProc.jsp";

function check() {
  if (!validate("input[name='cpy_nm']", "length", [2,30], "회사명을 입력하십시오.")) return false;
  if (!validate("input[name='cpy_ceo_nm']", "length", [2,30], "대표자명을 입력하십시오.")) return false;
  if ($("input[name='biz_type']:checked").val()==1) { // 법인사업자번호
    $("input[name='cpy_no']").val($("input[name='cpy_no']").val().replace(/-/g, ''));
    if (!validate("input[name='cpy_no']", "length", [13], "법인등록번호를 입력하십시오.")) return false;
  }
  if (!validate("input[name='uptae']", "length", [2,100], "업태를 입력하십시오.")) return false;
  if (!validate("input[name='upzong']", "length", [2,100], "종목을 입력하십시오.")) return false;
  if (!validate("input[name='basic_zipcode']", "length", [5], "주소를 입력하십시오.")) return false;
  if (!validate("input[name='basic_addr_b']", "length", [2, 100], "주소를 입력하십시오.")) return false;
  if (!validate("input[name='desc']", "length", [2,100], "간단한 기업설명을 입력하십시오.")) return false;
  if (!validate("input[name='found_ymd']", "length", [10], "설립일을 입력하십시오.")) return false;
  
  $("input[name='sale_amt']").val($("input[name='sale_amt']").val().replace(/[^0-9]/g, ""));
  
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
  
  if (!validate("input[name='login_nm']", "length", [2,10], "담당자명을 입력하십시오.")) return false;
  if (!validate("input[name='login_cell_tel']", "length", [9,14], "휴대전화번호를 입력하십시오.")) return false;
  if ($.trim($("input[name='login_email']").val()).length > 0) {
    if (!isValidEmail(document.frmEnt.login_email.value)) {
      toast("올바른 메일주소를 입력하십시오.");
      document.frmEnt.login_email.focus();
      return false;
    }
  }
  if (!isValidEmail(document.frmEnt.tax_email.value)) {
    toast("올바른 메일주소를 입력하십시오.");
    document.frmEnt.tax_email.focus();
    return false;
  }
  return true;
}

var btnSubmitIsClicked = false;
function goSubmit() {
  <% if (!strCpyId.equals("0")) { %>
  toast('로그인되어 있습니다.<br/>진행할 수 없습니다.');
  return;
  <% } else { %>
  var is = false;
  if (check()) {
    if (!btnSubmitIsClicked) {
      btnSubmitIsClicked = true;
      $("input[id='file']").each(function(){ // for upload
        this.checked = true;
      });
      showLoading();
      document.frmEnt.method = "post";
      document.frmEnt.action = "RegistProc.jsp";
      document.frmEnt.target = "work";
      document.frmEnt.submit();
    } else {
      toast("등록중입니다. 잠시만 기다려 주세요.");
    }
  }
  <% } %>
}
function callback() {
  location.href = "RegistComplete.jsp";
}
var strTemporaryCpyNo = "";
function cpy_no_open(o) { //법인사업자가 아니면 법인번호입력을 제한
  $("input[name='cpy_no']").prop("readonly", o);
  if (o) {
    strTemporaryCpyNo = $("input[name='cpy_no']").val();
    $("input[name='cpy_no']").val("");
  }
  else $("input[name='cpy_no']").val(strTemporaryCpyNo);
}
function toggleHint() { // 전년도매출액의 기입방법
  var is = $(".hint").is(":visible");
  if (!is) $(".hint").slideDown();
  else $(".hint").slideUp();
}
function searchAddr(tgt) { // 우편번호검색
  new daum.Postcode({
    oncomplete: function(data) {
      var fullRoadAddr = data.roadAddress;
      var extraRoadAddr = '';
      if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)) extraRoadAddr += data.bname;
      if(data.buildingName !== '' && data.apartment === 'Y') extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
      if(extraRoadAddr !== '') extraRoadAddr = ' (' + extraRoadAddr + ')';
      if(fullRoadAddr !== '') fullRoadAddr += extraRoadAddr;

      $("input[name='"+tgt+"_zipcode']").val(data.zonecode);
      $("input[name='"+tgt+"_addr']").val(fullRoadAddr);
      $("input[name='"+tgt+"_addr_b']").focus();
    }
  }).open();
}
function uploadBizDoc() { // 사업자등록증업로드버튼 클릭 이벤트
  if ($("#ul_attached_files li").length>0) {
    showCustomConfirm("첨부된 파일이 있습니다. 삭제 후 첨부하시겠습니까?", function() {
      $("#ul_attached_files li").remove();
      $("input[name='file_bizdoc']").val("");
      $("input[name='file_bizdoc']").click();
    });
  } else {
    $("input[name='file_bizdoc']").val("");
    $("input[name='file_bizdoc']").click();
  }
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
    if (cno=="N") {
      $("input[name='login_id']").prop("readonly", true);
      $("input[name='login_pw']").focus();
      $("#login-id-duplicate-check-btn a").remove();
      $("#login-id-duplicate-check-btn").html("<i class='fa-solid fa-check' style='color:#0096c6;font-size:1.6em;line-height:0;'></i>");
      document.frmEnt.checkDuplicated.value = 'Y';
      return false;
    } else if (cno=="E") {
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
function copyToInvoicer(obj) {
  if ($(obj).is(":checked")) {
    $("input[name='tax_nm']").val($("input[name='login_nm']").val());
    $("input[name='tax_email']").val($("input[name='login_email']").val());
    $("input[name='login_nm'], input[name='login_email']").prop("readonly", true);
  } else {
    $("input[name='login_nm'], input[name='login_email']").prop("readonly", false);
  }
}
function maxLengthCheck(object){
  if (object.value.length > object.maxLength) {
    object.value = object.value.slice(0, object.maxLength);
  }
}
$(document).ready(function(){
  initUploadForm(urlUpload, urlDragDrop, oFiles); // for upload	

  $("input[name='login_id'], input[name='login_pw']").on('keydown keyup', function (e) { // check CapsLock
    if (e.originalEvent.getModifierState && e.originalEvent.getModifierState('CapsLock')) $('#CapsWarning').show();
    else $('#CapsWarning').hide();
  }); 
  $("input[name='login_id']").on("keyup", function(){
    $("input[name='login_id']").val($("input[name='login_id']").val().replace(/\s+/g, '').replace(/[^a-zA-Z0-9]/g, ''));
  });
  $("input[name='login_pw']").on("keyup", function(){
    $("input[name='login_pw']").val($("input[name='login_pw']").val().replace(/\s+/g, '').replace(/[^a-zA-Z0-9!@#$%^&*(),.?:{}|<>\\/\[\]\-_+=;~'"]/g, ''));
  });
  
  const today = new Date().toISOString().split('T')[0]; 
  $("input[name='found_ymd']").attr('max', today);
  $("input[name='found_ymd']").keydown(function(e) {
    const forbiddenKeys = ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight','0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    if (forbiddenKeys.includes(e.key)) {
      e.preventDefault();
    }
  });
  
  $("ul.step li").each(function(idx, item) {
    $(item).slideDown(200*idx);
  });
  setTimeout(function(){
    $("ul.step li").eq(4).addClass("now");
    $("ul.step li").eq(5).addClass("now");
  }, 1000);

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
  <li><strong>STEP 2</strong><br/><br/>약관 및 개인정보처리방침 동의</li><li class='after'></li>
  <li><strong>STEP 3</strong><br/><br/>회원정보 입력</li><li class='after'></li>
  <li><strong>STEP 4</strong><br/><br/>회원가입 완료</li>
</ul>

<form name='frmEnt' autocomplete="off">
<input type='file' name='file_bizdoc' value='' onChange='uploadOneFile(event);' style='width:0;height:0;margin:0;padding:0;border:0;'>
<input type='hidden' name='checkDuplicated' value='N'>
<input type='hidden' name='cpy_id' value='0'>
<h3>기본 정보</h3>
<ul class='form'>
  <li>
    <label>사업자등록번호</label>
    <input type='text' name='bizno' value='<%=FormatUtil.addDashBizNo(IntegerCryptoUtil.crypt(strBizNo)) %>' readOnly>
  </li>
  <li>
    <label>회사명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_nm' value='' maxlength='30' placeholder='사업자등록증상의 회사명' required>
  </li>
  <li class='not-has-input'>
    <label>회사구분 <i class="fa-solid fa-asterisk"></i></label>
    <input type='radio' name='cpy_type' value='1' checked>구매
    <input type='radio' name='cpy_type' value='2'>판매
    <input type='radio' name='cpy_type' value='3'>구매&amp;판매
  </li>
  <li>
    <label>대표자명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_ceo_nm' value='' maxlength='30' placeholder='사업자등록증상의 대표자명' required>
  </li>
  <li class='not-has-input'>
    <label>기업형태 <i class="fa-solid fa-asterisk"></i></label>
    <input type='radio' name='biz_type' value='1' checked onclick='cpy_no_open(false);'> 법인사업자
    <input type='radio' name='biz_type' value='2' onclick='cpy_no_open(true);'> 개인사업자
  </li>
  <li>
    <label>법인등록번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='cpy_no' value='' maxlength='14' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='법인등록번호'>
  </li>
  <li>
    <label>업태 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='uptae' value='' maxlength='100' placeholder='사업자등록증상의 업태' required>
  </li>
  <li>
    <label>종목 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='upzong' value='' maxlength='100' placeholder='사업자등록증상의 종목' required>
  </li>
  <li class='wide'>
    <label>주소 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='basic_zipcode' style='width:120px;' readonly onclick='searchAddr("basic");'> <a onclick='searchAddr("basic");' class='btn'>검색</a><br/>
    <input type='text' name='basic_addr' value='' maxlength='200' placeholder='사업자등록증상의 주소' required class='space-label-1' style='margin-top:3px;' readonly onclick='searchAddr("basic");'><br/>
    <input type='text' name='basic_addr_b' value='' maxlength='200' placeholder='상세주소' required class='space-label-1' style='margin-top:3px;'>
  </li>
  <li class='not-has-input'>
    <label>파일첨부</label>
    <a onclick='uploadBizDoc();' class='btn lurian'>사업자등록증 업로드</a><br/>
    <ul id='ul_attached_files' class='space-label' style='width:100%;margin-top:14px;margin-bottom:0;'></ul>
  </li>
  <li>
    <label>팩스번호</label>
    <input type='text' name='fax' value='' maxlength='13' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='팩스번호'>
  </li>
  <li class='wide'>
    <label>기업설명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='desc' value='' maxlength='100' placeholder='간단한 기업설명 (100자 이내)' required>
  </li>
  <li>
    <label>설립일 <i class="fa-solid fa-asterisk"></i></label>
    <input type='date' name='found_ymd' value='' maxlength='10' style='width:100px;' placeholder='설립일' required>
  </li>
  <li>
    <label>전년도매출액 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='sale_amt' value='0' maxlength='9' pattern="[0-9]+" onkeypress='return checkNumber(event)' oninput='maxLengthCheck(this);' style='width:100px;' placeholder='전년도매출액 (백만원)' required> 백만원 <a onclick='toggleHint();' class='circle'>?</a>
    <div class='hint'>신설기업인 경우 매출액 0백만원 입력 (회원가입 후 최초 도래하는 결산 월 경과시 매출액을 반드시 등록해 주십시오)</div>
  </li>
  <li class='wide space-label' style='font-size:0.9em;color:#888;text-align:justify;'><i class="fa-solid fa-circle-info" style='vertical-align:middle;'></i> 설립일과 전년도 매출액은 보증기금 이상 거래 모니터링의 근거자료로 활용됩니다.</li>
</ul>

<h3>실무담당자 정보</h3>
<ul class='form'>
  <li>
    <label>로그인아이디 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='login_id' value='' maxlength='15' style='width:100px;' placeholder='로그인아이디 (6~15자)' autocomplete="off" required>
    <span id='login-id-duplicate-check-btn'><a onclick='checkDuplicated();' class='btn'>중복확인</a></span>
  </li>
  <li>
    <label>비밀번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='password' name='login_pw' value='' maxlength='15' style='width:100px;' placeholder='비밀번호 (6~15자)' autocomplete="new-password" required> &nbsp; 
    <i class="fa-solid fa-eye" style='font-size:1.6em;cursor:pointer;line-height:0;' onclick='togglePassword()'></i>
  </li>
  <li id='CapsWarning' class='wide hint' style='display:none;'><i class="fa-solid fa-triangle-exclamation" style='color:#FF5733;'></i> Caps Lock이 활성화되어 있습니다.</li>
  <li>
    <label>담당자명 <i class="fa-solid fa-asterisk"></i></label>
    <input type='text' name='login_nm' value='' maxlength='10' placeholder='담당자명' required>
  </li>
  <li>
    <label>일반전화(내선포함)</label>
    <input type='tel' name='login_tel' value='' maxlength='24' placeholder='일반전화(내선포함)' required>
  </li>
  <li>
    <label>휴대전화번호 <i class="fa-solid fa-asterisk"></i></label>
    <input type='tel' name='login_cell_tel' value='' maxlength='13' placeholder='휴대전화번호' required style='margin-bottom:5px;'><br/>
    <input type='checkbox' name='sms_yn' value='1' checked class='space-label-1' style='vertical-align:middle;'>거래진행 안내 문자(SMS) 수신
  </li>
  <li>
    <label>메일주소</label>
    <input type='email' name='login_email' value='' maxlength='30' placeholder='메일주소' pattern='[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$'>
  </li>
</ul>



<ul class='form'>
  <li><h3>MP수수료 세금계산서 정보</h3></li>
  <li class='block-title-aside' style='text-align:right;'><input type='checkbox' onclick='copyToInvoicer(this);'> 실무담당자 정보와 동일</li>
  <li>
    <label>수신담당자</label>
    <input type='text' name='tax_nm' value='' maxlength='20' placeholder='담당자명'>
  </li>
  <li>
    <label>수신메일 <i class="fa-solid fa-asterisk"></i></label>
    <input type='email' name='tax_email' value='' maxlength='30' placeholder='수신메일' pattern='[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' required>
  </li>
</ul>

</form>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='btns'><a onclick='goSubmit();'>등록</a></div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %>