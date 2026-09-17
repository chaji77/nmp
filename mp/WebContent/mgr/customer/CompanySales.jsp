<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.c.CompanySalesVO" %>
<%
request.setCharacterEncoding("utf-8");
CompanySalesVO pvo = new CompanySalesVO();
pvo.CPY_ID = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
ArrayList<CompanySalesVO> arr = new CustomerBean().COMPANY_SALES_LIST_PROC(pvo);
%>
  <h3>
    연매출액
    <span class='more'><a onclick='showSalesForm();' class='btn'>등록</a></span>
  </h3>
  <table class='detail'>
    <thead>
      <tr>
        <th>년도</th>
        <th class='right'>매출액 (백만원)</th>
      </tr>
    </thead>
    <tbody>
    <%
    if (arr!=null && arr.size()>0) {
      for (int i=0; i<arr.size();) {
        CompanySalesVO vo = arr.remove(i);
    %>
      <tr>
        <td class='center'><%=vo.YYYY %></td>
        <td class='right'><%=StrUtil.addComma(vo.SALES_AMT) %></td>
    <%
      }
    }
    %>
    </tbody>
  </table>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
