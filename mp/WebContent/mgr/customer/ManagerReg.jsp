<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.c.PersonVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = StrUtil.nvl(request.getParameter("cid"));
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

String strPrsId    = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("pid")));

CustomerBean bean = new CustomerBean();
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
PersonVO pvo = new PersonVO();
if (arrPersons!=null || arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
    if (v.PRS_ID.equals(strPrsId)) {
      pvo = v;
    }
  }
}
%>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<style>
</style>
<script type="text/javascript">
function togglePassword() { // 비밀번호 열람여부
  var t = ($("input[name='login_pw']").attr("type")=="password") ? "text" : "password";
  $("input[name='login_pw']").attr("type", t);
}
function formatPhoneNumber(input) {
  var phoneNumber = input.value.replace(/\D/g, '')
  if (phoneNumber.length < 4) {
    input.value = phoneNumber;
  } else if (phoneNumber.length < 7) {
	input.value = phoneNumber.replace(/(\d{3})(\d{0,4})/, '$1-$2');
  } else {
    if (phoneNumber.length === 10) {
	  input.value = phoneNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
	} else {
	  input.value = phoneNumber.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
	}
  }
}
$(document).ready(function(){
  $("input[name='login_id'], input[name='login_pw']").on('keydown keyup', function (e) { // check CapsLock
    if (e.originalEvent.getModifierState && e.originalEvent.getModifierState('CapsLock')) $('#CapsWarning').show();
    else $('#CapsWarning').hide();
  }); 
});
</script>

<h3>추가담당자 수정</h3>
<form name='frmManager'>
<input type='hidden' name='pid' value='<%=pvo.PRS_ID%>'>
<input type='hidden' name='cid' value='<%=strCpyId%>'>
<ul class='form'> 
  <li>
    <label>성명</label>
    <input name='prs_name' value='<%=pvo.PRS_NAME%>'></input>
  </li>
  <li>
    <label>일반전화</label>
    <input type='tel' name='tel' id='tel' value='<%=pvo.PRS_TEL%>'>
  </li>
  <li>
    <label>로그인 ID</label>
    <input type='text' name='login_id' value='<%=pvo.PRS_LOGIN%>' readonly></input>
  </li>
  <li>
    <label>비밀번호</label>
    <input type='password' name='login_pw' style='width:165px;' value='<%=CryptoDESUtil.decrypt(pvo.PRS_PASSWD)%>' autocomplete="new-password"></input>
    <i id='login-pw-toggle' class="fa-solid fa-eye" style='font-size:1.6em;cursor:pointer;line-height:0;' onclick='togglePassword()'></i>
  </li>
  <li id='CapsWarning' class='wide hint' style='display:none;'><i class="fa-solid fa-triangle-exclamation" style='color:#FF5733;'></i> Caps Lock이 활성화되어 있습니다.</li>
  <li>
    <label>이메일</label>
    <input type='email' name='email' value='<%=pvo.PRS_EMAIL %>' maxlength='30'></input>
  </li>
  <li>
    <label>휴대전화</label>
    <input type='tel' name='cell_tel' value='<%=pvo.PRS_MOBILE_NO %>' maxlength='13' oninput="formatPhoneNumber(this)"></input>
  </li>
  <li>
    <label></label>
    <input type='checkbox' name='sms_yn' style='width: 16px;' value='1' <%=pvo.PRS_SMS.equals("1")?"checked":"" %> >거래진행 안내 문자(SMS) 수신
  </li>
  <li>
    <label>직위</label>
    <input type='text' name='login_pstn' value='<%=pvo.PRS_PSTN %>' maxlength='50' placeholder='직위'>
  </li>
  <li>
    <label>내선번호</label>
    <input type='text' name='login_extn' value='<%=pvo.PRS_EXTN %>' maxlength='4' placeholder='내선번호'>
  </li>
  <li style='margin-top:15px;'>
    <label></label>
    <a onclick='modifyManager();' class='btn lurian'>수정</a>
  </li>
</ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
