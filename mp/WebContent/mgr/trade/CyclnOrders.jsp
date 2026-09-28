<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
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
// 000.110 형태의 수수료율을 0.11% 로 다듬는다.
String rate(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("")) return "";
  try {
    return new java.math.BigDecimal(s).stripTrailingZeros().toPlainString() + "%";
  } catch (NumberFormatException e) {
    return s;
  }
}
%>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

CyclnOrderVO pvo   = new CyclnOrderVO();
pvo.PAGE           = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT        = 20;
pvo.ORDERNO_COND   = StrUtil.nvl(request.getParameter("orderno"), "");
pvo.TRADEDATE_START = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
pvo.TRADEDATE_END   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
pvo.setStatusCd(StrUtil.nvl(request.getParameter("status_cd"), ""));

String strBcId  = StrUtil.nvl(request.getParameter("bc_id"), "0");
String strScId  = StrUtil.nvl(request.getParameter("sc_id"), "0");
String strBcNm  = StrUtil.nvl(request.getParameter("bc_nm"), "");
String strScNm  = StrUtil.nvl(request.getParameter("sc_nm"), "");
if (!StrUtil.isOnlyNumeric(strBcId)) strBcId = "0";
if (!StrUtil.isOnlyNumeric(strScId)) strScId = "0";
pvo.BC_ID = Integer.parseInt(strBcId);
pvo.SC_ID = Integer.parseInt(strScId);

// 화면 표시용 값(프로시저에 넘기기 전 형태를 유지한다)
String strStartYmd = pvo.TRADEDATE_START;
String strEndYmd   = pvo.TRADEDATE_END;

int intTotalCnt = 0;
ArrayList<CyclnOrderVO> arr = null;
try {
  arr = new CyclnBean().CYCLN_ORDER_LIST_PROC(pvo);
  if (arr.size()>0) intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
  arr = null;
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>싸이클론 주문관리</title>
<style>
table.detail, table.searchbox {font-size:110%;}
table.detail td {line-height:1.7em;vertical-align:top;}
table.detail td .sub, table.detail th .sub {display:block;color:#888;font-weight:normal;}
.ordername {max-width:260px;white-space:wrap;}
</style>

<script>
var strCompanyTarget = "bc"; // 구매사(bc) / 판매사(sc) 중 검색 대상
function searchCompany(target) {
  strCompanyTarget = target;
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch[strCompanyTarget + "_id"].value = $(obj).attr("cid");
  document.frmSearch[strCompanyTarget + "_nm"].value = $(obj).text();
  closePopup();
  goPage(1);
}
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "CyclnOrders.jsp";
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
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>싸이클론 거래관리</span>
  <span class='more'>
    <a class='btn white magnify mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='bc_id' value='<%=strBcId%>'>
<input type='hidden' name='sc_id' value='<%=strScId%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>구매사</label>
          <input type='search' name='bc_nm' readOnly placeholder='구매사' onclick='searchCompany("bc");' value='<%=strBcNm%>'>
        </li>
        <li>
          <label>판매사</label>
          <input type='search' name='sc_nm' readOnly placeholder='판매사' onclick='searchCompany("sc");' value='<%=strScNm%>'>
        </li>
        <li>
          <label>주문번호</label>
          <input type='search' name='orderno' placeholder='주문번호' value='<%=pvo.ORDERNO_COND%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
        </li>
        <li>
          <label>거래일</label>
          <input type='date' name='start_ymd' value='<%=strStartYmd%>' style='width:auto;'>
          <input type='date' name='end_ymd' value='<%=strEndYmd%>' style='width:auto;'>
        </li>
        <li class='search-option-status'>
          <label>진행상태</label>
          <select name='status_cd' onChange="goPage(1);">
            <option value=''>전체</option>
<%
for (String[] f : CyclnOrderVO.STATUS_FILTERS) {
  out.println("            <option value=\""+f[0]+"\" "+(pvo.STATUS_CD.equals(f[0])?"selected":"")+">"+f[1]+"</option>");
}
%>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='CyclnOrders.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>매매계약번호</th>
      <th class='left'>거래일시</th>
      <th class='left'>발주 계약서명</th>
      <th class='left'>납품기한</th>
      <th class='left'>구매기업<span class='sub' style='margin-top:5px;'>판매기업</span></th>
      <th class='right'>매매금액</th>
      <th class='right'>수수료율</th>
      <th class='left'>결제예정일</th>
      <th class='left'>세금계산서 발행일</th>
      <th class='left'>상태</th>
      <th class='left'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CyclnOrderVO vo : arr) {
%>
    <tr>
      <td class='left'><strong><%=vo.ORDERNO%></strong></td>
      <td class='left'><%=ymd(vo.TRADEDATE)%></td>
      <td class='left ordername'><%=vo.ORDERNAME%></td>
      <td class='left'><%=ymd(vo.REQDLVDATE)%></td>
      <td class='left'><%=dash(vo.BC_NAME)%><span class='sub'><%=dash(vo.SC_NAME)%></span></td>
      <td class='right'><%=StrUtil.addComma(vo.PURC_PRIC)%></td>
      <td class='right'><%=rate(vo.FEE_RATE)%></td>
      <td class='left'><%=ymd(vo.SETL_PLN_YMD)%></td>
      <td class='left'><%=ymd(vo.TAX_ISSU_YMD)%></td>
      <td class='left'><%=vo.getStatusNm()%></td>
      <td class='left'></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='11' class='noentry'>검색조건에 맞는 주문이 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>
<%@ include file="../Footer.jsp" %>
