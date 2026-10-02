<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
if (!StrUtil.isOnlyNumeric(strCpyId)) return;

String strCpyBizNo = StrUtil.nvl((String)pageContext.getAttribute("CPY_BIZ_NO"));

String csrf_token = UUID.randomUUID().toString();
session.setAttribute("csrf_token", csrf_token);

// 거래불가품목명. 매매계약서와 같은 설정을 쓴다.
String strBlockWords = StrUtil.nvl(ConfigurationMgr.getInstance().getString("TRADE_BLOCK_ITEM_NM"));
String strBlockWordsForJs = "\"" + strBlockWords.replaceAll(",", "\", \"") + "\"";

String strPageTitle = "발주계약서 작성";
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle%></title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script><!-- isValidBusinessNumber -->

<style>
/* 안내문 모양은 web/trade/CyclnOrder.jsp 와 맞춘다. */
ul.exp {display:flex;flex-flow:row wrap;justify-content:left;margin:20px 0;padding:10px;border:1px solid #ddd;color:#888;}
ul.exp>li {padding:10px;}
ul.exp>li>ul>li {padding:3px 0;}
ul.exp>li>ul>li>strong {color:#000;}
/* 입력칸 옆 설명글. 좁은 화면에서는 줄을 바꿔 아래로 내린다. */
ul.form span.guide {color:#888;margin-left:8px;}
@media only screen and (max-width:767px) {
  ul.form span.guide {display:block;margin-left:0;padding-left:10px;}
}
ul.caution {margin:15px 0;color:#c00;}
ul.caution>li {padding:2px 0;}
/* 입력칸 뒤의 '원'/단위가 잘리지 않도록 그 글자 자리를 빼고 폭을 잡는다. */
table#items td {vertical-align:middle;white-space:nowrap;}
table#items input.num {width:calc(100% - 22px);min-width:0;box-sizing:border-box;text-align:right;}
table#items input.name {width:100%;box-sizing:border-box;}
table#items input.unit {width:45px;text-align:center;}
table#items textarea {width:100%;box-sizing:border-box;}
/* 자동계산 칸은 입력칸이 아니라는 게 보이게 한다. */
table#items input[readOnly] {background-color:#f5f5f5;color:#555;}
table#items tr.sum {background-color:#fafafa;font-weight:bold;}
.won, .unit {color:#888;margin-left:2px;}
.estimate-type {margin:10px 0;padding:10px;border:3px solid #E8DFCF;}
#element_to_pop_up {background-color:transparent;display:none;padding:0 !important;}
.my-companies-list-element {padding:0;min-width:100%;width:auto !important;margin-left:auto;margin-right:auto;}
</style>
<script>
var wordtoblock = [<%=strBlockWordsForJs%>];
var MY_BIZ_NO   = "<%=strCpyBizNo%>";

/* bPopup 닫기. 검색창은 이 페이지 안에 있으므로 내용을 비우지 않는다. */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
}
/* 판매기업 검색창 열기 */
function showSellerSearch() {
  $("#my-companies-list").empty();
  $("input[name='mycompany_bizno'], input[name='mycompany_nm']").val("");
  $("#element_to_pop_up").bPopup();
}
/*
 * 판매기업 검색. 상호 또는 사업자번호로 찾는다.
 * 결과는 CompaniesSearched.jsp 가 그린다. 승인된 회원사(CST_ID=2)만 나온다.
 * 페이징도 그 안에서 searchCompany(page) 를 다시 부른다.
 */
function searchCompany(page) {
  var tBizNo = $.trim($("input[name='mycompany_bizno']").val()).replace(/-/g, '');
  var tBizNm = $.trim($("input[name='mycompany_nm']").val());
  if (tBizNo==="" && tBizNm==="") {
    toast("검색어를 입력하세요.");
    return;
  }
  if (tBizNo!=="" && !isValidBusinessNumber(tBizNo)) {
    toast("올바른 사업자번호가 아닙니다.");
    return;
  }
  showLoading();
  $.post("CompaniesSearched.jsp", {'mycompany_nm':tBizNm, 'mycompany_bizno':tBizNo, 'page':page}, function(data) {
    $("#my-companies-list").html(data);
    hideLoading();
  });
}
/*
 * 검색결과에서 판매기업을 고른다.
 * CompaniesSearched.jsp 가 그린 '추가' 버튼이 회사아이디만 넘겨주므로, 회사명은 눌린 줄에서 읽는다.
 */
function addCompany(cid) {
  var $tr   = $(event.target).closest("tr");
  var $tds  = $tr.find("td");
  var strNm = $.trim($tds.eq(0).clone().children().remove().end().text()); // 모바일용 덧붙임을 뺀 회사명
  var strNo = $.trim($tds.eq(1).text()).replace(/-/g, '');

  if (strNo!=="" && strNo===MY_BIZ_NO.replace(/-/g, '')) {
    toast("자기 회사에는 발주할 수 없습니다.");
    return;
  }
  $("#seller_cpy_id").val(cid);
  $("#seller_cpy_nm").val(strNm);
  closePopup();
}

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
/* 고른 계산서 종류. '1'(과세)일 때만 총액에 부가세가 포함돼 있다. */
function isVat() {
  return $("input[name='estimate_type']:checked").val() === "1";
}
/*
 * 한 줄 다시 계산. 요청수량과 총액이 입력값이고 나머지는 여기서 나온다.
 *   공급가액 = 총액 × (과세면 10/11, 아니면 1)
 *   세액     = 과세면 공급가액 ÷ 10, 아니면 0
 *   요청단가 = 공급가액 ÷ 요청수량 (소수 둘째자리까지)
 */
function calcRow(tr) {
  var $tr    = $(tr);
  var total  = toNumber($tr.find("input.total").val());
  var qty    = toNumber($tr.find("input.qty").val());
  var supply = total * (isVat() ? (10 / 11) : 1);
  var tax    = isVat() ? Math.round(supply / 10) : 0;
  var price  = (qty === 0) ? 0 : roundTo(supply / qty, 2);

  $tr.find("input.supply").val(addComma(Math.round(supply)));
  $tr.find("input.tax").val(addComma(tax));
  $tr.find("input.price").val(addComma(price));
}
/* 모든 줄을 다시 계산하고 합계를 맞춘다. */
function calcAll() {
  $("table#items tbody tr").each(function() { calcRow(this); });
  var sum = 0;
  $("table#items input.total").each(function() { sum += toNumber($(this).val()); });
  $("#sumTotalAmt").val(addComma(sum));
}
/* 품목 추가. 마지막 줄을 복사해 값만 비운다. */
function addRow() {
  var $last = $("table#items tbody tr:last");
  var $new  = $last.clone(true);
  $new.find("input[type='text']").val("");
  $new.find("textarea").val("");
  $new.find("input.unit").val("개");
  $last.after($new);
}
/* 품목 삭제. 마지막 한 줄은 남긴다. */
function dropRow(el) {
  if ($("table#items tbody tr").length <= 1) {
    toast("품목은 한 줄 이상이어야 합니다.");
    return;
  }
  $(el).closest("tr").remove();
  calcAll();
}

/* 제품명 바이트 길이. 한글은 2바이트로 센다. */
function byteLength(str) {
  var n = 0;
  for (var i=0; i<str.length; i++) n += (str.charCodeAt(i) > 127) ? 2 : 1;
  return n;
}
/* 입력값 검증. 문제가 있으면 안내하고 false. */
function validate() {
  if ($.trim($("input[name='order_name']").val()) === "") {
    toast("발주계약서명을 입력하십시오.");
    return false;
  }
  if ($("input[name='reqdlvdate']").val() === "") {
    toast("요청납기일을 선택하십시오.");
    return false;
  }
  if (toNumber($("#seller_cpy_id").val()) === 0) {
    toast("판매기업을 검색해 선택하십시오.");
    return false;
  }
  if ($.trim($("input[name='addr']").val()) === "") {
    toast("도착지를 입력하십시오.");
    return false;
  }

  var booValid = true;
  $("table#items tbody tr").each(function() {
    var strName = $.trim($(this).find("input.name").val());
    if (strName === "") {
      toast("제품명을 입력하십시오.");
      booValid = false;
      return false;
    }
    if (byteLength(strName) > 20) {
      toast("제품명은 한글 10자, 영문·숫자 20자까지 입력할 수 있습니다.");
      booValid = false;
      return false;
    }
    for (var i=0; i<wordtoblock.length; i++) {
      var strWord = $.trim(wordtoblock[i]);
      if (strWord !== "" && strName.indexOf(strWord) >= 0) {
        toast("제품명에 '" + strWord + "' 은(는) 쓸 수 없습니다.");
        booValid = false;
        return false;
      }
    }
    if (toNumber($(this).find("input.qty").val()) <= 0) {
      toast("요청수량을 확인하십시오.");
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

/* 발송. 저장에 성공하면 등록된 발주내역으로 넘어간다. */
function send() {
  if (!validate()) return;
  showCustomConfirm("판매기업에 발주계약서를 발송하시겠습니까?", function() {
    showLoading();
    $.post("CyclnOrderRegProc.jsp", $("form[name='frmOrder']").serialize(), function(data) {
      hideLoading();
      var r = null;
      try { r = JSON.parse(data); } catch (e) { r = null; }
      if (r === null) {
        showAlert("발송에 실패했습니다. 잠시 후 다시 시도하십시오.");
        return;
      }
      if (r.result === "ok") {
        showAlert("발송하였습니다.", function() {
          location.href = "CyclnOrder.jsp?orderno=" + r.orderno;
        });
      } else {
        showAlert(r.msg);
      }
    });
  }, function(){});
}

$(document).ready(function() {
  // 검색창에서 엔터로도 찾을 수 있게 한다.
  $("input[name='mycompany_bizno'], input[name='mycompany_nm']").keydown(function(key) {
    if (key.keyCode === 13) searchCompany(1);
  });
  $("table#items").on("keyup change", "input.qty, input.total", function() {
    calcRow($(this).closest("tr"));
    calcAll();
  });
  $("input[name='estimate_type']").on("change", calcAll);
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle%></span>
  <span class='more'>
    <a href='CyclnOrders.jsp' class='btn white'>목록</a>
  </span>
</div>

<ul class='exp'>
  <li class='mobile_hide'><i class="fa fa-commenting fa-5x" style="color:#246CEB;"></i></li>
  <li>
    <ul>
      <li>귀사가 구매를 희망하는 제품에 대한 발주계약서를 판매기업에 발송할 수 있습니다.</li>
      <li>구매희망제품, 요청 납기일 등 구매계약에 필요한 조건을 입력해 발주계약서를 작성해 주세요.</li>
    </ul>
  </li>
</ul>

<!-- 판매기업 검색창 -->
<div id='element_to_pop_up'>
  <div style='background-color:white;padding:20px;width:800px;'>
    <p style='text-align:center;font-size:1.2em;'><strong>판매기업 검색</strong></p>
    <p>&nbsp;</p>
    <p style='padding:10px 0 5px 0;text-align:center;'>
      <span class='mobile_hide'>사업자번호 &nbsp;</span>
      <input type='text' name='mycompany_bizno' style='width:110px;' placeholder='사업자번호' autocomplete='off'>
      <span>&nbsp;또는</span><span class='mobile_hide'>&nbsp;상호&nbsp;</span>
      <input type='text' name='mycompany_nm' style='width:110px;' placeholder='상호' autocomplete='off'>
      <a onclick='searchCompany(1);' class='btn' style='padding-top:7px;padding-bottom:7px;'>검색</a>
    </p>
    <p>&nbsp;</p>
    <div id='my-companies-list' style='text-align:center;'></div>
    <div style='text-align:center;margin-top:20px;'>※ 목록의 <b>추가</b> 를 누르면 판매기업으로 선택됩니다. 가입되지 않았거나 미승인 기업은 검색되지 않습니다.</div>
    <div style='text-align:center;margin-top:20px;margin-bottom:10px;'><i class="fa-solid fa-xmark" onclick='closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
  </div>
</div>

<form name='frmOrder' autocomplete='off' onsubmit='return false;'>
<input type='hidden' name='csrf_token' value='<%=csrf_token%>'>
<h3>계약기본정보</h3>

<ul class='form'>
  <li class='wide'>
    <label>발주계약서명</label>
    <input type='text' name='order_name' maxlength='50' style='width:220px;'>
    <span class='guide'>* 이곳에 발주계약서를 기억하기 쉬운 이름으로 적어주세요.</span>
  </li>
  <li class='wide'>
    <label>요청납기일</label>
    <input type='date' name='reqdlvdate' style='width:auto;'>
    <span class='guide'>* 판매기업에 요청할 납기일을 선택해 주세요.</span>
  </li>
  <li class='wide'>
    <label>판매기업</label>
    <input type='text' id='seller_cpy_nm' style='width:220px;cursor:pointer;' readonly placeholder='검색 버튼을 눌러 선택하세요' onclick='showSellerSearch();'>
    <input type='hidden' id='seller_cpy_id' name='seller_cpy_id'>
    <a onclick='showSellerSearch();' class='btn' style='vertical-align:middle;'>검색</a>
    <span class='guide'>* 상호 또는 사업자번호로 찾을 수 있습니다.</span>
  </li>
  <li class='wide'>
    <label>도 착 지</label>
    <input type='text' name='addr' maxlength='100' style='width:400px;'>
  </li>
</ul>

<ul class='caution'>
  <li>* 제품명 금칙어 - <%=strBlockWords%></li>
  <li>* 제품명은 영문과 숫자는 20자 / 한글은 10자 이내로 입력하여 주시기 바랍니다.</li>
  <li>* 제품정보 입력시 요청수량과 총액을 입력하시면 자동계산 되어 작성됩니다.</li>
</ul>

<h3>제품정보 <a onclick='addRow();' class='btn white' style='margin-left:10px;'>품목 추가</a></h3>

<div class='estimate-type'>
  <strong>부과될 계산서 종류를 선택해 주세요.</strong>
<%
for (String[] f : CyclnOrderDetailVO.ESTIMATE_TYPES) {
  out.print("  <input type='radio' name='estimate_type' value='"+f[0]+"' "+(f[0].equals("1")?"checked":"")+"> "+f[1]);
}
%>
</div>

<table id='items' class='detail'>
  <colgroup>
    <col width='60'/>
    <col width='*'/>
    <col width='130'/>
    <col width='115'/>
    <col width='115'/>
    <col width='105'/>
    <col width='120'/>
    <col width='180' class='mobile_hide'/>
  </colgroup>
  <thead>
    <tr>
      <th class='center'>삭제</th>
      <th class='center'>제품명</th>
      <th class='center'><font color='red'>요청수량</font> / 단위</th>
      <th class='center'>요청단가</th>
      <th class='center'>공급가액</th>
      <th class='center'>세액</th>
      <th class='center'><font color='red'>총액</font></th>
      <th class='center mobile_hide'>기타제품사양</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class='center'><a onclick='dropRow(this);' class='btn white'><i class="fa-solid fa-xmark"></i></a></td>
      <td><input type='text' name='prd_title' class='name' maxlength='20'></td>
      <td class='right'>
        <input type='text' name='reqqty' class='num qty' style='width:60px;'>
        <span class='unit'>/</span>
        <input type='text' name='unit' class='unit' value='개' maxlength='20'>
      </td>
      <td class='right'><input type='text' name='reqprice' class='num price' readOnly><span class='won'>원</span></td>
      <td class='right'><input type='text' name='supplyamt' class='num supply' readOnly><span class='won'>원</span></td>
      <td class='right'><input type='text' name='taxamt' class='num tax' readOnly><span class='won'>원</span></td>
      <td class='right'><input type='text' name='totalamt' class='num total'><span class='won'>원</span></td>
      <td class='left mobile_hide'><textarea name='description' rows='2' maxlength='500'></textarea></td>
    </tr>
  </tbody>
  <tfoot>
    <tr class='sum'>
      <td colspan='6' class='center'>합 계 금 액</td>
      <td class='right'><input type='text' id='sumTotalAmt' class='num' style='color:#c00;' readOnly><span class='won'>원</span></td>
      <td class='mobile_hide'></td>
    </tr>
  </tfoot>
</table>
</form>

<div class='btns'>
  <a onclick='send();'><i class="fa fa-paper-plane" aria-hidden="true"></i> &nbsp;발송하기</a>
  <a href='CyclnOrders.jsp' class='cancel'>취소</a>
</div>

<p>&nbsp;</p>
<%@ include file="../includes/Footer.jsp" %>
