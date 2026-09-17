<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationVO" %>
<%@ page import="kr.co.mp.mgr.customer.DirectRelationBean" %>
<%
request.setCharacterEncoding("utf-8");
String strSellCpyId = request.getParameter("sid");
String strBuyCpyId  = request.getParameter("bid");
strSellCpyId = (IntegerCryptoUtil.isEncrypted(strSellCpyId)) ? strSellCpyId : null;
strBuyCpyId  = (IntegerCryptoUtil.isEncrypted(strBuyCpyId)) ? strBuyCpyId : null;
int intSellCpyId = 0;
int intBuyCpyId  = 0;
if (strSellCpyId!=null) intSellCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("sid")));
else return;
if (strBuyCpyId!=null) intBuyCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("bid")));
else return;

DirectRelationVO pvo = new DirectRelationVO();
pvo.SELL_COMPANY = intSellCpyId;
pvo.BUY_COMPANY = intBuyCpyId;
DirectRelationVO vo = new DirectRelationBean().M_DIRECT_RELATION_DETAIL_PROC(pvo);
%>
<script type="text/javascript">
function modify() {
	$.post("<%=request.getContextPath()%>/mgr/direct/DirectRelationRegProc.jsp", $("form[name='frmDirect']").serialize(), function(data) {
		if (data==0) window.location.reload();
		else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
	})
}
$(document).ready(function() {
	var expired = '<%=vo.EXPIRE_DAY%>'
	$("select[name='expireDay']").val('<%=vo.EXPIRE_DAY%>');
	var useYN = '<%=StrUtil.nvl(vo.USE_YN, "Y") %>';
	$("input[name='useYN'][value='" + useYN +"']").prop('checked', true);
	var agreeYN = '<%=StrUtil.nvl(vo.AGREE_YN, "N") %>';
	$("input[name='agreeYN'][value='" + agreeYN +"']").prop('checked', true);
});
</script>

<h3>직발주 정보 수정</h3>
<form name='frmDirect'>
<input type='hidden' name='sellerCid' value='<%=intSellCpyId%>'>
<input type='hidden' name='buyerCid' value='<%=intBuyCpyId%>'>
<ul class='form'>
  <li>
    <label>판매기업명</label>
    <input name='seller' value='<%=vo.SELL_COMPANY_NAME %>' readonly>
  </li>
  <li>
    <label>구매기업명</label>
    <input name='buyer' value='<%=vo.BUY_COMPANY_NAME %>' readonly>
  </li>

  <li class='not-has-input'>
    <label>사용유무</label>
    <input type='radio' name='useYN' value='Y'>사용함
    <input type='radio' name='useYN' value='N'>사용안함
  </li>

  
  <li style='margin-top:15px;'>
    <label></label>
    <a onclick='modify();' class='btn lurian'>수정</a>
  </li>
</ul>
</form>


<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>