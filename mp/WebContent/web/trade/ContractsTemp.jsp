<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.common.MobileUtil" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;
String strPrsId       = (String)pageContext.getAttribute("PRS_ID");

String strPageTitle   = "임시보관함";
String strPageCode    = "S";
String strDetailPage  = "ContractReg.jsp";

String strPage        = StrUtil.nvl(request.getParameter("page"), "1");
String strStatus      = "010";
String strStartYmd    = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd      = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
String strTargetCpyId = StrUtil.nvl(request.getParameter("tc"), "0");

String MOBILE_YN          = StrUtil.nvl((String)pageContext.getAttribute("MOBILE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (MOBILE_YN.equals("Y") && MobileUtil.isMobile(request)) SIGN_EXCLUDE_YN = "Y"; // MOBILE APPROVAL IS REGISTERED, AND IF IT IS A MOBILE ENVIRONMENT, THE SIGNATURE IS EXCLUDED.

%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>
<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script>
function sendMulti() {
  <% 
  if (SIGN_EXCLUDE_YN.equals("Y")) out.println("goLoopSubmit();");
  else out.println("loadCert();");
  %>
}
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
/* call signature window */
function loadCert() {
  if ($("input[name='seq']:checked").length == 0) { 
    toast("선택된 매매계약서가 없습니다.");
    return;
  }
  $("#element_to_pop_up").empty();
  var url = strContextPath + '/static/programs/cert/?ssn='+$("#bizno").val();
  $("#signdata").val("");
  $('#element_to_pop_up').append("<iframe id='ifrm_cert'></iframe>");
  $('#ifrm_cert').attr('src', url);
  $('#element_to_pop_up').bPopup();
  console.log($('#element_to_pop_up').html());
  document.getElementById("ifrm_cert").contentWindow.postMessage("CALL", "*");
}
/* callback from signature window */
window.addEventListener("message", function(e) {
  hideLoading();
  $("#sgn_id").val("");
  $("#signdata").val("");
  if (e.data=="CLOSE") { // click cancel button
    closePopup();
    return;
  } else if (e.data=="CLOSE_FAIL_SSN") { // mismatch biz no.
    closePopup();
    toast("사업자번호가 불일치합니다.", intMessageShowTime);
    return;
  }
  if (e.data.length>30) { // success
    $("#sgn_id").val("0000");
    var k = (e.data.split("$data")[0]).replace("$dn=", ""); // extract header values
    $("#signdata").val(k);
    closePopup();
    goLoopSubmit();
  }
  return;
});
function toggleAllCheckContracts() {
  var isChecked = $("input[name='AllCheckContracts']").is(":checked");
  console.log(isChecked);
  $('#contract_list').find('input[name="seq"]').prop("checked", isChecked);
}
function getToSend() {
  var $nextChecked = $('#contract_list').find('input[name="seq"]:checked').first();
  if ($nextChecked.length > 0) {
    return $nextChecked.val();
  } else {
    return 0;
  }
}

function send(toSend, token, callback) {
  window.sendInProgress = true;
  $.ajax({
    url: strContextPath + "/web/transaction/B311.jsp",
    type: 'post',
    data: { "ctid": toSend, "token": token },
    async: true,
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        callback(true); // 성공 시 true 반환
      } else {
        showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
        callback(false); // 실패 시 false 반환
      }
    },
    error: function(request, status, error) {
      showAlert("전송에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
      console.log(request.status + " : " + request.responseText + " : " + error);
      callback(false); // 실패 시 false 반환
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      window.sendInProgress = false;
    }
  });
}

function goLoopSubmit() {
  var toSend = getToSend();
  if (toSend > 0) {
    $.ajax({
      url: "ContractRegMultiProc.jsp",
      type: 'post',
      data: { "seq": toSend, "sgn_id": $("#sgn_id").val(), "signdata": $("#signdata").val() },
      async: true,
      success: function(data) {
        hideSpinner();
        try {
          var json = JSON.parse(data);
          if (json.step == "complete") { // STANDBY-CONFIRM
            $('#contract_list').find('input[name="seq"][value="' + toSend + '"]').closest('tr').remove();
            goLoopSubmit();
          } else if (json.step == "send") { // DIRECT-SEND
            var enid = json.msg.split("____")[1];
            var token = json.msg.split("____")[2];
            send(enid, token, function(isSuccess) {
              if (isSuccess) {
                $('#contract_list').find('input[name="seq"][value="' + toSend + '"]').closest('tr').remove();
                goLoopSubmit();
              }
            });
          } else {
            showAlert(json.msg, function() {
              if (json.step === "session") {
                location.href = "<%=request.getContextPath()%>/web/Login.jsp";
              }
            });
            $("div.result-message").addClass("error-message");
          }
        } catch (e) {
          // JSON 파싱 오류 처리
          showAlert("서버 응답 형식이 올바르지 않습니다.");
          console.error(e);
        }
      },
      error: function(request, status, error) {
        hideSpinner();
        showAlert("통신에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
        console.log(request.status + " : " + request.responseText + " : " + error);
      },
      beforeSend: function() {
        showSpinner("발송 중입니다.");
      }
    });
  } else {
    hideSpinner();
  }
}
$(document).ready(function(){
  $(".search-option-status").remove();
  $(".exp").remove();
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<!-- ELECTRONIC SIGNATURE REQUIRED -->
<form name='signdata'>
<input type="hidden" id='bizno' name='bizno' value='<%=pageContext.getAttribute("CPY_BIZ_NO")%>'>
<input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
<input type='hidden' id='signdata' name='signdata'><!-- 결과값 : 서명값 -->
</form>
<div id='element_to_pop_up'></div>

<jsp:include page="Contracts.jsp">
  <jsp:param name="cpy_id" value="<%=strCpyId %>" />
  <jsp:param name="prs_id" value="<%=strPrsId %>" />
  <jsp:param name="page_code" value="<%=strPageCode %>" />
  <jsp:param name="page" value="<%=strPage %>" />
  <jsp:param name="status" value="<%=strStatus %>" />
  <jsp:param name="start_ymd" value="<%=strStartYmd %>" />
  <jsp:param name="end_ymd" value="<%=strEndYmd %>" />
  <jsp:param name="tc" value="<%=strTargetCpyId %>" />
  <jsp:param name="detail_page" value="<%=strDetailPage %>" />
  <jsp:param name="tmpyn" value="Y" />
</jsp:include>

<%@ include file="../includes/Footer.jsp" %>
