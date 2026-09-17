<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%
request.setCharacterEncoding("utf-8");

//부도여부코드
ArrayList<CodeVO> arrDishonorCodes = CodeBean.C_CODE_PROC("COMPANY.CPY_DISHONOR");

int CPY_ID = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String dishonorCode = StrUtil.nvl(request.getParameter("dishonor"));
%>

<script>
$(document).ready(function(){	
	var dishonorCode = <%=dishonorCode %>;
	if (dishonorCode!="") $("select[name='category']").val(dishonorCode);
});
</script>

<h3>
  회원사 부도 관리
</h3>
  
<form name='frmDishonor'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<ul class='form'>
  <li>
    <label>부도 구분</label>
    <select name='category'>
    	<%
        for (CodeVO c : arrDishonorCodes) {
          out.print("<option value='"+c.CODE_CD+"'>"+c.CODE_NM+"</option>");
        }
        %>
    </select>
  </li>
  <li style='margin-top:15px;'>
      <label></label>
      <a onclick='registDishonor();' class='btn lurian'>등록</a>
  </li>
</ul>
</form>
  
<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>