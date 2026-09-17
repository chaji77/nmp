<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<!-- RELATED COMPANIES -->
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<!-- TAX BILLS -->
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
String strTargetCpyId = StrUtil.nvl(request.getParameter("seller_id"), "0");
String strStartYmd = DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 180, "-");
String strEndYmd = DateTimeUtil.getCurrentDate("-");

String strRelatedCompaies = "9999999999";
if (!strTargetCpyId.equals("0") && StrUtil.isOnlyNumeric(strTargetCpyId)) {
  int intTargetCpyId = Integer.parseInt(strTargetCpyId);
  ArrayList<RelationCompanyVO> arrRelatedCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intTargetCpyId, "Y");
  if (arrRelatedCompanies!=null && arrRelatedCompanies.size()>0) {
    for (RelationCompanyVO v : arrRelatedCompanies) {
      strRelatedCompaies += "," + v.RELATIONBIZNO;
    }
  }
  // System.out.println(strRelatedCompaies);
}
%>
<script>
var bill_seller_id = '<%=strTargetCpyId%>';
/**
 * serch tax invoice
 * <pre>use the form fields and functions declared in ContractReg.jsp.</pre>
 */
function searchBills(page) {
  var bill_seller_id_for_search = bill_seller_id;
  var bill_all_search = $("input[name='bill_all_search']").prop("checked");
  if (bill_all_search) bill_seller_id_for_search = "0"; // option to view all imported tax invoices
  $("#bill-list-spinner").show();
  $("#bill-list-block").html("");
  $.post("<%=request.getContextPath()%>/web/trade/BillListForBills.jsp", {
    'page': page,
    'seller_id': bill_seller_id_for_search,
    'buyer_related_companies_biz_no':$("input[name='buyer_related_biz_nos']").val(),
    'seller_related_companies_biz_no':$("input[name='seller_related_biz_nos']").val(),
    'bill_start_ymd': $("input[name='bill_start_ymd']").val(),
    'bill_end_ymd': $("input[name='bill_end_ymd']").val()
  }, function(rtn) {
    $("#bill-list-block").html(rtn);
    $("#bill-list-spinner").hide();
  });
}
/* attach a tax invoice to the contract */
function choiceBill(seq, buyer_bizno, seller_bizno, max_limit) {
  showLoading();
  $("input[name='bill_buyer_biz_no']").val(buyer_bizno);
  $("input[name='bill_seller_biz_no']").val(seller_bizno);
  $("input[name='bill_max_limit']").val(max_limit);
  $("#bill-load-to-contract").load("BillLoadToContractReg.jsp?seq=" + seq);
}
function dropBill(seq) {
  showCustomConfirm("선택한 세금계산서를 정말 삭제하시겠습니까?", function() {
    $.post("<%=request.getContextPath()%>/web/trade/BillDropProc.jsp", {'seq':seq}, function(rtn) {
      if (rtn=="Y") searchBills(1);
      else showAlert("이미 매매계약에 사용된 세금계산서는 삭제할 수 없습니다.", function() {});
    });
  }, function() {});
}
$(document).ready(function() {
	if ($("select[name='seller_cpy_id']").length>0) {
    var seller = $("select[name='seller_cpy_id']").val();
    if (seller.indexOf("____")>-1) seller = seller.split("____")[1];
    $("input[name='seller_related_biz_nos']").val("<%=strRelatedCompaies%>"); // add headquarters/branch information of seller
	}
  setTimeout(function() {searchBills(1);}, 100); // start searching
});
</script>
<!-- tax invoice scraper -->
<div style='text-align:center;margin-top:20px;margin-bottom:20px;'>
  <a class='btn darkorange' style='padding:10px 15px;' onclick='openScrap();'>홈텍스 신고자료 가져오기</a>
  <% if (ConfigurationMgr.getInstance().getString("BILL_SCRAP_FAIL_YN").equals("Y")) { %>
  <a class='btn' style='padding:10px 15px;' onclick='openXml();'>XML업로드</a>
  <% } %>
</div>

<div style='text-align:center;text-align:justify;'>
   <!-- usage -->
  <p class='hide_in_invoice_page' style='width:100%;text-align:center;'><strong>홈택스 신고자료 가져오기 후 첨부할 세금계산서를 아래에서 선택</strong>하십시오. B2B구매자금은 <font color='red'>작성일 포함 31일내 전자세금계산서</font>만 사용 가능합니다.</p>
  <p class='hide_in_invoice_page'>&nbsp;</p>
  <!-- search form for tax invoice -->
  <p class='align_right_in_invoice_page' style='text-align:center;'>
    <span class='hide_in_invoice_page'><input type='checkbox' name='bill_all_search' onclick='searchBills(1);'>모든 판매사</span> 
    <input type='date' name='bill_start_ymd' style='width:90px;' value='<%=strStartYmd%>'> ~ 
    <input type='date' name='bill_end_ymd' style='width:90px;' value='<%=strEndYmd%>'> 
    <i class="fa fa-search" aria-hidden="true" onclick='searchBills(1);'></i>
  </p>
</div>

<p>&nbsp;</p>
<!-- tax invoices -->
<div id='bill-list-spinner' style='display:none;text-align:center;'><i class="fa fa-spinner" style='animation: rotate_loading .8s linear infinite;'></i> 데이터를 불러오고 있습니다.</div>
<div id='bill-list-block'></div>

<!-- hidden area for attaching tax invoice -->
<div id='bill-load-to-contract'></div>

<p>&nbsp;</p>
<div class='hide_in_invoice_page' style='width:100%;text-align:center;'><i class="fa fa-times" aria-hidden="true" style='font-size:2em;cursor:pointer;' onclick='toggleBills();'></i></div>
<p>&nbsp;</p>

