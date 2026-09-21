<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.regreq.RegReqVO" %>
<%
request.setCharacterEncoding("utf-8");
String strSeq  = StrUtil.nvl(request.getParameter("seq"));
boolean isEdit = !strSeq.isEmpty() && StrUtil.isOnlyNumeric(strSeq) && !strSeq.equals("0");
String strAction = isEdit ? "수정" : "등록";

String strBuyCpyId   = StrUtil.input(request.getParameter("buyCpyId"));
String strBuyCpyName = StrUtil.input(request.getParameter("buyCpyName"));
String strSellCpyName = StrUtil.input(request.getParameter("sellCpyName"));
String strSellPrsName = StrUtil.input(request.getParameter("sellPrsName"));
String strSellPhone   = StrUtil.input(request.getParameter("sellPhone"));
String strSellFax     = StrUtil.input(request.getParameter("sellFax"));
String strSellEmail   = StrUtil.input(request.getParameter("sellEmail"));
String strBizNo       = StrUtil.input(request.getParameter("bizNo"));
String strTradeDate   = StrUtil.input(request.getParameter("tradeDate"));
String strMemo        = StrUtil.input(request.getParameter("memo")).replaceAll("<br>", "\n");
String strFeePay      = StrUtil.nvl(request.getParameter("feePay"));
String strReqStatus   = StrUtil.nvl(request.getParameter("reqStatus"), "1");
%>
<style>
#element_to_pop_up {width:40vw !important;}
#element_to_pop_up ul.form {display:flex;flex-flow:row wrap;}
#element_to_pop_up ul.form li {width:50%;margin-bottom:10px;}
#element_to_pop_up ul.form li.wide {width:100%;}
#element_to_pop_up ul.form label {width:131px;padding-left:10px;margin-right:0;}
#element_to_pop_up ul.form input {width:calc(100% - 156.5px);}
#element_to_pop_up ul.form select {width:calc(100% - 146.5px);}
</style>
<h3>판매기업 등록요청 <%=strAction%></h3>
<form name='frmRegReqReg'>
<input type='hidden' name='seq' value='<%=isEdit ? strSeq : ""%>'>
<input type='hidden' name='buyCpyId' value='<%=strBuyCpyId%>'>
<ul class='form'>
  <li class='wide'>
    <label>구매기업<span style='color:red;'>*</span></label>
    <input type='text' name='buyCpyName' value='<%=strBuyCpyName%>' readonly style='width:calc(100% - 212px);margin-right:5px;'>
    <a onclick='searchBuyCompany();' class='btn'>검색</a>
  </li>
  <li>
    <label>판매기업명<span style='color:red;'>*</span></label>
    <input type='text' name='sellCpyName' value='<%=strSellCpyName%>' maxlength='100' required>
  </li>
  <li>
    <label>담당자명</label>
    <input type='text' name='sellPrsName' value='<%=strSellPrsName%>' maxlength='20'>
  </li>
  <li>
    <label>연락처<span style='color:red;'>*</span></label>
    <input type='text' name='sellPhone' value='<%=strSellPhone%>' maxlength='15' placeholder='- 없이 입력' required>
  </li>
  <li>
    <label>팩스</label>
    <input type='text' name='sellFax' value='<%=strSellFax%>' maxlength='15' placeholder='- 없이 입력'>
  </li>
  <li>
    <label>이메일</label>
    <input type='text' name='sellEmail' value='<%=strSellEmail%>' maxlength='100'>
  </li>
  <li>
    <label>사업자번호<span style='color:red;'>*</span></label>
    <input type='text' name='sellCpyBusinessNo' value='<%=strBizNo%>' maxlength='10' placeholder='- 없이 입력' required>
  </li>
  <li>
    <label>거래예정일</label>
    <input type='date' name='tradeDate' value='<%=strTradeDate%>'>
  </li>
  <li>
    <label>수수료부담</label>
    <select name='feePay'>
      <option value=''>선택안함</option>
<%
for (Map.Entry<Integer, String> entry : RegReqVO.getFeePayMap().entrySet()) {
%>
      <option value='<%=entry.getKey()%>' <%= String.valueOf(entry.getKey()).equals(strFeePay) ? "selected" : "" %>><%=entry.getValue()%></option>
<%
}
%>
    </select>
  </li>
