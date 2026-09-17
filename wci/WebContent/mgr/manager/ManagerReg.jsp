<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

ManagerVO pvo = new ManagerVO();
String strMid = request.getParameter("mid");
strMid = (IntegerCryptoUtil.isEncrypted(strMid)) ? strMid : null;
ManagerVO vo = new ManagerVO();
String strActionName = "등록";
if (strMid!=null) {
  vo = new ManagerBean().M_MANAGER_DETAIL_PROC(Integer.parseInt(IntegerCryptoUtil.crypt(strMid)));
  strActionName = "수정";
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>관리자관리</title>
<script>
function togglePasswdVisible() {
  if ($("input[name='login_pw']").attr("type")=="password") $("input[name='login_pw']").attr("type", "text");
  else $("input[name='login_pw']").attr("type", "password");
}
function check() {
  var is = validate("input[name='user_nm']", "length", [2,12], "관리자명을 확인하세요.");
  if (is) is = validate("input[name='login_id']", "length", [4,11], "아이디를 확인하세요.");
  if (is) is = validate("input[name='login_pw']", "length", [4,15], "비밀번호를 확인하세요.");
  return is;
}
function goSubmit() {
  if (check()) {
  showCustomConfirm("<%=strActionName%>하시겠습니까?", function() {
    $.post("ManagerRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      if (data!="-1") {
        <% 
        if (strMid==null) out.println("location.href = 'Managers.jsp';");
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
    $.post("ManagerDropProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      if (data=="0") {
        goHistoryBack();
      }
    });
  }, function() {});
}
$(document).ready(function(){
  $("input[name='user_nm']").focus();
});
</script>

<!-- page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>관리자 <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<form name='frmEnt' method='post' autocomplete="off">
<input type='hidden' name='mid' value='<%=StrUtil.nvl(strMid)%>'>
<ul class='form-with-label'>
  <li>
    <label for='user_nm' class='emphasis'>관리자명</label>
    <input type='text'     name='user_nm' value='<%=StrUtil.xss(vo.USER_NM) %>' maxlength='12' placeholder="관리자명">
  </li>
  <li>
    <label for='login_id' class='emphasis'>아이디</label>
    <input type='text'     name='login_id' value='<%=StrUtil.xss(vo.LOGIN_ID) %>' maxlength='11' placeholder="아이디" <%=((strMid!=null) ?"readonly":"") %>>
  </li>
  <li>
    <label for='login_pw' class='emphasis'>비밀번호</label>
    <input type='password' name='login_pw' value='<%=StrUtil.xss(vo.LOGIN_PW) %>' maxlength='15' placeholder="비밀번호" style='width: 120px;'>
    <img src='//image.mp1.co.kr/mp/visible.png' style='height: 24px;vertical-align:middle;cursor:pointer;' onclick='togglePasswdVisible();'>
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