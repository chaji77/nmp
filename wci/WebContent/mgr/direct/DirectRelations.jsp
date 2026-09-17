<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationVO" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

DirectRelationVO pvo = new DirectRelationVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 20;
pvo.SELL_COMPANY_NAME = StrUtil.nvl(request.getParameter("sellCpyName"));
pvo.BUY_COMPANY_NAME = StrUtil.nvl(request.getParameter("buyCpyName"));

ArrayList<DirectRelationVO> arr = new DirectRelationBean().M_DIRECT_RELATION_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>직발주회원관리</title>
<style></style>
<script>
function goPage(p) {
	document.frmSearch.page.value = p;
	document.frmSearch.action = "DirectRelations.jsp";
	document.frmSearch.target = "_top";
	document.frmSearch.submit();
}
function edit(obj) {
	closePopup();
	var sid = $(obj).parent().parent().attr("sid");
	var bid = $(obj).parent().parent().attr("bid");
	$("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/direct/DirectRelationModify.jsp?sid=' + sid + '&bid=' + bid});
}
$(document).ready(function(){
	$(".searchbox input[name='sellCpyName'], .searchbox input[name='buyCpyName']").keydown(function(key) {
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
  <span class='title'>직발주회원관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
    <a class='btn' href='<%=request.getContextPath() %>/mgr/direct/DirectRelationReg.jsp'>신규등록</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<table class='searchbox mobile_hide'>
<tbody>
</tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>판매기업명</label>
          <input type='text' name='sellCpyName' value='<%=pvo.SELL_COMPANY_NAME %>'>
        </li>
        <li>
          <label>구매기업명</label>
          <input type='text' name='buyCpyName' value='<%=pvo.BUY_COMPANY_NAME %>'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='DirectRelations.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</table>
</form>

<table id='target-list' class='list detail clickable-tr'>
  <thead>
   <tr class='mobile_hide'>
     <th class='left'>판매기업</th>
     <th class='left'>사업자번호</th>
     <th class='left'>대표자</th>
     <th class='left'>구매기업</th>
     <th class='left'>사업자번호</th>
     <th class='left'>대표자</th>
     <th class='left'>작성일</th>
     <th class='left'>사용</th>
     <th class='left'>명령</th>
   </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
	for (int i = 0; i < arr.size();) {
	  DirectRelationVO v = arr.remove(i);
	  intTotalCnt = v.TOTAL_CNT;
%>
    <tr sid=<%=IntegerCryptoUtil.crypt(v.SELL_COMPANY) %> bid=<%=IntegerCryptoUtil.crypt(v.BUY_COMPANY) %>>
      <td><%=v.SELL_COMPANY_NAME %></td>
      <td><%=FormatUtil.addDashBizNo(v.SELL_COMPANY_BIZNO)%></td>
      <td><%=v.SELL_COMPANY_CEO_NAME %></td>
      <td><%=v.BUY_COMPANY_NAME %></td>
      <td><%=FormatUtil.addDashBizNo(v.BUY_COMPANY_BIZNO) %></td>
      <td><%=v.BUY_COMPANY_CEO_NAME %></td>
      <td><%=v.CREATE_DATE.substring(0, 10) %></td>
      <td><%=v.USE_YN %></td>
      <td><a class='btn' onclick='edit(this)'>수정</a></td>
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