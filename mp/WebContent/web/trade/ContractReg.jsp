<%@page import="kr.co.mp.common.MobileUtil"%>
<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.common.MobileUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String csrf_token         = UUID.randomUUID().toString();
/* LOGIN USER'S INFORMATION */
String strCpyGubun        = (String)pageContext.getAttribute("CPY_GUBUN");
String strCpyId           = (String)pageContext.getAttribute("CPY_ID");
String strCpyBizNo        = (String)pageContext.getAttribute("CPY_BIZ_NO");
String strCpyNm           = (String)pageContext.getAttribute("CPY_NM");
/* LOGIN USER'S TRADE OPTIONS */
String CU_USE_YN          = StrUtil.nvl((String)pageContext.getAttribute("CU_USE_YN"), "N");
String CONFIRM_SETTLE_YN  = StrUtil.nvl((String)pageContext.getAttribute("CONFIRM_SETTLE_YN"), "N");
String REVERSE_YN         = StrUtil.nvl((String)pageContext.getAttribute("REVERSE_YN"), "N");
String MOBILE_YN          = StrUtil.nvl((String)pageContext.getAttribute("MOBILE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
String CRG_ID             = StrUtil.nvl((String)pageContext.getAttribute("CRG_ID"), "N");
String PAPER_BILL_YN      = StrUtil.nvl((String)pageContext.getAttribute("PAPER_BILL_YN"), "N");
String FEE_MOD_YN         = StrUtil.nvl((String)pageContext.getAttribute("FEE_MOD_YN"), "N");
if (MOBILE_YN.equals("Y") && MobileUtil.isMobile(request)) SIGN_EXCLUDE_YN = "Y"; // MOBILE APPROVAL IS REGISTERED, AND IF IT IS A MOBILE ENVIRONMENT, THE SIGNATURE IS EXCLUDED.

session.setAttribute("csrf_token", csrf_token);
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, 0); // MY PARTNERS
ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().CT_MY_PAYMETHOD_PROC(intCpyId);  // MY GUARANTEES

/*** for edit mode ***/
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));

String strRelatedCompaies = strCpyBizNo; // MY COMPANY'S HEADQUARTERS/BRANCH OFFICE
ArrayList<RelationCompanyVO> arrRelatedCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intCpyId, "N");
if (arrRelatedCompanies!=null && arrRelatedCompanies.size()>0) {
  for (RelationCompanyVO v : arrRelatedCompanies) {
    strRelatedCompaies += "," + v.RELATIONBIZNO;
  }
}

/*** messages ***/
boolean isEditMode   = false;
isEditMode = (intCtId>0) ? true : false;
String strPageTitle  = (isEditMode) ? "매매계약서 수정" : "매매계약서 작성";
String strBlockWords = ConfigurationMgr.getInstance().getString("TRADE_BLOCK_ITEM_NM"); // 거래불가품목명
strBlockWords = "\"" + strBlockWords.replaceAll(",", "\", \"") + "\"";
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />

<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type='text/javascript'>
let strCpyId = "<%=IntegerCryptoUtil.crypt(strCpyId)%>";
let strBuyerBizNumber = "<%=strCpyBizNo%>";
let wordtoblock = [<%=strBlockWords%>];
</script>
<script type='text/javascript' src='ContractReg.js?<%=DateTimeUtil.getCurrentDateTime()%>'></script>
<script>
function cancel() {
  showCustomConfirm("계약을 취소하시겠습니까?<br/>취소된 매매계약서는 복원되지 않습니다.", function() {
    $.post("ContractCancelProc.jsp", $("form[name='frmEnt']").serialize(), function(data) {
      if (data==0) {
        showAlert("취소할 수 없습니다.<br/>취소는 승인전까지 가능합니다.<br/>진행상태가 변경되었을 수 있으니 다시 확인하십시오.", function(){
          window.location.reload();
        });
      } else {
        showAlert("취소되었습니다.", function() {
          location.href = strContextPath + "/web/trade/";
        });
      }
    });
  }, function(){});
}
$(document).ready(function() {
  <% if (isEditMode) { %>
  // set values for edit mode
  showSpinner("불러오고 있습니다.");
  $("#load-for_modify").load("ContractFillToReg.jsp?seq=<%=intCtId%>");
  <% } else { %>
  $("select[name='seller_cpy_id']").select2();
  <% } %>
  // number of temporary storage sales contracts
  $.post("ContractsTempCnt.jsp", {'cpy_id':'<%=strCpyId%>'}, function(data){
    if (data!=0) $("#temp_contact_cnt").text(data);
    else $("#temp_contact_cnt").remove();
  });
  // scrap trading option
  <%=(CU_USE_YN.equals("Y"))?"$('.scrap_yn_block').show();":"" %>
});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <% if (REVERSE_YN.equals("Y")) { %>
    <a href='ContractRegForSeller.jsp' class='btn' title='판매계약서'>판매계약서</a>
    <% } %>
    <a href='ContractsTemp.jsp' class='btn' title='임시계약서'>임시보관함<span id='temp_contact_cnt'></span></a>
  </span>
  <% if (REVERSE_YN.equals("Y")) { %>
  <div style='text-align:right;margin-top: 20px;'>
    <span style='padding:10px;border:1px solid #ddd;'>판매사가 계약서를 작성하고 구매사가 승인하는 계약서를 작성하시려면, 판매계약서를 선택하십시오.</span>
  </div>
  <% } %>
