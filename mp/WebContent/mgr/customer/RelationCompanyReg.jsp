<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String seqNo = StrUtil.nvl(request.getParameter("seqNo"));
seqNo = seqNo!="" ? seqNo : null;
String cpyName = StrUtil.nvl(request.getParameter("cnm"));
String cpyBizNo = StrUtil.nvl(request.getParameter("bizno"));
String strActionName = "등록";
boolean readonly = false;

RelationCompanyVO pvo = new RelationCompanyVO();
if (seqNo!=null) {
	strActionName = "수정";
	pvo = new MgrCustomerBean().M_RELATION_COMPANY_DETAIL_PROC(Integer.parseInt(seqNo));
	cpyName = pvo.CPY_NAME;
	cpyBizNo = pvo.CPY_BIZ_NO;
	readonly = true;
}
%>

<style>
li.etc label {vertical-align:top;}
</style>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script>
$(document).ready(function(){	
	var useYN = '<%=StrUtil.nvl(pvo.USE_YN, "Y") %>';
	$("input[name='useYN'][value='" + useYN +"']").prop('checked', true);
	var loanType = '<%=StrUtil.nvl(pvo.LOANTYPE) %>';
	$("select[name='loanType']").val(loanType);
});
</script>

<h3>
  본·지사 사업자 <%=strActionName %>
</h3>

<form name='frmRelationCompanies'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<input type='hidden' name='seqNo' value='<%=StrUtil.nvl(seqNo) %>'>
<ul class='form'>
  <li>
    <label>회사명</label>
    <input value='<%=cpyName %> (<%=FormatUtil.addDashBizNo(cpyBizNo) %>)' readonly/>
  </li>
  <li>
    <label>사업자번호</label>
    <input type='text' name='bizno' id='bizno' maxlength='12' pattern="[0-9]+" onkeypress='return checkNumber(event)' placeholder='사업자번호 숫자 10자리' 
    	   value='<%=StrUtil.nvl(pvo.RELATIONBIZNO) %>' <%=readonly ? "readonly":"" %> />
  </li>
  <li></li>
  <li>
    <label>기금선택</label>
    <select name='loanType'>
      <option></option>
      <option value="KODIT">신용보증기금</option>
      <option value="KIBO">기술보증기금</option>
      <option value="KOREG">신용보증재단</option>
      <option value="NOGUAR">비보증</option>	
    </select>
  </li>
  <li class='not-has-input'>
    <label>사용유무</label>
    <input type='radio' name='useYN' value='Y'><span style='margin-right:50px'>사용함</span>
    <input type='radio' name='useYN' value='N'>사용안함
  </li>
  <li class='etc'>
    <label>처리내용</label>
    <textarea name='result'><%=StrUtil.nvl(pvo.PRO_RESULT)%></textarea>
  </li>
  
  <li style='margin-top:15px;'>
    <label></label>
    <a onclick='registRelationCompany();' class='btn lurian'><%=strActionName %></a>
  </li>
</ul>
</form>
  
<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>