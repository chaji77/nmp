<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, 0); // 내거래처
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>거래처 관리</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>

<style>
#element_to_pop_up {
  background-color:transparent;
  display:none;
  padding:0 !important;
}
</style>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script src="<%=request.getContextPath()%>/static/js/pop.js" type="text/javascript"></script>
<script>
function showPartnerReg() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/PartnersReg.jsp?cid=<%=strCpyId%>'});
}
function drop(cid) {
  showCustomConfirm("복원되지 않습니다.<br/>정말 삭제하시겠습니까?", function() {
    $.post("<%=request.getContextPath()%>/mgr/customer/PartnersDropProc.jsp", {'cid':'<%=strCpyId%>', 'targetId':cid}, function(data){
      window.location.reload();
    });
  }, function() {});
}
$(document).ready(function () {
  $("#search").keyup(function () {
    search_table($(this).val());
  });
  function search_table(value) {
    $("table.detail tbody tr").each(function () {
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
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래처 관리</span>
  <span class='more'>
    <a onclick='showPartnerReg()' class='btn'>등록</a>
  </span>
</div>

<jsp:include page="./CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="7" />
</jsp:include>

<form name='frmSearch' onsubmit="return false;">
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
     <ul>
        <li>
          <label>거래처명</label>
          <input type='search' name='search' id='search' value='' maxlength='10' placeholder='검색어'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
  </tr>
</tbody>
</table>
</form>

<table class='detail'>
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
      <td class='right'><a onclick="drop('<%=IntegerCryptoUtil.crypt(mcvo.CPY_ID)%>');" class='btn darkred'>삭제</a></td>
    </tr>
    <%
      }
    } else out.println("<tr><td colspan='5' class='noentry'>등록된 거래처가 없습니다.<p>&nbsp;</p><p><a onclick='showPartnerReg();' class='btn'>거래처 추가</a></p></td></tr>");
    %>
  </tbody>
</table>
<%@ include file="../Footer.jsp" %>