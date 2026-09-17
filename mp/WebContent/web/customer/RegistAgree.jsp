<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
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
String strCpyId = IntegerCryptoUtil.crypt((String)pageContext.getAttribute("CORP_ID"));
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>회원가입</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
ul.step {height: 96px;}
ul.step li {display:none;padding:15px;}
div.box {border:1px solid #eee;padding:20px;height:160px;overflow:scroll;text-align:justify;line-height:1.2em;overflow-x:hidden;color:#999;font-size:0.9em;margin-bottom:10px;}
</style>
<script>
function goNext() {
  <% if (!strCpyId.equals("0")) { %>
  toast('로그인되어 있습니다.<br/>진행할 수 없습니다.');
  return;
  <% } else { %>
  var intChecked = 0;
  $("input[type='checkbox']").removeClass("focus");
  if ($("input[name='agree_rule']").is(":checked")) intChecked++;
  else {
    toast("이용약관의 동의가 필요합니다.");
    return;
  }
  if ($("input[name='agree_privacy']").is(":checked")) intChecked++;
  else {
    toast("개인정보처리방침의 동의가 필요합니다.");
    return;
  }
  if (intChecked==2) {
    document.frmEnt.action = "Regist.jsp";
    document.frmEnt.method = "post";
    document.frmEnt.submit();
  }
  <% } %>
}
$(document).ready(function(){
  $("ul.step li").each(function(idx, item) {
    $(item).slideDown(200*idx);
  });
  setTimeout(function(){
    $("ul.step li").eq(2).addClass("now");
    $("ul.step li").eq(3).addClass("now");
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

<form name='frmAgree'>
<h3>이용약관</h3>
<div class='box'><%=StrUtil.templateToString("rule.htm") %></div>
<div style='text-align:center;'><input type='checkbox' name='agree_rule'> 이용약관에 동의합니다.</div>

<h3>개인정보처리방침</h3>
<div class='box'><%=StrUtil.templateToString("privacy.htm") %></div>
<div style='text-align:center;'><input type='checkbox' name='agree_privacy'> 개인정보처리방침에 동의합니다.</div>
</form>

<form name='frmEnt'>
<input type='hidden' name='bizno' value='<%=strBizNo%>'>
</form>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='btns'><a onclick='goNext();'>다음단계로</a></div>

<%@ include file="../includes/Footer.jsp" %>