<% if (isEdit) { %>
  <li>
    <label>상태</label>
    <select name='reqStatus'>
<%
for (Map.Entry<Integer, String> entry : RegReqVO.getReqStatusMap().entrySet()) {
%>
      <option value='<%=entry.getKey()%>' <%= String.valueOf(entry.getKey()).equals(strReqStatus) ? "selected" : "" %>><%=entry.getValue()%></option>
<%
}
%>
    </select>
  </li>
<% } %>
  <li class='wide' style='margin-top:10px;'>
    <label>비고</label>
    <textarea name='memo' maxlength='500' style='height:100px;width:calc(100% - 2px);padding:5px;margin-top:5px;'><%=strMemo%></textarea>
  </li>
  <li style='margin-top:15px;text-align:right;'>
    <a onclick='goRegReqSubmit();' class='btn lurian'><%=strAction%></a>
  </li>
</ul>
</form>

<!-- 구매기업 검색용 별도 팝업(등록폼 위에 겹쳐서 뜸, 등록폼 DOM은 안 건드림) -->
<div id='regreq-buy-search' style='display:none;background:#fff;border-radius:15px;padding:20px;min-width:340px;max-width:480px;'>
<h3>구매기업 검색</h3>
<style>
#regreq-buy-search ul.company-search-fields {display:ruby-text;}
#regreq-buy-search ul.company-search-fields li>input {width:120px;}
#regreq-buy-search div.company-search-result>ul>li {border-bottom:1px solid #ddd;padding:5px 0;cursor:pointer;}
#regreq-buy-search div.company-search-result>ul>li:hover {background-color:#fafafa;}
</style>
<ul class='company-search-fields'>
  <li><input type='text' id='buySearchBizNo' maxlength='12' pattern="[0-9]+" placeholder='사업자번호'></li>
  <li><input type='text' id='buySearchNm' maxlength='20' placeholder='회사명'></li>
  <li><a onclick='doBuyCompanySearch();' class='btn' style='padding:7px;'>검색</a></li>
</ul>
<div class='company-search-result'></div>
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closeBuySearchPopup();'></i>
</div>

<script>
function searchBuyCompany() {
  $("#buySearchBizNo, #buySearchNm").val('');
  $("#regreq-buy-search div.company-search-result").empty();
  $("#regreq-buy-search").bPopup({});
}
function closeBuySearchPopup() {
  $("#regreq-buy-search").bPopup().close();
}
function doBuyCompanySearch() {
  $.post("<%=request.getContextPath()%>/mgr/customer/CompaniesForPopupResult.jsp", {
    page: 1,
    bizno: $("#buySearchBizNo").val(),
    nm: $("#buySearchNm").val()
  }, function(data) {
    // ponytail: 결과 10건 넘으면 더보기 링크가 오지만 여기선 미지원, 검색어로 좁혀쓰는걸로 충분
    $("#regreq-buy-search div.company-search-result").html(data);
  });
}
$(document).on("keydown", "#buySearchBizNo, #buySearchNm", function(key) {
  if (key.keyCode == 13) doBuyCompanySearch();
});
function choiceCompany(obj) {
  document.frmRegReqReg.buyCpyId.value = $(obj).attr("cid");
  document.frmRegReqReg.buyCpyName.value = $(obj).text();
  closeBuySearchPopup();
}
function goRegReqSubmit() {
  if (document.frmRegReqReg.buyCpyId.value == '') {
    toast("구매기업을 선택해주세요.");
    return;
  }
  if ($.trim(document.frmRegReqReg.sellCpyName.value) == '') {
    toast("판매기업명을 입력해주세요.");
    return;
  }
  if ($.trim(document.frmRegReqReg.sellPhone.value) == '') {
    toast("연락처를 입력해주세요.");
    return;
  }
  if ($.trim(document.frmRegReqReg.sellCpyBusinessNo.value) == '') {
    toast("사업자번호를 입력해주세요.");
    return;
  }
  var isEdit = document.frmRegReqReg.seq.value != '';
  var target = isEdit ? "CompanyRegReqModProc.jsp" : "CompanyRegReqRegProc.jsp";
  $.post("<%=request.getContextPath()%>/mgr/customer/" + target, $("form[name='frmRegReqReg']").serialize(), function(data) {
    if (data > 0) {
      location.reload();
    } else {
      toast((isEdit ? "수정" : "등록") + "하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
</script>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
