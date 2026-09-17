<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baroservice.ws.Contact" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%@ page import="kr.co.mp.mptax.BillReceiverVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
/* get parameters and set variables */
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String ymd = DateTimeUtil.getCurrentDate("");

String strCtId  = StrUtil.nvl(request.getParameter("ctid"), "0");
BillReceiverVO vo = null;
if (StrUtil.isOnlyNumeric(strCtId)) {
  vo = new InvoiceDAO().T_BILL_RECEIVER_BY_CTID_PROC(Integer.parseInt(strCtId));
}
if (vo==null) return;


Tax tax = new Tax();
%>
<%@ include file="../Header.jsp" %>
<title>세금계산서발행신청</title>

<!-- for calendar -->
<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<!-- for numberOnly -->
<script type="text/javascript" src="<%=request.getContextPath() %>/static/plugin/jquery.number.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<style>
.readonly {background-color:#eee;}
tbody.obj>tr>th.red {background-color:#ffeeee;}
tbody.obj>tr>th.blue {background-color:#eeeeff;}
input:-moz-read-only {background-color: #eee;}
input:read-only {background-color: #eee;}
table.detail {margin-bottom:10px;}
</style>

<script>

var isCompressed = false;

function addRow() {
  var str = "";
  str += "<tr>";
  str += "  <td><input type='number' name='item_m'     class='item_m readonly'     maxlength='2' readOnly></td>";
  str += "  <td><input type='number' name='item_d'     class='item_d'     maxlength='2' min=1 max=31></td>";
  str += "  <td><input type='text'   name='item_item'  class='item_item'  maxlength='80'></td>";
  str += "  <td><input type='text'   name='item_spec'  class='item_spec'  maxlength='20'></td>";
  str += "  <td><input type='text'   name='item_cnt'   class='item_cnt'   numberOnly style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>";
  str += "  <td><input type='text'   name='item_unit'  class='item_unit'  numberOnly style='text-align:right;padding-right:5px;' onchange='calcSum();'></td>";
  str += "  <td><input type='text'   name='item_price' class='item_price' numberOnly style='text-align:right;padding-right:5px;' onchange='changePrice(this);'></td>";
  str += "  <td><input type='text'   name='item_tax'   class='item_tax'   numberOnly style='text-align:right;padding-right:5px;' onchange='changeTax(this);'></td>";
  str += "  <td><a class='btn btnDelRow'>-</a></td>";
  str += "</tr>";
  $("#itemlist>tbody").append(str);
  matchMonth();
}
$(function(){
  $( ".datepicker" ).datepicker({dateFormat:"yy<%=strDateSeparator%>mm<%=strDateSeparator%>dd"});
  localStorage.removeItem("tax_items");

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
  $(".compress").hide();

  $(document).on("keyup", "input:text[numberOnly]", function() {
    $(this).number(true);
  });

});

// 공급가만 수정
function changePrice(obj) {
  var p = $(obj).val().replaceAll(",", "");
  $(obj).val(addComma(p));

  var sumPrice = 0;
  $(".item_cnt").each(function(index, item) {
    var price = $(".item_price").eq(index).val().replaceAll(",", "");
    price = Math.round(price);
    sumPrice += price;
  });
  document.frmEnt.price_sum.value = addComma(sumPrice);
}

// 세금만 수정
function changeTax(obj) {
  var p = $(obj).val().replaceAll(",", "");
  $(obj).val(addComma(p));
  var sumTax = 0;
  $(".item_cnt").each(function(index, item) {
    var tax = $(".item_tax").eq(index).val().replaceAll(",", "");
    tax = Math.round(tax);
    sumTax += tax;
  });
  document.frmEnt.tax_sum.value = addComma(sumTax);
}

// 합계계산
function calcSum() {
  var sumPrice = 0;
  var isZeroTax = true;
  if ($("input:radio[name='taxtype']:checked").val() == "Y") isZeroTax = false;

  $(".item_cnt").each(function(index, item) {
    $(".item_cnt").eq(index).val(addComma($(".item_cnt").eq(index).val()));
    $(".item_unit").eq(index).val(addComma($(".item_unit").eq(index).val()));
    var price = $(".item_cnt").eq(index).val().replaceAll(",", "") * $(".item_unit").eq(index).val().replaceAll(",", "");
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
  var r   = (ymd.lastIndexOf("<%=strDateSeparator%>")==7) ? ymd.split("<%=strDateSeparator%>") : currentymd.split("<%=strDateSeparator%>");
  var m   = parseInt("1"+r[1]) - 100;
  var d   = parseInt("1"+r[2]) - 100;
  $(".item_cnt").each(function(index, item) {
    $(".item_m").eq(index).val(m);
    // if ($(".item_d").eq(index).val()>d) $(".item_d").eq(index).val(d);
  });
}

function setValues() {
  <%
  if (vo!=null) {
    int i = 0;
    String d = Integer.toString((100 + Integer.parseInt(StrUtil.nvl(vo.TRADEDATE, DateTimeUtil.getCurrentDate("")).substring(6)))-100);
  %>
  $('.item_m').eq(<%=i%>).val("");
  $('.item_d').eq(<%=i%>).val("<%=d%>");
  $('.item_item').eq(<%=i%>).val("<%=ConfigurationMgr.getInstance().getString("ETAX_ITEM_DEFAULT_NM") %> (<%=vo.CTNO%>)");
  $('.item_spec').eq(<%=i%>).val('-');
  $('.item_cnt').eq(<%=i%>).val("1");
  $('.item_unit').eq(<%=i%>).val("<%=vo.MPFEE_SUPPLYAMT%>");
  $('.item_price').eq(<%=i%>).val("<%=vo.MPFEE_SUPPLYAMT%>");
  $('.item_tax').eq(<%=i%>).val("<%=vo.MPFEE_TAXAMT %>");
  <%
  }
  %>
  calcSum();
  localStorage.setItem("tax_items", $("#itembody").html());
}

function integrated() {
  var itemcnt = $(".item_cnt").length - 1;
  var itemtail = (itemcnt>0) ? " 외 "+addComma(itemcnt)+"건" : "";
  var m     = $('.item_m').eq(0).val();
  var d     = $('.item_d').eq(0).val();
  var item  = $('.item_item').eq(0).val() + itemtail;
  var spec  = $('.item_spec').eq(0).val();
  var cnt   = 1;
  var unit  = document.frmEnt.price_sum.value;
  var price = document.frmEnt.price_sum.value;
  var tax   = document.frmEnt.tax_sum.value;

  $("#itembody").html("");
  addRow();

  $('.item_m').eq(0).val(m);
  $('.item_d').eq(0).val(d);
  $('.item_item').eq(0).val(item);
  $('.item_spec').eq(0).val(spec);
  $('.item_cnt').eq(0).val(addComma(cnt));
  $('.item_unit').eq(0).val(addComma(unit));
  $('.item_price').eq(0).val(addComma(price));
  $('.item_tax').eq(0).val(addComma(tax));

  $(".compress").show();
  $(".notcompress").hide();
}

function revoke() {
  $(".compress").hide();
  $(".notcompress").show();
  $("#itembody").html(localStorage.getItem("tax_items"));
  localStorage.removeItem("tax_items");
  setValues();
  calcSum();
}

// 발급
function publish() {
  if (checkFormField()) {

    var txt = "<table style='width:100%;'>";
    txt += "<tr><td>작성일</td><td class='right'>" + document.frmEnt.write_ymd.value + "</td></tr>";
    txt += "<tr><td>공급가액 합계</td><td class='right'>" + document.frmEnt.price_sum.value + "</td></tr>";
    txt += "<tr><td>세액 합계</td><td class='right'>" + document.frmEnt.tax_sum.value + "</td></tr>";
    txt += "<tr><td>합계 금액</td><td class='right'>" + document.frmEnt.sum_sum.value + "</td></tr>";
    txt += "</table>";
    txt += "<p>&nbsp;</p>";
    txt += "<p>상기 내용을 확인하시고 세금계산서를 발행신청하시려면 확인을 클릭하십시오.</p>";

    showCustomConfirm(
      txt,
      function() {
        hideLoading();
        $.ajax({
          type:"POST",
          url:"TaxWriteProc.jsp",
          data:$("#frmEnt").serialize(),
          contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
          success:function(r) {
            cnt = $.trim(r);
            if (cnt>0) {
              toast("발행신청되었습니다.", 1000, function() {
              location.href = "TaxRequestList.jsp";
              });
            }
          },
          error:function(a,b,c){
            toast("오류가 발생했습니다. 잠시 후 다시 시도하십시오. 문제가 지속되면 관리자에게 문의바랍니다.")
          }
        });
        // document.frmEnt.submit();
      },
      function() {

      }
    );
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
  if ($.trim(frm.comnm.value).length < 2) {
    toast("공급받는자의 상호 또는 이름(개인의 경우)을 입력하세요.");
    frm.comnm.value = $.trim(frm.comnm.value);
    frm.comnm.focus();
    return false;
  }
  
  if ($.trim(frm.ceonm.value).length < 2) {
    toast("공급받는자의 대표자명을 입력하세요.");
    frm.ceonm.value = $.trim(frm.ceonm.value);
    frm.ceonm.focus();
    return false;   
  }
  if ($.trim(frm.uptae.value).length < 2) {
    toast("업태를 입력하세요.");
    frm.uptae.value = $.trim(frm.uptae.value);
    frm.uptae.focus();
    return false;
  }
  if ($.trim(frm.upzong.value).length < 2) {
    toast("종목을 입력하세요.");
    frm.upzong.value = $.trim(frm.upzong.value);
    frm.upzong.focus();
    return false;
  }
  if (!checkEmailAddress(frm.tax_email.value)) {
    toast("올바른 이메일주소를 입력하세요.");
    frm.tax_email.value = $.trim(frm.tax_email.value);
    frm.tax_email.focus();
    return false;
  }
  if ($.trim(frm.address.value).length < 2) {
    toast("공급받는자의 주소를 입력하세요.");
    frm.address.value = $.trim(frm.address.value);
    frm.address.focus();
    return false;
  }
  if ($.trim(frm.manager.value).length < 2) {
    frm.manager.value = "담당자";
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

  // 합계금액 검증
  var totalPrice = Math.round(document.frmEnt.price_sum.value.replaceAll(",", ""));
  var totalTax   = Math.round(document.frmEnt.tax_sum.value.replaceAll(",", ""));
  var totalSum   = Math.round(document.frmEnt.sum_sum.value.replaceAll(",", ""));

  if (totalSum != totalPrice + totalTax) {
    showCustomConfirm("합계금액이 일치하지 않습니다.<br/>합계금액을 변경하시겠습니까?",
      function() {
      document.frmEnt.sum_sum.value = addComma(totalPrice + totalTax);
      }, function() {}
    );
    s = false;
    return false;
  }

  return s;
}

</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>세금계산서발행신청</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'></a>
  </span>
</div>

  <form name='frmEnt' id='frmEnt' method='post' action='TaxWriteProc.jsp'>
  <input type='hidden' name='senderCode' value="<%=ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE")%>">
  <input type='hidden' name='ctid' id='ctid' value='<%=strCtId%>'>
  <input type='hidden' name='cpyid' id='cpyid' value='<%=vo.CPY_ID %>'>


  <table class='list detail'>
    <colgroup>
      <col width='130'/>
      <col width='*'/>
      <col width='130'/>
      <col width='*'/>
    </colgroup>
    <tbody>
      <tr>
        <th>과세구분</th>
        <td>
          <input type='radio' name='taxtype' id='taxtype_general' value='Y' onclick='calcSum()' checked> 일반
          <!-- 
          <input type='radio' name='taxtype' id='taxtype_free'    value='F' onclick='calcSum()'> 면세
          <input type='radio' name='taxtype' id='taxtype_zero'    value='Z' onclick='calcSum()'> 영세
           -->
        </td>
        <th>영수/청구 구분</th>
        <td>
          <!-- 
          <input type='radio' name='purposetype' value='1'> 영수
          -->
          <input type='radio' name='purposetype' value='2' checked> 청구
        </td>
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
        <td colspan='3'><input type='number' name='bizno' value='<%=vo.CPY_BUSINESS_NO %>' readOnly></td>
      </tr>
      <tr>
        <th class='red'>상　호</th>
        <td style='white-space:normal;'><%=tax.getComNm() %></td>
        <th class='red'>성　명</th>
        <td style='white-space:normal;'><%=tax.getCeo() %></td>
        <th class='blue'>상　호</th>
        <td><input type='text' name='comnm' value='<%=vo.CPY_NAME %>' maxlength='20' readOnly></td>
        <th class='blue'>성　명</th>
        <td><input type='text' name='ceonm' value='<%=vo.CPY_CEO_NAME %>' maxlength='10' placeholder="대표자명(필수)"></td>
      </tr>
      <tr>
        <th class='red'>주　소</th>
        <td colspan='3' style='white-space:normal;'><%=tax.getAddr() %></td>
        <th class='blue'>주　소</th>
        <td colspan='3'><input type='text' name='address' value='<%=vo.CPY_ADDR %> <%=vo.CPY_ADDR2 %>' maxlength='150' placeholder="주소(필수)"></td>
      </tr>
      <tr>
        <th class='red'>업　태</th>
        <td style='white-space:normal;'><%=tax.getBizType() %></td>
        <th class='red'>종　목</th>
        <td style='white-space:normal;'><%=tax.getBizClass() %></td>
        <th class='blue'>업　태</th>
        <td><input type='text' name='uptae' value='<%=vo.BUSINESS_TYPE %>' maxlength='30' placeholder="업태(필수)"></td>
        <th class='blue'>종　목</th>
        <td><input type='text' name='upzong' value='<%=vo.INDUSTRY %>' maxlength=30 placeholder='업종(필수)'></td>
      </tr>
      <tr>
        <th class='red'>담당자</th>
        <td><%=tax.getManager() %></td>
        <th class='red'>연락처</th>
        <td></td>
        <th class='blue'>담당자</th>
        <td><input type='text' name='manager' value='<%=vo.MPTAX_USER_NM %>' maxlength=50 placeholder='담당자명(필수)'></td>
        <th class='blue'>연락처</th>
        <td><input type='text' name='phoneno' value='' maxlength=20 placeholder='전화번호'></td>
      </tr>
      <tr>
        <th class='red'>이메일</th>
        <td colspan='3'><%=tax.getEmail() %></td>
        <th class='blue'>이메일</th>
        <td colspan='3'><input type='text' name='tax_email' value='<%=vo.MPTAX_EMAIL %>' maxlength=50 placeholder='이메일주소(필수)'></td>
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
      <tr>
        <td colspan='4'><input type='text' name='remark' value='' maxlength='50' placeholder='비고'></td>
    </tbody>
  </table>

  <table id="itemlist" class='list detail'>
    <colgroup>
      <col width='80'/>
      <col width='80'/>
      <col width='*'/>
      <col width='200'/>
      <col width='100'/>
      <col width='150'/>
      <col width='150'/>
      <col width='150'/>
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
        <th><a href='javascript:addRow(this)' class='btn'>+</a></th>
      </tr>
    </thead>
    <tbody id='itembody'>

    </tbody>
  </table>

</form>

<div class='btns'>
  <a href='javascript:publish();'>발행신청</a>
</div>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>