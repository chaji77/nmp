<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String category = StrUtil.nvl(request.getParameter("category"));

CompanyVO pvo = new CompanyVO();
pvo.PAGE    = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT = 5;
pvo.CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("search"), "").replace("-", "").trim();
pvo.CPY_NAME        = StrUtil.nvl(request.getParameter("search"), "").trim();
if (category.equals("cpy_name")) {
  pvo.CPY_BUSINESS_NO = "";
} else pvo.CPY_NAME = "";

ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
int intToalCnt = 0;
%>
  <table class='detail'>
    <thead>
      <tr>
        <th class='left'>회사명</th>
        <th class='left'>사업자번호</th>
        <th class='left'>대표자명</th>
        <th class='left'>명령</th>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CompanyVO v:arr) {
    intToalCnt = v.TOTAL_CNT;
%>
      <tr>
        <td><%=StrUtil.cutString(v.CPY_NAME, 20, "..") %></td>
        <td><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %></td>
        <td><%=StrUtil.cutString(v.CPY_CEO_NAME, 10, "..") %></td>
        <td><a onclick='addCompany(<%=v.CPY_ID %>);' class='btn'>추가</a></td>
      </tr>
<%
  }
} else {
  out.println("<tr><td colspan='4' class='noentry'>검색결과가 없습니다.</td></tr>");
}
%>    
    </tbody>
  </table>
  
  <div id="mycompany-paging">
  <script>
  setPaging('#mycompany-paging', 'searchCompany','<%=pvo.PAGE%>', '<%=intToalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
  </div>