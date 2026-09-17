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
pvo.ROW_CNT = 10;
pvo.CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("bizno")).replaceAll("-", "");
pvo.CPY_NAME = StrUtil.nvl(request.getParameter("nm"));
ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>
<ul>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
    CompanyVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
%>
<li onclick='choiceCompany(this);' cid='<%=v.CPY_ID %>'><%=v.CPY_NAME %> (<%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %>, <%=v.CPY_CEO_NAME %>)</li>
<%
  }
}
%>
</ul>
<%
if (intTotalCnt > (pvo.PAGE*pvo.ROW_CNT)) {
  out.print("<div style='text-align:center;margin-top:20px;'><a onclick='goCompanySearchPageForPopup("+(pvo.PAGE+1)+")' class='btn'>더보기</a></div>");
}
%>
