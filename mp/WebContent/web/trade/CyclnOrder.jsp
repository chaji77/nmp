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
// yyyyMMddHHmmss 를 yyyy/MM/dd HH:mm:ss 로 보인다.
String ymdhms(String s) {
  return FormatUtil.addSeparatorDateTime(StrUtil.nvl(s).trim(), "/");
}
// 금액. 값이 없으면 '-' 로 보인다. 전문 컬럼은 앞에 0 이 채워져 오므로 숫자로 걸러낸다.
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
// 되돌아갈 목록. 실제 역할은 아래에서 주문의 거래당사자로 다시 정한다.
String strListPage = "CyclnOrders.jsp?role="
                   + (CyclnOrderVO.ROLE_SELLER.equals(request.getParameter("role")) ? CyclnOrderVO.ROLE_SELLER : CyclnOrderVO.ROLE_BUYER);
String strReturnForError = "<script>alert('열람권한이 없습니다.');location.href = '"+strListPage+"';</script>";

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

// 보는 사람의 입장은 프로시저가 정해준다.
String  strRole      = CyclnOrderVO.ROLE_SELLER.equals(vo.ROLE) ? CyclnOrderVO.ROLE_SELLER : CyclnOrderVO.ROLE_BUYER;
boolean isSeller     = CyclnOrderVO.ROLE_SELLER.equals(strRole);
String  strPageTitle = isSeller ? "납품내역" : "발주내역";
strListPage = "CyclnOrders.jsp?role=" + strRole;

// 수량/총액을 고칠 수 있는지는 CYCLN_ORDER_STATUS 의 변경요청/변경승인 플래그가 정한다.
// 결제전문이 나간 뒤에는 상태와 무관하게 막는다.
boolean isEditable  = vo.isItemEditable() && StrUtil.nvl(vo.CQ100_STATUS).equals("");
String  strReadOnly = isEditable ? "" : "readOnly";

// 결제가 끝나면 결제정보를 보이고, 제품정보에서 요청수량/요청단가는 감춘다.
boolean isSettled   = vo.isSettled();
String  strLoanRate = vo.getLoanRate();

