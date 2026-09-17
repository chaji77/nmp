<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
String strMenuIdx = StrUtil.nvl(request.getParameter("menuidx"), "1");
int intCpyId = 0;
if (strCpyId!=null && StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CustomerBean bean = new CustomerBean();
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
%>
<script>
function goCompanyMenu(idx) {
  var url = "";
  switch (idx) {
  case 1 :
    url = "<%=request.getContextPath()%>/mgr/customer/Company.jsp";
    break;
  case 2 : 
    url = "<%=request.getContextPath()%>/mgr/customer/Guarantee.jsp";
    break;
  case 3 : 
    url = "<%=request.getContextPath()%>/mgr/mpfee/MpFeePerCustomer.jsp";
    break;
  case 4 : 
    url = "<%=request.getContextPath()%>/mgr/trade/ContractsPerCustomer.jsp";
    break;
  case 5 : 
    url = "<%=request.getContextPath()%>/mgr/memo/MemosPerCustomer.jsp";
    break;
  case 6 :
    url = "<%=request.getContextPath()%>/mgr/customer/RelationCompanies.jsp";
    break;
  case 7 :
    url = "<%=request.getContextPath()%>/mgr/customer/PartnersPerCustomer.jsp";
    break;
  case 8 :
    url = "<%=request.getContextPath()%>/mgr/trade/InvoicesPerCustomer.jsp";
    break;
  }
  document.frmCompanyHead.action = url;
  document.frmCompanyHead.submit();
}
</script>
<form name='frmCompanyHead' method='post'>
<input type='hidden' name='cpy_id' value='<%=IntegerCryptoUtil.crypt(strCpyId)%>'>
<input type='hidden' name='cpy_nm' value='<%=StrUtil.input(cvo.CPY_NAME)%> (<%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %>, <%=StrUtil.input(cvo.CPY_CEO_NAME)%>)'>
</form>

<ul class='detail'>
  <li class='th'>회사명</li>
  <li class='td'><span style='font-weight:bold;'><%=cvo.CPY_NAME%></span><span style='margin-left:30px;color:gray;'><i class="fa-solid fa-hashtag"></i> <%=intCpyId %></span></li>
  <li class='th'>사업자번호</li>
  <li class='td'><%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %></li>
  <li class='th'>대표자</li>
  <li class='td'><%=cvo.CPY_CEO_NAME%></li>
  <li class='th'>커뮤니케이션</li>
  <li class='td'>
    <a class='btn white' title='MEMO' onclick='getMemoWindow(<%=intCpyId%>);'><i class="fa-solid fa-pen"></i><span class='mobile_hide'> 메모</span></a>
    <a class='btn white' title='SMS'  onclick='getSMSWindow(<%=intCpyId%>);'><i class="fa-solid fa-comment-sms"></i><span class='mobile_hide'> 문자</span></a>
    <a class='btn white' title='MAIL' onclick='getMailWindow(<%=intCpyId%>);'><i class="fa-solid fa-paper-plane"></i><span class='mobile_hide'> 메일</span></a>
    <a class='btn white' title='Invoice' href='<%=request.getContextPath()%>/mgr/etax/Invoice.jsp?cpy_id=<%=intCpyId%>'><i class="fa-solid fa-receipt"></i></i><span class='mobile_hide'> 세금계산서 수기발행</span></a>
    <!-- a class='btn white' title='FAX'  onclick='getFaxWindow(<%=intCpyId%>);'><i class="fa-solid fa-fax"></i><span class='mobile_hide'> 팩스</span></a -->
</li>
</ul>
<p>&nbsp;</p>
<ul class='category'>
  <li></li>
  <li class='category<%=(strMenuIdx.equals("1"))?" selected":""%>' onclick='goCompanyMenu(1);'>회원정보</li>
  <li class='category<%=(strMenuIdx.equals("2"))?" selected":""%>' onclick='goCompanyMenu(2);'>보증서</li>
  <li class='category<%=(strMenuIdx.equals("3"))?" selected":""%>' onclick='goCompanyMenu(3);'>수수료</li>
  <li class='category<%=(strMenuIdx.equals("4"))?" selected":""%>' onclick='goCompanyMenu(4);'>거래</li>
  <li class='category<%=(strMenuIdx.equals("8"))?" selected":""%>' onclick='goCompanyMenu(8);'>거래세금계산서</li>
  <li class='category<%=(strMenuIdx.equals("5"))?" selected":""%>' onclick='goCompanyMenu(5);'>메모</li>
  <li class='category<%=(strMenuIdx.equals("6"))?" selected":""%>' onclick='goCompanyMenu(6);'>본·지사</li>
  <li class='category<%=(strMenuIdx.equals("7"))?" selected":""%>' onclick='goCompanyMenu(7);'>거래처</li>
  <li></li>
</ul>