<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCommId = StrUtil.nvl(request.getParameter("commid"), "0");
String strCpyId  = StrUtil.nvl(request.getParameter("cpy_id"), "0");
String strCpyNm  = StrUtil.nvl(request.getParameter("cpy_nm"), "");
strCpyId         = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? IntegerCryptoUtil.crypt(strCpyId) : strCpyId;
String strAction = "등록";
CommissionVO vo  = null;
String strDesc   = "";
if (!strCommId.equals("0") && StrUtil.isOnlyNumeric(strCommId)) {
  vo = new CommissionBean().INFO_COMMISSION_DETAIL_PROC(Integer.parseInt(strCommId));
  strDesc = vo.COMM_DESC.replaceAll("<br>", "");
  strAction = "수정";
}
if (vo!=null && vo.COMM_ID==0) {
  vo = null;
  strAction = "등록";
}

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("INFO_COMMISSION.COMM_METHOD");
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>수수료<%=strAction %></title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">

<script>
function numberToKorean(num) {
  if (typeof num !== 'number' || isNaN(num)) throw new Error('유효한 숫자를 입력해주세요.');
  const units = ['', '만', '억', '조', '경'];
  const digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
  const positions = ['', '십', '백', '천'];
  if (num === 0) return '영';
  let result = '';
  let unitIndex = 0;
  while (num > 0) {
    let part = num % 10000; // 4자리씩 나눔
    num = Math.floor(num / 10000);
    if (part > 0) {
      let partStr = '';
      let positionIndex = 0;
      while (part > 0) {
        let digit = part % 10;
        if (digit > 0) partStr = digits[digit] + positions[positionIndex] + partStr;
        part = Math.floor(part / 10);
        positionIndex++;
      }
      result = partStr + units[unitIndex] + result;
    }
    unitIndex++;
  }
  return result;
}
function printKorean() {
  $(".receive_money>span").text(numberToKorean(1*document.frmEnt.receive_money.value)+"원");
}

function toogleMethod() {
  var method = document.frmEnt.pay_method[document.frmEnt.pay_method.selectedIndex].value;
  $(".term, .max_yn, .receive_money, .offline_yn, .discount_rate, .std_days, .mty_days, .commission_rate, .commission_rate_etc").hide();
  if ("A10,C10,B10,B20".indexOf(method)>-1) {
    $(".max_yn, .discount_rate").show();
    if ($("input[name='max_yn']").is(":checked") == true) $(".term, .receive_money, .offline_yn").show();
    if (method=="A10") $(".commission_rate, .commission_rate_etc, .std_days, .mty_days").show();
    if (method=="C10") $(".commission_rate_etc, .std_days, .mty_days").show();
    if (method=="B10" || method=="B20") $(".commission_rate").show();
  }
  else if (method=="F10") {
    $("input[name='max_yn']").prop("checked", false);
    $(".term").show();
  } else {
    $("input[name='max_yn']").prop("checked", false);
    $(".term, .receive_money, .offline_yn, .commission_rate, .commission_rate_etc").show();
  }

  if ($("input[name='max_yn']").is(":checked") == true) {
    $("input[name='offline_yn']").prop("checked", false).prop("disabled", true); 
  } else {
    $("input[name='offline_yn']").prop("disabled", false); 
  }


  if ($(".offline_yn").is(":visible") == false) {
    $("input[name='offline_yn']").prop("checked", false);
  }
}


$(document).ready(function() {
  $("input[name='max_yn']").on("change", function() {
    if ($(this).is(":checked")) {
      $("input[name='offline_yn']").prop("checked", false).prop("disabled", true); 
    } else {
      $("input[name='offline_yn']").prop("disabled", false); 
    }
  });
});