</div>

<form name='frmEnt' autocomplete="off">

<input type="hidden" name="csrf_token" id="csrf_token" value="<%=csrf_token%>" />
<input type='hidden' id="seq" name='seq' value='<%=intCtId%>'>

<!-- COMPANY ATTRIBUTIONS -->
<input type='hidden' name='crg_id' value='<%=CRG_ID %>'><!--  CORPORATION (1), INDIVIDUAL (2) -->
<input type='hidden' name='paper_bill_yn' value='<%=PAPER_BILL_YN %>'><!-- WHETHER PAPER TAX INVOICES ARE ALLOWED -->
<input type='hidden' name='confirm_settle_yn' value='<%=CONFIRM_SETTLE_YN %>'>

<!-- TOKEN FOR SEND -->
<input type='hidden' name='ctid'>
<input type='hidden' name='token'>

<!-- ACTION CONTROL -->
<input type='hidden' name='temp_save' value='0'>
<input type='hidden' name='cttype' value='B'>
<input type='hidden' name='permmit_bill_items_yn' value='Y'>
<input type='hidden' name='non_warranty' value='N'>

<!-- ALDIS FINANCIAL SYSTEM ESSENTIAL COLUMN -->
<input type="hidden" id="aNumber" name="aNumber" value='2'><!-- SALES (1), PURCHASE (2) CLASSIFICATION  -->
<input type="hidden" id='bizno' name='bizno' value='<%=strCpyBizNo%>'>
<input type="hidden" id="loading" name="loading" value="1">
<input type="hidden" id="isenc" name="isenc" value="0">
<input type='hidden' id="junmun_string1" name="junmun_string1">
<input type="hidden" name="request_string" id="request_string"><!-- SCRAPING TOOL CALL VALUE -->
<input type="hidden" name="result_string"  id="result_string"><!-- SCRAPING RESULT VALUE -->

<!-- ELECTRONIC SIGNATURE REQUIRED -->
<input type='hidden' id='sgn_id' name='sgn_id'><!-- RESULT VALUE: 0000 IS VALIDATED -->
<input type='hidden' id='signdata' name='signdata'><!-- RESULT VALUE: SIGNATURE VALUE -->

<!-- BRANCH BUSINESS REGISTRATION NUMBER -->
<input type='hidden' name='buyer_related_biz_nos' value='<%=strRelatedCompaies%>'>
<input type='hidden' name='seller_related_biz_nos'>

<!-- ATTACHED TAX INVOICE KEY -->
<input type='hidden' name='sbill_seq'>
<input type='hidden' name='bill_buyer_biz_no'>
<input type='hidden' name='bill_seller_biz_no'>
<input type='hidden' name='bill_max_limit' value='0'>
<input type='hidden' name='contract_amt'>

<h3>결제정보</h3>

