<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
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
// yyyyMMddHHmmss 를 yyyy/MM/dd HH:mm 으로 보인다.
String ymdhm(String s) {
  s = FormatUtil.addSeparatorDateTime(StrUtil.nvl(s).trim(), "/");
  return (s.length()>16) ? s.substring(0, 16) : s;
}
// 금액. 전문 컬럼이 고정폭이라 '000000011352000' 처럼 앞에 0 이 붙어 오므로 숫자로 한 번 걸러낸다.
String won(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("")) return "-";
  try {
    s = new BigDecimal(s).stripTrailingZeros().toPlainString();
  } catch (NumberFormatException e) {
    return s;
  }
  return StrUtil.addComma(s);
}
%>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(strCpyId));
else return;

// 회원별 화면은 구매·판매를 구분하지 않고 그 회사가 끼어있는 거래를 모두 본다.
CyclnOrderVO pvo    = new CyclnOrderVO();
pvo.PAGE            = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT         = 20;
pvo.CPY_ID          = intCpyId;
pvo.ROLE            = CyclnOrderVO.ROLE_ALL;
pvo.ORDERNO_COND    = StrUtil.nvl(request.getParameter("orderno"), "");
// 거래상대 검색어. CompanyHeader 가 탭 이동 때 회사명을 cpy_nm 으로 넘기므로 이름을 따로 쓴다.
pvo.CPY_NAME_COND   = StrUtil.nvl(request.getParameter("partner_nm"), "");
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

// 현재 페이지 발주계약금액 총액
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
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>싸이클론거래</title>
<style>
table.detail td {line-height:1.7em;vertical-align:top;}
/* 한 칸에 두 줄을 쌓는다. 아랫줄은 딸린 값이라는 게 보이게 흐리고 작게 쓴다. */
table.detail td .sub, table.detail th .sub {display:block;color:#888;font-weight:normal;font-size:0.92em;}
.ordername {max-width:260px;white-space:wrap;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "CyclnOrdersPerCpy.jsp";
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
  <span class='title'>싸이클론거래</span>
  <span class='more'>
    <a class='btn white magnify mobile_show'>검색</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="12" />
</jsp:include>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
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
          <label>거래상대</label>
          <input type='search' name='partner_nm' placeholder='거래상대 기업명' value='<%=pvo.CPY_NAME_COND%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
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
      <a href='CyclnOrdersPerCpy.jsp?cpy_id=<%=strCpyId%>' title='초기화'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<div style='margin-bottom:15px;text-align:right;'><strong>현재 페이지 발주계약금액 총액 : <font color='red'><%=StrUtil.addComma(bdPagePurcPric.toPlainString())%></font>원</strong></div>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>발주-ID<span class='sub'>(거래일자)</span></th>
      <th class='left'>발주서명</th>
      <th class='left'>구매기업<span class='sub'>판매기업</span></th>
      <th class='left'>요청납기일<span class='sub'>만기일</span></th>
      <th class='right'>발주계약금액<span class='sub'>결제예정금액</span></th>
      <th class='right'>실결제금액</th>
      <th class='left'>등록일시<span class='sub'>결제일시</span></th>
      <th class='left'>상태</th>
      <th class='center'>바로가기</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CyclnOrderVO vo : arr) {
%>
    <tr>
      <td class='left'>
        <a href='CyclnOrderPerCpy.jsp?orderno=<%=vo.ORDERNO%>&cpy_id=<%=strCpyId%>'><strong><%=vo.ORDERNO%></strong></a>
        <span class='sub'>(<%=ymd(vo.TRADEDATE)%>)</span>
      </td>
      <td class='left ordername'><%=dash(vo.ORDERNAME)%></td>
      <td class='left'><%=dash(vo.BC_NAME)%><span class='sub'><%=dash(vo.SC_NAME)%></span></td>
      <td class='left'><%=dash(ymd(vo.REQDLVDATE))%><span class='sub'><%=dash(ymd(vo.MTR_YMD))%></span></td>
      <td class='right'><%=won(vo.PURC_PRIC)%><span class='sub'><%=won(vo.SETL_PLN_PRIC)%></span></td>
      <td class='right'><%=won(vo.SETL_PRIC)%></td>
      <td class='left'><%=dash(ymdhm(vo.REGTIME))%><span class='sub'><%=dash(ymdhm(vo.PAYTIME))%></span></td>
      <td class='left'><%=vo.getOrderStatusNm()%></td>
      <td class='center'><a href='CyclnOrderPerCpy.jsp?orderno=<%=vo.ORDERNO%>&cpy_id=<%=strCpyId%>' class='btn white'>자세히</a></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='9' class='noentry'>검색조건에 맞는 거래가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>
<%@ include file="../Footer.jsp" %>
