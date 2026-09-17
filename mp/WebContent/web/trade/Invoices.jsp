<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;
String strPrsId       = (String)pageContext.getAttribute("PRS_ID");

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
}

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, Integer.parseInt(strPrsId)); // MY PARTNERS
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>거래세금계산서관리</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />
<style>
div.dynamic-page {border:0;padding:0;width:100%;}
.hide_in_invoice_page {display:none;}
.align_right_in_invoice_page {text-align:right !important;}
ul.exp {display:flex;flex-flow:row wrap;justify-content:left;margin:0 0 40px 0;padding:10px;border:1px solid #ddd;color:#888;}
ul.exp>li {padding:10px;}
ul.exp>li>ul>li {padding:3px 0;}
ul.exp>li>ul>li>strong {color:#000;}
.valid_invoice_date h2 {font-size:1em;margin-bottom:5px;}
.valid_invoice_date .due-date {font-weight:bold;}
</style>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script type='text/javascript' src='ContractReg.js?<%=DateTimeUtil.getCurrentDateTime()%>'></script>
<script>
$(document).ready(function() {
  toggleBills();
  // $(".valid_invoice_date").load("<%=request.getContextPath()%>/ValidInvoiceDate.jsp?today=Y");
  $(".valid_invoice_date").load("<%=request.getContextPath()%>/ValidInvoiceDate.jsp");
});
</script>

<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래세금계산서관리</span>
  <span class='more'>
  </span>
</div>

<ul class='exp'>
  <li class='mobile_hide'><i class="fa fa-commenting fa-5x" style="color:#246CEB;"></i></li>
  <li>
    <ul>
      <li><font color='red'>여러 건의 매매계약서를 작성하신다면</font> 이 페이지에서 미리 세금계산서를 첨부하는 것이 편리합니다.</li>
      <li class='valid_invoice_date'></li>
    </ul>
  </li>
</ul>

<!-- ALDIS FINANCIAL SYSTEM ESSENTIAL COLUMN -->
<form name='frmEnt'>
<input type="hidden" id="aNumber" name="aNumber" value='2'><!-- SALES (1), PURCHASE (2) CLASSIFICATION  -->
<input type="hidden" id='bizno' name='bizno' value=''>
<input type="hidden" id="loading" name="loading" value="1">
<input type="hidden" id="isenc" name="isenc" value="0">
<input type='hidden' id="junmun_string1" name="junmun_string1">
<input type="hidden" name="request_string" id="request_string"><!-- SCRAPING TOOL CALL VALUE -->
<input type="hidden" name="result_string"  id="result_string"><!-- SCRAPING RESULT VALUE -->
</form>

<!-- BLOCK FOR TAX INVOICE WINDOW -->
<div id='bills' class='dynamic-page'></div>
<div id='element_to_pop_up'></div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>

<%@ include file="../includes/Footer.jsp" %>