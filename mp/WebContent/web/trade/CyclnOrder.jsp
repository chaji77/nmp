<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
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
// 금액/단가에 자릿수 구분을 넣는다. 13188.410 처럼 의미없는 끝자리 0 은 버린다.
String amt(String s) {
  s = StrUtil.nvl(s, "0");
  try {
    s = new BigDecimal(s).stripTrailingZeros().toPlainString();
  } catch (NumberFormatException e) {
    return s;
  }
  return StrUtil.addComma(s);
}
%>
<%
String strReturnForError = "<script>alert('열람권한이 없습니다.');location.href = 'CyclnOrders.jsp';</script>";

String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) return;
int intCpyId = Integer.parseInt(strCpyId);

String strOrderNo = StrUtil.nvl(request.getParameter("orderno"));
if (strOrderNo.equals("")) {
  out.print(strReturnForError);
  return;
}

// 프로시저가 거래당사자(구매기업/판매기업)인지 확인한다. 아니면 null 이다.
CyclnOrderDetailVO vo = new CyclnBean().CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC(strOrderNo, intCpyId);
if (vo==null) {
  out.print(strReturnForError);
  return;
}

// 로그인 회사가 구매기업이면 구매사 기준 상태명을 보인다.
String strRole = vo.CPYBUYER.equals(strCpyId) ? CyclnOrderVO.ROLE_BUYER : CyclnOrderVO.ROLE_SELLER;

