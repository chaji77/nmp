const intMessageShowTime  = 2000;
var   intLimitSum         = 0;
var   PurchasePayCode     = "4"; // 구매자금상품끝자리(세금계산서 31일 제한 대상)
var   KoditGeneralPayCode = [6, 56]; // 신보일반자금상품
var   KoditExceptSeller   = [58954, 15028, 29308]; // 신보 일반자금 세금계산서 첨부 예외 판매사(변경바람)
var   NonWarrantyPayCodes = [21,23,24,26,104,124]; // 비보증상품코드
var   NeedBillNonWarrantyBandAndPayCodes = ['HN____24','KE____24','HN____104','KE____104','HN____124','KE____124','KE____124']; // 세금계산서 첨부가 의무인 비보증 상품의 은행/제품 코드
var   KiboPayCode         = [11,12,13,14,16]; // 기보상품코드

////////////////////////// WINDOW CONTROL //////////////////////////

/* hint toggle */
function toggleHint(tgt) {
  var is = $(".hint."+tgt).is(":visible");
  if (!is) $(".hint."+tgt).slideDown();
  else $(".hint."+tgt).slideUp();
}
/* close bPopup window */
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}
/* 거래처를 선택하거나 세금계산서 첨부화면을 열거나, 세금계산서가 첨부되면 실행한다 */
function checkSeller() {
  var is = $("#bills").is(":visible");
  if ($("select[name='seller_cpy_id']").length==0) { // 판매계약서는 선택할 판매사가 없으므로 생략
    changeTaxRate();
    return false;
  }
  var seller = $("select[name='seller_cpy_id']").val();
  if (is && seller.indexOf("____")>-1) { // 세금계산서 창이 열려 있으면 세금계산서 창에 필요한 변수를 할당
    if (typeof bill_seller_id != 'undefined') bill_seller_id = seller.split("____")[0]; // 세금계산서 첨부대상아아디
    if (typeof searchBills != 'undefined') searchBills(1); // searchBills()가 존재하면 재실행하여 세금계산서를 가져온다
  }
  $("input[name='mp_pay_cpy']").prop("checked", false);
  if (seller.split("____")[2] == "S") {
    $("input[name='mp_pay_cpy'][value='1']").prop("checked", true); // MP수수료 부담주체를 판매사로 변경
  } else {
    $("input[name='mp_pay_cpy'][value='2']").prop("checked", true); // MP수수료 부담주체를 구매사로 변경
  }
  itemWriteMode(); // 세금계산서수기등록 허용여부를 판단
  changeTaxRate(); // 공급가/세액/합계금액을 재계산
}
/* 내거래처 추가화면 호출 */
function showPartnerReg() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/web/trade/MyCompanyReg.jsp'});
}
/* 한도조회 */
function checkLimit(booShowMsg) {
  if (($("select[name='bnk_pay_id'] option:selected").val()).indexOf("____")<0) {
    toast("결제은행 및 결제수단을 선택하십시오.");
    return;
  }
  var bp = ($("select[name='bnk_pay_id'] option:selected").val()).split("____");
  $.ajax({
    url:strContextPath + "/web/transaction/A311.jsp", 
    type: 'post',
    data:{'cpy_id':strCpyId,'bank_cd':bp[0],'pay_cd':bp[1]}, 
    success: function(data) {
      var json = JSON.parse($.trim(data));
      intLimitSum = json.limit; // 한도총액을 저장하지만, 이 정보로 거래를 제한하지는 않는다
      json.msg = "<h4 style='margin-top:0;padding-top:0;'>"+$("select[name='bnk_pay_id'] option:selected").text()+" 한도조회결과</h4>" + json.msg;
      if (!json.is || booShowMsg) showAlert(json.msg);
    },
    beforeSend: function() {
      showSpinner("보증기관 및 은행과 통신하고 있습니다.<br/>잠시 기다려주세요.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
/* calendar window toggle */
function toggleCalendar() {
  var is = $("#calendar").is(":visible");
  if (!is) $("#calendar").load(strContextPath + "/web/trade/Calendar.jsp").slideDown();
  else hideCalendar();
}
/* hide calendar window */
function hideCalendar() {
  $("#calendar").hide();
  $("#calendar").children().remove();
}
/* 세금계산서 첨부화면을 열거나 닫는다 */
function toggleBills() {
  var seller = 0;
  if ($("select[name='seller_cpy_id']").length>0) { // 판매계약서는 해당사항이 없다
    seller = $("select[name='seller_cpy_id']").val();
    if (seller=="0") {
      toast("판매기업을 먼저 선택하십시오.", intMessageShowTime);
      $("select[name='seller_cpy_id']").focus();
      return;
    }
  }
  var is = $("#bills").is(":visible"); // 세금계산서 첨부화면이 열렸는지
  if (!is) { // 세금계산서 첨부화면이 닫혀 있으면 연다
    $("#bills").children().remove();
    if ($("select[name='seller_cpy_id']").length==0) {
      var url = strContextPath + "/web/trade/Bills.jsp?seller_id=0";
    } else {
      var seller_id = $("select[name='seller_cpy_id']").val().split("____")[0];
      var url = strContextPath + "/web/trade/Bills.jsp?seller_id="+seller_id;
    }
    $("#bills").load(url).slideDown();
    $(".reverse-bills").hide();
  } else { // 세금계산서 첨부화면이 열려있으면 닫는다
    $("#bills").slideUp();
    $("#bills").children().remove();
    $(".reverse-bills").show();
  }
}
/* 세금계산서첨부화면을 다시 연다 */
function reloadBills() {
  $("#bills").hide();
  toggleBills();
}

/* 세금계산서 가져오기창을 연다 */
function openScrap() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/web/trade/BillScrap.jsp'});
}

/* 세금계산서파일 첨부 창을 연다 */
function openXml() {
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/web/trade/BillXml.jsp'});
}

////////////////////////// 수기등록 통제 //////////////////////////

/* 비보증 거래 및 신보 일반자금 중 일부 판매사 대상 매매계약서는 세금계산서 첨부가 필요하지 않다 */
function isNonWarranty() {
  var isMode       = false;
  if ($('select[name="bnk_pay_id"]').length==0) return false; // 판매계약서는 예외처리
  if ($('select[name="bnk_pay_id"]').val() == null) return false; // 약정된 상품이 없으면 예외처리
  var selectedBankAndPayCode = ($('select[name="bnk_pay_id"]').val()).split("____");
  for (var i=0; i<NonWarrantyPayCodes.length; i++) {
    if (selectedBankAndPayCode[1] == NonWarrantyPayCodes[i]) {
      isMode = true; // 비보증은 기본적으로 세금계산서 첨부 예외
      for (var j=0; j<NeedBillNonWarrantyBandAndPayCodes.length; j++) {
        if (selectedBankAndPayCode[0]+"____"+selectedBankAndPayCode[1] == NeedBillNonWarrantyBandAndPayCodes[j]) {
          return false; // 세금계산서첨부가 의무화된 은행은 첨부 필수
        }
      }
    }
  }
  if ($("select[name='seller_cpy_id']").val().indexOf("____")>0) { // 판매계약서가 아니면
    var ks = $("select[name='seller_cpy_id']").val().split("____")[0];
    for (var i=0; i<KoditExceptSeller.length; i++) {
      if (KoditExceptSeller[i]==ks) {
        for (var j=0; j<KoditGeneralPayCode.length; j++) {
          if (KoditGeneralPayCode[j] ==selectedBankAndPayCode[1]) return true; // 신보 일반자금 중 일부 판매사와 거래하는 경우 세금계산서 첨부 예외
        }
      }
    }
  }
  return isMode;
}
/* 기보상품인 경우 판매사가 개인기업인 경우 세금계산서 첨부가 필요하지 않다 : 2025/05/12 */
function isKiboPersonal() { 
  var seller = $("select[name='seller_cpy_id']").val();
  if (seller.indexOf("____")<0) return false;
  var sellerCrsId = seller.split("____")[3];
  // console.log(sellerCrsId);
  if (sellerCrsId=="2") {
    if ($('select[name="bnk_pay_id"]').val() == null) return false; // 상품코드가 없는 경우 예외처리
    var selectedBankAndPayCode = ($('select[name="bnk_pay_id"]').val()).split("____");
    for (var i=0; i<KiboPayCode.length; i++) {
      if (selectedBankAndPayCode[1] == KiboPayCode[i]) {
        return true;
      }
    }
  }
  return false;
}
/* 수기세금계산서 작성을 허용할지 결정한다 */
function itemWriteMode() {
  if (isNonWarranty() || isKiboPersonal()) { // 비보증상품 또는 일반자금 일부 판매사 대상 거래, 개인기업으로 종이세금계산서발행허용업체이면서 기보상품을 이용하면 품목정보등록허용
    $("a.btnItemWriteMode").show();
    $("#items tfoot").show();
    if ($("#bill-item-list tr.load_mode_tr").length>0) $("a.btnItemWriteMode").hide(); // 수기작성을 허용했지만, 세금계산서를 첨부하는 경우 품목등록 버튼을 감춘다
  } else {
    $("a.btnItemWriteMode").hide(); // 버튼을 감춘다
    $("#bill-item-list tr.write_mode_tr").remove(); // 품목작성폼을 없앤다
    $('#bill-item-list td.noentry').show(); // 세금계산서첨부 안내를 띄운다
  }
}
/* 수기세금계산서 품목작성폼을 추가한다 */
function addItemWriteRow() {
  var strItemRow = "<tr class='write_mode_tr'>";
  strItemRow += "<td><input type='text' name='item_nm' value=''></td>";
  strItemRow += "<td class='item_cnt right mobile_hide'><input type='text' name='item_qty' value='1' class='numput' maxlength='5'></td>";
  strItemRow += "<td><input type='text' name='item_unit' value=''></td>";
  strItemRow += "<td class='item_amount right' style='padding-right:10px;'></td>";
  strItemRow += "<td class='item_tax right mobile_hide' style='padding-right:10px;'></td>";
  strItemRow += "<td><input type='text' name='item_sum' value='' maxlength='12' class='numput'></td>";
  strItemRow += "<td class='center'><a onclick='dropItem(this);' class='btn'><i class='fa fa-trash' aria-hidden='true'></i></a></td>";
  strItemRow += "</tr>";
  $('#bill-item-list td.noentry').hide();
  $('#bill-item-list').append(strItemRow);
}

////////////////////////// ITEM CONTROL //////////////////////////

/* 스크랩거래 또는 계산서종류의 선택, 거래처의 변경, 품목의 합계금액 변경에 따라 세액계산을 다시한다 */
function changeTaxRate() {
  var booScrap = ($("input[name='scrap_yn']").is(":checked")) ? true : false; 
  if (booScrap) $("input:radio[name='tax_biz_type']:input[value='G']").prop("checked", true);

  $("#bill-item-list tr").each(function(idx, item) {
    if (typeof calcItem != 'undefined') {
      var t = $(item).find("td").find("input[name='item_sum']");
      if (t.length>0) calcItem(t);
    }
  });
}
/* 선택된 품목을 삭제한다. 세금계산서의 분할 사용 등의 이유로 삭제를 허용한다. */
function dropItem(obj) {
  if ($("#bill-item-list tr").length < 2) {
    toast("삭제할 수 없습니다.<br/>하나 이상의 품목이 필요합니다.", 2000);
    return;
  }
  $(obj).parent().parent().remove();
  calcSum();
  return;
}
/** 
 * 세액계산의 방법 변경에 따라 품목의 공급가, 세액 등을 조정한다.
 * @param obj 품목의 합계금액요소
 */
function calcItem(obj) {
  $(obj).val($(obj).val().replace(/[^0-9,]/g, '')); // 숫자만 남긴다
  var sum      = 1 * ($(obj).val().replace(/,/g, "")); // 숫자로 변환
  var booScrap = ($("input[name='scrap_yn']").is(":checked")) ? true : false; // 스크랩거래여부 
  var biztype  = $("input[name='tax_biz_type']:checked").val(); // 세액계산방식
  var taxrate  = (biztype!="G") ? 1 : 1.1; // 일반계산서가 아니면 세율이 1이다
  var amount   = Math.round(sum/taxrate); // 공급가계산
  if (booScrap) { // 스크랩거래라면 
    biztype    = "G"; // 세액계산방식을 일반으로 바꾸고
    $("input:radio[name='tax_biz_type']:input[value='G']").prop("checked", true);
    taxrate    = 1;   // 세율을 없애고
    if ($(obj).parent().parent().find(".item_tax").text()==0) amount = sum; // 이미 세액이 0이면 총액을 수정한 것이므로 공급가를 총액에 맞춘다
    else { // 세액이 0이 아니면 처음 세금계산서가 첨부된 것으로 총액을 공급가로 반영한다
      amount   = 1 * $(obj).parent().parent().find(".item_amount").text().replace(/,/g, "");
      sum      = amount;
    }
    tax        = 0; // 세액도 0이다
  }
  var tax = sum - amount;
  $(obj).parent().parent().find(".item_amount").text((""+amount).replace(/\B(?=(\d{3})+(?!\d))/g, ","));
  $(obj).parent().parent().find(".item_tax").text((""+tax).replace(/\B(?=(\d{3})+(?!\d))/g, ","));
  $(obj).val((""+sum).replace(/\B(?=(\d{3})+(?!\d))/g, ","));
  
  // 스크랩거래의 경우 세금계산서 사용한도를 재설정한다
  if (booScrap) {
    var intScripLimitAmt = 0;
    $("#bill-item-list tr").find(".item_amount").each(function(idx, item) {
      var amt = $(item).text().replace(/[^0-9]/g, '');
      if (!isNaN(amt)) intScripLimitAmt += (1 * amt);
      else console.log(amt);
    });
    $("input[name='bill_max_limit']").val(intScripLimitAmt);
    console.log($("input[name='bill_max_limit']").val());
  }
  calcSum();
}
/* 품목정보를 불러와 합계금액을 변경한다 */
function calcSum() {
  let sa = 0;
  let sv = 0;
  let ss = 0;
  let tr_length = $("#bill-item-list tr").length - (($('#bill-item-list tr td').hasClass('noentry'))?1:0); // 품목의 수를 계산한다
  if (tr_length>0) { 
    $("#bill-item-list tr").each(function(idx, item) {
      if ($(item).find("input[name='item_sum']").length>0) {
        sa += 1*$(item).find(".item_amount").text().replace(/,/g, ""); // 공급가액을 추가
        sv += 1*$(item).find(".item_tax").text().replace(/,/g, ""); // 세액을 추가
        ss += 1*$(item).find("td>input[name='item_sum']").val().replace(/,/g, ""); // 합계금액을 추가
      }
    });
  } else $('#bill-item-list td.noentry').show(); // 품목이 없으면 추가하라는 메시지를 출력
  $(".item_total_amount").text((""+sa).replace(/\B(?=(\d{3})+(?!\d))/g, ",")); // 공급가의 합계를 출력
  $(".item_total_tax").text((""+sv).replace(/\B(?=(\d{3})+(?!\d))/g, ","));    // 세액의 합계를 출력
  $(".item_total_sum").text((""+ss).replace(/\B(?=(\d{3})+(?!\d))/g, ","));    // 합계금액의 합계를 출력
}

////////////////////////// SIGNATURE //////////////////////////

/* call signature window */
function loadCert() {
  if (document.frmEnt.ctid.value.length > 0 && document.frmEnt.token.value.length > 0) { // FAILED DURING TRANSMISSION, RETRANSMISSION ATTEMPTED
    send();
    return;
  }
  $("#element_to_pop_up").empty();
  var url = strContextPath + '/static/programs/cert/?ssn='+$("#bizno").val();
  $("#signdata").val("");
  $('#element_to_pop_up').append("<iframe id='ifrm_cert'></iframe>");
  $('#ifrm_cert').attr('src', url);
  $('#element_to_pop_up').bPopup();
  document.getElementById("ifrm_cert").contentWindow.postMessage("CALL", "*");
}
/* callback from signature window */
window.addEventListener("message", function(e) {
  hideLoading();
  $("#sgn_id").val("");
  $("#signdata").val("");
  if (e.data=="CLOSE") { // click cancel button
    closePopup();
    return;
  } else if (e.data=="CLOSE_FAIL_SSN") { // mismatch biz no.
    closePopup();
    toast("사업자번호가 불일치합니다.", intMessageShowTime);
    return;
  }
  if (e.data.length>30) { // success
    $("#sgn_id").val("0000");
    var k = (e.data.split("$data")[0]).replace("$dn=", ""); // extract header values
    $("#signdata").val(k);
    closePopup();
  $("input[name='temp_save']").val(0); // 서명하면 임시저장아님
    goSubmit(); // 등록실행
  }
  return;
});

////////////////////////// CHECK BEFORE SUBMIT //////////////////////////
function formatYmdKorean(dateStr) {
  if (!/^\d{8}$/.test(dateStr)) {
    throw new Error("Invalid date format. Expected yyyyMMdd (e.g., 20250201).");
  }
  let year = dateStr.substring(0, 4);
  let month = dateStr.substring(4, 6);
  let day = dateStr.substring(6, 8);
  return `${year}년 ${month}월 ${day}일`;
}
/* show error message */
function showErrorMsg(msg) {
  showAlert(msg);
  if (self != top) {
    parent.hideSpinner();
    parent.showAlert(msg);
  }
}
/* verification confirmation */
function check() {
  var is = true;

  // 판매사선택여부 (판매계약서는 통과)
  var seller = $("select[name='seller_cpy_id']").val();
  if (seller.indexOf("____")<0) {
    showErrorMsg("판매기업을 선택하십시오.");
    $("select[name='seller_cpy_id']").focus();
    return false;
  }
  // 결제은행/수단선택여부 (판매계약서는 통과)
  if ($("select[name='bnk_pay_id'] option:selected").val()==undefined || ($("select[name='bnk_pay_id'] option:selected").val()).indexOf("____")<0) {
    showErrorMsg("결제은행 및 결제수단이 선택되지 않았습니다.");
    $("select[name='bnk_pay_id']").focus();
    return false;
  }
  // 만기일지정여부
  if ($.trim($("input[name='maturity_ymd']").val()).length < 8) {
    showErrorMsg("만기(대출상환)일 지정이 필요합니다.");
    $("input[name='maturity_ymd']").focus();
    return false;
  }
  // 세금계산서첨부여부
  if (!isNonWarranty() && !isKiboPersonal()) { // 비보증, 일반자금 중 일부, 기보 개인+종이세금계산서 사용업체는 제외
    if ($.trim($("input[name='bill_app_no']").val()).length < 8 && $.trim($("input[name='bill_ymd']").val()).length!=8) {
      showErrorMsg("세금계산서 첨부가 필요합니다.");
      return false;
    }
  }
  // 구매기업 사업자번호와 세금계산서 공급받는자 사업자번호 비교(본지사포함)
  if (($("input[name='buyer_related_biz_nos']").val()).indexOf($("input[name='bill_buyer_biz_no']").val())<0) {
    console.log($("input[name='buyer_related_biz_nos']").val() + ":" + $("input[name='bill_buyer_biz_no']").val());
    showErrorMsg("구매기업과 세금계산서 공급받는자의 사업자번호가 일치하지 않습니다.<br/>공급받는자의 사업자가 본지사의 관계인 경우, 고객센터로 문의바랍니다.");
    return false;
  }
  // 판매기업 사업자번호와 세금계산서 공급자 사업자번호 비교(본지사포함)
  if (($("input[name='seller_related_biz_nos']").val()).indexOf($("input[name='bill_seller_biz_no']").val())<0) {
    showErrorMsg("판매기업과 세금계산서 공급자의 사업자번호가 일치하지 않습니다.<br/>공급자의 사업자가 본지사의 관계인 경우, 고객센터로 문의바랍니다.");
    return false;
  }
  /* 거래금액 vs. 세금계산서 점검 */
  var max_amount = 1 * ($("input[name='bill_max_limit']").val());
  var ask_amount = 1 * (($("#item_total_sum").text()).replace(/,/g, ""));
  if($.trim($("input[name='bill_ymd']").val()).length==8 && ask_amount>max_amount) { // WHEN THE INVOICE IS ATTACHED AND THE TRANSACTION AMOUNT EXCEEDS THE INVOICE'S PAYABLE AMOUN
    showErrorMsg("첨부한 세금계산서로 결제할 수 있는 금액("+addComma(max_amount)+"원)을 초과하였습니다.");
    return false;
  }
  $("input[name='contract_amt']").val(ask_amount); // 매매계약금액 확정

  // 품목정보등록여부
  let tr_length = $("#bill-item-list tr").length - (($('#bill-item-list tr td').hasClass('noentry'))?1:0);
  if (tr_length<1) {
    showErrorMsg("하나 이상의 품목정보가 필요합니다.");
    return false;
  }
  // 품목정보공란점검 & 비경상적거래품목점검
  $("#bill-item-list tr td input[name='item_nm']").each(function(idx, item) {
    $(item).css("border", "1px solid #ddd").focus();
    for (var i=0; i<wordtoblock.length; i++) {
      var word = $(item).val();
      word = $.trim(word);
      if (word.length == 0) {
        is = false;
        $(item).css("border", "1px solid #f00").focus();
        showErrorMsg("품목명을 입력하십시오.");
        return is;
      }
      /* 이상거래로 이동(2025.04.08)
      if (word.indexOf(wordtoblock[i])>-1) {
        is = false;
        $(item).css("border", "1px solid #f00").focus();
        showErrorMsg("<strong class='emp'>" + wordtoblock[i] + "</strong><br/><br/>단어가 포함된 품목의 거래는 진행할 수 없습니다.<br/>품목을 확인하십시오.");
        return is;
      }
      */
    }
  });
  if (!is) return false;
  
  // 결제금액확인
  if (isNaN($("input[name='contract_amt']").val()) || $("input[name='contract_amt']").val()<1) {
    showErrorMsg("결제금액을 확인하십시오.");
    return false;
  }
  
  // 구매자금 세금계산서 31일 초과 여부
  var today   = new Date().toISOString().split('T')[0].replace(/-/g, '');
  var bank    = ($("select[name='bnk_pay_id'] option:selected").val()).split("____")[0];
  var payment = ($("select[name='bnk_pay_id'] option:selected").val()).slice(-1);
  var wdate   = $("input[name='bill_ymd']").val().replace(/\D/g, '');
  if (payment==PurchasePayCode && !isNonWarranty() && !isKiboPersonal()) { // 구매자금이고 세금계산서 첨부대상이면
    $.ajaxSetup({async:false});
    $.post(strContextPath + '/common/Check31Day.jsp', {'date':wdate,'bank':bank}, function(data) {
      var json = JSON.parse($.trim(data));
      if (today > json.d) {
        is = false;
        showErrorMsg("첨부한 세금계산서의 작성일은 <strong>"+formatYmdKorean(wdate)+"</strong>이며, "+json.nm+"은 <strong>"+formatYmdKorean(json.d)+"</strong>까지만 사용가능합니다.");
        return false;
      }
    });
  }
  if (!is) return false;
  
  if (isNonWarranty() || isKiboPersonal()) $("input[name='non_warranty']").val("Y"); // 세금계산서미첨부허용대상
  
  // 수수료부담처 확인 등 마지막 동의
  
  return is;
}

////////////////////////// SUBMIT //////////////////////////
function goSubmit() {
  if (check()) {
    $("select[name='seller_cpy_id'], input[name='mp_pay_cpy'], input[name='tax_biz_type']").prop("disabled", false); // 변경은 막았지만, 폼으로 넘어가지 않는 요소를 활성화
    $.ajax({
      url: strContextPath + "/web/trade/ContractRegProc.jsp", 
      type: 'post',
      data:$("form[name='frmEnt']").serialize(), 
      async: true,
      success: function(data) {
        console.log("Received ContractRegProc : " + data);
        if (isNaN(data)) {
          var json = JSON.parse(data);
          if (json.step=="send") { // 전송
            var token = json.msg;
            if (token.indexOf("____")>-1) {
              document.frmEnt.seq.value   = token.split("____")[0];
              document.frmEnt.ctid.value  = token.split("____")[1];
              document.frmEnt.token.value = token.split("____")[2];
              send();
            }
          }
          else { // 전송하지 않음
            showAlert(json.msg, function(){
              if (json.step=="abnormal" || json.step=="nocommission") location.href = strContextPath + "/web/trade/ContractsTemp.jsp";
            }); // 이상거래 또는 수수료정보 미확인은 임시저장 페이지로 이동
            $("div.result-message").addClass("error-message"); // 오류출력
            $("select[name='seller_cpy_id'], input[name='mp_pay_cpy'], input[name='tax_biz_type']").prop("disabled", true); // 변경을 막음
          }
        } else { // 매매계약번호만 넘어옴. 상세페이지로 이동시킴
          $("input[name='seq']").val(data);
          document.frmEnt.action = strContextPath + "/web/trade/Contract.jsp";
          document.frmEnt.target = "_top";
          document.frmEnt.method = "post";
          document.frmEnt.submit();
        }
      },
      error: function(request, status, error) {
        showAlert("통신에 문제가 있습니다. 잠시 후 다시 시도하십시오.");
        console.log(request.status + " : " + request.responseText + " : " + error);
      }, 
      beforeSend: function() {
        console.log("beforeSend");
        if ($("input[name='temp_save']").val()==0) showSpinner("매매계약서를 발송하고 있습니다.<br/>거래검증을 위한 보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
        else showSpinner("임시저장하고 있습니다.");
      },
      complete: function () {
        if (window.sendInProgress) {
          console.log("goSubmit()의 complete: send() 실행 중이므로 hideSpinner() 실행 안 함");
          return;
        }
        hideSpinner();
      }
    });
  }
}
/* 매매계약서 전송 */
function send() {
  window.sendInProgress = true;
  $.ajax({
    url:strContextPath + "/web/transaction/B311.jsp", 
    type: 'post',
    data:$("form[name='frmEnt']").serialize(), 
    success: function(data) {
      console.log(data);
      var json = JSON.parse(data);
      if (json.is) {
        showAlert("전송되었습니다.", function() {
          document.frmEnt.action = "index.jsp";
          document.frmEnt.method = "post";
          document.frmEnt.submit();
        });
      } else showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg, function() {
        location.href = strContextPath + "/web/trade/";
      });
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
      window.sendInProgress = false;
    }
  });
}

/* save and submit */
function save(callback) {
  if (check()) callback();
  return;
}
/* move temporary documents. */
function goTemporaryList() {
  $("input[name='temp_save']").val(1);
  goSubmit();
  return;
}

function remove() {
  showCustomConfirm("정말 삭제하시겠습니까?<br/>삭제된 매매계약서는 복원되지 않습니다.", function() {
  $.post(strContextPath + "/web/trade/ContractDropProc.jsp",$("form[name='frmEnt']").serialize(),function(data){
  if (data==0) {
    showAlert("삭제할 수 없습니다.<br/>삭제는 발송전까지 가능합니다.<br/>진행상태가 변경되었을 수 있으니 다시 확인하십시오.", function(){
      window.location.reload();
    });
  } else location.href = strContextPath + "/web/trade/";
  });
  }, function(){});
}

$(document).ready(function() {
  $("input[name='tax_biz_type'], input[name='scrap_yn']").on("click", function() {
    changeTaxRate();
  });
  itemWriteMode();
  $('#bill-item-list').on('input change', "input[name='item_sum']", function(e){
    changeTaxRate();
    calcSum();
  });
});
$(document).on('visibilitychange', function() { // reset uuid when the screen opens again
  if (document.visibilityState === 'visible') {
    $.post(strContextPath + "/common/UUID.jsp", {}, function(data){
      $("input[name='csrf_token']").val(data);
    });
  }
});