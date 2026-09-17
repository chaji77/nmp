<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.PersonVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
if (intCpyId==0) return;

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("ACTIVE_MANAGEMENT.ACTIVE_KIND");
ArrayList<PersonVO> arrPersons = new CustomerBean().PERSON_LIST_PROC(intCpyId);
%>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script>
function getBytes(str) {
  let bytes = 0;
  for (let char of str) {
    const code = char.charCodeAt(0);
    bytes += (code <= 0x007F) ? 1 : 2;  // 한글 포함 문자 2바이트
  }
  return bytes;
}
function sendSMS() {
  showLoading();
  $.post(strContextPath + "/mgr/customer/SMSSendProc.jsp", $("form[name='frmSMSSend']").serialize(), function(data) {
    if (data!="0") {
      toast("전송하였습니다.", 1000, function() {
        closePopup();
        hideLoading();
        if ($(".memo-page").is(":visible")) window.location.reload();
      });
    } else {
      hideLoading();
      showAlert("전송하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
$(document).ready(function() {
  $("select[name='active_kind']").select2();
  $('#msg').on('input', function () {
    var intSMSMaxLenth = 86;
    var input = $(this).val();
    var bytes = getBytes(input);
    if (bytes > intSMSMaxLenth) {
      var trimmed = '';
      var totalBytes = 0;
      for (var i = 0; i < input.length; i++) {
        var ch = input.charAt(i);
        var charCode = ch.charCodeAt(0);
        var charBytes = (charCode <= 0x007F) ? 1 : 2;
        if (totalBytes + charBytes > intSMSMaxLenth) break;
          totalBytes += charBytes;
          trimmed += ch;
        }
        $(this).val(trimmed);
    }
    $("#sms_current_bytes").text(getBytes($(this).val()));
  });
});
</script>

<h3>SNS전송</h3>
<form name='frmSMSSend' autocomplete='off'>
<input type='hidden' name='cid' value='<%=intCpyId%>'>
<select name='active_kind' style='width:100%;margin-bottom:5px;'>
<%
if (arrCodes!=null && arrCodes.size()>0) {
  for (CodeVO v : arrCodes) {
    out.println("<option value='"+v.CODE_CD+"'>"+v.CODE_NM+"</option>");
  }
}
%>
</select>
<select id='sms_send_to' name='to' style='width:100%;margin-bottom:5px;'>
<%
if (arrPersons!=null && arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
    if (!StrUtil.nvl(v.PRS_MOBILE_NO).equals("")) {
        out.println("<option value='"+v.PRS_MOBILE_NO+"'>"+v.PRS_NAME+" ("+v.PRS_MOBILE_NO+")</option>");
    }
  }
}
%>
</select>
<textarea id="msg" name="msg" style="height:100px;width:calc(100% - 22px);"></textarea>
<p>최대 86바이트까지 가능합니다. (현재 <span id='sms_current_bytes'>0</span>자)</p>
</form>

<div class='btns'><a onclick='sendSMS();'><i class="fa-solid fa-paper-plane"></i></a></div>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>