var to = 0;
function searchCompany(t) {
  to = t;
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function cannotSearchCompany() {
  toast("입금내역이 있어 구매기업, 판매기업, 부담주체는 수정할 수 없습니다.", 2000);
}
function choiceCompany(obj) {
  if (to==0) {
    document.frmEnt.buyer_id.value = $(obj).attr("cid");
    document.frmEnt.buyer_nm.value = $(obj).text();
  } else {
    document.frmEnt.seller_id.value = $(obj).attr("cid");
    document.frmEnt.seller_nm.value = $(obj).text();
  }
  closePopup();
}
function goSubmit() {
  if (document.frmEnt.pay_cpy[document.frmEnt.pay_cpy.selectedIndex].value=="B" && document.frmEnt.buyer_id.value==0) {
    showAlert("구매사 부담인 경우, 구매사의 선택은 필수입니다.");
    return false;
  }
  if (document.frmEnt.pay_cpy[document.frmEnt.pay_cpy.selectedIndex].value=="S" && document.frmEnt.seller_id.value==0) {
    //showAlert("판매사 부담인 경우, 판매사의 선택은 필수입니다.");
    //return false;
  }
  var isSuccess = true;
  $("ul.form input[type='number']:visible, ul.form input[type='text']:visible, ul.form input[type='date']:visible").each(function(idx,item) {
    $(item).css("border-color", "#ddd");
    if ($(item).val()=="") {
      showAlert($(item).parent().children("label").text() + "항목을 입력하십시오.");
      $(item).css("border-color", "hotpink");
      isSuccess = false;
      return false;
    }
  });
  
  $("ul.form input[type='number']:hidden, ul.form input[type='text']:hidden, ul.form input[type='date']:hidden").each(function(idx,item) {
    $(item).val("");
  });
  
  if (isSuccess) {
    showLoading();
    $.post("MpFeeRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data){
      if (data=="-1") {
    	hideLoading();
        showAlert("선택한 구매사와 판매사의 수수료정보가 이미 등록되어 있어 등록할 수 없습니다.");
      } else if (data!="") {
        location.href = strContextPath + "/mgr/mpfee/MpFeePerCustomer.jsp?cpy_id="+data;
      } else {
        hideLoading();
        showAlert("<%=strAction %>에 실패했습니다.");
      }
    });
  }
  return false;
}

<%
if (!strCommId.equals("0") && vo!=null) {
  String strBuyer  = (!vo.CPY_BUYER.equals("0")) ? vo.BUYER_NM + "(" + vo.BUYER_BIZ_NO + ")" : "";
  String strSeller = (!vo.CPY_SELLER.equals("0")) ? vo.SELLER_NM + "(" + vo.SELLER_BIZ_NO + ")" : "";
%>
function fillData() {
  $("input[name='buyer_id']").val(<%=vo.CPY_BUYER %>);
  $("input[name='seller_id']").val(<%=vo.CPY_SELLER %>);
  $("input[name='buyer_nm']").val("<%=strBuyer%>");
  $("input[name='seller_nm']").val("<%=strSeller%>");
  $("select[name='pay_cpy']").val("<%=vo.PAY_CPY%>");
  $("select[name='pay_gubun']").val("<%=vo.PAY_GUBUN%>");
  $("select[name='pay_method']").val("<%=vo.COMM_METHOD%>");
  $("input[name='max_yn']").prop("checked", <%=(vo.MAX_YN.equals("Y"))?"true":"false"%>);
  $("input[name='receive_money']").val("<%=StrUtil.extractInteger(vo.RECEIVE_MONEY) %>");
  $("input[name='offline_yn']").prop("checked", <%=(vo.OFFLINE_YN.equals("Y"))?"true":"false"%>);
  $("input[name='start_dt']").val("<%=FormatUtil.addSeparatorDate(vo.START_DT, "-") %>");
  $("input[name='end_dt']").val("<%=FormatUtil.addSeparatorDate(vo.END_DT, "-") %>");
  $("input[name='std_days']").val("<%=vo.STD_DAYS %>");
  $("input[name='mty_stdays']").val("<%=vo.MTY_STDAYS %>");
  $("input[name='mty_enddays']").val("<%=vo.MTY_ENDDAYS %>");
  $("input[name='cpy_commission_rate']").val("<%=vo.CPY_COMMISSION_RATE %>");
  $("input[name='discount_rate']").val("<%=vo.DISCOUNT_RATE %>");
  $("input[name='cpy_commission_rate1']").val("<%=vo.CPY_COMMISSION_RATE1 %>");
  $("input[name='cpy_commission_rate2']").val("<%=vo.CPY_COMMISSION_RATE2 %>");
  $("input[name='end_money']").val("<%=StrUtil.extractInteger(vo.END_MONEY) %>");
  printKorean();
  
  if ($("input[name='end_money']").val()!="0") {
    $("a.search-company").css('background-color', '#eee');
    $("input[name='buyer_nm'], input[name='seller_nm'], a.search-company").attr('onclick', 'cannotSearchCompany()');
    $("select[name='pay_cpy']").css("pointer-events", "none");
    $("select[name='pay_cpy']").css('color', '#888');
    $("div.comment").text("[참고] 입금내역이 있어 구매기업, 판매기업, 부담주체는 수정할 수 없습니다.");
  }
}
<%
}
%>

