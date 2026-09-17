<%@ page contentType="text/html;charset=utf-8"%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<script>
function formatBusinessNumber(value) {
  value = value.replace(/\D/g, "");
  if (value.length <= 3) return value;
  else if (value.length <= 5) return value.slice(0, 3) + "-" + value.slice(3);
  else return value.slice(0, 3) + "-" + value.slice(3, 5) + "-" + value.slice(5, 10);
}
function goPage(page) {
  document.frmSearch.page.value = page;
  showSpinner("불러오고 있습니다.");
  $.post("CompanySearchInc.jsp", $("form[name='frmSearch']").serialize(), function(data) {
    $("#ResultSet").html(data);
    hideSpinner();
  });
}
function chooseThis(cid, zipcode, row) {
  let columns = $(row).find("td");
  let nm      = $(columns[0]).text().trim();
  let ceo     = $(columns[1]).text().trim();
  let bizno   = $(columns[2]).text().trim();
  let addr    = $(columns[3]).text().trim();
  if (window.opener) {
    $(window.opener.document).find("#seller_cpy_id").val(cid);
    $(window.opener.document).find("#seller_cpy_nm").val(nm);
    $(window.opener.document).find("#seller_ceo").val(ceo);
    $(window.opener.document).find("#seller_bizno").val(bizno);
    $(window.opener.document).find("#seller_addr").val(addr);
    $(window.opener.document).find("#adr_zipcode").val(zipcode);
    $(window.opener.document).find(".seller_cpy_nm").text(nm);
    $(window.opener.document).find(".seller_ceo").text(ceo);
    $(window.opener.document).find(".seller_bizno").text(formatBusinessNumber(bizno));
    $(window.opener.document).find(".seller_addr").text(addr);
    self.close();
  } else alert("Parent Window is Closed.");
}
$(document).ready(function() {
  $("#search-company-name").keydown(function(key) {
    if (key.keyCode == 13) {
      event.preventDefault();
      goPage(1);
    }
  });
});
</script>
<!-- // page head block -->
</head>
<body style='padding:20px;'>

<h3>거래처검색</h3>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='1'>
<div style='margin-bottom:20px;'>
    <label>거래처명</label>
    <input type='text' id='search-company-name' name='nm' value='' style='width:120px;' maxlength='20' placeholder='거래처명'>
    <a onclick='goPage(1);' class='btn'>검색</a>
</div>
</form>

<div id='ResultSet'>

<table class="detail clickable-tr">
<thead>
<tr>
  <th class='left'>회사명</th>
  <th class='left'>대표자명</th>
  <th class='left'>사업자번호</th>
  <th class='left'>주소</th>
</tr>
</thead>
</table>

</div>


</body>