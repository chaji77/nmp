<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
request.setCharacterEncoding("utf-8");
String guar_gubun = StrUtil.nvl(request.getParameter("guar"));
%>
<script>
function goBranchSearchPageForPopup(p) {
  document.frmGuaranteeLocationForPopup.page.value = p;
  $.post("<%=request.getContextPath()%>/mgr/customer/GuaranteeLocationsForPopupResult.jsp", $("#frmGuaranteeLocationForPopup").serialize(), function(data){
   $("div.branch-search-result").html(data);
  });
}
$(document).ready(function(){
  $("form[name='frmGuaranteeLocationForPopup'] input").keydown(function(key) {
    if (key.keyCode == 13) {
      event.preventDefault();
      goBranchSearchPageForPopup(1);
    }
  });
});
</script>
<h3>발급기관 검색</h3>
<style>
ul.branch-search-fields {display:ruby-text;}
ul.branch-search-fields li>input {width:120px;}
div.branch-search-result>ul>li {border-bottom:1px solid #ddd;padding:5px 0;cursor:pointer;}
div.branch-search-result>ul>li:hover {background-color:#fafafa;}
</style>
<form name='frmGuaranteeLocationForPopup' id='frmGuaranteeLocationForPopup' method="post" autocomplete="off">
<input type='hidden' name='page' value='1'>
<input type='hidden' name='guar_gubun' value='<%=guar_gubun%>'>
<ul class='branch-search-fields'>
  <li><input type='text' name='branch' maxlength='20' placeholder='지점명'></li>
  <li><a onclick='goBranchSearchPageForPopup(1);' class='btn' style='padding:7px;'>검색</a></li>
</ul>
</form>

<div class='branch-search-result'></div>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>