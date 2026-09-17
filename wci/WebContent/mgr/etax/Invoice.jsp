<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baroservice.ws.Contact" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.BillReceiverVO" %>
<%@ page import="kr.co.mp.mptax.TaxPublish" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
/* get parameters and set variables */
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strCpyId = StrUtil.nvl(request.getParameter("cpy_id"), "0");
Tax tax = new Tax();
BillReceiverVO r = new BillReceiverVO();
if (StrUtil.isOnlyNumeric(strCpyId) && !strCpyId.equals("0")) {
  r = TaxPublish.T_BILL_FILL_BY_CPY_ID_PROC(Integer.parseInt(strCpyId));
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>세금계산서발급</title>

<!-- for calendar -->
<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<style>
.readonly {background-color:#eee;}
table.detail {margin-bottom:10px;}
tbody.obj>tr>th.red {background-color:#ffeeee;}
tbody.obj>tr>th.blue {background-color:#eeeeff;}
</style>

<script>

function addRow() {
  var str = "";
  str += "<tr>";
  str += "  <td><input type='number' name='item_m'     class='item_m readonly'     maxlength='2' readOnly></td>";
  str += "  <td><input type='number' name='item_d'     class='item_d'     maxlength='2' min=1 max=31></td>";
  str += "  <td><input type='text'   name='item_item'  class='item_item'  maxlength='80'></td>";
  str += "  <td><input type='text'   name='item_spec'  class='item_spec'  maxlength='20'></td>";
  str += "  <td><input type='number' name='item_cnt'   class='item_cnt'   style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>";
  str += "  <td><input type='number' name='item_unit'  class='item_unit'  style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>";
  str += "  <td><input type='text'   name='item_price' class='item_price readonly' style='text-align:right;padding-right:5px;' readOnly></td>";
  str += "  <td><input type='text'   name='item_tax'   class='item_tax readonly'   style='text-align:right;padding-right:5px;' readOnly></td>";
  str += "  <td class='center'><a class='btnDelRow'><i class='fa-regular fa-square-minus'></i></a></td>";
  str += "</tr>";
  $("#itemlist>tbody").append(str);
  matchMonth();
}
$(function(){
  $( ".datepicker" ).datepicker({dateFormat:"yy<%=strDateSeparator%>mm<%=strDateSeparator%>dd"});

  // 품목정보 기본등록양식 노출
  for (var i=0; i<1; i++) {
    addRow();
  }
  matchMonth();

  $(document).on("click", ".btnDelRow", function() {
    $(this).parent().parent().remove();
    calcSum();
  });

  setValues();

});

// 합계계산
function calcSum() {
  var sumPrice = 0;
  var isZeroTax = true;
  if ($("input:radio[name='taxtype']:checked").val() == "Y") isZeroTax = false;

  $(".item_cnt").each(function(index, item) {
    var price = $(".item_cnt").eq(index).val() * $(".item_unit").eq(index).val();
    price = Math.round(price);
    $(".item_price").eq(index).val(addComma(price));
    var tax = (isZeroTax) ? 0 : Math.floor(price*0.1);
    $(".item_tax").eq(index).val(addComma(tax));
    sumPrice += price;
  });
  var sumTax = (isZeroTax) ? 0 : Math.floor(sumPrice*0.1);
  var sumSum = sumPrice + sumTax;
  document.frmEnt.price_sum.value = addComma(sumPrice);
  document.frmEnt.tax_sum.value = addComma(sumTax);
  document.frmEnt.sum_sum.value = addComma(sumSum);

  matchMonth();
}

// 품목정보의 거래월을 작성일의 월로 맞춤
function matchMonth() {
  var currentymd = "<%=DateTimeUtil.getCurrentDate(strDateSeparator)%>";
  var ymd = document.frmEnt.write_ymd.value;
  var m   = (ymd.lastIndexOf("<%=strDateSeparator%>")==7) ? ymd.split("<%=strDateSeparator%>")[1] : currentymd.split("<%=strDateSeparator%>")[1];
  m = parseInt("1"+m) - 100;
  $(".item_cnt").each(function(index, item) {
    $(".item_m").eq(index).val(m);
  });
}

function setValues() {
  /*
  document.frmEnt.serialnum.value = "EMTNET123456KU";
  $(".item_cnt").each(function(index, item) {
    $('.item_m').eq(index).val(2);
    $('.item_d').eq(index).val(10);
    $('.item_item').eq(index).val("CVSVOFFICEPASCIP");
    $('.item_spec').eq(index).val('ea');
    $('.item_cnt').eq(index).val(30);
    $('.item_unit').eq(index).val(4000);
    $('.item_price').eq(index).val(30*400);
    $('.item_tax').eq(index).val(3*400);
  });
  calcSum();
  */
}

// 발급
function publish() {
  if (checkFormField()) {
    console.log("success");
    document.frmEnt.submit();
  }
}

function checkEmailAddress(str) {
  var reg = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/;
  return reg.test(str);
}

function checkFormField() {
  var frm = document.frmEnt;
  if (frm.bizno.value.length < 10) {
    toast("공급받는자 사업자번호를 입력하세요.");
    frm.bizno.focus();
    return false;
  }
  if (frm.comnm.value.length < 2) {
    toast("공급받는자의 상호 또는 이름(개인의 경우)을 입력하세요.");
    frm.comnm.focus();
    return false;
  }
  if (frm.uptae.value.length < 2) {
    toast("업태를 입력하세요.");
    frm.uptae.focus();
    return false;
  }
  if (frm.upzong.value.length < 2) {
    toast("종목을 입력하세요.");
    frm.upzong.focus();
    return false;
  }
  if (!checkEmailAddress(frm.tax_email.value)) {
    toast("올바른 이메일주소를 입력하세요.");
    frm.tax_email.focus();
    return false;
  }
  if (frm.comnm.value.length < 2) {
    toast("공급받는자의 상호 또는 이름(개인의 경우)을 입력하세요.");
    frm.comnm.focus();
    return false;
  }
  if (frm.manager.value.length < 2) {
    toast("공급받는자의 담당자명을 입력하세요.");
    frm.manager.focus();
    return false; 
  }

  if ($(".item_cnt").length < 1) {
    toast("품목정보를 입력하세요.");
    return false;
  }
  var s = true;
  $(".item_cnt").each(function(index, item) {
    if ($('.item_d').eq(index).val().length < 1) {
      toast("거래일을 입력하세요.");
      $('.item_d').eq(index).focus();
      s = false;
      return false;
    }
    if ($('.item_item').eq(index).val().length < 1) {
      toast("품목명을 입력하세요.");
      $('.item_item').eq(index).focus();
      s = false;
      return false;
    }
    if ($('.item_spec').eq(index).val().length < 1) {
      toast("규격을 입력하세요.");
      $('.item_spec').eq(index).focus();
      s = false;
      return false;
    }
    if ($('.item_cnt').eq(index).val().length < 1) {
      toast("수량을 입력하세요.");
      $('.item_cnt').eq(index).focus();
      s = false;
      return false;
    }
    if ($('.item_unit').eq(index).val().length < 1) {
      toast("단가를 입력하세요.");
      $('.item_unit').eq(index).focus();
      s = false;
      return false;
    }
  });
  return s;
}

</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>세금계산서발급</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'></a>
  </span>
</div>

  <form name='frmEnt' method='post' action='InvoiceProc.jsp'>
  <input type='hidden' name='cpyid' id='cpyid' value='<%=strCpyId%>'>

  <table class='list detail'>
    <colgroup>
      <col width='100'/>
      <col width='30%'/>
      <col width='100'/>
      <col width='30%'/>
      <col width='100'/>
      <col width='30%'/>
    </colgroup>
    <tbody>
      <tr>
        <th>과세구분</th>
        <td>
          <input type='radio' name='taxtype' id='taxtype_general' value='Y' onclick='calcSum()' checked> 일반
          <input type='radio' name='taxtype' id='taxtype_free'    value='F' onclick='calcSum()'> 면세
          <input type='radio' name='taxtype' id='taxtype_zero'    value='Z' onclick='calcSum()'> 영세
        </td>
        <th>영수/청구 구분</th>
        <td>
          <input type='radio' name='purposetype' value='1'> 영수
          <input type='radio' name='purposetype' value='2' checked> 청구
        </td>
        <th>일련번호</th>
        <td><input type='text' name='serialnum' value='' maxlength='20'></td>
      </tr>
    </tbody>
  </table>

  <table class='list detail'>
    <colgroup>
      <col width='10'/>
      <col width='100'/>
      <col width='20%'/>
      <col width='100'/>
      <col width='20%'/>
      <col width='10'/>
      <col width='100'/>
      <col width='20%'/>
      <col width='100'/>
      <col width='20%'/>
    </colgroup>
    <tbody class='obj'>
      <tr>
        <th rowspan='6' class='red'>공<br/>급<br/>자</th>
        <th class='red'>등록번호</th>
        <td colspan='3'><%=FormatUtil.addDashBizNo(tax.getBizNo()) %></td>
        <th rowspan='6' class='blue'>공<br/>급<br/>받<br/>는<br/>자</th>
        <th class='blue'>등록번호</th>
        <td colspan='3'><input type='number' name='bizno' value='<%=StrUtil.nvl(r.CPY_BUSINESS_NO) %>' maxlength=13 placeholder='숫자만 입력하십시오.' onKeyDown="onlyNumber();"></td>
      </tr>
      <tr>
        <th class='red'>상　호</th>
        <td style='white-space:normal;'><%=tax.getComNm() %></td>
        <th class='red'>성　명</th>
        <td style='white-space:normal;'><%=tax.getCeo() %></td>
        <th class='blue'>상　호</th>
        <td><input type='text' name='comnm' value='<%=StrUtil.nvl(r.CPY_NAME) %>' maxlength='20'></td>
        <th class='blue'>성　명</th>
        <td><input type='text' name='ceonm' value='<%=StrUtil.nvl(r.CPY_CEO_NAME) %>' maxlength='10'></td>
      </tr>
      <tr>
        <th class='red'>주　소</th>
        <td colspan='3' style='white-space:normal;'><%=tax.getAddr() %></td>
        <th class='blue'>주　소</th>
        <td colspan='3'><input type='text' name='address' value='<%=(StrUtil.input(r.CPY_ADDR) + " " + StrUtil.input(r.CPY_ADDR2)) %>' maxlength='150'></td>
      </tr>
      <tr>
        <th class='red'>업　태</th>
        <td style='white-space:normal;'><%=tax.getBizType() %></td>
        <th class='red'>종　목</th>
        <td style='white-space:normal;'><%=tax.getBizClass() %></td>
        <th class='blue'>업　태</th>
        <td><input type='text' name='uptae' value='<%=StrUtil.input(r.BUSINESS_TYPE) %>' maxlength='30' placeholder="업태"></td>
        <th class='blue'>종　목</th>
        <td><input type='text' name='upzong' value='<%=StrUtil.input(r.INDUSTRY) %>' maxlength=30 placeholder='업종'></td>
      </tr>
      <tr>
        <th class='red'>담당자</th>
        <td><%=tax.getManager() %></td>
        <th class='red'>연락처</th>
        <td></td>
        <th class='blue'>담당자</th>
        <td><input type='text' name='manager' value='<%=StrUtil.input(r.MPTAX_USER_NM, "담당자") %>' maxlength=50 placeholder='담당자명'></td>
        <th class='blue'>연락처</th>
        <td><input type='text' name='phoneno' value='' maxlength=50 placeholder='전화번호'></td>
      </tr>
      <tr>
        <th class='red'>이메일</th>
        <td colspan='3'><%=tax.getEmail() %></td>
        <th class='blue'>이메일</th>
        <td colspan='3'><input type='text' name='tax_email' value='<%=StrUtil.input(r.MPTAX_EMAIL) %>' maxlength=50 placeholder='이메일주소'></td>
      </tr>
    </tbody>
  </table>

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
        <td><input type='text' name='write_ymd' class='datepicker' value='<%=DateTimeUtil.getCurrentDate("/")%>' onChange="matchMonth();" readOnly></td>
        <td><input type='text' name='price_sum' class='readonly'   style='text-align:right;padding-right:5px;' readOnly></td>
        <td><input type='text' name='tax_sum'   class='readonly'   style='text-align:right;padding-right:5px;' readOnly></td>
        <td><input type='text' name='sum_sum'   class='readonly'   style='text-align:right;padding-right:5px;' readOnly></td>
      </tr>
    </tbody>
  </table>

  <table id="itemlist" class='list detail'>
    <colgroup>
      <col width='80'/>
      <col width='80'/>
      <col width='*'/>
      <col width='200'/>
      <col width='100'/>
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
        <th><a href='javascript:addRow(this)'><i class="fa-regular fa-square-plus"></i></a></th>
      </tr>
    </thead>
    <tbody>

    </tbody>
  </table>

  <div class='btns'>
    <a href='javascript:publish();'>발행신청</a>
  </div>


</form>

</div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>