<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.CyclnOrderVO" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%
request.setCharacterEncoding("utf-8");
/* 승인·수정·취소로 내용이 바뀌는 화면이다. 뒤로가기로 지난 화면이 되살아나면
   이미 처리한 건을 처리 전 모습으로 보게 되므로 캐시를 남기지 않는다.
   Header.jsp 의 meta 태그는 뒤로가기 캐시에 듣지 않아 응답 헤더로 막는다. */
response.setHeader("Cache-Control", "no-store, must-revalidate");
response.setDateHeader("Expires", 0);
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
// 비었거나 0 이면 아직 채워지지 않은 값으로 본다.
boolean isZero(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("")) return true;
  try {
    return new BigDecimal(s).signum()==0;
  } catch (NumberFormatException e) {
    return false;
  }
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

// 결제가 끝나면 결제정보를 보이고, 제품정보에서 요청수량/요청단가는 감춘다.
boolean isSettled     = vo.isSettled();
// 은행에 접수(CL090)만 된 건은 예정 내용만 보인다.
boolean isPaymentSent = vo.isPaymentSent();
String  strLoanRate   = vo.getLoanRate();

// 할 수 있는 일은 VO 가 판단한다. 저장하는 쪽(Proc JSP)도 같은 판단을 다시 한다.
boolean canConfirm = vo.canConfirm(); // 판매기업 승인. CL080 전문이 전송대기로 등록된다
boolean canModify  = vo.canModify();  // 구매기업 수정. 승인 전까지만 된다
boolean canPay     = vo.canPay();     // 구매기업 결제접수. CL090 전문이 전송대기로 등록된다
boolean canChgReq    = vo.canChgReq();    // 승인 뒤 변경요청. 전문은 상대가 승인해야 나간다
boolean canChgCfm    = vo.canChgCfm();    // 상대 변경요청 승인. CL080 변경 전문이 나간다
boolean canCancelReq = vo.canCancelReq(); // 승인 뒤 취소요청. 상대 승인 없이 취소 전문이 나간다

// 입력칸은 저장할 수 있을 때만 연다. 발주가 끝난 뒤에는 고쳐도 보낼 곳이 없어
// 고칠 수 있는 것처럼 보이면 안 된다.
boolean isEditable  = canConfirm || canModify;
String  strReadOnly = isEditable ? "" : "readOnly";

String  strToday   = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
String  str7DaysAfter = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 7L * 24L * 60L * 60L * 1000L));
String  csrf_token = "";
if (canConfirm || canModify || canPay || canChgReq || canChgCfm || canCancelReq) {
  csrf_token = UUID.randomUUID().toString();
  session.setAttribute("csrf_token", csrf_token);
}

