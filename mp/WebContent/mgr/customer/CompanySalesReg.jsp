<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.c.CompanySalesVO" %>
<%
request.setCharacterEncoding("utf-8");
String strYear = DateTimeUtil.getCurrentDate("").substring(0, 4);
CompanySalesVO pvo = new CompanySalesVO();
pvo.CPY_ID = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
ArrayList<CompanySalesVO> arr = new CustomerBean().COMPANY_SALES_LIST_PROC(pvo);
if (arr!=null && arr.size()>0) pvo = arr.remove(0);
%>
  <script>
  
  </script>

  <h3>연매출액 등록</h3>
  <form name='frmSales'>
  <input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
  <ul class='form'>
    <li>
      <label>년도</label>
      <select name='yyyy'>
      <%
      for (int i=1; i<5; i++) {
    	  int y = Integer.parseInt(strYear)-i;
    	  out.println("<option value='"+y+"'>"+y+"</option>");
      }
      %>
      </select>
    </li>
    <li>
      <label>매출액 (백만원)</label>
      <input type='number' name='amt' value='<%=pvo.SALES_AMT%>'>
    </li>
    <li style='margin-top:15px;'>
      <label></label>
      <a onclick='registSales();' class='btn lurian'>등록</a>
    </li>
  </ul>
  </form>
  
  <p>&nbsp;</p>
  <p><i class="fa-solid fa-asterisk"></i> 같은 년도의 매출액은 업데이트됩니다.</p>
  
  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
