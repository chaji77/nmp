<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepVO" %>
<%@ page import="kr.co.mp.mgr.salesrep.SalesrepBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

SalesrepVO pvo = new SalesrepVO();
String strMid = request.getParameter("mid");
strMid = (IntegerCryptoUtil.isEncrypted(strMid)) ? strMid : null;
String strActionName = "등록";
if (strMid!=null) {
  pvo = new SalesrepBean().M_SALESREP_DETAIL_PROC(Integer.parseInt(IntegerCryptoUtil.crypt(strMid)));
  strActionName = "수정";
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>영업담당자관리</title>
<script> 
function check() {
  var is = validate("input[name='name']", "length", [2,12], "담당자명을 확인하세요.");
  if (is) is = validate("input[name='phone_no']", "length", [4,15], "연락처를 확인하세요.");
  if (is) is = validate("input[name='fax_no']", "length", [4,15], "팩스번호를 확인하세요.");
  if (is) is = validate("input[name='email']", "length", [4,30], "이메일을 확인하세요.");
  if (is) is = validatePattern("input[name='email']", /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/, "이메일 형식이 올바르지 않습니다.");
  
  return is;
}
function validatePattern(selector, pattern, message) {
  var value = document.querySelector(selector).value.trim();
  if (!pattern.test(value)) {
	showAlert(message);
    document.querySelector(selector).focus();
    return false;
  }
  return true;
}
function goSubmit() {
  if (check()) {
  showCustomConfirm("<%=strActionName%>하시겠습니까?", function() {
    $.post("SalesrepRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
    	if (data!="-1") {
        <% 
        if (strMid==null) out.println("location.href = 'Salesreps.jsp';");
        else out.println("goHistoryBack();");
        %>
      } else {
        toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
      }
    });
  }, function() {});
  }
}
function drop() {
  showCustomConfirm("정말 삭제하시겠습니까?", function() {
    $.post("SalesrepDropProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      if (data=="0") {
        goHistoryBack();
      }
    });
  }, function() {});
}
$(document).ready(function(){
  $("input[name='name']").focus();
});

</script>

<!-- page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>영업담당자 <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>
<form name='frmEnt' method='post' autocomplete="off">
<input type='hidden' name='mid' value='<%=StrUtil.nvl(strMid)%>'>
<ul class='form-with-label'>
  <li>
    <label for='name' class='emphasis'>담당자명</label>
    <input type='text'     name='name' value='<%=StrUtil.xss(pvo.NM)%>' maxlength='12' placeholder="담당자명">
  </li>
  <li>
    <label for='phone_no' class='emphasis'>연락처</label>
    <input type='text'     name='phone_no' value='<%=StrUtil.xss(pvo.PHONE_NO) %>' maxlength='15' placeholder="연락처">
  </li>
  <li>
    <label for='fax_no' class='emphasis'>팩스</label>
    <input type='text'     name='fax_no' value='<%=StrUtil.xss(pvo.FAX_NO) %>' maxlength='15' placeholder="팩스">
  </li>
  <li>
    <label for='fax_no' class='emphasis'>이메일</label>
    <input type='text'     name='email' value='<%=StrUtil.xss(pvo.EMAIL) %>' maxlength='30' placeholder="이메일"<%=((strMid!=null) ?"readonly":"") %>>
  </li>
</ul>
</form>
<div class='btns'>
  <a onclick='goSubmit();'><%=strActionName%></a>
  <% if (strMid!=null) { %> 
  <a onclick='drop();' class='cancel'>삭제</a>
  <% } %>
</div>


<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>