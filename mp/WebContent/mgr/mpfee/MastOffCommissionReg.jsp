<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%
request.setCharacterEncoding("utf-8");

int intCommId = Integer.parseInt(StrUtil.nvl(request.getParameter("commid"), "0"));
%>
<h3>별도수수료 등록</h3>
  
<form name='frmMastOffCommission'>
<input type='hidden' name='commid' value='<%=intCommId%>'>
<ul>
  <li>
    <label>매매계약아이디</label>
    <input type='number' name='ctid' value='0'>
  </li>
  <li style='margin-top:5px;'>
    <label>받은금액</label>
    <input type='number' name='money' value='0'>
  </li>  
  <li style='margin-top:15px;'>
      <label></label>
      <a onclick='addMastCommission();' class='btn lurian'>등록</a>
  </li>
</ul>
</form>

<p>&nbsp;</p>
<p><i class="fa-solid fa-circle-info"></i> 매매계약아이디를 입력하면, 받은 금액은 매매계약서의 MP수수료로 대체됩니다.</p>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>