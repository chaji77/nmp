<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

strCpyId           = IntegerCryptoUtil.crypt(strCpyId);

CustomerBean cbean = new CustomerBean();
CompanyVO cvo      = cbean.COMPANY_DETAIL_PROC(intCpyId);
String strCpyGubun = cvo.CPY_GUBUN;
String strCpyBizNo = cvo.CPY_BUSINESS_NO;
String strCpyNm    = cvo.CPY_NAME;
String strCuUseYn  = cvo.CU_USE_YN;

ArrayList<CompanyVO> arrMyCompanies  = cbean.CT_MYCOMPANY_LIST_PROC(intCpyId, 0); // MY PARTNERS
ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().CT_MY_PAYMETHOD_PROC(intCpyId);  // MY GUARANTEES

// for edit mode
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
    
String strRelatedCompaies = strCpyBizNo;
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
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/web/trade/ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />

<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/pop.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/js/validate.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type='text/javascript'>
let strCpyId = "<%=IntegerCryptoUtil.crypt(strCpyId)%>";
let strBuyerBizNumber = "<%=strCpyBizNo%>";
let wordtoblock = [<%=strBlockWords%>];
</script>
<script type='text/javascript' src='<%=request.getContextPath()%>/web/trade/ContractReg.js?<%=DateTimeUtil.getCurrentDateTime()%>'></script>
<script>
function checkAbnormal() {
  if (check()) {
    $("select[name='seller_cpy_id']").prop("disabled", false);
    $.ajax({
      url: "UnusualCheck.jsp", 
      type: 'post',
      data:$("form[name='frmEnt']").serialize(), 
      async: true,
      success: function(data) {
        if (isNaN(data)) {
          var json = JSON.parse(data);
          if (self != top) {
            parent.showAlert(json.msg, function(){}, "error-message");
          } else {
            showAlert(json.msg, function(){}, "error-message");
            // $("div.result-message").addClass("error-message");
          }
          
        } else {
          if (self != top) parent.showAlert("이상거래검증에 성공했습니다.");
          else showAlert("이상거래검증에 성공했습니다.");
        }
      },
      beforeSend: function() {
        if (self != top) parent.showSpinner("검증하고 있습니다.");
        else showSpinner("검증하고 있습니다.");
      },
      complete: function() {
        if (self != top) parent.hideSpinner();
    	  else hideSpinner();
      }
    });
  }
}
function saveByManager() {
  if (check()) {
    $("select[name='seller_cpy_id']").prop("disabled", false);
    $.ajax({
      url: "ContractRegProc.jsp", 
      type: 'post',
      data:$("form[name='frmEnt']").serialize(), 
      success: function(data) {
        if (isNaN(data)) {
          var json = JSON.parse(data);
          showAlert(json.msg);
          $("div.result-message").addClass("error-message");
        } else {
          document.frmEnt.action = "Contract.jsp";
          document.frmEnt.method = "post";
          document.frmEnt.submit();
        }
      },
      beforeSend: function() {
        showSpinner("저장하고 있습니다.");
      },
      complete: function() {
        hideSpinner();
      }
    });
  }
}
function goDetail() {
  document.frmEnt.action = "Contract.jsp";
  document.frmEnt.method = "post";
  document.frmEnt.submit();
}
$(document).ready(function() {
  $("#load-for_modify").load("ContractFillToReg.jsp?seq=<%=intCtId%>");
  // scrap trading option
  <%=(strCuUseYn.equals("Y"))?"$('.scrap_yn_block').show();":"" %>
  
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <a onclick='goDetail();' class='btn'>돌아가기</a>
  </span>
</div>

<form name='frmEnt' autocomplete="off">
<!-- ONLY MANAGER -->
<input type='hidden' name='cpy_id' value='<%=intCpyId%>'>
<input type='hidden' name='buyer_ip' value=''>
<input type='hidden' name='seller_ip' value=''>
<input type='hidden' name='reg_id' value=''>
<input type='hidden' name='buyer_sgn_id' value=''>
<input type='hidden' name='seller_sgn_id' value=''>

<!-- DEFAULT SET -->
<input type='hidden' id="seq" name='seq' value='<%=intCtId%>'>
<input type='hidden' name='temp_save' value='0'>

<!-- 알디스금융시스템 필수 컬럼 -->
<input type="hidden" id="aNumber" name="aNumber" value='2'><!-- 매출(1),매입(2) 구분  -->
<input type="hidden" id='bizno' name='bizno' value='<%=strCpyBizNo%>'>
<input type="hidden" id="loading" name="loading" value="1">
<input type="hidden" id="isenc" name="isenc" value="0">
<input type='hidden' id="junmun_string1" name="junmun_string1">
<input type="hidden" name="request_string" id="request_string"><!-- 스크래핑도구호출값 -->
<input type="hidden" name="result_string"  id="result_string"><!-- 스크래핑결과값 -->

<!-- 전자서명 필수값 -->
<input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
<input type='hidden' id='signdata' name='signdata'><!-- 결과값 : 서명값 -->

<!-- 본지사사업자번호 -->
<input type='hidden' name='buyer_related_biz_nos' value='<%=strRelatedCompaies%>'>
<input type='hidden' name='seller_related_biz_nos'>

<!-- 첨부한 세금계산서 키 -->
<input type='hidden' name='sbill_seq'>
<input type='hidden' name='bill_buyer_biz_no'>
<input type='hidden' name='bill_seller_biz_no'>
<input type='hidden' name='bill_max_limit' value='0'>
<input type='hidden' name='contract_amt'>

<h3>결제정보</h3>

<ul class='form'>
  <li>
    <label>판매기업</label>
    <select class='select2' name='seller_cpy_id' onchange='checkSeller();'>
    <option value='0'></option>
    <%
    if (arrMyCompanies!=null && arrMyCompanies.size()>0) {
      for (CompanyVO mcvo : arrMyCompanies) {
        out.println("<option value='"+mcvo.CPY_ID+"____"+mcvo.CPY_BUSINESS_NO+"____"+mcvo.CU_USE_YN+"'>"+mcvo.CPY_NAME+" ("+mcvo.CPY_CEO_NAME+")</option>");
      }
    }
    %>
    </select>
    <a onclick='showPartnerReg();' class='btn mobile_hide cannot-changable' style='vertical-align:middle;'>추가</a>
  </li>
  <li class='not-has-input'>
    <label>MP수수료부담</label>
    <input type='radio' name='mp_pay_cpy' value='2' checked> 구매기업 <input type='radio' name='mp_pay_cpy' value='1'> 판매기업
  </li>
  <!-- 결제방법 -->
  <li>
    <label>결제은행/수단</label>
    <select class='select2' name='bnk_pay_id'>
    <%
    if (arrPayMethods!=null && arrPayMethods.size()>0) {
      for (PayMethodVO v : arrPayMethods) {
        out.println("<option value='"+v.BNK_CD+"____"+v.PAY_ID+"'>"+v.BNK_NAME+" "+v.PAY_SDESC+"</option>");
      }
    }
    %>
    </select>
    <a onclick='checkLimit(true);' class='btn mobile_hide' style='vertical-align:middle;'>한도조회</a>
  </li>
  <li>
    <label>만기(대출상환)일</label>
    <input type='text' name='maturity_ymd' style='width:120px;cursor:pointer;' readOnly onclick='toggleCalendar();'>
    <a onclick='toggleCalendar();' class='btn'><i class="fa-regular fa-calendar"></i></a>
    <span id='maturity-cnt'>
      <span></span>
    </span>
  </li>
</ul>

<!-- block for calendar window -->
<div id='calendar' class='dynamic-page'></div>

<!-- 계약정보타이틀 -->
<div>
  <h3 style='width:auto;display:inline-block;'>계약정보</h3>
  <!-- span class='more' style='margin-top:30px;'>
    <a onclick='toggleBills();' class='btn lurian' style='padding:7px 12px;'><i class="fa-solid fa-receipt"></i> &nbsp;세금계산서첨부</a>
  </span -->
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
    <input type='radio' name='tax_biz_type' value='G' checked><strong>일반</strong><span class='mobile_show'><br/><label></label></span>
    <input type='radio' name='tax_biz_type' value='S'><strong>영세</strong><span class='mobile_show'><br/><label></label></span>
    <input type='radio' name='tax_biz_type' value='E'><strong>면세</strong>
    <span class='more scrap_yn_block'><input type='checkbox' name='scrap_yn' value='Y'>철(구리)스크랩 거래</span>
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

</form>

<p>&nbsp;</p>
<p>&nbsp;</p>

<!-- execute buttons -->
<div class='btns'>
  <a onclick='saveByManager();'>저장</a>
  <a onclick='checkAbnormal();' class='lurian'>이상거래검증</a>
</div>

<div id='load-for_modify'></div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>
<%@ include file="../Footer.jsp" %>