<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
request.setCharacterEncoding("utf-8");
int CPY_ID = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String YN = StrUtil.nvl(request.getParameter("yn"));
%>
<script type="text/javascript">
$(document).ready(function(){
	$("input[name='useYN'][value='<%=YN%>']").prop('checked', true);
});
</script>
<h3>
  수수료 수정권한 관리
</h3>
<p>&nbsp;</p>
<form name='frmUseYN'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<input type='hidden' name='title' value='feemod'>
<ul class='form'>
  <li>
    <label class='not-has-input'>수정 권한</label>
    <input type='radio' name='useYN' value='Y'><span style='margin-right:50px'>수정가능</span>
  </li>
  <li>
    <label class='not-has-input'></label>
    <input type='radio' name='useYN' value='N'>수정불가
  </li>
  <li style='margin-top:25px;'>
      <label></label>
      &nbsp;&nbsp;<a onclick='editAdditionalInfo();' class='btn lurian'>수정</a>
  </li>
</ul>
</form>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
