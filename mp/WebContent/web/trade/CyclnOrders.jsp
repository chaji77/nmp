<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%!
// 8자리(yyyyMMdd)일 때만 구분자를 넣는다.
String ymd(String s) {
  s = StrUtil.nvl(s).trim();
  return (s.length()==8) ? FormatUtil.addSeparatorDate(s) : s;
}
// 값이 없으면 '-' 로 보인다.
String dash(String s) {
  s = StrUtil.nvl(s).trim();
  return s.equals("") ? "-" : s;
}
// yyyyMMddHHmmss 를 yyyy/MM/dd HH:mm 으로 보인다(초는 버린다).
String ymdhm(String s) {
  s = FormatUtil.addSeparatorDateTime(StrUtil.nvl(s).trim(), "/");
  return (s.length()>16) ? s.substring(0, 16) : s;
}
%>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) return;

String strPageTitle = "발주계약서";

CyclnOrderVO pvo    = new CyclnOrderVO();
pvo.PAGE            = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT         = 20;
pvo.BC_ID           = Integer.parseInt(strCpyId); // 로그인 회사가 구매사
pvo.ORDERNO_COND    = StrUtil.nvl(request.getParameter("orderno"), "");
pvo.SC_NAME_COND    = StrUtil.nvl(request.getParameter("sc_nm"), "");
pvo.STATUS_COND     = StrUtil.nvl(request.getParameter("status"), "");
pvo.TRADEDATE_START = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
pvo.TRADEDATE_END   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));

// 화면 표시용 값(프로시저 호출 시 구분자가 제거되므로 미리 담아둔다)
String strStartYmd = pvo.TRADEDATE_START;
String strEndYmd   = pvo.TRADEDATE_END;

int intTotalCnt = 0;
ArrayList<CyclnOrderVO> arr = null;
try {
  arr = new CyclnBean().CYCLN_ORDER_LIST_PER_CPY_ID_PROC(pvo);
  if (arr.size()>0) intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
  arr = null;
}

// 현재 페이지 매매금액 총액
BigDecimal bdPagePurcPric = BigDecimal.ZERO;
if (arr!=null) {
  for (CyclnOrderVO v : arr) {
    try {
      bdPagePurcPric = bdPagePurcPric.add(new BigDecimal(StrUtil.nvl(v.PURC_PRIC, "0")));
    } catch (NumberFormatException e) {
      // 숫자가 아닌 값은 합계에서 제외한다.
    }
  }
}
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle%></title>
<style>
table.detail td {line-height:1.7em;vertical-align:top;}
.ordername {max-width:260px;white-space:wrap;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.submit();
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle%></span>
  <span class='more'>
    <a class='btn white magnify mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>거래일</label>
          <input type='date' name='start_ymd' value='<%=strStartYmd%>' style='width:auto;'>
          <input type='date' name='end_ymd' value='<%=strEndYmd%>' style='width:auto;'>
        </li>
        <li>
          <label>주문번호</label>
          <input type='search' name='orderno' placeholder='주문번호' value='<%=pvo.ORDERNO_COND%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
        </li>
        <li>
          <label>판매기업</label>
          <input type='search' name='sc_nm' placeholder='판매기업명' value='<%=pvo.SC_NAME_COND%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
        </li>
        <li class='search-option-status'>
          <label>진행상태</label>
          <select name='status' onChange="goPage(1);">
            <option value=''>전체</option>
<%
for (String[] f : CyclnOrderVO.ORDER_STATUS) {
  out.println("            <option value=\""+f[0]+"\" "+(pvo.STATUS_COND.equals(f[0])?"selected":"")+">"+f[1]+"</option>");
}
%>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);' title='검색'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='CyclnOrders.jsp' title='초기화'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<div style='margin-bottom:15px;text-align:right;'><strong>현재 페이지 매매금액 총액 : <font color='red'><%=StrUtil.addComma(bdPagePurcPric.toPlainString())%></font>원</strong></div>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>주문번호</th>
      <th class='left'>거래일</th>
      <th class='left'>발주 계약서명</th>
      <th class='left'>판매기업</th>
      <th class='left'>납품기한</th>
      <th class='right'>매매금액</th>
      <th class='left'>등록일시</th>
      <th class='center'>진행상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CyclnOrderVO vo : arr) {
%>
    <tr>
      <td class='left'><a href='CyclnOrder.jsp?orderno=<%=vo.ORDERNO%>'><strong><%=vo.ORDERNO%></strong></a></td>
      <td class='left'><%=ymd(vo.TRADEDATE)%></td>
      <td class='left ordername'><%=dash(vo.ORDERNAME)%></td>
      <td class='left'><%=dash(vo.SC_NAME)%></td>
      <td class='left'><%=ymd(vo.REQDLVDATE)%></td>
      <td class='right'><%=StrUtil.addComma(vo.PURC_PRIC)%></td>
      <td class='left'><%=ymdhm(vo.CRETIME)%></td>
      <td class='center'><%=vo.getOrderStatusNm(CyclnOrderVO.ROLE_BUYER)%></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='8' class='noentry'>검색조건에 맞는 발주계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>
<%@ include file="../includes/Footer.jsp" %>
