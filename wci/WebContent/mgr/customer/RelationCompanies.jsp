<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

RelationCompanyVO pvo  = new RelationCompanyVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 10;
pvo.CPY_ID = IntegerCryptoUtil.crypt(request.getParameter("cpy_id"));
pvo.USE_YN = StrUtil.nvl(request.getParameter("useYN"));

ArrayList<RelationCompanyVO> arr = new MgrCustomerBean().M_RELATION_COMPANY_LIST_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>본·지사 사업자 관리</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>

<style>
td.emp {color:red;}
</style>
<script>
function add() {
  closePopup();
  var companyName = $('ul.detail .td:eq(0)').text();
  var companyBizNo = $('ul.detail .td:eq(1)').text();
  $("#element_to_pop_up").bPopup({loadUrl:'RelationCompanyReg.jsp?cid=<%=intCpyId%>&cnm='+encodeURIComponent(companyName)+'&bizno='+companyBizNo});
}
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "RelationCompanies.jsp?cpy_id=<%=strCpyId%>";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function edit(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'RelationCompanyReg.jsp?cid=<%=intCpyId%>&seqNo=' + seq});
}
 function registRelationCompany() {
  $.post("RelationCompanyRegProc.jsp", $("form[name='frmRelationCompanies']").serialize(), function(data) {
    if (isNaN(data)) showAlert(data, function(){ });
    else location.reload(true); 
  });
} 
$(document).ready(function(){
  $("select[name='useYN']").val('<%=pvo.USE_YN%>');
  
  $("a.magnify").on("click", function() {
	if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
	else $("table.searchbox").slideDown();
  });
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>본·지사 사업자 관리</span>
  <span class='more'>
    <a onclick='add()' class='btn'>등록</a>
  </span>
</div>

<jsp:include page="./CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="6" />
</jsp:include>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
     <ul>
        <li>
          <label>사용여부</label>
          <select name='useYN'>
            <option value=''>전체</option>
            <option value='Y'>사용</option>
            <option value='N'>미사용</option>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:goPage(1);'></td>
  </tr>
</tbody>
</table>
</form>

<table id='target-list' class='list detail clickable-tr'>
  <thead>
   <tr class='mobile_hide'>
     <th class='left'>기금</th>
     <th class='left'>회사명</th>
     <th class='left'>등록된 사업자번호</th>
     <th class='left'>처리내용</th>
     <th class='left'>처리자</th>
     <th class='left'>처리일시</th>
     <th class='left'>사용유무</th>
     <th class='left'>명령</th>
   </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
    RelationCompanyVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
    String strId = IntegerCryptoUtil.crypt(v.CPY_ID);
    String strLoanType = v.LOANTYPE;
    if (strLoanType.equals("KODIT")) strLoanType = "신용보증기금";
    else if (strLoanType.equals("KIBO")) strLoanType = "기술보증기금";
    else if (strLoanType.equals("KOREG")) strLoanType = "신용보증재단";
    else if (strLoanType.equals("NOGUAR")) strLoanType = "비보증";
%>
	 <tr>
      <td><%=strLoanType %></td>
      <td class='mobile_hide'><%=v.CPY_NAME %></td>
      <td><%=FormatUtil.addDashBizNo(v.RELATIONBIZNO) %></td>
      <td class='mobile_hide'><textarea readonly><%=v.PRO_RESULT %></textarea></td>
      <td class='mobile_hide'><%=v.LASTUSER %></td>
      <td class='mobile_hide'><%=FormatUtil.addSeparatorDateTime(v.LASTTIME, "/") %></td>
      <td class='<%=(v.USE_YN.equals("N") ? "emp": "")%>'><%=v.USE_YN.equals("N") ? "미사용" : "사용" %></td>
      <td class='mobile_hide'><a class='btn' onclick='edit(<%=v.SEQNO %>)'>수정</a></td>
    </tr>
  </tbody>
<%
  }
}
%>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>
  
