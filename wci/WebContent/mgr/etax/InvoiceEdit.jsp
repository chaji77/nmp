<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = StrUtil.nvl(request.getParameter("seq"), "0");

if (!StrUtil.isOnlyNumeric(strBillSeq)) return;

int intBillSeq = Integer.parseInt(strBillSeq);
InvoiceVO vo = new InvoiceDAO().T_BILL_DETAIL_PROC(intBillSeq);

if (vo.BILL_STATUS != 0) {
  out.println("<script>alert('이미 발행 처리되어 수정할 수 없습니다.');window.close();</script>");
  return;
}

String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
double dblTaxRate = (vo.intTaxType == 2 || vo.intTaxType == 3) ? 0 : 0.1;
%>
<!DOCTYPE HTML>
<html>
<head>
  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
  <title>세금계산서 수정</title>
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/style.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
  <link rel="stylesheet" type="text/css" href="bill.css?<%=DateTimeUtil.getCurrentDateTime() %>"/>
  <link href="<%=request.getContextPath() %>/static/font/fontawesome-free-6.7.2-web/css/fontawesome.css" rel="stylesheet" />
  <link href="<%=request.getContextPath() %>/static/font/fontawesome-free-6.7.2-web/css/solid.css" rel="stylesheet" />
  <link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
  <script src="<%=request.getContextPath() %>/static/js/jquery-3.7.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion() %>" type="text/javascript"></script>
  <script src="<%=request.getContextPath() %>/static/js/common.js?<%=DateTimeUtil.getCurrentResourceVersion() %>" type='text/javascript'></script>
  <script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
  <style>
  body {padding:20px;}
  .readonly {background-color:#eee;}
  table.detail {margin-bottom:10px;}
  </style>
</head>
<body>

    <table class="table-invoice">
      <colgroup>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
        <col style="width:2.94117647058824%;"/>
      </colgroup>
      <thead>
      <tr>
        <th colspan="17" rowspan="2"><span class="f24"><%=InvoiceUtil.getInvoiceType(vo) %></span></th>
        <th colspan="4" rowspan="2">공 급 자<br/>(보 관 용)</th>
        <th colspan="4">책번호 : </th>
        <td colspan="4"></td>
        <th colspan="1">권</th>
        <td colspan="3"></td>
        <th colspan="1">호</th>
      </tr>
      <tr>
        <th colspan="4">일련번호 : </th>
        <td colspan="9"><%=vo.BILL_SENDER_KEY %><%=vo.BILL_SEQ %></td>
      </tr>
      </thead>
      <tbody>
      <tr>
        <th colspan="1" rowspan="6">공<br/>급<br/>자</th>
        <th colspan="3">등록번호</th>
        <td colspan="8"><%=InvoiceUtil.getBizNo(vo.INVOICER_CORP_NUM)%></td>
        <th colspan="3">종사업장</th>
        <td colspan="2"></td>
        <th colspan="1" rowspan="6">공<br/>급<br/>받<br/>는<br/>자</th>
        <th colspan="3">등록번호</th>
        <td colspan="8"><%=InvoiceUtil.getBizNo(vo.strToBizNo)%></td>
        <th colspan="3">종사업장</th>
        <td colspan="2"></td>
      </tr>
      <tr>
        <th colspan="3">상호</th>
        <td colspan="8"><%=vo.INVOICER_CORP_NAME%></td>
        <th colspan="1">성명</th>
        <td colspan="4"><%=vo.INVOICER_CEO_NAME%></td>
        <th colspan="3">상호</th>
        <td colspan="8"><%=vo.strToCorpNm %></td>
        <th colspan="1">성명</th>
        <td colspan="4"><%=vo.strToCeo %></td>
      </tr>
      <tr>
        <th colspan="3">사업장<br/>주소</th>
        <td colspan="13"><%=vo.INVOICER_ADDR%></td>
        <th colspan="3">사업장<br/>주소</th>
        <td colspan="13"><%=vo.strToAddr%></td>
      </tr>
      <tr>
        <th colspan="3">업태</th>
        <td colspan="6"><%=vo.INVOICER_BIZ_TYPE%></td>
        <th colspan="1">종목</th>
        <td colspan="6"><%=vo.INVOICER_BIZ_CLASS%></td>
        <th colspan="3">업태</th>
        <td colspan="6"><%=vo.strToBizType%></td>
        <th colspan="1">종목</th>
        <td colspan="6"><%=vo.strToBizClass%></td>
      </tr>
      <tr>
        <th colspan="3">담당자</th>
        <td colspan="6"><%=vo.INVOICER_CONTACT_NAME%></td>
        <th colspan="2">연락처</th>
        <td colspan="5"><%=vo.INVOICER_TEL%></td>
        <th colspan="3">담당자</th>
        <td colspan="6"><%=vo.strToManager%></td>
        <th colspan="2">연락처</th>
        <td colspan="5"><%=vo.strToTel%></td>
      </tr>
      <tr>
        <th colspan="3">이메일</th>
        <td colspan="13"><%=vo.INVOICER_EMAIL %></td>
        <th colspan="3">이메일</th>
        <td colspan="13"><%=vo.strToEmail%></td>
      </tr>
      </tbody>
    </table>

<form name='frmEnt'>
  <input type='hidden' name='seq' value='<%=intBillSeq%>'>

  <table class='list detail'>
    <colgroup>
      <col width='120'/>
      <col width='*'/>
      <col width='*'/>
      <col width='*'/>
    </colgroup>
    <thead>
      <tr>
        <th>작성일</th>
        <th>공급가액</th>
        <th>세액</th>
        <th>합계금액</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><input type='text' name='write_ymd' class='datepicker' value='<%=FormatUtil.addSeparatorDate(vo.strWriteDate, strDateSeparator)%>' onChange="matchMonth();" readOnly></td>
        <td><input type='text' name='price_sum' class='readonly' style='text-align:right;padding-right:5px;' readOnly></td>
        <td><input type='text' name='tax_sum'   class='readonly' style='text-align:right;padding-right:5px;' readOnly></td>
        <td><input type='text' name='sum_sum'   class='readonly' style='text-align:right;padding-right:5px;' readOnly></td>
      </tr>
    </tbody>
  </table>

  <table id="itemlist" class='list detail'>
    <colgroup>
      <col width='60'/>
      <col width='60'/>
      <col width='*'/>
      <col width='80'/>
      <col width='80'/>
      <col width='100'/>
      <col width='100'/>
      <col width='100'/>
      <col width='50'/>
    </colgroup>
    <thead>
      <tr>
        <th>월</th>
        <th>일</th>
        <th>품목</th>
        <th>규격</th>
        <th>수량</th>
        <th>단가</th>
        <th>공급가액</th>
        <th>세액</th>
        <th><a href='javascript:addRow();'><i class="fa-regular fa-square-plus"></i></a></th>
      </tr>
    </thead>
    <tbody>
<%
if (vo.arrTradeItem != null && vo.arrTradeItem.size() > 0) {
  for (InvoiceVO.TradeItem t : vo.arrTradeItem) {
    String strDay = "";
    if (t.strPurchaseExpiry != null && t.strPurchaseExpiry.length() == 8) {
      strDay = Integer.toString(Integer.parseInt("1" + t.strPurchaseExpiry.substring(6)) - 100);
    }
%>
      <tr>
        <td><input type='number' name='item_m'     class='item_m readonly'      maxlength='2' readonly></td>
        <td><input type='number' name='item_d'     class='item_d'      maxlength='2' min=1 max=31 value='<%=strDay%>'></td>
        <td><input type='text'   name='item_item'  class='item_item'  maxlength='80' value='<%=StrUtil.nvl(t.strName)%>'></td>
        <td><input type='text'   name='item_spec'  class='item_spec'  maxlength='20' value='<%=StrUtil.nvl(t.strInformation)%>'></td>
        <td><input type='number' name='item_cnt'   class='item_cnt'   style='text-align:right;padding-right:5px;' value='<%=StrUtil.nvl(t.strChargeableUnit)%>'></td>
        <td><input type='number' name='item_unit'  class='item_unit'  style='text-align:right;padding-right:5px;' value='<%=StrUtil.nvl(t.strUnitPrice)%>'></td>
        <td><input type='text'   name='item_price' class='item_price' style='text-align:right;padding-right:5px;' value='<%=StrUtil.nvl(t.strAmount)%>' onchange='updateTaxByPrice(this);'></td>
        <td><input type='text'   name='item_tax'   class='item_tax'   style='text-align:right;padding-right:5px;' value='<%=StrUtil.nvl(t.strTax)%>' onchange='calcSum();'></td>
        <td class='center'><a class='btnDelRow'><i class='fa-regular fa-square-minus'></i></a></td>
      </tr>
<%
  }
} else {
%>
      <tr>
        <td><input type='number' name='item_m'     class='item_m'      maxlength='2' min=1 max=12></td>
        <td><input type='number' name='item_d'     class='item_d'      maxlength='2' min=1 max=31></td>
        <td><input type='text'   name='item_item'  class='item_item'  maxlength='80'></td>
        <td><input type='text'   name='item_spec'  class='item_spec'  maxlength='20'></td>
        <td><input type='number' name='item_cnt'   class='item_cnt'   style='text-align:right;padding-right:5px;'></td>
        <td><input type='number' name='item_unit'  class='item_unit'  style='text-align:right;padding-right:5px;'></td>
        <td><input type='text'   name='item_price' class='item_price' style='text-align:right;padding-right:5px;' onchange='updateTaxByPrice(this);'></td>
        <td><input type='text'   name='item_tax'   class='item_tax'   style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>
        <td class='center'><a class='btnDelRow'><i class='fa-regular fa-square-minus'></i></a></td>
      </tr>
<%
}
%>
    </tbody>
  </table>

  <div style="text-align:right; margin-top:15px;">
    <a href="javascript:saveEdit();" class="btn">저장</a>
  </div>

</form>

<script>
var TAX_RATE = <%=dblTaxRate%>;

function toNumber(val) {
  if (val == null) return 0;
  var s = ("" + val).replace(/,/g, "");
  var n = parseInt(s, 10);
  return isNaN(n) ? 0 : n;
}

function getTaxRate() {
  return TAX_RATE;
}

function updateTaxByPrice(obj) {
  var idx   = $(".item_price").index(obj);
  var price = toNumber($(obj).val());
  var rate  = getTaxRate();

  var tax = Math.floor(price * rate);
  $(".item_tax").eq(idx).val(addComma(tax));

  calcSum();
}

function calcSum() {
  var sumPrice = 0;
  var sumTax   = 0;

  $(".item_price").each(function(index, item) {
    sumPrice += toNumber($(this).val());
  });

  $(".item_tax").each(function(index, item) {
    sumTax += toNumber($(this).val());
  });

  var sumSum = sumPrice + sumTax;

  document.frmEnt.price_sum.value = addComma(sumPrice);
  document.frmEnt.tax_sum.value   = addComma(sumTax);
  document.frmEnt.sum_sum.value   = addComma(sumSum);

  matchMonth();
}

function matchMonth() {
  var currentymd = "<%=DateTimeUtil.getCurrentDate(strDateSeparator)%>";
  var ymd = document.frmEnt.write_ymd.value;
  var m   = (ymd.lastIndexOf("<%=strDateSeparator%>")==7) ? ymd.split("<%=strDateSeparator%>")[1] : currentymd.split("<%=strDateSeparator%>")[1];
  m = parseInt("1"+m) - 100;
  $(".item_cnt").each(function(index, item) {
    $(".item_m").eq(index).val(m);
  });
}

function addRow() {
  var str = "";
  str += "<tr>";
  str += "  <td><input type='number' name='item_m'     class='item_m'     maxlength='2' min=1 max=12></td>";
  str += "  <td><input type='number' name='item_d'     class='item_d'     maxlength='2' min=1 max=31></td>";
  str += "  <td><input type='text'   name='item_item'  class='item_item'  maxlength='80'></td>";
  str += "  <td><input type='text'   name='item_spec'  class='item_spec'  maxlength='20'></td>";
  str += "  <td><input type='number' name='item_cnt'   class='item_cnt'   style='text-align:right;padding-right:5px;'></td>";
  str += "  <td><input type='number' name='item_unit'  class='item_unit'  style='text-align:right;padding-right:5px;'></td>";
  str += "  <td><input type='text'   name='item_price' class='item_price' style='text-align:right;padding-right:5px;' onchange='updateTaxByPrice(this);'></td>";
  str += "  <td><input type='text'   name='item_tax'   class='item_tax'   style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>";
  str += "  <td class='center'><a class='btnDelRow'><i class='fa-regular fa-square-minus'></i></a></td>";
  str += "</tr>";
  $("#itemlist>tbody").append(str);
  matchMonth();
}

function checkFormField() {
  if ($(".item_cnt").length < 1) {
    alert("품목정보를 입력하세요.");
    return false;
  }
  var s = true;
  $(".item_cnt").each(function(index, item) {
    if ($('.item_item').eq(index).val().length < 1) {
      alert("품목명을 입력하세요.");
      $('.item_item').eq(index).focus();
      s = false;
      return false;
    }
  });
  return s;
}

function saveEdit() {
  if (!checkFormField()) return;
  $.post('InvoiceEditProc.jsp', $("form[name='frmEnt']").serialize(), function(res) {
    if ($.trim(res) === 'ok') {
      alert('수정되었습니다.');
      if (window.opener) window.opener.location.reload();
      window.close();
    } else {
      alert('수정에 실패했습니다.');
    }
  });
}

$(function(){
  $(".datepicker").datepicker({dateFormat:"yy<%=strDateSeparator%>mm<%=strDateSeparator%>dd"});

  $(document).on("click", ".btnDelRow", function() {
    $(this).parent().parent().remove();
    calcSum();
  });

  calcSum();
});
</script>

</body>
</html>
