<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
CompanyVO pvo = new CompanyVO();
pvo.PAGE    = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT = 10;
pvo.CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("mycompany_bizno"), "");
pvo.CPY_NAME        = StrUtil.nvl(request.getParameter("mycompany_nm"), "");
pvo.CST_ID          = "2"; // 승인된 회원사만 검색 가능
ArrayList<CompanyVO> arr = new CustomerBean().COMPANY_SEARCH_PROC(pvo);
int intToalCnt = 0;
%>
  <style>
  .paging {text-align:center !important;}
  </style>
  <script>
  $(document).ready(function(){
    if ($(window).width()<500) {
      $(".my-companies-list-element").css({"min-width":"340px","width":"340px"});
      console.log($(".my-companies-list-element").width());
    }
  });
  </script>
  <table class='my-companies-list-element detail'>
    <thead>
      <tr>
        <th class='left'>회사명</th>
        <th class='left mobile_hide'>사업자번호</th>
        <th class='left mobile_hide'>대표자명</th>
        <th class='left'>명령</th>
    </thead>
    <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CompanyVO v:arr) {
    intToalCnt = v.TOTAL_CNT;
%>
      <tr>
        <td class='left'><%=StrUtil.cutString(v.CPY_NAME, 20, "..") %><div class='mobile_show'><br/><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %><br/><%=StrUtil.cutString(v.CPY_CEO_NAME, 10, "..") %></div></td>
        <td class='left mobile_hide'><%=FormatUtil.addDashBizNo(v.CPY_BUSINESS_NO) %></td>
        <td class='left mobile_hide'><%=StrUtil.cutString(v.CPY_CEO_NAME, 10, "..") %></td>
        <td><a onclick='addCompany(<%=v.CPY_ID %>);' class='btn'>추가</a></td>
      </tr>
<%
  }
} else {
  out.println("<tr><td colspan='4' class='noentry'>검색 결과가 없거나 미승인 회원사입니다.</td></tr>");
}
%>
    </tbody>
  </table>
  
  <div id="mycompany-paging" class="my-companies-list-element">
  <script>
  setPaging('#mycompany-paging', 'searchCompany','<%=pvo.PAGE%>', '<%=intToalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
  </div>