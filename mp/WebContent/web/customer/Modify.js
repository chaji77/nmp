var oFiles;
var urlUpload   = strContextPath + "/web/customer/UploadFileProc.jsp";
var urlDragDrop = strContextPath + "/web/customer/DragUploadFileProc.jsp";
var strSubmitTarget = "ModifyProc.jsp";
var btnSubmitIsClicked = false;

function check() {
  if (!validate("input[name='cpy_nm']", "length", [2,30], "회사명을 입력하십시오.")) return false;
  if (!validate("input[name='cpy_ceo_nm']", "length", [2,30], "대표자명을 입력하십시오.")) return false;
  if ($("input[name='biz_type']:checked").val()==1) { // 법인사업자번호
    $("input[name='cpy_no']").val($("input[name='cpy_no']").val().replace(/-/g, ''));
    if (!validate("input[name='cpy_no']", "length", [13], "법인등록번호를 입력하십시오.")) return false;
  }
  if (!validate("input[name='uptae']", "length", [2,100], "업태를 입력하십시오.")) return false;
  if (!validate("input[name='upzong']", "length", [2,100], "종목을 입력하십시오.")) return false;
  if (!validate("input[name='basic_zipcode']", "length", [5], "주소를 입력하십시오.")) return false;
  if (!validate("input[name='basic_addr_b']", "length", [2, 100], "주소를 입력하십시오.")) return false;
  if (!validate("input[name='desc']", "length", [2,100], "간단한 기업설명을 입력하십시오.")) return false;
  if (!validate("input[name='found_ymd']", "length", [10], "설립일을 입력하십시오.")) return false;
  
  $("input[name='sale_amt']").val($("input[name='sale_amt']").val().replace(/[^0-9]/g, ""));
  
  if (!validate("input[name='login_nm']", "length", [2,10], "담당자명을 입력하십시오.")) return false;
  if (!validate("input[name='login_cell_tel']", "length", [9,14], "휴대전화번호를 입력하십시오.")) return false;
  if ($.trim($("input[name='login_email']").val()).length > 0) {
    if (!isValidEmail(document.frmEnt.login_email.value)) {
      toast("올바른 메일주소를 입력하십시오.");
      document.frmEnt.login_email.focus();
      return false;
    }
  }
  if (!isValidEmail(document.frmEnt.tax_email.value)) {
    toast("올바른 메일주소를 입력하십시오.");
    document.frmEnt.tax_email.focus();
    return false;
  }
  return true;
}

function goSubmit() {
  var is = false;
  if (check()) {
    if (!btnSubmitIsClicked) {
      btnSubmitIsClicked = true;
      $("input[id='file']").each(function(){ // for upload
        this.checked = true;
      });
      showLoading();
      document.frmEnt.method = "post";
      document.frmEnt.action = strSubmitTarget;
      document.frmEnt.target = "work";
      document.frmEnt.submit();
    } else {
      toast("등록중입니다. 잠시만 기다려 주세요.");
    }
  }
}
function callback() {
  location.href = "MyPage.jsp";
}
var strTemporaryCpyNo = "";
function cpy_no_open(o) { //법인사업자가 아니면 법인번호입력을 제한
  $("input[name='cpy_no']").prop("readonly", o);
  if (o) {
    strTemporaryCpyNo = $("input[name='cpy_no']").val();
    $("input[name='cpy_no']").val("");
  }
  else $("input[name='cpy_no']").val(strTemporaryCpyNo);
}
function toggleHint() { // 전년도매출액의 기입방법
  var is = $(".hint").is(":visible");
  if (!is) $(".hint").slideDown();
  else $(".hint").slideUp();
}
function searchAddr(tgt) { // 우편번호검색
  new daum.Postcode({
    oncomplete: function(data) {
      var fullRoadAddr = data.roadAddress;
      var extraRoadAddr = '';
      if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)) extraRoadAddr += data.bname;
      if(data.buildingName !== '' && data.apartment === 'Y') extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
      if(extraRoadAddr !== '') extraRoadAddr = ' (' + extraRoadAddr + ')';
      if(fullRoadAddr !== '') fullRoadAddr += extraRoadAddr;

      $("input[name='"+tgt+"_zipcode']").val(data.zonecode);
      $("input[name='"+tgt+"_addr']").val(fullRoadAddr);
      $("input[name='"+tgt+"_addr_b']").focus();
    }
  }).open();
}
function uploadBizDoc() { // 사업자등록증업로드버튼 클릭 이벤트
  if ($("#ul_attached_files li").length>0) {
    showCustomConfirm("첨부된 파일이 있습니다. 삭제 후 첨부하시겠습니까?", function() {
      $("#ul_attached_files li").remove();
      $("input[name='file_bizdoc']").val("");
      $("input[name='file_bizdoc']").click();
    });
  } else {
    $("input[name='file_bizdoc']").val("");
    $("input[name='file_bizdoc']").click();
  }
}
function copyToInvoicer(obj) {
  if ($(obj).is(":checked")) {
    $("input[name='tax_nm']").val($("input[name='login_nm']").val());
    $("input[name='tax_email']").val($("input[name='login_email']").val());
    $("input[name='login_nm'], input[name='login_email']").prop("readonly", true);
  } else {
    $("input[name='login_nm'], input[name='login_email']").prop("readonly", false);
  }
}
$(document).ready(function(){
  initUploadForm(urlUpload, urlDragDrop, oFiles); // for upload	
  fillData();
  
  const today = new Date().toISOString().split('T')[0]; 
  $("input[name='found_ymd']").attr('max', today);
  $("input[name='found_ymd']").keydown(function(e) {
    const forbiddenKeys = ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight','0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    if (forbiddenKeys.includes(e.key)) {
      e.preventDefault();
    }
  });
  
});