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
String strMailSign = "<p>본 메일은 발신전용입니다.<br>문의사항은 " 
                   + ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM") + " 고객센터(" 
                   + ConfigurationMgr.getInstance().getString("OWNER_TEL") +")로 문의바랍니다.</p>";
%>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script>
function sendMail() {
  if ($("#mail_send_to").val().indexOf("____")<0) {
    toast("발송대상이 없습니다.");
    return false;
  }
  if (document.frmMailSend.title.value.length<1) {
    toast("제목을 입력하십시오.");
    return false;
  }
  document.frmMailSend.body.value = CKEDITOR.instances['contents'].getData();
  showLoading();
  $.post(strContextPath + "/mgr/customer/MailSendProc.jsp", $("form[name='frmMailSend']").serialize(), function(data) {
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
});
</script>

<h3>메일전송</h3>
<form name='frmMailSend' autocomplete='off'>
<input type='hidden' name='cid' value='<%=intCpyId%>'>
<input type='hidden' name='body'>
<select name='active_kind' style='width:100%;margin-bottom:5px;'>
<%
if (arrCodes!=null && arrCodes.size()>0) {
  for (CodeVO v : arrCodes) {
    out.println("<option value='"+v.CODE_CD+"'>"+v.CODE_NM+"</option>");
  }
}
%>
</select>
<select id='mail_send_to' name='to' style='width:100%;margin-bottom:5px;'>
<%
if (arrPersons!=null && arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
    if (!StrUtil.nvl(v.PRS_EMAIL).equals("") && v.PRS_EMAIL.indexOf("@")>0) {
        out.println("<option value='"+v.PRS_NAME+"____"+v.PRS_EMAIL+"'>"+v.PRS_NAME+"&lt;"+v.PRS_EMAIL+"&gt;</option>");
    }
  }
}
%>
</select>
<input type='text' name='title' placeholder='제목' style='width:calc(100% - 12px);margin-bottom:5px;'>
<textarea id="contents" style="height:300px;width:calc(100% - 2px);"></textarea>
</form>

<p style='margin:20px 0 10px 0;padding-bottom:10px;border-bottom: 1px solid #ddd;color:#aaa;'>[참고] 메일 발송시 본문에 아래 문구가 추가됩니다.</p>
<%=strMailSign %>
<p>&nbsp;</p>
<div class='btns'><a onclick='sendMail();'><i class="fa-solid fa-paper-plane"></i></a></div>
<script type="text/javascript" src='<%=request.getContextPath() %>/static/js/CKEditorSetMini.js?<%=DateTimeUtil.getCurrentResourceVersion()%>'></script>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>