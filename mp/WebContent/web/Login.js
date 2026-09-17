function check() {
  var is     = validate("input[name='login_id']", "length", [3,15], "아이디를 확인하세요.");
  if (is) is = validate("input[name='login_pw']", "length", [3,15], "비밀번호를 확인하세요.");
  return is;
}
function logon() {
  if (check()) {
    $.post(strContextPath + "/web/LoginProc.jsp", $("form[name='frmEnt']").serialize(), function(data){
      hideLoading();
      if (data=="0") {
        toast("등록된 정보가 없습니다. 아이디와 비밀번호를 확인하십시오.", 2000);
      } else if (data=="-1") {
        toast("잘못된 접근입니다. 페이지를 다시 불러옵니다.", 1000, function() {
          location.href = strContextPath + "/web/Login.jsp";
        });
      } else if (data=="-2") { 
        showAlert("승인 대기 중입니다. 가입승인을 위하여 고객센터로 문의 바랍니다. (1688-7400)", function() {
          $("input[name='login_id']").focus();
        });
        $("#custom-confirm-cancel").remove(); 
      } else {
        checkRevenue();
      }
    });
  }
}
function afterLogon() { // require strReffer at page to load
  location.href = strReffer;
}
$(document).ready(function(){
  $("input[name='login_id']").focus();
  $("input[name='login_id'],input[name='login_pw']").keydown(function(e) {
    if (e.keyCode == 13) {
      logon();
      e.preventDefault();
      e.stopPropagation();
    }
  });
  $("#SSN").keydown(function(e) {
    if (e.keyCode == 13) {
      loadCert();
      e.preventDefault();
      e.stopPropagation();
    }
  });
});
$(document).on('visibilitychange', function() {
  if (document.visibilityState === 'visible') {
    $.post(strContextPath + "/common/UUID.jsp", $("#frmEnt").serialize(), function(data){
      $("input[name='csrf_token']").val(data);
      $("#SSN").attr("name", data);
    });
  } else if (document.visibilityState === 'hidden') {
    //
  }
});

/**************************** login via cert ****************************/
/* 팝업창 감추기 */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
/* 전자서명창 호출 */
function loadCert() {
  $("#SSN").val(($("#SSN").val()).replace(/-/g, ''));
  if ($("#SSN").val().length!=10) {
    $("#SSN").focus();
    toast("사업자번호를 확인하십시오.");
    return;
  } else {
    $("#element_to_pop_up").html("<iframe id='ifrm_cert'></iframe>");
    var url = strContextPath + '/static/programs/cert/?ssn='+$("#SSN").val();
    $("#signdata").val("");
    $('#ifrm_cert').attr('src', url);
    $('#element_to_pop_up').bPopup({});
    document.getElementById("ifrm_cert").contentWindow.postMessage("CALL", "*");
    return;
  }
}
/* 전자서명창에서 호출 */
window.addEventListener("message", function(e) {
  $("#sgn_id").val("");
  $("#signdata").val("");
  if (e.data=="CLOSE") { // 취소버튼클릭
    $('#element_to_pop_up').bPopup().close();
    return;
  } else if (e.data=="CLOSE_FAIL_SSN") { // 사업자번호불일치
    $('#element_to_pop_up').bPopup().close();
    showAlert("사업자번호가 불일치합니다.", function(){});
    return;
  }
  if (e.data.length>30) { // 결과값정상수신
    $("#sgn_id").val("0000");
    $("#signdata").val(e.data);
    $('#element_to_pop_up').bPopup().close();
    showLoading();
    $.post(strContextPath + "/web/LoginViaCertProc.jsp", $("form[name='frmEntForCert']").serialize(), function(data){
      hideLoading();
      if (data=="0") {
        showAlert("등록된 정보가 없습니다.", function(){});
      } else if (data=="-1") {
        toast("잘못된 접근입니다. 페이지를 다시 불러옵니다.", 1000, function() {
          location.href = strContextPath + "/web/Login.jsp";
        });
      } else {
        checkRevenue();
      }
    });
  }
  return;
});
/**************************** find id/password ****************************/
function forgotAccount() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/web/AccountForgot.jsp'});
}
function searchId() { // @see AccountForgot.jsp
  document.frmAccount.bizno.value = document.frmAccount.bizno.value.replace(/-/g, '');
  if (document.frmAccount.bizno.value.length != 10) {
    toast("사업자번호를 확인하십시오.");
    return;
  }
  $.post(strContextPath + "/web/AccountSearchId.jsp", $("form[name='frmAccount']").serialize(), function(data){
    var msg = (data!="") ? "로그인아이디는 [ <strong>"+data+"</strong> ]입니다.<br/><br/>" : "존재하지 않습니다.<br/><br/>고객센터 문의 또는 공동인증서 로그인하십시오.<br/><br/>";
    if (data!="") $("input[name='login_id']").val(data);
    closePopup();
    showAlert(msg, function() {});
    $("#custom-confirm-cancel").remove();
  });
}
function resetPw() { // @see AccountForgot.jsp
  document.frmPassword.bizno.value = document.frmPassword.bizno.value.replace(/-/g, '');
  if (document.frmPassword.bizno.value.length != 10) {
    toast("사업자번호를 확인하십시오.");
    return;
  }
  showLoading();
  $.post(strContextPath + "/web/AccountSendEmail.jsp", $("form[name='frmPassword']").serialize(), function(data){
    console.log(data);
    var email = data.split("____")[0];
    var msg = (email!="") ? "[ <strong>"+email+"</strong> ]로 비밀번호 재발급을 위한 메일을 전송하였습니다.<br/><br/>" : "사업자번호와 아이디를 확인하십시오.<br/>문제가 지속되면 고객센터로 문의하시거나 공동인증서 로그인을 사용하십시오.<br/><br/>";
    hideLoading();
    closePopup();
    showAlert(msg, function() {});
    $("#custom-confirm-cancel").remove();
  });
}
function checkRevenue() { // Open the sales sales confirmation screen
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/web/customer/SellerRevenueCheck.jsp'});
}
function confirmNotChange() {
  $.post(strContextPath+'/web/customer/NotChangeProc.jsp', {}, function(data){
    afterLogon();
  });
}
