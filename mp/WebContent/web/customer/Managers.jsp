<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CustomerBean bean = new CustomerBean();
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
int intCnt = (arrPersons!=null) ? arrPersons.size() : 0;
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>계정관리</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
span.bullet i {vertical-align:middle;font-size:3em;color:hotpink;margin-right:10px;}
span.alert {text-align:justify;padding-top:10px;}
@media only screen and (max-width:767px) {
  span.alert {padding-top:0;}
}
</style>
<script>
function modify(pid) {
  location.href = 'ManagerReg.jsp?pid='+pid;
}
function remove(pid) {
console.log(pid);
<% if (intCnt>1) { %>
  showCustomConfirm("정보는 복원할 수 없습니다.<br/>정말 삭제하시겠습니까?", function() {
    $.post("ManagerDropProc.jsp", {'prs_id':pid}, function(data) {
      if (data>0) location.href = "Managers.jsp";
      else toast("삭제할 수 없습니다. 고객센터에 문의하십시오.", 3000);
    });
  }, function() {});
<% } else { %>
  toast("삭제할 수 없습니다.<br/>하나 이상의 계정이 존재해야 합니다.", 3000);
<% } %>
}
$(document).ready(function(){

});

</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>계정관리</span>
  <span class='more'>
    <a href='MyPage.jsp' class='btn white mobile_hide'>마이페이지로 이동</a>
    <a href='ManagerReg.jsp' class='btn'>계정추가</a>
  </span>
</div>

<table class='list'>
<thead class='mobile_hide'>
  <tr>
    <th class='left'>성명</th>
    <th class='left'>로그인아이디</th>
    <th class='left'>휴대전화</th>
    <th class='left'>일반전화</th>
    <th class='left'>이메일</th>
    <th>명령</th>
  </tr>
</thead>
<tbody>
<%
if (arrPersons!=null && arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
%>
  <tr>
    <td width='*'>
      <%=StrUtil.nvl(v.PRS_NAME) %>
      <span class='mobile_show'> (<%=StrUtil.nvl(v.PRS_LOGIN) %>)</span>
      <div class='mobile_show'><br/><%=StrUtil.nvl(v.PRS_MOBILE_NO) %></div>
      <div class='mobile_show'><br/><%=StrUtil.nvl(v.PRS_EMAIL) %></div>
    </td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_LOGIN) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_MOBILE_NO) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_TEL) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_EMAIL) %></td>
    <td class='center' width='70'>
      <a onclick='modify("<%=IntegerCryptoUtil.crypt(v.PRS_ID)%>");' class='btn lurian'>수정</a>
      <a onclick='remove("<%=IntegerCryptoUtil.crypt(v.PRS_ID)%>");' class='btn darkred'>삭제</a>
    </td>
  </tr>
<%
  }
}
%>
</tbody>
</table>

<%@ include file="../includes/Footer.jsp" %>