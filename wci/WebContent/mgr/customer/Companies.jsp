<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

CompanyVO pvo  = new CompanyVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
pvo.CPY_BUSINESS_NO    = StrUtil.nvl(request.getParameter("bizno")).replaceAll("-", "");
pvo.CPY_NAME           = StrUtil.nvl(request.getParameter("nm"));
pvo.CPY_GUBUN          = StrUtil.nvl(request.getParameter("gubun"), "0");
pvo.CU_USE_YN          = StrUtil.nvl(request.getParameter("cu_use_yn"), "X");
pvo.MOBILE_YN          = StrUtil.nvl(request.getParameter("mobile_yn"), "X");
pvo.REVERSE_YN         = StrUtil.nvl(request.getParameter("reverse_yn"), "X");
pvo.SIGN_EXCLUDE_YN    = StrUtil.nvl(request.getParameter("sign_exclude_yn"), "X");
pvo.CONFIRM_SETTLE_YN  = StrUtil.nvl(request.getParameter("confirm_settle_yn"), "X");
pvo.MPTAX_MONTH_USE_YN = StrUtil.nvl(request.getParameter("mptax_month_use_yn"), "X");
pvo.CST_ID             = StrUtil.nvl(request.getParameter("cst_id"), "0");

ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>회원관리</title>
<style>
.bigo span {padding:2px;border:1px solid #bbb;margin-right:5px;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "Companies.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function goDetail(url) {
  document.frmSearch.cpy_id.value = url;
  document.frmSearch.action = "Company.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
$(document).ready(function(){
  $(".searchbox input[name='bizno'], .searchbox input[name='nm']").keydown(function(key) {
    if (key.keyCode == 13) goPage(1);
  });
  $("a.magnify").on("click", function() {
  	if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
  	else $("table.searchbox").slideDown();
  });
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cpy_id' value=''>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
     <ul>
        <li>
          <label>사업자번호</label>
          <input type='text' name='bizno' maxlength='12' pattern="[0-9]+" onkeypress='return checkNumber(event)' value='<%=pvo.CPY_BUSINESS_NO %>' placeholder='사업자번호'>
        </li>
        <li>
          <label>회사명</label>
          <input type='text' name='nm' maxlength='20' value='<%=pvo.CPY_NAME %>' placeholder='회사명'>
        </li>
        <li>
          <label>회원구분</label>
          <select name='gubun'  onchange='goPage(1);'>
          <option value='0'<%=(pvo.CPY_GUBUN.equals("0"))?" selected":"" %>>전체</option>
          <option value='1'<%=(pvo.CPY_GUBUN.equals("1"))?" selected":"" %>>구매사</option>
          <option value='2'<%=(pvo.CPY_GUBUN.equals("2"))?" selected":"" %>>판매사</option>
          <option value='3'<%=(pvo.CPY_GUBUN.equals("3"))?" selected":"" %>>구매&판매사</option>
          </select>
        </li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='cst_id' value='1' <%=(pvo.CST_ID.equals("1"))?"checked":"" %>>미승인</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='cu_use_yn' value='Y' <%=(pvo.CU_USE_YN.equals("Y"))?"checked":"" %>> 스크랩거래</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='confirm_settle_yn' value='Y' <%=(pvo.CONFIRM_SETTLE_YN.equals("Y"))?"checked":"" %>> 확인결제</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='mobile_yn' value='Y' <%=(pvo.MOBILE_YN.equals("Y"))?"checked":"" %>> 모바일승인</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='reverse_yn' value='Y' <%=(pvo.REVERSE_YN.equals("Y"))?"checked":"" %>> 역발행</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='sign_exclude_yn' value='Y' <%=(pvo.SIGN_EXCLUDE_YN.equals("Y"))?"checked":"" %>> 서명예외</li>
        <li><input type='checkbox' style='min-width:auto !important;width:auto !important;' onclick='goPage(1);' name='mptax_month_use_yn' value='Y' <%=(pvo.MPTAX_MONTH_USE_YN.equals("Y"))?"checked":"" %>> 월합발행</li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='Companies.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>


<table id='target-list' class='list detail clickable-tr'>
  <thead>
   <tr class='mobile_hide'>
     <th class='left'>구분</th>
     <th class='left'>사업자번호</th>
     <th class='left'>회사명</th>
     <th class='left'>대표자명</th>
     <th class='left'>소재지</th>
     <th class='left'>등록일</th>
     <th class='left'>승인일</th>
     <th class='left'>비고</th>
   </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
    CompanyVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
    String strId = IntegerCryptoUtil.crypt(v.CPY_ID);
%>
   <tr onclick='goDetail("<%=strId %>");'>
     <td class='mobile_hide'><%
     if (v.CPY_GUBUN.equals("1")) out.print("구매사");
     else if (v.CPY_GUBUN.equals("2")) out.print("판매사");
     else out.print("구매&amp;판매사");
     %></td>
     <td><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %><div class='mobile_show'><br/><%=v.CPY_NAME %> (<%=v.CPY_CEO_NAME %>)</div></td>
     <td class='mobile_hide'><%=v.CPY_NAME %></td>
     <td class='mobile_hide'><%=v.CPY_CEO_NAME %></td>
     <td class='mobile_hide'><%=v.CPY_ADDR %></td>
     <td class='mobile_hide'><%=v.CPY_CREDATE %></td>
     <td class='mobile_hide'><%=v.CPY_VALIDATE %></td>
     <td class='mobile_hide bigo'>
       <%=(v.CU_USE_YN.equals("Y"))?"<span>스크랩</span>":"" %>
       <%=(v.CONFIRM_SETTLE_YN.equals("Y"))?"<span>확인결제</span>":"" %>
       <%=(v.MOBILE_YN.equals("Y"))?"<span>모바일승인</span>":"" %>
       <%=(v.REVERSE_YN.equals("Y"))?"<span>역발행</span>":"" %>
       <%=(v.SIGN_EXCLUDE_YN.equals("Y"))?"<span>서명예외</span>":"" %>
       <%=(v.MPTAX_MONTH_USE_YN.equals("Y"))?"<span>월합발행</span>":"" %>
     </td>
   </tr>
<%
	}
}
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>
