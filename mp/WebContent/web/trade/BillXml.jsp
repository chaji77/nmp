<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<script>
function attachXmlFile() {
  document.frmXmlUpload.action = "BillXMLAddProc.jsp";
  document.frmXmlUpload.method = "post";
  document.frmXmlUpload.target = "work";
  document.frmXmlUpload.submit();
}
function savedXmlFile(intTotal, intDuplicatedCnt, strErrorMsg) {
  if ($.trim(strErrorMsg).length==0) {
    if (intTotal == intDuplicatedCnt) showAlert("이미 첨부한 전자세금계산서입니다.");
    else {
      if (intDuplicatedCnt==0) showAlert(intTotal + "건의 전자세금계산서를 첨부하였습니다.");
      else showAlert("이미 첨부한 " + intDuplicatedCnt +"건의 전자세금계산서를 제외한 " + (intTotal - intDuplicatedCnt)  + "건의 전자세금계산서를 첨부하였습니다.");
    }
  } else {
    showAlert(strErrorMsg);
  }
  closePopup();
  reloadBills();
}
$(document).ready(function(){
  $("input[name='xmlfile']").click();
});
</script>
<div style='background-color:white;padding:40px 20px 20px 20px;min-width:370px;'>
  <p style='text-align:center;font-size:1.3em;'><strong>세금계산서 XML 첨부하기</strong></p>
  <p>&nbsp;</p>
  <div style='text-align:center;width:100%;'>
    <form name='frmXmlUpload' method='post' enctype='multipart/form-data'>
    <input type='file' name='xmlfile' accept="application/xml" style="padding-top:7px;">
    </form>
    <p>&nbsp;</p>
    <a onclick="attachXmlFile();" class='btn'>첨부</a>
  </div>
  <div style='text-align:center;margin-top:50px;margin-bottom:10px;'><i class="fa-solid fa-xmark" onclick='closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
</div>