// 합계금액 행
BigDecimal bdReqQty    = BigDecimal.ZERO;
BigDecimal bdQty       = BigDecimal.ZERO;
BigDecimal bdSupplyAmt = BigDecimal.ZERO;
BigDecimal bdTaxAmt    = BigDecimal.ZERO;
BigDecimal bdTotalAmt  = BigDecimal.ZERO;
for (CyclnOrderDetailVO.ItemVO r : vo.ITEMS) {
  try {
    bdReqQty    = bdReqQty.add(new BigDecimal(StrUtil.nvl(r.REQQTY, "0")));
    bdQty       = bdQty.add(new BigDecimal(StrUtil.nvl(r.QTY, "0")));
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
<title><%=strPageTitle%></title>
<style>
/* 안내문 모양은 web/trade/Contracts.jsp 와 맞춘다. */
ul.exp {display:flex;flex-flow:row wrap;justify-content:left;margin:20px 0;padding:10px;border:1px solid #ddd;color:#888;}
ul.exp>li {padding:10px;}
ul.exp>li>ul>li {padding:3px 0;}
ul.exp>li>ul>li>strong {color:#000;}
/* 입력칸 뒤의 '원'/단위가 잘리지 않도록 그 글자 자리를 빼고 폭을 잡는다. */
table#items td {vertical-align:middle;white-space:nowrap;}
table#items td.name {white-space:normal;word-break:break-all;}
table#items tr.sum {background-color:#fafafa;font-weight:bold;}
table#items tr.sum td {color:#000;}
table#items input.num {width:calc(100% - 22px);min-width:0;box-sizing:border-box;text-align:right;}
table#items textarea {width:100%;box-sizing:border-box;}
/* 자동계산 칸은 입력칸이 아니라는 게 보이게 한다. */
table#items input[readOnly] {background-color:#f5f5f5;color:#555;}
table#items textarea[readOnly] {background-color:#f5f5f5;color:#555;}
.won, .unit {color:#888;margin-left:2px;}
.estimate-type {margin:10px 0;padding:10px;border:3px solid #E8DFCF;}
.estimate-type strong {color:#c00;}
/* style.css 의 인쇄 규칙은 .btn 만 감춘다. div.btns 안의 목록보기는 따로 감춰야 한다. */
@media print {
  div.btns {display:none;}
}
</style>
<script>
/* 계산서 종류. '1'(과세)일 때만 총액에 부가세가 포함돼 있다. */
var ESTIMATE_TYPE = "<%=StrUtil.nvl(vo.ESTIMATE_TYPE)%>";
var IS_VAT        = (ESTIMATE_TYPE === "1");
var SUPPLY_RATIO  = IS_VAT ? (10 / 11) : 1;

/* 쉼표가 섞인 입력값을 숫자로 바꾼다. 비어 있거나 숫자가 아니면 0. */
function toNumber(str) {
  var n = parseFloat(String(str).replace(/[^0-9.-]/g, ""));
  return isNaN(n) ? 0 : n;
}
/* 소수점 자리수를 지정해 반올림한다. */
function roundTo(n, digits) {
  var p = Math.pow(10, digits);
  return Math.round(n * p) / p;
}
/*
 * 한 줄 다시 계산. 총액과 수량이 입력값이고 나머지는 여기서 나온다.
 * 수량/단가는 발주내역이면 요청수량·요청단가, 납품내역이면 납품수량·납품단가다.
 *   공급가액 = 총액 × (과세면 10/11, 아니면 1)
 *   세액     = 과세면 공급가액 ÷ 10, 아니면 0
 *   단가     = 공급가액 ÷ 수량 (소수 둘째자리까지)
 */
function calcRow(tr) {
  var $tr    = $(tr);
  var total  = toNumber($tr.find("input.total").val());
  var qty    = toNumber($tr.find("input.qty").val());
  var supply = total * SUPPLY_RATIO;
  var tax    = IS_VAT ? Math.round(supply / 10) : 0;
  var price  = (qty === 0) ? 0 : roundTo(supply / qty, 2);

  $tr.find("input.supply").val(addComma(Math.round(supply)));
  $tr.find("input.tax").val(addComma(tax));
  $tr.find("input.price").val(addComma(price));
}
/* 합계 행 다시 계산. */
function sumItems() {
  var sum = function(cls) {
    var total = 0;
    $("table#items input." + cls).each(function() { total += toNumber($(this).val()); });
    return total;
  };
  $("#sumQty").text(addComma(sum("qty")));
  $("#sumSupplyAmt").text(addComma(sum("supply")));
  $("#sumTaxAmt").text(addComma(sum("tax")));
  $("#sumTotalAmt").text(addComma(sum("total")));
}
$(document).ready(function() {
  $("table#items").on("keyup change", "input.qty, input.total", function() {
    calcRow($(this).closest("tr"));
    sumItems();
  });
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle%></span>
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

<%-- 결제정보는 결제가 끝난 건에만 보인다. --%>
<% if (isSettled) { %>
<h3>결제정보</h3>

<ul class='detail'>
  <li class='th'>발주계약금액</li>
  <li class='td'><%=won(vo.PURC_PRIC)%></li>
  <li class='th'>결제예정금액</li>
  <li class='td'><%=won(vo.SETL_PLN_PRIC)%></li>
  <li class='th'>실결제금액</li>
  <li class='td'>
    <strong><%=won(vo.SETL_PRIC)%></strong><%=strLoanRate.equals("") ? "" : "(구매자금대출 "+strLoanRate+"%)"%>
  </li>
  <li class='th'>결제일시</li>
  <li class='td'><%=dash(ymdhms(vo.PAYTIME))%></li>
<%-- 만기일은 대출을 갚는 구매기업에만 보인다. --%>
<% if (!isSeller) { %>
  <li class='th'>만기일(대출상환날짜)</li>
  <li class='td wide'><%=ymd(vo.MTR_YMD)%></li>
<% } %>
  <li class='th'>결제예정일</li>
  <li class='td'><%=ymd(vo.SETL_PLN_YMD)%></li>
  <li class='th'>세금계산서발행일</li>
  <li class='td'><%=ymd(vo.TAX_ISSU_YMD)%></li>
</ul>
<% } %>

<h3>계약기본정보</h3>

<ul class='detail'>
  <li class='th'>발주-ID</li>
  <li class='td'><%=dash(vo.ORDERNO)%></li>
  <li class='th'>등록일시</li>
  <li class='td'><%=ymdhms(vo.REGTIME)%></li>
  <li class='th'>발주계약서명</li>
  <li class='td'><%=dash(vo.ORDERNAME)%></li>
  <li class='th'>상태</li>
  <li class='td'><strong style='color:blue;'><%=CyclnOrderVO.getOrderStatusNm(vo.CODE_NM, vo.STATUS, vo.CQ100_STATUS, vo.TRX_CLS)%></strong></li>
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

<div class='estimate-type'>계산서종류 : <strong><%=vo.getEstimateTypeNm()%></strong></div>

<table id='items' class='detail'>
  <colgroup>
    <col width='160'/>
<%-- 결제가 끝나면 요청수량/요청단가는 의미가 없어 감춘다. --%>
<% if (!isSettled) { %>
    <col width='100'/>
    <col width='120'/>
<% } %>
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
<% if (!isSettled) { %>
      <th class='center'>요청수량</th>
      <th class='center'>요청단가</th>
<% } %>
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
      <td class='center name'><%=dash(r.PRD_TITLE)%>
        <input type='hidden' name='prd_id' value='<%=StrUtil.nvl(r.PRD_ID)%>'>
      </td>
<% if (isSettled) { %>
      <%-- 결제가 끝난 건은 고칠 수 없으므로 입력칸 없이 글자로만 보인다. --%>
      <td class='right'><%=amt(r.QTY)%><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span></td>
      <td class='right'><%=amt(r.PRICE)%><span class='won'>원</span></td>
      <td class='right'><%=amt(r.SUPPLYAMT)%><span class='won'>원</span></td>
      <td class='right'><%=amt(r.TAXAMT)%><span class='won'>원</span></td>
      <td class='right'><%=amt(r.TOTALAMT)%><span class='won'>원</span></td>
      <td class='left mobile_hide'><%=StrUtil.nvl(r.DESCRIPTION)%></td>
<% } else { %>
<%-- 고치는 수량/단가가 역할에 따라 다르다.
     발주내역(구매사)은 요청수량, 납품내역(판매사)은 납품수량. 단가는 총액에서 자동으로 나온다. --%>
<% if (isSeller) { %>
      <td class='right'><%=amt(r.REQQTY)%><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span></td>
      <td class='right'><%=amt(r.REQPRICE)%><span class='won'>원</span></td>
      <td class='right'>
        <input type='text' name='qty' class='num qty' value='<%=amt(r.QTY)%>' <%=strReadOnly%>><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span>
      </td>
      <td class='right'>
        <input type='text' name='price' class='num price' value='<%=amt(r.PRICE)%>' readOnly><span class='won'>원</span>
      </td>
<% } else { %>
      <td class='right'>
        <input type='text' name='reqqty' class='num qty' value='<%=amt(r.REQQTY)%>' <%=strReadOnly%>><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span>
      </td>
      <td class='right'>
        <input type='text' name='reqprice' class='num price' value='<%=amt(r.REQPRICE)%>' readOnly><span class='won'>원</span>
      </td>
      <td class='right'><%=amt(r.QTY)%><span class='unit'><%=StrUtil.nvl(r.UNIT)%></span></td>
      <td class='right'><%=amt(r.PRICE)%><span class='won'>원</span></td>
<% } %>
      <td class='right'>
        <input type='text' name='supplyamt' class='num supply' value='<%=amt(r.SUPPLYAMT)%>' readOnly><span class='won'>원</span>
      </td>
      <td class='right'>
        <input type='text' name='taxamt' class='num tax' value='<%=amt(r.TAXAMT)%>' readOnly><span class='won'>원</span>
      </td>
      <td class='right'>
        <input type='text' name='totalamt' class='num total' value='<%=amt(r.TOTALAMT)%>' <%=strReadOnly%>><span class='won'>원</span>
      </td>
      <td class='left mobile_hide'>
        <textarea name='description' rows='2' <%=strReadOnly%>><%=StrUtil.nvl(r.DESCRIPTION)%></textarea>
      </td>
<% } %>
    </tr>
<%
  }
%>
    <tr class='sum'>
      <td class='center'>합 계</td>
<% if (isSettled) { %>
      <td class='right'><%=StrUtil.addComma(bdQty.toPlainString())%></td>
      <td></td>
<% } else if (isSeller) { %>
<%-- 합계도 고치는 쪽 수량만 다시 계산된다. --%>
      <td class='right'><%=StrUtil.addComma(bdReqQty.toPlainString())%></td>
      <td></td>
      <td class='right'><span id='sumQty'><%=StrUtil.addComma(bdQty.toPlainString())%></span></td>
      <td></td>
<% } else { %>
      <td class='right'><span id='sumQty'><%=StrUtil.addComma(bdReqQty.toPlainString())%></span></td>
      <td></td>
      <td class='right'><%=StrUtil.addComma(bdQty.toPlainString())%></td>
      <td></td>
<% } %>
      <td class='right'><span id='sumSupplyAmt'><%=StrUtil.addComma(bdSupplyAmt.toPlainString())%></span><span class='won'>원</span></td>
      <td class='right'><span id='sumTaxAmt'><%=StrUtil.addComma(bdTaxAmt.toPlainString())%></span><span class='won'>원</span></td>
      <td class='right'><font color='red'><span id='sumTotalAmt'><%=StrUtil.addComma(bdTotalAmt.toPlainString())%></span></font><span class='won'>원</span></td>
      <td class='mobile_hide'></td>
    </tr>
<%
} else out.println("<tr><td colspan='"+(isSettled?7:9)+"' class='noentry'>등록된 제품이 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div class='btns'>
  <a href='<%=strListPage%>' class='cancel'>목록보기</a>
</div>

<p>&nbsp;</p>
<%@ include file="../includes/Footer.jsp" %>
