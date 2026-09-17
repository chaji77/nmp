<%@ page contentType="text/html;charset=utf-8"%>
<style>
ul.account li {padding-bottom:5px;}
ul.account li:last-child {padding-top:10px;}
</style>
<script>
$(document).ready(function(){
  $("input[name='usernm']").keydown(function(e) {
    if (e.keyCode == 13) {
      searchId();
      e.preventDefault();
      e.stopPropagation();
    }
  });
  $("input[name='userid']").keydown(function(e) {
    if (e.keyCode == 13) {
      resetPw();
      e.preventDefault();
      e.stopPropagation();
    }
  });
});

</script>
<div style='background-color:white;padding:20px;min-width:300px;'>
  <h3>아이디 찾기</h3>
  <form name='frmAccount' method='post' autocomplete="off">
  <ul class='account'>
    <li>
      <label>사업자번호</label>
      <input type='text' name='bizno' placeholder='사업자번호' maxlength='12'>
    </li>
    <li>
      <label>담당자명</label>
      <input type='text' name='usernm' placeholder='담당자명' maxlength='24'>
    </li>
    <li>
      <label></label>
      <a class='btn searchId' onclick='searchId();'>검색</a>
    </li>
  </ul>
  </form>
  
  <h3>비밀번호 재발급</h3>
  <form name='frmPassword' method='post' autocomplete="off">
  <ul class='account'>
    <li>
      <label>사업자번호</label>
      <input type='text' name='bizno' placeholder='사업자번호' maxlength='12'>
    </li>
    <li>
      <label>아이디</label>
      <input type='text' name='userid' placeholder='아이디' maxlength='24'>
    </li>
    <li>
      <label></label>
      <a class='btn resetPw' onclick='resetPw();'>재발급</a>
    </li>
  </ul>
  </form>
  
  <!-- close -->
  <div style='text-align:center;margin-top:50px;margin-bottom:30px;'><i class="fa-solid fa-xmark" onclick='closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
</div>