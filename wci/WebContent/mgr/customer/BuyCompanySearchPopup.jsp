<%@ page contentType="text/html;charset=utf-8"%>
<%
%>
<%@ include file="../Header.jsp" %>
<style>
ul.company-search-fields {display:ruby-text;}
ul.company-search-fields li>input {width:120px;}
div.company-search-result>table>tbody>tr {border-bottom:1px solid #ddd;padding:5px 0;cursor:pointer;}
div.company-search-result>table>tbody>tr:hover {background-color:#fafafa;}
</style>
<script>
function goCompanySearchPageForPopup(p) {
  document.frmSearchBuyCompanyForPopup.page.value = p;
  $.post("<%=request.getContextPath()%>/mgr/customer/BuyCompanySearchPopupResult.jsp", $("#frmSearchBuyCompanyForPopup").serialize(), function(data){
   $("div.company-search-result").html(data);
  });
}
function choiceCompany(obj) {
  var buycid = $(obj).attr("cid");
  var strBuyCpy = $(obj).children('td').eq(0).text();
  window.opener.$("[name='buy_cid']").val(buycid);
  window.opener.$("[name='buy_company']").val(strBuyCpy);
  window.close();
}
$(document).ready(function(){
  $("form[name='frmSearchBuyCompanyForPopup'] input").keydown(function(key) {
    if (key.keyCode == 13) {
      key.preventDefault();
      goCompanySearchPageForPopup(1);
    }
  });
});
</script>
</head>
<body style='padding:20px;'>
<h3>구매사 검색</h3>
<form name='frmSearchBuyCompanyForPopup' id='frmSearchBuyCompanyForPopup' method="post" autocomplete="off">
<input type='hidden' name='page' value='1'>
<ul class='company-search-fields'>
  <li><input type='text' name='nm' maxlength='20' placeholder='회사명' ><a onclick='goCompanySearchPageForPopup(1);' class='btn' style='padding:7px;margin-left:5px;'>검색</a></li>
</ul>
</form>

<div class='company-search-result'></div>

</body>