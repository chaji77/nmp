<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CompanyVO vo = new CustomerBean().COMPANY_SALEAMT_CHECK_PROC(intCpyId);
if (vo==null) {
  out.print("<script>afterLogon();</script>");
} else {
%>
<div style='background-color:white;padding:20px;border-radius:20px;'>
<h3>판매기업 매출액 및 사업자정보확인 등록</h3>

<p>B2B대출 결제 시 이상거래모니터링 진행을 위한 판매기업 매출액 및 기존 사업자등록증 정보에 대한 확인 절차 입니다.</p>
<p>아래 항목 중 변경사항이 있으면 수정하십시오.</p>
<p>&nbsp;</p>
<p style='color:red;'>※ 매출액을 허위기재하실 경우 부진정 거래로 간주되어 향후 손해배상, 민·형사상 책임이 있을수 있습니다.</p>
<p>&nbsp;</p>
<table class='detail'>
  <tr>
    <th>매출년도</th>
    <td><%=vo.YYYY %></td>
    <th>매출액</th>
    <td><%=StrUtil.addComma(vo.SALES_AMT) %> (백만원)</td>
  </tr>
  <tr>
    <th>대표자명</th>
    <td><%=vo.CPY_CEO_NAME %></td>
    <th>사업자명</th>
    <td><%=vo.CPY_NAME %></td>
  </tr>
  <tr>
    <th>주소</th>
    <td colspan='3'><%=vo.CPY_ADDR %> <%=vo.CPY_ADDR2 %></td>
  </tr>
</table>
<p>&nbsp;</p>
<div style='width:100%;text-align:center;margin-bottom:40px;'>
  <a href='javascript:confirmNotChange();' class='btn'>변경사항 없음</a>
  <a href='<%=request.getContextPath()%>/web/customer/Modify.jsp' class='btn'>수정페이지로 이동</a>
  <a href='javascript:afterLogon();' class='btn'>다음에</a>
</div>
</div>
<%
}
%>