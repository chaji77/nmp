<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
String strFromPage = StrUtil.nvl(request.getParameter("from"));
%>
<script>
function searchCompany(page) {
  var myBizNo = $("input[name='bizno']").val();
  var tBizNo  = $.trim($("input[name='mycompany_bizno']").val()).replace(/-/g, '');
  var tBizNm  = $.trim($("input[name='mycompany_nm']").val());
  if (myBizNo==tBizNo) {
    toast("자신의 사업자를 추가할 수 없습니다.");
    return;
  }
  if (tBizNo!="" && !isValidBusinessNumber(tBizNo)) {
    toast("올바른 사업자번호가 아닙니다.");
    return;
  }
  if (tBizNo=="" && tBizNm=="") {
    toast("검색어를 입력하세요.");
    return;
  }
  
  showLoading();
  $.post("CompaniesSearched.jsp", {'mycompany_nm':tBizNm,'mycompany_bizno':tBizNo,'page':page}, function(data){
    $("#my-companies-list").html(data);
    hideLoading();
  });
}
function addCompany(cid) {
  showLoading();
  $.post("MyCompanyRegProc.jsp", {'cid':cid}, function(data){
    closePopup();
    hideLoading();
	<% if (strFromPage.equals("")) { %>
    $("select[name='seller_cpy_id'], select[name='buyer_cpy_id']").html(data);
    $("select.select2").select2();
    <% } else { %>
    toast("추가되었습니다.", 1000, function() {
      window.location.reload();
    });
    <% } %>
  });
}
function showNewSellerReg() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/web/customer/regreq/RegReqReg.jsp'});
}
$(document).ready(function(){
  $("input[name='mycompany_bizno'],input[name='mycompany_nm']").keydown(function(key) {
    if (key.keyCode == 13) searchCompany(1);
  });
});
</script>
<style>
.my-companies-list-element {padding:0;min-width:100%;width:auto !important;margin-left:auto;margin-right:auto;}
</style>
<div style='background-color:white;padding:20px;width:800px;'>
  <p style='text-align:center;font-size:1.2em;'><strong>거래처 추가</strong></p>
  <p>&nbsp;</p>
  <p style='padding:10px 0 5px 0;text-align:center;'>
    <span class='mobile_hide'>추가할 거래처의 사업자번호 &nbsp;</span>
    <input type='text' name='mycompany_bizno' value='' style='width:90px;' placeholder='사업자번호' autocomplete="off">
    <span>&nbsp;또는</span><span class='mobile_hide'>&nbsp;상호&nbsp;</span>
    <input type='text' name='mycompany_nm' value='' style='width:90px;' placeholder='상호' autocomplete="off">
    <a onclick='searchCompany(1);' class='btn' style='padding-top:7px;padding-bottom:7px;'>검색</a>
    <a onclick='showNewSellerReg();' class='btn' style='padding-top:7px;padding-bottom:7px;margin-left:5px;'>등록요청</a>
  </p>
  <p>&nbsp;</p>
  <div id='my-companies-list' style='text-align:center;'></div>
  
  <div style='text-align:center;margin-top:20px;'>※ 거래하고자 하는 기업이 가입되어있지 않은 경우, <b>등록요청</b> 버튼을 눌러주세요.</div>
  <div style='text-align:center;margin-top:20px;margin-bottom:10px;'><i class="fa-solid fa-xmark" onclick='closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
</div>