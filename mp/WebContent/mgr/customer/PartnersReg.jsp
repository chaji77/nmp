<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cid");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cid")));
else return;
%>
<script>
function searchCompany(page) {
  var searchCategory = $("select[name='searchCategory']").val();
  var searchWord = $("input[name='search_word']").val();
  if (searchCategory == 'cpy_name') {
    if (searchWord=='') {
      toast("기업명을 입력해주세요.");
      return;
    }
  } else {
	if (!isValidBusinessNumber(searchWord.replace(/-/g, ''))) {
	  toast("올바른 사업자번호가 아닙니다.");
	  return;
	}
  }
  showLoading();
  $.post("<%=request.getContextPath()%>/mgr/customer/PartnersSearchResult.jsp", {'category':searchCategory, 'search':searchWord, 'page':page}, function(data) {
	$("#my-companies-list").html(data);
	hideLoading();
  });
}
function addCompany(cid) {
  $.post("<%=request.getContextPath()%>/mgr/customer/PartnersRegProc.jsp", {'cid':'<%=strCpyId%>', 'targetId':cid}, function(data){
    closePopup();
    toast("추가되었습니다", 1000, function() {
      window.location.reload();
    });
  });
}
$(document).ready(function(){
  $("input[name='search_word']").keydown(function(key) {
    if (key.keyCode == 13) searchCompany(1);
  });
});
</script>

<div style='background-color:white;padding:20px;min-width:800px;'>
  <p style='text-align:center;font-size:1.2em;'><strong>거래처 검색</strong></p>
  <p>&nbsp;</p>
  <p style='padding:10px 0 5px 0;text-align:center;'>
    <select name='searchCategory' style='width:15%;'>
      <option value="cpy_name">기업명</option>
      <option value="cpy_bizno">사업자번호</option>
    </select>
    <input type='text' name='search_word' value='' style='width:90px;' autocomplete="off">
    <a onclick='searchCompany(1);' class='btn' style='padding-top:7px;padding-bottom:7px;'>검색</a>
  </p>
  
  <div id='my-companies-list' style='max-width:800px;'></div>
  
  <div style='text-align:center;margin-top:50px;margin-bottom:30px;'><i class="fa-solid fa-xmark" onclick='closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
</div>