// 합계금액 행
BigDecimal bdReqQty    = BigDecimal.ZERO;
BigDecimal bdQty       = BigDecimal.ZERO;
BigDecimal bdSupplyAmt = BigDecimal.ZERO;
BigDecimal bdTaxAmt    = BigDecimal.ZERO;
BigDecimal bdTotalAmt  = BigDecimal.ZERO;
for (CyclnOrderDetailVO.ItemVO r : vo.ITEMS) {
  try {
    // 납품수량은 '690(개)' 처럼 단위가 붙어 오므로 숫자만 뽑아서 더한다.
    bdReqQty    = bdReqQty.add(new BigDecimal(StrUtil.nvl(r.REQQTY, "0")));
    bdQty       = bdQty.add(new BigDecimal(StrUtil.nvl(StrUtil.extractInteger(r.QTY), "0")));
    bdSupplyAmt = bdSupplyAmt.add(new BigDecimal(StrUtil.nvl(r.SUPPLYAMT, "0")));
    bdTaxAmt    = bdTaxAmt.add(new BigDecimal(StrUtil.nvl(r.TAXAMT, "0")));
    bdTotalAmt  = bdTotalAmt.add(new BigDecimal(StrUtil.nvl(r.TOTALAMT, "0")));
  } catch (NumberFormatException e) {
    // 숫자가 아닌 값은 합계에서 제외한다.
  }
}
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>발주내역</title>
<style>
/* 입력칸 뒤의 '원'/단위가 잘리지 않도록 그 글자 자리를 빼고 폭을 잡는다. */
table#items td {vertical-align:middle;white-space:nowrap;}
table#items td.name {white-space:normal;word-break:break-all;}
table#items tr.sum {background-color:#fafafa;font-weight:bold;}
table#items tr.sum td {color:#000;}
table#items input.num {width:calc(100% - 22px);min-width:0;box-sizing:border-box;text-align:right;}
table#items textarea {width:100%;box-sizing:border-box;}
.won, .unit {color:#888;margin-left:2px;}
</style>
<script>
/* 쉼표가 섞인 입력값을 숫자로 바꾼다. 비어 있거나 숫자가 아니면 0. */
function toNumber(str) {
  var n = parseFloat(String(str).replace(/[^0-9.-]/g, ""));
  return isNaN(n) ? 0 : n;
}
/* 입력값이 바뀌면 합계금액 행을 다시 계산한다. */
function sumItems() {
  var sum = function(cls) {
    var total = 0;
    $("table#items input." + cls).each(function() { total += toNumber($(this).val()); });
    return total;
  };
  $("#sumReqQty").text(addComma(sum("sum-reqqty")));
  $("#sumSupplyAmt").text(addComma(sum("sum-supplyamt")));
  $("#sumTaxAmt").text(addComma(sum("sum-taxamt")));
  $("#sumTotalAmt").text(addComma(sum("sum-totalamt")));
}
$(document).ready(function() {
  $("table#items").on("keyup change", "input.num", sumItems);
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>발주내역</span>
  <span class='more'>
    <a href='javascript:self.print();' class='btn lurian'>인쇄하기</a>
  </span>
</div>

<ul class='exp'>
  <li class='mobile_hide'><i class="fa fa-commenting fa-5x" style="color:#246CEB;"></i></li>
  <li>
    <ul>
      <li>발주계약서 상세정보를 확인하는 화면입니다.</li>
    </ul>
  </li>
</ul>

<h3>계약기본정보</h3>

<ul class='detail'>
  <li class='th'>발주계약서명</li>
  <li class='td'><%=dash(vo.ORDERNAME)%></li>
  <li class='th'>상태</li>
  <li class='td'><strong style='color:blue;'><%=CyclnOrderVO.getOrderStatusNm(vo.STATUS, vo.CQ100_STATUS, vo.TRX_CLS, strRole)%></strong></li>
  <li class='th'>거래일자</li>
  <li class='td'><%=ymd(vo.TRADEDATE)%></li>
  <li class='th'>요청납기일</li>
  <li class='td'><%=ymd(vo.REQDLVDATE)%></li>
  <li class='th'>구매기업</li>
  <li class='td'><%=dash(vo.BC_NAME)%></li>
  <li class='th'>판매기업</li>
  <li class='td'><%=dash(vo.SC_NAME)%></li>
  <li class='th'>도착지</li>
  <li class='td wide'><%=dash(vo.DLVADDRESS)%></li>
</ul>

<h3>제품정보</h3>

<table id='items' class='detail'>
  <colgroup>
    <col width='160'/>
    <col width='100'/>
    <col width='120'/>
    <col width='100'/>
    <col width='100'/>
    <col width='115'/>
    <col width='105'/>
    <col width='120'/>
    <col width='*' class='mobile_hide'/>
  </colgroup>
  <thead>
    <tr>
      <th class='center'>제품명</th>
      <th class='center'>요청수량</th>
      <th class='center'>요청단가</th>
      <th class='center'>납품수량</th>
      <th class='center'>납품단가</th>
      <th class='center'>공급가액</th>
      <th class='center'>세액</th>
      <th class='center'>총액</th>
      <th class='center mobile_hide'>기타제품사양</th>
    </tr>
  </thead>
  <tbody>
<%
if (vo.ITEMS.size()>0) {
  for (CyclnOrderDetailVO.ItemVO r : vo.ITEMS) {
%>
    <tr>
      <td class='center name'><%=dash(r.PRD_TITLE)%></td>
      <td class='right'>
        <input type='text' name='reqqty' class='num sum-reqqty' value='<%=amt(r.REQQTY)%>'><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span>
      </td>
      <td class='right'>
        <input type='text' name='reqprice' class='num' value='<%=amt(r.REQPRICE)%>'><span class='won'>원</span>
      </td>
      <td class='center'><%=dash(r.QTY)%></td>
      <td class='right'><%=amt(r.PRICE)%><span class='won'>원</span></td>
      <td class='right'>
        <input type='text' name='supplyamt' class='num sum-supplyamt' value='<%=amt(r.SUPPLYAMT)%>'><span class='won'>원</span>
      </td>
      <td class='right'>
        <input type='text' name='taxamt' class='num sum-taxamt' value='<%=amt(r.TAXAMT)%>'><span class='won'>원</span>
      </td>
      <td class='right'>
        <input type='text' name='totalamt' class='num sum-totalamt' value='<%=amt(r.TOTALAMT)%>'><span class='won'>원</span>
      </td>
      <td class='left mobile_hide'>
        <textarea name='description' rows='2'><%=StrUtil.nvl(r.DESCRIPTION)%></textarea>
      </td>
    </tr>
<%
  }
%>
    <tr class='sum'>
      <td class='center'>합 계 금 액</td>
      <td class='center' id='sumReqQty'><%=StrUtil.addComma(bdReqQty.toPlainString())%></td>
      <td></td>
      <td class='center'><%=StrUtil.addComma(bdQty.toPlainString())%></td>
      <td></td>
      <td class='right'><span id='sumSupplyAmt'><%=StrUtil.addComma(bdSupplyAmt.toPlainString())%></span><span class='won'>원</span></td>
      <td class='right'><span id='sumTaxAmt'><%=StrUtil.addComma(bdTaxAmt.toPlainString())%></span><span class='won'>원</span></td>
      <td class='right'><font color='red'><span id='sumTotalAmt'><%=StrUtil.addComma(bdTotalAmt.toPlainString())%></span></font><span class='won'>원</span></td>
      <td class='mobile_hide'></td>
    </tr>
<%
} else out.println("<tr><td colspan='9' class='noentry'>등록된 제품이 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div class='btns'>
  <a href='CyclnOrders.jsp' class='cancel'>목록보기</a>
</div>

<p>&nbsp;</p>
<%@ include file="../includes/Footer.jsp" %>
