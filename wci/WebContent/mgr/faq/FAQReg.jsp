<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.mp.c.faq.FAQBean" %>
<%@ page import="kr.co.mp.c.faq.FAQVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strId = request.getParameter("id");
strId = (IntegerCryptoUtil.isEncrypted(strId)) ? strId : null;
String strActionName = "등록";

FAQVO	vo	= new FAQVO();
if(strId!=null) {
	vo = new FAQBean().C_FAQ_DETAIL_PROC(Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("id"))));
	strActionName = "수정";
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>FAQ관리</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script type="text/javascript">

function goSubmit() {
	if(check()) {
	showCustomConfirm("<%=strActionName%>하시겠습니까?", function() {
		$.post("FAQRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
			if (data!=-1) {
				<%
				out.println("goHistoryBack()");
				%>
			} else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
		});
	})
	}
}
function check() {
	document.frmEnt.title.value = $.trim(document.frmEnt.title.value.replace(/(<([^>]+)>)/ig,""));
	if (document.frmEnt.title.value.trim().length<2) {
	  toast("제목을 입력하십시오.");
	  document.frmEnt.title.focus();
	  return false;
	}
	document.frmEnt.editor.value = CKEDITOR.instances['contents'].getData();
	return true;
}
$(document).ready(function(){
	if ($("input[name='id']").val()!="") {
		var cat_id = $("input[name='category']").val();
		$("select[name='category']").val(cat_id);
	} else $("input[name='category']").val(1);
	
	$("select[name='category']").change(function() {
		var selectedValue = $(this).val();
		$("input[name='category']").val(selectedValue);
	})
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>FAQ <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<form name='frmEnt' id='frmEnt' autocomplete="off">
<input type='hidden' name='id' value='<%=StrUtil.nvl(strId) %>'>
<input type='hidden' name='category' value='<%=vo.CAT_ID%>'>
<input type='hidden' name='editor' value=''>
<table class="form list detail" summary="Registration Form">
  <colgroup>
  <col width="100px" />
  <col width="150px" />
  <col width="100px" />
  <col width="*" />
  </colgroup>
  <tbody>
    <tr>
      <th>카테고리</th>
      <td>
        <select name='category'>
          <option value="1">B2B전자결제</option>
          <option value="2">구매기업</option>
          <option value="3">판매기업</option>
          <option value="4">수수료</option>
          <option value="5">회원가입정보</option>
        </select>
      </td>
      <th>제목</th>
      <td><input type='text' name='title' maxlength='50' value='<%=StrUtil.input(vo.TITLE) %>'></td>
    </tr>
  </tbody>
</table>
<div><textarea id="contents" style="height:400px;width:calc(100% - 2px);"><%=StrUtil.nvl(vo.CONTENTS) %></textarea></div>
</form>

<div class='btns'>
  <a href='javascript:goSubmit();'><%=strActionName%></a>
  <a onclick='history.go(-1);' class='cancel'>취소</a>
</div>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>
<script type="text/javascript" src='<%=request.getContextPath() %>/static/js/CKEditorSet.js?<%=DateTimeUtil.getCurrentResourceVersion() %>' charset='utf-8'></script>