<div class='hint company' style='margin-bottom:5px;'>목록에서 찾을 수 없다면, 추가 버튼을 클릭해 새로운 거래처를 추가하십시오.<br/>만약 거래불가업체로 등록된 경우라면 내거래처로 등록하셔도 목록에서 찾을 수 없습니다. 고객센터로 문의하십시오.</div>
<ul class='form'>
  <li>
    <label>판매기업</label>
    <select class='select2' name='seller_cpy_id' onchange='checkSeller();'>
    <option value='0'></option>
    <%
    if (arrMyCompanies!=null && arrMyCompanies.size()>0) {
      for (CompanyVO mcvo : arrMyCompanies) {
    	String formattedBizNo = FormatUtil.addDashBizNo(mcvo.CPY_BUSINESS_NO);
        out.println("<option value='"+mcvo.CPY_ID+"____"+mcvo.CPY_BUSINESS_NO+"____"+mcvo.PAY_CPY+"____"+mcvo.CRG_ID+"'>"+mcvo.CPY_NAME+" ("+ mcvo.CPY_CEO_NAME + ", " + formattedBizNo +")</option>");
      }
    }
    %>
    </select>
    <a onclick='showPartnerReg();' class='btn mobile_hide cannot-changable' style='vertical-align:middle;'>추가</a>
    <a onclick='toggleHint("company");' class='btn circle mobile_hide cannot-changable' style='vertical-align:middle;'><i class="fa-solid fa-question"></i></a>
  </li>
  <li class='not-has-input'>
    <label>MP수수료부담</label>
    <span <%=FEE_MOD_YN.equals("Y") ? "" : "style='pointer-events:none;opacity:0.5;'"%>>
      <input type='radio' name='mp_pay_cpy' value='2' checked> 구매기업 <input type='radio' name='mp_pay_cpy' value='1'> 판매기업
    </span>
  </li>
  <!-- 결제방법 -->
  <li>
    <label>결제은행/수단</label>
    <select class='select2' name='bnk_pay_id' onChange='itemWriteMode();'>
    <%
    if (arrPayMethods!=null && arrPayMethods.size()>0) {
      for (PayMethodVO v : arrPayMethods) {
        out.println("<option value='"+v.BNK_CD+"____"+v.PAY_ID+"'>"+v.BNK_NAME+" "+v.PAY_SDESC+"</option>");
      }
    }
    %>
    </select>
    <a onclick='checkLimit(true);' class='btn mobile_hide' style='vertical-align:middle;'>한도조회</a>
    <a onclick='toggleHint("method");' class='btn circle mobile_hide' style='vertical-align:middle;'><i class="fa-solid fa-question"></i></a>
  </li>
  <li>
    <label>만기(대출상환)일</label>
    <input type='text' name='maturity_ymd' style='width:120px;cursor:pointer;' readOnly onclick='toggleCalendar();'>
    <a onclick='toggleCalendar();' class='btn'><i class="fa-regular fa-calendar"></i></a>
    <a onclick='toggleHint("maturity");' class='btn circle mobile_hide'><i class="fa-solid fa-question"></i></a>
    <span id='maturity-cnt'>
      <span></span>
    </span>
  </li>
</ul>
<div class='hint method'>조회된 한도에는 오차가 있을 수 있으며, B2B한도로만 결제하실 수 있습니다. 한도조회를 하지 않거나 조회 오류시에도 거래진행은 가능합니다.</div>
<div class='hint maturity'>만기일은 계약서 작성 시 입력한 일자 기준으로 조기상환 및 연장에 대한 정보는 제공되지 않습니다.</div>

<!-- block for calendar window -->
<div id='calendar' class='dynamic-page'></div>

<!-- 계약정보타이틀 -->
<div>
  <h3 style='width:auto;display:inline-block;'>계약정보</h3>
  <span class='more' style='margin-top:30px;'>
    <a onclick='toggleBills();' class='btn lurian' style='padding:7px 12px;'><i class="fa-solid fa-receipt"></i> &nbsp;세금계산서첨부</a>
  </span>
</div>

<!-- block for tax invoice window -->
<div id='bills' class='dynamic-page'></div>

<!-- attached tax invoice information -->
<div id='element_to_pop_up'></div>
<ul class='form'>
  <li>
     <label>승인번호</label>
     <input type='text' name='bill_app_no' placeholder='세금계산서첨부를 실행하십시오.' readonly>
  </li>
  <li>
    <label>작성일</label>
    <input type='text' name='bill_ymd' readonly>
  </li>
  <li>
     <label>발행금액</label>
     <input type='text' name='bill_amt' readonly>
  </li>
  <li class='not-has-input'>
    <label>사업자구분</label>
    <input type='radio' name='tax_biz_type' value='G' checked><strong>일반</strong>
    <input type='radio' name='tax_biz_type' value='S'><strong>영세</strong>
    <input type='radio' name='tax_biz_type' value='E'><strong>면세</strong>
    <span class='mobile_show'><br/><br/><label></label></span>
    <span class='more'>
      <span class='scrap_yn_block'><input type='checkbox' name='scrap_yn' value='Y'>철(구리)스크랩 거래</span>
      <a onclick='addItemWriteRow();' class='btn btnItemWriteMode' style='display:none;'>품목추가</a>
    </span>
  </li>