// 납품수량·납품단가는 판매기업이 승인하면서 채운다. 아직 비어 있으면 요청값을 기본으로 둔다.
// 합계도 입력칸도 이 값을 쓰므로 그리기 전에 한 번만 맞춰둔다.
for (CyclnOrderDetailVO.ItemVO r : vo.ITEMS) {
  if (isZero(r.QTY))   r.QTY   = StrUtil.nvl(r.REQQTY);
  if (isZero(r.PRICE)) r.PRICE = StrUtil.nvl(r.REQPRICE);
}

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
/* 오늘 날짜(yyyy-MM-dd). 요청납기일이 오늘 이후인지 보는 기준이다. */
var TODAY         = "<%=strToday%>";
/* 결제예정일 상한. 오늘부터 7일 뒤까지 고를 수 있다. */
var DAYS7         = "<%=str7DaysAfter%>";
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
/* 계산서 종류를 바꾸면 부가세 포함 여부가 달라져 모든 줄을 다시 계산한다. */
function recalcAll() {
  var sel = $("select[name='estimate_type']").val();
  if (sel) ESTIMATE_TYPE = sel;
  IS_VAT       = (ESTIMATE_TYPE === "1");
  SUPPLY_RATIO = IS_VAT ? (10 / 11) : 1;
  $("table#items tbody tr").not(".sum").each(function() { calcRow(this); });
  sumItems();
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
/* 승인 전 검사. 납품수량과 총액이 있어야 전문 금액이 만들어진다. */
function validateConfirm() {
  /* 요청납기일은 오늘 이후여야 한다. yyyy-MM-dd 라 글자 비교로 충분하다. */
  var reqdlvdate = $("input[name='reqdlvdate']").val();
  if (reqdlvdate === "" || reqdlvdate < TODAY) {
    showAlert("요청납기일을 다시 선택해주세요.");
    return false;
  }
  var booValid = true;
  $("table#items tbody tr").not(".sum").each(function() {
    if (toNumber($(this).find("input.qty").val()) <= 0) {
      toast("납품수량을 확인하십시오.");
      booValid = false;
      return false;
    }
    if (toNumber($(this).find("input.total").val()) <= 0) {
      toast("총액을 확인하십시오.");
      booValid = false;
      return false;
    }
  });
  return booValid;
}
/* 전문(CL080·CL090)을 등록한 뒤 은행 응답을 2초마다 읽는다. 2분이 지나면 그만둔다.
   취소하면 기다리기만 멈춘다. 이미 등록한 전문은 통신서버가 그대로 보낸다.
   done(msg) 는 끝났을 때 한 번 불린다. msg 가 null 이면 은행 처리 성공이다. */
var bankRun = 0; // 취소하면 올라가서 이전 확인의 응답을 버린다
function waitBank(kncd, r, done) {
  var run = ++bankRun;
  var tries = 0;
  showSpinner("은행 응답을 기다리고 있습니다.<br/><br/><a onclick='bankRun++;hideSpinner();location.reload();' class='btn'>취소</a>");
  (function poll() {
    $.post("CyclnTmsgResultProc.jsp", {"kncd":kncd, "tmsg_seq":r.tmsg_seq, "req_ymd":r.req_ymd}, function(d) {
      if (run!=bankRun) return;
      var json = null;
      try { json = JSON.parse($.trim(d)); } catch (e) { json = {"result":"wait"}; }
      if (json.result=="wait" && ++tries<60) { setTimeout(poll, 2000); return; }
      hideSpinner();
      done(json.result=="ok" ? null
         : json.result=="wait" ? "은행 응답이 지연되고 있습니다. 잠시 후 목록에서 상태를 확인하십시오."
         : json.msg);
    }).fail(function() {
      if (run!=bankRun) return;
      if (++tries<60) { setTimeout(poll, 2000); return; }
      hideSpinner();
      done("은행 응답을 확인하지 못했습니다. 잠시 후 목록에서 상태를 확인하십시오.");
    });
  })();
}
/* 승인. 성공하면 바뀐 상태를 보여주려고 같은 화면을 다시 띄운다. */
function confirmOrder() {
  if (!validateConfirm()) return;
  showCustomConfirm("승인하시겠습니까?<br/>승인하면 발주계약 내용이 은행으로 전송됩니다.", function() {
    showLoading();
    $.post("CyclnOrderConfirmProc.jsp", $("form[name='frmConfirm']").serialize(), function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("승인에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        waitBank("CL080", r, function(msg) {
          showAlert(msg === null ? "승인하였습니다." : msg, function() {
            /* replace 로 들어가야 처리 전 화면이 뒤로가기 기록에 남지 않는다. */
            location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
          });
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
/* 수정 전 검사. 판매기업 승인 전이라 전문은 나가지 않고 DB 만 바뀐다. */
function validateModify() {
  if ($("input[name='order_name']").val().trim() === "") {
    showAlert("발주계약서명을 입력하십시오.");
    return false;
  }
  var reqdlvdate = $("input[name='reqdlvdate']").val();
  if (reqdlvdate === "" || reqdlvdate < TODAY) {
    showAlert("요청납기일을 다시 선택해주세요.");
    return false;
  }
  if ($("input[name='addr']").val().trim() === "") {
    showAlert("도착지를 입력하십시오.");
    return false;
  }
  var booValid = true;
  $("table#items tbody tr").not(".sum").each(function() {
    var $tr = $(this);
    if ($tr.find("input[name='prd_title']").val().trim() === "") {
      toast("제품명을 입력하십시오.");
      booValid = false;
      return false;
    }
    if (toNumber($tr.find("input.qty").val()) <= 0) {
      toast("요청수량을 확인하십시오.");
      booValid = false;
      return false;
    }
    if (toNumber($tr.find("input.total").val()) <= 0) {
      toast("총액을 확인하십시오.");
      booValid = false;
      return false;
    }
  });
  return booValid;
}
/* 수정 저장. 성공하면 바뀐 내용을 보여주려고 같은 화면을 다시 띄운다. */
function saveOrder() {
  if (!validateModify()) return;
  showCustomConfirm("수정한 내용을 저장하시겠습니까?", function() {
    showLoading();
    $.post("CyclnOrderModProc.jsp", $("form[name='frmConfirm']").serialize(), function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("수정에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        showAlert("수정하였습니다.", function() {
          /* replace 로 들어가야 처리 전 화면이 뒤로가기 기록에 남지 않는다. */
          location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
/* 취소. 승인 전이라 전문은 나가지 않고 상태만 바뀐다.
   누른 쪽에 따라 구매사 취소(090) / 판매사 취소(095)로 갈리는 것은 프로시저가 정한다. */
function cancelOrder() {
  showCustomConfirm("이 발주계약서를 취소하시겠습니까?<br/>취소하면 되돌릴 수 없습니다.", function() {
    showLoading();
    $.post("CyclnOrderModProc.jsp", {
      "orderno"    : "<%=StrUtil.nvl(vo.ORDERNO)%>",
      "csrf_token" : $("input[name='csrf_token']").val(),
      "action"     : "CANCEL"
    }, function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("취소에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        showAlert("취소하였습니다.", function() {
          /* replace 로 들어가야 처리 전 화면이 뒤로가기 기록에 남지 않는다. */
          location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
/* 변경요청. 누르면 납품수량·총액·사양·요청납기일을 고칠 수 있게 열고 버튼을 보내기로 바꾼다. */
function startChange() {
  $("table#items input.qty, table#items input.total, table#items textarea, input[name='reqdlvdate']").prop("readOnly", false);
  $(".chg-off").hide();
  $(".chg-on").show();
}
/* 변경요청 보내기. 전문은 나가지 않고, 상대 기업이 승인하면 그때 은행으로 전송된다. */
function chgReq() {
  if (!validateConfirm()) return;
  showCustomConfirm("변경을 요청하시겠습니까?<br/>상대 기업이 승인하면 변경 내용이 은행으로 전송됩니다.", function() {
    showLoading();
    $.post("CyclnOrderReqProc.jsp", $("form[name='frmConfirm']").serialize() + "&action=CHGREQ", function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("변경요청에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        showAlert("변경을 요청하였습니다.", function() {
          location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
/* 변경승인. 상대가 요청한 내용으로 CL080 변경 전문을 보낸다. */
function chgCfm() {
  showCustomConfirm("변경요청을 승인하시겠습니까?<br/>승인하면 변경 내용이 은행으로 전송됩니다.", function() {
    showLoading();
    $.post("CyclnOrderReqProc.jsp", {
      "orderno"    : "<%=StrUtil.nvl(vo.ORDERNO)%>",
      "csrf_token" : $("input[name='csrf_token']").val(),
      "action"     : "CHGCFM"
    }, function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("변경승인에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        waitBank(r.kncd, r, function(msg) {
          showAlert(msg === null ? "변경을 승인하였습니다." : msg, function() {
            location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
          });
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
/* 취소요청. 상대 승인 없이 바로 취소 전문이 나간다.
   결제예정정보(CL090)가 나가 있으면 그것부터 취소하고, 은행 처리가 끝나면 매매계약(CL080) 취소를 이어서 보낸다. */
function cancelReq() {
  showCustomConfirm("거래를 취소하시겠습니까?<br/>상대 기업의 승인 없이 은행으로 취소가 전송되며 되돌릴 수 없습니다.", function() {
    sendCancel($("input[name='csrf_token']").val());
  }, function(){});
}
function sendCancel(token) {
  showLoading();
  $.post("CyclnOrderReqProc.jsp", {
    "orderno"    : "<%=StrUtil.nvl(vo.ORDERNO)%>",
    "csrf_token" : token,
    "action"     : "CANREQ"
  }, function(data) {
    hideLoading();
    var r = null;
    try { r = JSON.parse(data); } catch (e) { r = null; }
    if (r === null) {
      showAlert("취소요청에 실패했습니다. 잠시 후 다시 시도하십시오.");
      return;
    }
    if (r.result !== "ok") {
      showAlert(r.msg);
      return;
    }
    waitBank(r.kncd, r, function(msg) {
      if (msg === null && r.kncd === "CL090") { sendCancel(r.csrf_token); return; }
      showAlert(msg === null ? "취소하였습니다." : msg, function() {
        location.replace("CyclnOrder.jsp?orderno=" + encodeURIComponent(r.orderno));
      });
    });
  });
}
/* 결제하기. 은행에 결제예정정보(CL090)를 접수한다.
   접수가 끝나면 은행에서 결제가 이뤄지고, 은행이 결제통보(CL100)를 보내면 결제완료가 된다. */
function payOrder() {
  /* 결제예정일은 오늘부터 7일 이내여야 한다. yyyy-MM-dd 라 글자 비교로 충분하다. */
  var setlPlnYmd = $("input[name='setl_pln_ymd']").val();
  if (setlPlnYmd === "" || setlPlnYmd < TODAY || setlPlnYmd > DAYS7) {
    showAlert("결제예정일을 다시 선택해주세요.");
    return;
  }
  /* 세금계산서 발행일은 지난 날짜도 쓴다. 월 정산으로 묶는 거래는 발행일이 접수일보다 앞선다. */
  var taxIssuYmd = $("input[name='tax_issu_ymd']").val();
  if (taxIssuYmd === "") {
    showAlert("세금계산서 발행일을 선택해주세요.");
    return;
  }
  showCustomConfirm("은행에 접수하시겠습니까?", function() {
    showLoading();
    $.post("CyclnOrderPayProc.jsp", {
      "orderno"      : "<%=StrUtil.nvl(vo.ORDERNO)%>",
      "csrf_token"   : $("input[name='csrf_token']").val(),
      "setl_pln_ymd" : setlPlnYmd,
      "tax_issu_ymd" : taxIssuYmd
    }, function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("은행 접수에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        waitBank("CL090", r, function(msg) {
          showAlert(msg === null ? "접수가 완료되었습니다. 은행에서 결제해주세요." : msg, function() {
            location.replace("<%=strListPage%>");
          });
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}
$(document).ready(function() {
  // input 은 붙여넣기까지 잡는다. 고치는 중에도 자릿수 구분을 유지한 뒤 다시 계산한다.
  $("table#items").on("input change", "input.qty, input.total", function() {
    reformatNumberInput(this);
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
<% if (canChgCfm) { %>
      <li><strong>상대 기업이 변경을 요청한 내용입니다.</strong> 확인 후 승인하거나, 다시 고쳐 변경요청하십시오.</li>
<% } else if (vo.isChgPending()) { %>
      <li><strong>변경을 요청했습니다.</strong> 상대 기업이 승인하면 변경 내용이 은행으로 전송됩니다.</li>
<% } %>
    </ul>
  </li>
</ul>

<%-- 결제할 수 있는 건은 접수 전에도 보인다. 결제예정일은 여기서 고른다.
     접수(CL090)한 뒤에는 보낸 내용이, 결제가 끝나면 실제 결제내용이 함께 보인다. --%>
<% if (isSettled || isPaymentSent || canPay) { %>
<h3><%=isSettled ? "결제정보" : "결제예정정보"%></h3>

<ul class='detail'>
  <li class='th'>발주계약금액</li>
  <li class='td'><%=won(vo.PURC_PRIC)%></li>
  <li class='th'>결제예정금액</li>
<%-- 접수 전에는 발주계약금액 전액이 결제예정금액이 된다. --%>
  <li class='td'><%=won(canPay ? vo.PURC_PRIC : vo.SETL_PLN_PRIC)%></li>
<%-- 실결제금액과 결제일시는 은행이 결제통보(CL100)를 보낸 뒤에 생긴다. --%>
<% if (isSettled) { %>
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
<% } %>
  <li class='th'>결제예정일</li>
<% if (canPay) { %>
  <li class='td'>
    <input type='date' name='setl_pln_ymd' style='width:auto;' value='<%=strToday%>' min='<%=strToday%>' max='<%=str7DaysAfter%>'>
    <span class='guide'>* 은행에 결제를 요청할 날짜</span>
  </li>
  <li class='th'>세금계산서 발행일</li>
  <li class='td'>
    <input type='date' name='tax_issu_ymd' style='width:auto;' value='<%=strToday%>'>
    <span class='guide'>* 세금계산서를 발행할 날짜</span>
  </li>
<% } else { %>
  <li class='td'><%=ymd(vo.SETL_PLN_YMD)%></li>
  <li class='th'>세금계산서발행일</li>
  <li class='td'><%=ymd(vo.TAX_ISSU_YMD)%></li>
<% } %>
</ul>
<% } %>

<%-- 승인할 때 넘길 값은 모두 이 폼 안에 있어야 한다. 요청납기일도 고칠 수 있다. --%>
<form name='frmConfirm' method='post' action='CyclnOrderConfirmProc.jsp' onsubmit='return false;'>
<input type='hidden' name='orderno' value='<%=StrUtil.nvl(vo.ORDERNO)%>'>
<input type='hidden' name='csrf_token' value='<%=csrf_token%>'>

<h3>계약기본정보</h3>

<ul class='detail'>
  <li class='th'>발주-ID</li>
  <li class='td'><%=dash(vo.ORDERNO)%></li>
  <li class='th'>등록일시</li>
  <li class='td'><%=ymdhms(vo.REGTIME)%></li>
  <li class='th'>발주계약서명</li>
<% if (canModify) { %>
  <li class='td'><input type='text' name='order_name' value='<%=StrUtil.nvl(vo.ORDERNAME)%>' maxlength='50'></li>
<% } else { %>
  <li class='td'><%=dash(vo.ORDERNAME)%></li>
<% } %>
  <li class='th'>상태</li>
  <li class='td'><strong style='color:<%=CyclnOrderVO.getOrderStatusColor(vo.STATUS, vo.CQ100_STATUS, vo.TRX_CLS)%>;'><%=CyclnOrderVO.getStepStatusNm(vo.STEP_CD, vo.SEND_CD, vo.CODE_NM)%></strong></li>
  <li class='th'>거래일자</li>
  <li class='td'><%=ymd(vo.TRADEDATE)%></li>
  <li class='th'>요청납기일</li>
<%-- 승인하거나 수정하면서 납기일을 다시 잡을 수 있다. 오늘 이전은 고를 수 없다.
     변경요청은 버튼을 눌러야 열린다. --%>
<% if (canConfirm || canModify || canChgReq) { %>
  <li class='td'>
    <input type='date' name='reqdlvdate' style='width:auto;' <%=isEditable ? "" : "readOnly"%>
           value='<%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.REQDLVDATE), "-")%>' min='<%=strToday%>'>
  </li>
<% } else { %>
  <li class='td'><%=ymd(vo.REQDLVDATE)%></li>
<% } %>
  <li class='th'>구매기업</li>
  <li class='td'><%=dash(vo.BC_NAME)%></li>
  <li class='th'>판매기업</li>
  <li class='td'><%=dash(vo.SC_NAME)%></li>
  <li class='th'>도착지</li>
<% if (canModify) { %>
  <li class='td wide'><input type='text' name='addr' value='<%=StrUtil.nvl(vo.DLVADDRESS)%>' maxlength='100' style='width:90%;'></li>
<% } else { %>
  <li class='td wide'><%=dash(vo.DLVADDRESS)%></li>
<% } %>
</ul>

<h3>제품정보</h3>

<% if (canModify) { %>
<div class='estimate-type'>계산서종류 :
  <select name='estimate_type' onchange='recalcAll();'>
<%  for (String[] f : CyclnOrderDetailVO.ESTIMATE_TYPES) { %>
    <option value='<%=f[0]%>' <%=f[0].equals(StrUtil.nvl(vo.ESTIMATE_TYPE)) ? "selected" : ""%>><%=f[1]%></option>
<%  } %>
  </select>
  <span class='guide'>* 과세계산서만 총액에 부가세가 포함됩니다.</span>
</div>
<% } else { %>
<div class='estimate-type'>계산서종류 : <strong><%=vo.getEstimateTypeNm()%></strong></div>
<% } %>

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
      <td class='center name'>
<% if (canModify) { %>
        <input type='text' name='prd_title' value='<%=StrUtil.nvl(r.PRD_TITLE)%>' maxlength='64' style='width:100%;box-sizing:border-box;'>
        <%-- 단위는 화면에서 고치지 않지만 수정 저장 때 그대로 다시 넣어야 한다. --%>
        <input type='hidden' name='unit' value='<%=StrUtil.nvl(r.UNIT)%>'>
<% } else { %>
        <%=dash(r.PRD_TITLE)%>
<% } %>
        <input type='hidden' name='prd_id' value='<%=StrUtil.nvl(r.PRD_ID)%>'>
        <%-- 승인할 때 금액을 CYCLN_ORDER_ITEM 의 어느 줄에 넣을지 정하는 키다. --%>
        <input type='hidden' name='seqno' value='<%=StrUtil.nvl(r.SEQNO)%>'>
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
     발주내역(구매사)은 요청수량, 납품내역(판매사)은 납품수량. 단가는 총액에서 자동으로 나온다.
     승인 뒤 변경요청은 구매사도 납품수량을 고친다. --%>
<% if (isSeller || canChgReq) { %>
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
<% } else if (isSeller || canChgReq) { %>
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
</form>

<div class='btns'>
<%-- 판매기업은 승인하면서 납기일·납품수량을 함께 고치므로 따로 수정 버튼을 두지 않는다. --%>
<% if (canModify) { %>
  <a href='javascript:saveOrder();' class='btn'>수정</a>
  <a href='<%=strListPage%>' class='cancel'>목록보기</a>
  <a href='javascript:cancelOrder();' class='btn white'>발주취소</a>
<% } else if (canConfirm) { %>
  <a href='javascript:cancelOrder();' class='btn white'>취소</a>
  <a href='<%=strListPage%>' class='cancel'>목록보기</a>
  <a href='javascript:confirmOrder();' class='btn'>승인</a>
<% } else { %>
<%-- 승인 뒤. 변경요청을 누르면 입력칸이 열리고 나머지 버튼은 감춘다(chg-off / chg-on). --%>
<% if (canChgReq) { %>
  <a href='javascript:startChange();' class='btn white chg-off'>변경요청</a>
  <a href='javascript:chgReq();' class='btn chg-on' style='display:none;'>변경요청 보내기</a>
  <a href='javascript:location.reload();' class='cancel chg-on' style='display:none;'>변경취소</a>
<% } %>
<% if (canChgCfm) { %>
  <a href='javascript:chgCfm();' class='btn chg-off'>변경승인</a>
<% } %>
<% if (canCancelReq) { %>
  <a href='javascript:cancelReq();' class='btn white chg-off'><%=vo.isCancelRequested() ? "취소 계속" : "취소요청"%></a>
<% } %>
<% if (canPay) { %>
  <a href='javascript:payOrder();' class='btn chg-off'>결제하기</a>
<% } %>
  <a href='<%=strListPage%>' class='cancel chg-off'>목록보기</a>
<% } %>
</div>

<p>&nbsp;</p>
<%@ include file="../includes/Footer.jsp" %>
