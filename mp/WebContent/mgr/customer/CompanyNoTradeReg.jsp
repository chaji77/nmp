<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeBean" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeVO" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
request.setCharacterEncoding("utf-8");
String seqNo = request.getParameter("seqNo");
String cpyName = StrUtil.nvl(request.getParameter("cnm"));
String cpyBizNo = StrUtil.nvl(request.getParameter("bizno"));
String strActionName = "등록";

CompanyNoTradeVO nvo = new CompanyNoTradeVO();
if (seqNo!=null) {
	strActionName = "수정";
	ArrayList<CompanyNoTradeVO> arr = new CompanyNoTradeBean().M_COMPANY_NO_TRADE_LIST_PROC(Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0")), Integer.parseInt(seqNo));
	nvo = new CompanyNoTradeVO();
	nvo = arr.remove(0);
}
%>

<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<style>
li.bizNo input {width:200px !important;} 
li.bizNo a.disabled {pointer-events:none;}
li.etc label {vertical-align:top;}
</style>
<script type="text/javascript">
function check() {
	document.frmNoTrade.bizno.value = document.frmNoTrade.bizno.value.replace(/[^0-9]/g, "");
	var is = isValidBusinessNumber(document.frmNoTrade.bizno.value);
	if (!is) {
	  toast("올바른 사업자번호가 아닙니다.", 1000, function() {
	    $("input[name='sellerName']").val('');
	  });
	}
	return is;
}
function goCheck() {
 	if (check()) {
 		var sellerBizNo = document.frmNoTrade.bizno.value;
 		$.post("BizNoCheck.jsp", {cpyId: <%=request.getParameter("cid")%>, bizno: sellerBizNo}, function(data) {
 			var sellerName = $.trim(data);
 			if (sellerName=='이미 등록된 업체입니다.') {
 				toast(sellerName, 1000, function() {
 					$("input[name='sellerName']").val('');
 				})
 			} else if (sellerName!="") $("input[name='sellerName']").val(data);
 			else toast("해당 사업자번호의 회원이 존재하지 않습니다.", 1000, function() {
 				$("input[name='sellerName']").val('');
 			})
 		});
 	}
}
function fill() {
	$("input[name='buyerBizNo']").val("<%=nvo.BUYER_BIZ_NO%>");
	$("input[name='seqNo']").val("<%=nvo.SEQNO%>");
	$("input[name='buyerName']").val("<%=nvo.BUYER_NAME%>");
	$("input[name='bizno']").val("<%=nvo.SELLER_BIZ_NO%>");
	$("input[name='sellerName']").val("<%=nvo.SELLER_NAME%>");
	$("textarea[name='etc']").val("<%=nvo.ETC%>");
	$("select[name='yn']").val("<%=nvo.DEL_YN%>");
}
$(document).ready(function(){	
<% if (seqNo!=null && nvo!=null) out.print("fill();");%>
});
</script>

<h3>거래불가업체 등록</h3>
<form name='frmNoTrade'>
<input type='hidden' name='buyerBizNo' value='<%=cpyBizNo%>'>
<input type='hidden' name='seqNo'>
<ul class='form'> 
  <li>
    <label>구매사명</label>
    <input name='buyerName' value='<%=cpyName %>' readonly></input>
  </li>
  <li class='bizNo'>
    <label>사업자번호</label>
    <input style='width:140px !important;' type='text' name='bizno' id='bizno' maxlength='12' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='사업자번호 숫자 10자리' <%=StrUtil.nvl(nvo.SELLER_BIZ_NO).equals("")?"":"readonly" %>/>
    <a onClick='goCheck();' class='btn <%=StrUtil.nvl(nvo.SELLER_BIZ_NO).equals("")?"":"disabled" %>'>선택</a>
  </li>
  <li>
    <label>판매기업명</label>
    <input name='sellerName' readonly></input>
  </li>
  <li class='etc'>
    <label>비고</label>
	<textarea name='etc'></textarea>
  </li>
  <li>
    <label>사용여부</label>
    <select name='yn'>
      <option value="N">적용</option>
      <option value="Y">미적용</option>
    </select>
  </li>
  
  <li style='margin-top:15px;'>
    <label></label>
    <a onclick='registNoTrade();' class='btn lurian'><%=strActionName %></a>
  </li>
</ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
