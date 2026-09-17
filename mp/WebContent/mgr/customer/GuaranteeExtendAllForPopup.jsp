<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
%>
<script></script>
<h3>유효보증서 일괄연장</h3>
<form name='frmExtendAll'>
<ul class='form'>
  <li>
    <label>날짜</label>
    <input type='date' name='val_date'>
  </li>
  <li style='margin-top:15px;'>
      <label></label>
      <a onclick='extendAll();' class='btn lurian'>제출</a>
  </li>
</ul>
</form>
<p>&nbsp;</p>
<p><i class="fa-solid fa-asterisk"></i> 입력하신 날짜 이전에 해당되는 유효만기일을 가진 유효보증서들이 일괄적으로 연장됩니다.  </p>

 <!-- close -->
 <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
