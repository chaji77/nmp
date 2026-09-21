<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
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
pvo.CPY_CREDIT_GRADE   = StrUtil.nvl(request.getParameter("credit_grade"));
pvo.CPY_SCALE          = StrUtil.nvl(request.getParameter("scale"), "0");

ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SALES_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>영업업체관리</title>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js"></script>
<style>
.bigo span {padding:2px;border:1px solid #bbb;margin-right:5px;}
.searchbox label.long {
  display: inline-block;
  min-width: 80px;
}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "SalesCompanies.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function goDetail(url) {
  closePopup();
  $("#element_to_pop_up").css({width:"40vw"});
  $("#element_to_pop_up").bPopup({loadUrl:'SalesInformation.jsp?cpy_id='+url+'&popup=1'});
}
$(document).ready(function(){
  $(".searchbox input[name='bizno'], .searchbox input[name='nm'], .searchbox input[name='credit_grade']").keydown(function(key) {
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
  <span class='title'>영업업체관리</span>
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
		  <input type='text' name='nm' maxlength='20' value='<%=pvo.CPY_NAME %>' placeholder='회사명 또는 대표자명'>
        </li>
        <li>
          <label class= "long">기업신용등급</label>
		  <input type='text' name='credit_grade' maxlength='20' value='<%=pvo.CPY_CREDIT_GRADE %>' placeholder='AAA, AA, A...'>
        </li>
        <li>
          <label>기업구분</label>
          <select name='scale'  onchange='goPage(1);'>
          <option value='0'<%=(pvo.CPY_SCALE.equals("0"))?" selected":"" %>>전체</option>
          <option value='1'<%=(pvo.CPY_SCALE.equals("1"))?" selected":"" %>>일반</option>
          <option value='2'<%=(pvo.CPY_SCALE.equals("2"))?" selected":"" %>>외감</option>
          <option value='3'<%=(pvo.CPY_SCALE.equals("3"))?" selected":"" %>>중견</option>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='<%=request.getContextPath()%>/mgr/sales/SalesCompanies.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>


<table id='target-list' class='list detail clickable-tr' style='font-size:15px;'>
  <thead>
   <tr class='mobile_hide'>
     <th class='left' style='width:12%;'>회사명</th>
     <th class='left' style='width:7%;'>사업자번호</th>
     <th class='left' style='width:5%;'>대표자명</th>
     <th class='left' style='width:4%;'>기업구분</th>
     <th class='left' style='width:4%;'>신용등급</th>
     <th class='left' style='width:4%;'>업종코드</th>
     <th class='left' style='width:12%;'>업종상세</th>
     <th class='left' style='width:8%;'>매출액 (백만원)</th>
     <th class='left' style='width:5%;'>종업원수</th>
     <th class='left' style='width:24%;'>소재지</th>
     <th class='left' style='width:15%;white-space:nowrap;'>비고</th>
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
     <td class='mobile_hide'><%=v.CPY_NAME %></td>
     <td><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %><div class='mobile_show'><br/><%=v.CPY_NAME %> (<%=v.CPY_CEO_NAME %>)</div></td>
     <td class='mobile_hide'><%=v.CPY_CEO_NAME %></td>
     <td class='mobile_hide'><%
     if (v.CPY_SCALE.equals("1")) out.print("일반");
     else if (v.CPY_SCALE.equals("2")) out.print("외감");
     else if (v.CPY_SCALE.equals("3")) out.print("중견");
     else out.print("-");
     %></td>
     <td class='mobile_hide'><%=v.CPY_CREDIT_GRADE %></td>
     <td class='mobile_hide'><%=v.CPY_INDUSTRY_CODE %></td>
     <td class='mobile_hide'><%=v.INDUSTRY_DETAIL %></td>
     <td class='mobile_hide'><%=v.SALES_AMOUNT.isEmpty()?"":v.SALES_YEAR+"년 / "+StrUtil.addComma(v.SALES_AMOUNT)%></td>
      <td class='mobile_hide'><%=(v.EMPLOYEE_COUNT==null||v.EMPLOYEE_COUNT.isEmpty())?"-":v.EMPLOYEE_COUNT+"명" %></td>
     <td class='mobile_hide'><%=v.CPY_ADDR %></td>
     <td class='mobile_hide bigo' style='width:1%;white-space:nowrap;'>
       <%=(v.EXPORT_YN.equals("Y"))?"<span>수출</span>":"" %>
       <%=(v.MAINBIZ_YN.equals("Y"))?"<span>메인비즈</span>":"" %>
       <%=(v.INNOBIZ_YN.equals("Y"))?"<span>이노비즈</span>":"" %>
       <%=(v.PATENT_YN.equals("Y"))?"<span>특허</span>":"" %>
       <%=(v.LAB_YN.equals("Y"))?"<span>연구소</span>":"" %>
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