$(document).ready(function(){
<%
  if (!strCommId.equals("0") && vo!=null) out.print("fillData();");
%>
  toogleMethod();
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>수수료<%=strAction %></span>
  <span class='more'>
    <a onclick='history.go(-1);' class='btn'>돌아가기</a>
  </span>
</div>

<form name='frmEnt'>
<input type='hidden' name='comm_id' value='<%=strCommId %>'>
<input type='hidden' name='buyer_id' value='<%=strCpyId%>'>
<input type='hidden' name='seller_id' value='0'>
<input type='hidden' name='end_money' value='0'>
<h3 style='margin-top:0;'>&nbsp;</h3>
<ul class='form'>
  <li>
    <label>구매사</label>
    <input type='search' name='buyer_nm' value='<%=strCpyNm %>' style='width:calc(100% - 196px);' readOnly placeholder='선택하지 않으면 모든 구매사로 적용' onclick='searchCompany(0);'>
    <a onclick='searchCompany(0);' class='btn search-company'>검색</a>
  </li>
  <li>
    <label>판매사</label>
    <input type='search' name='seller_nm' style='width:calc(100% - 196px);' readOnly placeholder='선택하지 않으면 모든 판매사로 적용' onclick='searchCompany(1);'>
    <a onclick='searchCompany(1);' class='btn search-company'>검색</a>
  </li>
  <li>
    <label>부담주체</label>
    <select name='pay_cpy'>
      <option value='B'>구매기업</option>
      <option value='S'>판매기업</option>
    </select>
  </li>
  <li>
    <label>결제구분</label>
    <select name='pay_gubun'>
      <option selected value="10">구매자금/카드(론)</option>
      <option value="20">종통대</option>
      <option value="30">글로벌구매카드</option>
    </select>
  </li>
  <li>
    <label>계산방식</label>
    <select name='pay_method' onchange='toogleMethod();'>
      <%
      if (arrCodes!=null && arrCodes.size()>0) {
        for (int i=0; i<arrCodes.size();) {
          CodeVO c = arrCodes.remove(0);
          out.println("<option value='"+StrUtil.nvl(c.CODE_CD).trim()+"'>"+StrUtil.nvl(c.CODE_NM).trim()+"</option>");
        }
      }
      %>
    </select>
  </li>
  <li class='max_yn not-has-input'>
    <label>연맥스여부</label>
    <input type='checkbox' name='max_yn' value='Y' onclick='toogleMethod();'> 연맥스
  </li>
  <li class='receive_money'>
    <label>받을금액</label>
    <input type='number' name='receive_money' style='width:85px;' onKeyUp='printKorean();'>
    <span></span>
  </li>
  <li class='offline_yn not-has-input'>
    <label>오프라인징수여부</label>
    <input type='checkbox' name='offline_yn' value='Y'> 징수
  </li>
  <li class='term'>
    <label>적용기간</label>
    <input type='date' name='start_dt' style='width:auto;'> ~ <input type='date' name='end_dt' style='width:auto;'>
  </li>
  <li class='std_days'>
    <label>기준일수</label>
    <input type='number' name='std_days' style='width:85px;' placeholder='기준일수'>
  </li>
  <li class='mty_days'>
    <label>만기계산일수</label>
    <input type='number' name='mty_stdays' style='width:85px;' placeholder='시작일수'> ~ <input type='number' name='mty_enddays' style='width:85px;' placeholder='종료일수'>
  </li>
  <li class='commission_rate'>
    <label>기본수수료율(%)</label>
    <input type='number' name='cpy_commission_rate' style='width:85px;' placeholder='기본율'>
  </li>
  <li class='discount_rate'>
    <label>할인율(%)</label>
    <input type='number' name='discount_rate' style='width:85px;' placeholder='할인율'>
  </li>
  <li class='commission_rate_etc'>
    <label>비례수수료율1, 2(%)</label>
    <input type='number' name='cpy_commission_rate1' style='width:85px;' placeholder='비례율1'>
    <input type='number' name='cpy_commission_rate2' style='width:85px;' placeholder='비례율2'>
  </li>
</ul>
<ul class='form'>
  <li>
    <label style='vertical-align:top;'>메모</label>
    <textarea name='comm_desc' style='width:calc(100% - 168px);'><%=strDesc%></textarea>
  </li>
</ul>
</form>
<div class='comment' style='text-align:center;color:hotpink;'></div>
<p>&nbsp;</p>
<div class='btns'><a onclick='goSubmit();'><%=strAction %></a></div>

<%@ include file="../Footer.jsp" %>



