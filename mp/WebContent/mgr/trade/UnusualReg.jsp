<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%
request.setCharacterEncoding("utf-8");
int intSeq = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
if (intSeq==0) return;

%>
<script>
function writeMemo() {
  $.post(strContextPath + "/mgr/trade/UnusualRegProc.jsp", $("form[name='frmRelease']").serialize(), function(data) {
    if (data!="0") {
      toast("등록하였습니다.", 1000, function() {
        closePopup();
        window.location.reload();
      });
    } else {
      toast("등록하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
$(document).ready(function() {

});
</script>
<h3>이상거래 관리</h3>
<form name='frmRelease' method='post' autocomplete='off'>
<input type='hidden' name='seq' value='<%=intSeq%>'>
<ul>
  <li><textarea name="contents" style="height:120px;width:calc(100% - 20px);"></textarea><li>
  <li style='margin-top:5px;'>
    <select name='use_yn' style='width:100%;'>
    <option value='Y'>해제</option>
    <option value='N'>해제하지 않음</option>
    </select>
  </li>
</ul>
<div class='btns'><a onclick='writeMemo();'>등록</a></div>
</form>

  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>

