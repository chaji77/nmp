<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>직발주 등록</title>

<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">

<script>
function searchForBizNo(type, obj) {
  closePopup();
  var bizno = $(obj).prev('input[name="bizno"]').val();
  if (!isValidBusinessNumber(bizno.replace(/-/g, ''))) {
	toast("올바른 사업자번호가 아닙니다.");
	return;
  }
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/direct/DirectRelationSearchForPopup.jsp?type=' + type + '&bizno=' + bizno});
}
function choiceCompany(obj, type) {
  if (type=='seller') {
	document.frmEnt.sellerCid.value = $(obj).attr("cid");
	document.frmEnt.seller.value = $(obj).children('td').eq(0).text();
	closePopup();
  } else if (type=='buyer') {
    document.frmEnt.buyerCid.value = $(obj).attr("cid");
	document.frmEnt.buyer.value = $(obj).children('td').eq(0).text();
	closePopup(); 
  }
}
function check() {
  var is = true;
  if ($("input[name='seller']").val() == '' || $("input[name='buyer']").val() == '') {
    showAlert("직발주 업체를 선택해주세요");
    is = false;
  }
  return is;
}
function goSubmit() {
  if (check()) {
    $.post("<%=request.getContextPath()%>/mgr/direct/DirectRelationRegProc.jsp", $("form[name='frmEnt']").serialize(), function(data){
	  if (data==0) {
	    location.href = "DirectRelations.jsp";
	  } else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
    });
  }
}
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>직발주 등록</span>
  <span class='more'>
    <a onclick='history.go(-1);' class='btn'>돌아가기</a>
  </span>
</div>

<form name='frmEnt'>
<input type='hidden' name='sellerCid'>
<input type='hidden' name='buyerCid'>
<h3 style='margin-top:0;'>&nbsp;</h3>
<ul class='form'>
  <li>
    <label>판매기업 사업자번호</label>
    <input type='text' name='bizno' style='width:calc(100% - 200px);'>
    <a onclick='searchForBizNo("seller", this)' class='btn'>검색</a>
  </li>
  <li>
    <label>판매기업명</label>
    <input type='text' name='seller' readonly> 
  </li>
  <li>
    <label>구매기업 사업자번호</label>
    <input type='text' name='bizno' style='width:calc(100% - 200px);'>
    <a onclick='searchForBizNo("buyer", this)' class='btn'>검색</a>
  </li>
  <li>
    <label>구매기업명</label>
    <input type='text' name='buyer' readonly>
  </li>

  
</ul>
</form>

<div class='btns'><a onclick='goSubmit();'>등록</a></div>
<%@ include file="../Footer.jsp" %>