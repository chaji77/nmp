<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<!-- 내거래처 -->
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
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

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, 0); // 내거래처
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>거래처관리</title>

<link rel="stylesheet" href="<%=request.getContextPath()%>/static/plugin/select2.css?b"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<style>
#element_to_pop_up {
  background-color:transparent;
  display:none;
  padding:0 !important;
}
div.searchbox {text-align:center;background-color:transparent;margin-bottom:20px;}
div.searchbox input {width:170px;border-radius:20px 0 0 20px;padding:20px;border:3px solid #555;border-right:0;background-color:transparent;vertical-align:top;}
div.searchbox i.fa {font-size:2em;vertical-align:top;cursor:pointer;color:#555;padding:7px 14px;border-radius:0 20px 20px 0;border:3px solid #555;border-left:0;}
</style>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script src="<%=request.getContextPath()%>/static/js/pop.js" type="text/javascript"></script>
<script>
/* close bPopup window */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
/* call partner registration window */
function showPartnerReg() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:'MyCompanyReg.jsp?from=MyCompanies'});
}
function drop(cid) {
  showCustomConfirm("복원되지 않습니다.<br/>정말 삭제하시겠습니까?", function() {
    $.post("MyCompanyDropProc.jsp", {'cid':cid}, function(data){
      window.location.reload();
    });
  }, function() {});
}
$(document).ready(function () {
  $("#search").keyup(function () {
    search_table($(this).val());
  });
  function search_table(value) {
    $("table.list tbody tr").each(function () {
      var found = "false";
      $(this).each(function () {
        if ($(this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0) {
          found = "true";
        }
      });
      if (found == "true") {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래처관리</span>
  <span class='more'>
    <a onclick='showPartnerReg();' class='btn'>추가</a>
  </span>
</div>

<!-- partner registration window -->
<div id='element_to_pop_up'></div>

<div class='searchbox'>
  <input type='search' name='search' id='search' value='' maxlength='10' placeholder='검색어'><i class="fa fa-search" aria-hidden="true" onclick='javascript:search();'></i>
</div>

<table class='list'>
  <thead class='mobile_hide'>
    <tr>
      <th class='left'>사업자번호</th>
      <th class='left'>회사명</th>
      <th>대표자</th>
      <th class='left'>소재지</th>
      <th class='right'>명령</th>
  </thead>
  <tbody>
    <%
    if (arrMyCompanies!=null && arrMyCompanies.size()>0) {
      for (CompanyVO mcvo : arrMyCompanies) {
    %>
    <tr>
      <td class='mobile_hide'><%=FormatUtil.addDashBizNo(mcvo.CPY_BUSINESS_NO)%></td>
      <td>
        <%=mcvo.CPY_NAME%>
        <p class='mobile_show'><br/><%=FormatUtil.addDashBizNo(mcvo.CPY_BUSINESS_NO)%> <span style='color:#ddd;'>|</span> <%=mcvo.CPY_CEO_NAME%></p>
      </td>
      <td class='center mobile_hide'><%=mcvo.CPY_CEO_NAME%></td>
      <td class='left mobile_hide'><%=mcvo.CPY_ADDR %></td>
      <td class='right'><a onclick="drop('<%=IntegerCryptoUtil.crypt(mcvo.CPY_ID)%>');" class='btn darkred'><i class="fa-solid fa-trash-can"></i></a></td>
    </tr>
    <%
      }
    } else out.println("<tr><td colspan='5' class='noentry'>등록된 거래처가 없습니다.<p>&nbsp;</p><p><a onclick='showPartnerReg();' class='btn'>거래처 추가</a></p></td></tr>");
    %>
  </tbody>
</table>

<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>
<%@ include file="../includes/Footer.jsp" %>