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

String strPageTitle   = "보낸 계약서";
String strPageCode    = "S";
String strDetailPage  = "Contract.jsp";

String strPage        = StrUtil.nvl(request.getParameter("page"), "1");
String strStatus      = StrUtil.nvl(request.getParameter("status"), "000");
String strStartYmd    = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd      = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
String strTargetCpyId = StrUtil.nvl(request.getParameter("tc"), "0");
/*
String MOBILE_YN          = StrUtil.nvl((String)pageContext.getAttribute("MOBILE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (MOBILE_YN.equals("Y") && MobileUtil.isMobile(request)) SIGN_EXCLUDE_YN = "Y"; // MOBILE APPROVAL IS REGISTERED, AND IF IT IS A MOBILE ENVIRONMENT, THE SIGNATURE IS EXCLUDED.
*/
String SIGN_EXCLUDE_YN = "Y"; // 확인결제에는 이미 서명되어 있으므로 서명이 필요하지 않음

%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>
<script>
function sendMulti() {
  <% 
  if (SIGN_EXCLUDE_YN.equals("Y")) out.println("goLoopSubmit(0);");
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
    goLoopSubmit(0);
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
        callback(true);
      } else {
        showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
        callback(false);
      }
    },
    error: function(request, status, error) {
      showAlert("전송에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
      console.log(request.status + " : " + request.responseText + " : " + error);
      callback(false);
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      window.sendInProgress = false;
    }
  });
}
// 확인결제
function goLoopSubmit() {
  var toSend = getToSend();
  if (toSend > 0) {
    $.ajax({
      url: "ConfirmSettleContractSendProc.jsp",
      type: 'post',
      data: { "seq": toSend, "sgn_id": $("#sgn_id").val(), "signdata": $("#signdata").val() },
      async: true,
      success: function(data) {
        hideSpinner();
        try {
          var json = JSON.parse(data);
          if (json.step !== "send") {
            showAlert(json.msg, function() {
              if (json.step === "session") {
                location.href = "<%=request.getContextPath()%>/web/Login.jsp";
              }
            });
            $("div.result-message").addClass("error-message");
          } else {
            var enid = json.msg.split("____")[1];
            var token = json.msg.split("____")[2];
            send(enid, token, function(isSuccess) {
              if (isSuccess) {
                $('#contract_list').find('input[name="seq"][value="' + toSend + '"]').closest('tr').remove();
                goLoopSubmit();
              }
            });
          }
        } catch (e) {
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
</script>

<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <a onclick='document.frmToExcel.submit();' class='btn white' title='excel download'><i class="fa-solid fa-download"></i>엑셀다운로드</a>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<%
String sessionSignSeq = StrUtil.nvl((String)session.getAttribute("signseq"), "0");
%>

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
</jsp:include>

<!-- for excel download -->
<form name='frmToExcel' method='post' action='ContractsForExcel.jsp' target='FrameForExcel'>
  <input type='hidden' name="cpy_id" value="<%=strCpyId %>" />
  <input type='hidden' name="prs_id" value="<%=strPrsId %>" />
  <input type='hidden' name="page_code" value="<%=strPageCode %>" />
  <input type='hidden' name="page" value="<%=strPage %>" />
  <input type='hidden' name="status" value="<%=strStatus %>" />
  <input type='hidden' name="start_ymd" value="<%=strStartYmd %>" />
  <input type='hidden' name="end_ymd" value="<%=strEndYmd %>" />
  <input type='hidden' name="tc" value="<%=strTargetCpyId %>" />
  <input type='hidden' name="detail_page" value="<%=strDetailPage %>" />
</form>
<iframe name='FrameForExcel' id='FrameForExcel' style="display: none;"></iframe>
<!-- // for excel download -->

<%@ include file="../includes/Footer.jsp" %>

