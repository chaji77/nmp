<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strActionName = "등록";

int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));

String strBuyCpyId = StrUtil.nvl(request.getParameter("buyCid"));
strBuyCpyId = (IntegerCryptoUtil.isEncrypted(strBuyCpyId)) ? strBuyCpyId : null;
int intBuyCpyId = 0;
if (strBuyCpyId!=null) intBuyCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("buyCid")));

//담당자정보
ArrayList<PersonVO> arrPersons = new CustomerBean().PERSON_LIST_PROC(intCpyId);

%>
<style></style>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type="text/javascript">
function searchBuyCompany() {
  var strUrl = strContextPath+'/mgr/customer/BuyCompanySearchPopup.jsp';
  var searchWindow = window.open(strUrl, "_businessPerson_", 'width=500,height=500,scrollbars=yes,resizable=no');
}
function checkBusinessPerson() {
  $.post("BusinessPersonRegProc.jsp", $("form[name='frmBusinessPerson']").serialize(), function(data) {
    if(data!=-1) location.reload(true);
    else toast("Error!");
  });
}
function fill() {
  $("input[name='buy_cid']").val(<%=intBuyCpyId%>);
  $("input[name='origin_buy_cid']").val(<%=intBuyCpyId%>);
  $("input[name='action']").val("edit");
}
$(document).ready(function(){ 
<% if (intBuyCpyId!=0) out.print("fill();");%>
});
</script>

<h3>구매사관리 담당자 <%=strActionName %></h3>
<form name='frmBusinessPerson'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<input type='hidden' name='buy_cid'>
<input type='hidden' name='action'>
<input type='hidden' name='origin_buy_cid'>
<ul class='form'>
  <li>
    <label>담당구매사</label>
    <input id='buy_company' name='buy_company' value='' style='width:140px !important;' readonly></input>
    <a onClick='javascript:searchBuyCompany();' class='btn'>검색</a>
  </li>
  <li>
    <label>담당자</label>
    <select id='prs_id' name='prs_id'>
      <%
      if (arrPersons!=null && arrPersons.size()>0) {
        for (PersonVO v : arrPersons) {
      %>
      <option value='<%=StrUtil.nvl(v.PRS_ID, "0") %>'><%=StrUtil.nvl(v.PRS_NAME) %> (<%=StrUtil.nvl(v.PRS_LOGIN) %>)</option>
      <%
        }
      }
      %>
    </select>
  </li>
  <li style='margin-top:15px;'>
    <label></label>
    <a onclick='checkBusinessPerson();' class='btn lurian'>등록</a>
  </li>
  
</ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>