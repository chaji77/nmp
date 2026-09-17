<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%
request.setCharacterEncoding("utf-8");

%>
<script>
function goCompanySearchPageForPopup(p) {
  document.frmSearchCompanyForPopup.page.value = p;
  $.post("<%=request.getContextPath()%>/mgr/customer/CompaniesForPopupResult.jsp", $("#frmSearchCompanyForPopup").serialize(), function(data){
   $("div.company-search-result").html(data);
  });
}
$(document).ready(function(){
  $("form[name='frmSearchCompanyForPopup'] input").keydown(function(key) {
    if (key.keyCode == 13) goCompanySearchPageForPopup(1);
  });
});
</script>
<h3>회원사검색</h3>
<style>
ul.company-search-fields {display:ruby-text;}
ul.company-search-fields li>input {width:120px;}
div.company-search-result>ul>li {border-bottom:1px solid #ddd;padding:5px 0;cursor:pointer;}
div.company-search-result>ul>li:hover {background-color:#fafafa;}
</style>
<form name='frmSearchCompanyForPopup' id='frmSearchCompanyForPopup' method="post" autocomplete="off">
<input type='hidden' name='page' value='1'>
<input type='hidden' name='cpy_id' value=''>
<ul class='company-search-fields'>
  <li><input type='text' name='bizno' maxlength='12' pattern="[0-9]+" placeholder='사업자번호'></li>
  <li><input type='text' name='nm' maxlength='20' placeholder='회사명'></li>
  <li><a onclick='goCompanySearchPageForPopup(1);' class='btn' style='padding:7px;'>검색</a></li>
</ul>
</form>

<div class='company-search-result'></div>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>

