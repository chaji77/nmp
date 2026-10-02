<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
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
// yyyyMMddHHmmss 를 yyyy/MM/dd HH:mm:ss 로 보인다.
String ymdhms(String s) {
  return FormatUtil.addSeparatorDateTime(StrUtil.nvl(s).trim(), "/");
}
// 금액. 값이 없으면 '-' 로 보인다.
// 전문 컬럼이 고정폭이라 '000000011352000' 처럼 앞에 0 이 붙어 오므로 숫자로 한 번 걸러낸다.
String won(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("")) return "-";
  try {
    s = new BigDecimal(s).stripTrailingZeros().toPlainString();
  } catch (NumberFormatException e) {
    return s;
  }
  return StrUtil.addComma(s) + "원";
}
%>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) return;

// role=S 면 판매기업 기준(납품내역관리), 그 외에는 구매기업 기준(발주계약서).
String  strRole     = CyclnOrderVO.ROLE_SELLER.equals(request.getParameter("role"))
                    ? CyclnOrderVO.ROLE_SELLER : CyclnOrderVO.ROLE_BUYER;
boolean isSeller    = CyclnOrderVO.ROLE_SELLER.equals(strRole);

String strPageTitle = isSeller ? "납품내역관리" : "발주계약서";
String strGuide     = isSeller ? "구매기업이 발주한 발주계약서 목록을 조회하고 관리하는 화면입니다."
                               : "우리 회사가 발주한 발주계약서 목록을 조회하는 화면입니다.";
String strCpyLabel  = isSeller ? "구매기업" : "판매기업"; // 목록에 보일 거래상대

CyclnOrderVO pvo    = new CyclnOrderVO();
pvo.PAGE            = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT         = 20;
pvo.CPY_ID          = Integer.parseInt(strCpyId);
pvo.ROLE            = strRole;
pvo.ORDERNO_COND    = StrUtil.nvl(request.getParameter("orderno"), "");
pvo.CPY_NAME_COND   = StrUtil.nvl(request.getParameter("cpy_nm"), "");
pvo.STATUS_COND     = StrUtil.nvl(request.getParameter("status"), "");
pvo.TRADEDATE_START = StrUtil.nvl(request.getParameter("start_ymd"));
pvo.TRADEDATE_END   = StrUtil.nvl(request.getParameter("end_ymd"));

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
/* 검색박스와 안내문 모양은 web/trade/Contracts.jsp 와 맞춘다. */
table.searchbox td {padding:20px;}
.searchbox label {width:60px;}
ul.exp {display:flex;flex-flow:row wrap;justify-content:left;margin:20px 0;padding:10px;border:1px solid #ddd;color:#888;}
ul.exp>li {padding:10px;}
ul.exp>li>ul>li {padding:3px 0;}
ul.exp>li>ul>li>strong {color:#000;}
table.detail td {line-height:1.7em;vertical-align:top;}
.ordername {max-width:260px;white-space:wrap;}
/* 한 칸에 두 줄을 쌓는다. 아랫줄은 딸린 값이라는 게 보이게 흐리고 작게 쓴다. */
.sub {display:block;color:#888;font-size:0.92em;}
@media only screen and (max-width:767px) {
  table.searchbox td {padding:5px;}
}
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
    <a href='CyclnOrderReg.jsp' class='btn'>등록</a>
    <a class='btn white magnify mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='role' value='<%=strRole%>'>
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
          <label><%=strCpyLabel%></label>
          <input type='search' name='cpy_nm' placeholder='<%=strCpyLabel%>명' value='<%=pvo.CPY_NAME_COND%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
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
      <a href='CyclnOrders.jsp?role=<%=strRole%>' title='초기화'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<ul class='exp'>
  <li class='mobile_hide'><i class="fa fa-commenting fa-5x" style="color:#246CEB;"></i></li>
  <li><ul><li><%=strGuide%></li></ul></li>
</ul>

<div style='margin-bottom:15px;text-align:right;'><strong>현재 페이지 매매금액 총액 : <font color='red'><%=StrUtil.addComma(bdPagePurcPric.toPlainString())%></font>원</strong></div>

<table class='detail'>
  <thead>
    <tr>
      <th class='center'>발주-ID<span class='sub'>(거래일자)</span></th>
      <th class='center'>발주서명<span class='sub'><%=strCpyLabel%></span></th>
      <th class='center'>요청납기일<span class='sub'>만기일</span></th>
      <th class='center'>발주계약금액<span class='sub'>결제예정금액</span></th>
      <th class='center'>실결제금액</th>
      <th class='center'>등록일시<span class='sub'>결제일시</span></th>
      <th class='center'>상태</th>
      <th class='center'>바로가기</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CyclnOrderVO vo : arr) {
%>
    <tr>
      <td class='center'>
        <a href='CyclnOrder.jsp?orderno=<%=vo.ORDERNO%>&role=<%=strRole%>'><strong><%=vo.ORDERNO%></strong></a>
        <span class='sub'>(<%=ymd(vo.TRADEDATE)%>)</span>
      </td>
      <td class='center ordername'><%=dash(vo.ORDERNAME)%><span class='sub'><%=dash(isSeller ? vo.BC_NAME : vo.SC_NAME)%></span></td>
      <td class='center'><%=dash(ymd(vo.REQDLVDATE))%><span class='sub'><%=dash(ymd(vo.MTR_YMD))%></span></td>
      <td class='right'><%=won(vo.PURC_PRIC)%><span class='sub'><%=won(vo.SETL_PLN_PRIC)%></span></td>
      <td class='right'><%=won(vo.SETL_PRIC)%></td>
      <td class='center'><%=dash(ymdhms(vo.REGTIME))%><span class='sub'><%=dash(ymdhms(vo.PAYTIME))%></span></td>
      <td class='center'><%=vo.getOrderStatusNm()%></td>
      <td class='center'><a href='CyclnOrder.jsp?orderno=<%=vo.ORDERNO%>&role=<%=strRole%>' class='btn white'>자세히</a></td>
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