</ul>

<!-- items table -->
<table id='items' class='detail'>
  <colgroup>
    <col width='*'/>
    <col width='80' class='mobile_hide'/>
    <col width='80'/>
    <col width='90'/>
    <col width='90' class='mobile_hide'/>
    <col width='100'/>
    <col width='50'/>
  </colgroup>
  <thead>
    <tr>
      <th class='left'>품목</th>
      <th class='right mobile_hide'>수량</th>
      <th class='left'>단위</th>
      <th class='right'>공급가</th>
      <th class='right mobile_hide'>세액</th>
      <th class='right'>총액</th>
      <th>명령</th>
    </tr>
  </thead>
  <tbody id='bill-item-list'>
    <tr><td colspan='7' class='noentry'><a onclick='toggleBills();' class='btn white reverse-bills'>세금계산서첨부</a></td></tr>
  </tbody>
  <tfoot style='display:none;'>
    <tr>
      <th colspan='3'>합계(결제금액)</th>
      <th id='item_total_amount' class='item_total_amount right mobile_hide'>0</th>
      <th id='item_total_tax' class='item_total_tax right mobile_hide'>0</th>
      <th id='item_total_sum' class='item_total_sum right' style='color:darkred;font-weight:bold;'>0</th>
      <th></th>
    </tr>
  </tfoot>
</table>
<div class='cause'><i class="fa-solid fa-bell" style='animation:blink 3s infinite;color:hotpink;'></i> 비경상적인 거래품목에 대한 결제는 불가합니다. <a onclick='toggleHint("example");' class='btn circle mobile_hide'>예시</a></div>

<div class='hint example' style='margin-top:8px;'>보증기관 및 금융기관에서는 원칙적으로 거래의 물품 또는 용역의 내역을 자세히 제시하지 않거나 경상적 영업활동과 무관한 <%=strBlockWords%> 등의 거래를 금지하고 있습니다.</div>

<!-- 결제진행방식
<ul class='form'>
  <li class='wide'>
     <label>결제진행방식</label>
     <input type='radio' checked> <strong><font color='red'>바로결제</font></strong> <span class='mobile_hide'>(판매기업 계약승인 시 바로 인터넷뱅킹 실행)</span><br/>
     <input type='radio' style='margin-left:118px;margin-top:10px;'> <strong><font color='red'>확인결제</font></strong> <span class='mobile_hide'>(판매기업 계약승인 시 MP1 사이트에서 확인 후 인터넷뱅킹 실행)</span>
  </li>
</ul>
-->
</form>

<p>&nbsp;</p>
<p>&nbsp;</p>

<!-- EXECUTE BUTTONS -->
<div class='btns'>
 <% if (!isEditMode) { %>
  <a onclick='save(<%=(SIGN_EXCLUDE_YN.equals("Y"))?"goSubmit":"loadCert"%>);'><i class="fa fa-paper-plane" aria-hidden="true"></i> &nbsp;발송하기</a>
 <% } %>
  <a onclick='save(goTemporaryList);' style='background-color:#333;'>임시저장</a>
 <!-- <a href='javascript:location.reload();' style='background-color:#888;'>다시작성</a> -->
  <% if (isEditMode) { %>
  <a onclick='remove();' style='background-color:#333;'>삭제</a>
  <% } %>
</div>

<!-- 부정대출신청금지안내 -->
<div style='border-radius:20px;border:1px solid #ddd;padding:20px;margin-top:200px;'>
  <p style='font-size:1.2em;'><strong>B2B대출 부정 취급 금지 안내</strong></p>
  <p>&nbsp;</p>
  <p>1. 용도외 또는 실거래 없이 사용</p>
  <p>2. 대출 실행 후 전자(세금)계산서 취소 등 진정한 상거래가 아닌 '허위,융통거래'에 사용</p>
  <p>3. 기업구매자금일 경우 (세금)계산서(발급일로부터 31일 이내)없는 거래에 사용</p>
  <p>&nbsp;</p>
  <p><a href='//image.mp1.co.kr/images/popup_master/notice_150615.jpg' target='_new' class='btn'>금융기관 기업구매자금대출 취급세칙</a></p>
  <p>&nbsp;</p>
  <p>※ 부정 취급할 경우 기 대출금 즉시 상환, 건별 대출 실행금지등 대출금의 정상적인 운용이 불가하며 형사처벌 대상이 될 수 있습니다.</p>
</div>


<div id='load-for_modify'></div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>
<%@ include file="../includes/Footer.jsp" %>