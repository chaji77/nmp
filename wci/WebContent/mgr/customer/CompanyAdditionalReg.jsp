<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
request.setCharacterEncoding("utf-8");
int CPY_ID = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String YN = StrUtil.nvl(request.getParameter("yn"));
String title = StrUtil.nvl(request.getParameter("title"));

if (title!="") {
  switch (title) {
    case "settle":
      title = "확인결제";
      break;
    case "mptax":
      title = "월합세금계산서";
      break;
    case "scrap":
      title = "구리, 철 스크랩";
      break;
    case "mobile":
      title = "모바일 승인";
      break;
    case "reverse":
      title = "계약서 역발행";
      break;
    case "sign":
      title = "전자서명 예외";
      break;
  }
}
%>
<script type="text/javascript">
$(document).ready(function(){
	$("input[name='useYN'][value='<%=YN%>']").prop('checked', true);
});
</script>
<h3>
  <%=title %> 관리
</h3>
<p>&nbsp;</p>
<form name='frmUseYN'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<input type='hidden' name='title' value='<%=StrUtil.nvl(request.getParameter("title"))%>'>
<ul class='form'>
  <li>
    <label class='not-has-input'>사용 구분</label>
    <input type='radio' name='useYN' value='Y'><span style='margin-right:50px'>사용함</span>
  </li>
  <li>
    <label class='not-has-input'></label>
    <input type='radio' name='useYN' value='N'>사용안함
  </li>
  <li style='margin-top:25px;'>
      <label></label>
      &nbsp;&nbsp;<a onclick='editAdditionalInfo();' class='btn lurian'>수정</a>
  </li>
</ul>
</form>
  
<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>