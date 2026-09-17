<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String type = StrUtil.nvl(request.getParameter("type"));

CompanyVO pvo  = new CompanyVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1"));
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 10;
pvo.CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("bizno")).replaceAll("-", "");
pvo.CPY_NAME = StrUtil.nvl(request.getParameter("nm"));
ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
%>
<style>
table tr.result {border-bottom:1px solid #ddd;padding:5px 0;cursor:pointer;}
table tr.result:hover {background-color:#fafafa;}
</style>
<script type="text/javascript">
</script>

<p style='text-align:center;margin-bottom:20px;'><i class="fa-solid fa-asterisk"></i> 직발주를 받을 <%=type.equals("seller")?"판매기업":"구매기업" %>을 선택합니다.  </p>

<table style='margin-top:20px;'>
 <thead>
  <tr>
   <td>회원사명</td><td>사업자번호</td><td>대표자</td>
  </tr>
 </thead>
 <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
	CompanyVO v = arr.remove(i);
%>
  <tr class='result' onclick='choiceCompany(this, "<%=type %>")' cid='<%=v.CPY_ID%>'>
   <td><%=v.CPY_NAME %></td><td><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %></td><td><%=v.CPY_CEO_NAME %></td>
  </tr>
<%
  }
} else {
%>
  <tr><td colspan='3' style='text-align:center;'>검색된 결과가 없습니다.</td></tr>
<%	
}
%>
 </tbody>
</table>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
