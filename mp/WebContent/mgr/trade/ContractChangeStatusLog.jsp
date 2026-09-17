<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
ArrayList<String[]> arr = new TradeBean().CT_HEADER_STATUS_CHANGE_LIST_BY_CTID_PROC(intCtId);
%>
  <h3>상태변경로그</h3>
  
  <table class='detail'>
    <thead>
      <tr>
        <th class='left'>이전</th>
        <th class='left'>변경</th>
        <th class='left'>변경자</th>
        <th class='left'>변경일시</th>
      </tr>
    </thead>
    <tbody>
    <%
    if (arr!=null && arr.size()>0) {
      for (String[] v : arr) {
       out.println("<tr>");
       out.print("<td>" + v[0] + "</td>");
       out.print("<td>" + v[1] + "</td>");
       out.print("<td>" + v[2] + "</td>");
       out.print("<td>" + v[3] + "</td>");
       out.println("</tr>");
      }
    }
    %>
    </tbody>
  </table>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>

