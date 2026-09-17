<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
CompanyVO pvo  = new CompanyVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1"));
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;
pvo.ROW_CNT = 5;
pvo.CPY_BUSINESS_NO = "";
pvo.CPY_NAME = StrUtil.nvl(request.getParameter("nm"));
ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>

<table>
  <thead>
    <tr>
      <td>업체명</td><td>사업자번호</td><td>대표자명</td>
    </tr>
  </thead>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
    CompanyVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
%>
    <tr cid='<%=v.CPY_ID%>' onclick='choiceCompany(this)'>
      <td><%=v.CPY_NAME %></td><td><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO)%></td><td><%=v.CPY_CEO_NAME %></td>
    </tr>
<%
  }
}
%>
</table>
<%
if (intTotalCnt > (pvo.PAGE*pvo.ROW_CNT)) {
  out.print("<div style='text-align:center;margin-top:20px;'><a onclick='goCompanySearchPageForPopup("+(pvo.PAGE+1)+")' class='btn'>더보기</a></div>");
}
%>