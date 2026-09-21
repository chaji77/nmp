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
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String csrf_token  = UUID.randomUUID().toString();
String strCpyGubun = (String)pageContext.getAttribute("CPY_GUBUN");
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
String strPrsId    = (String)pageContext.getAttribute("PRS_ID");
String strCpyBizNo = (String)pageContext.getAttribute("CPY_BIZ_NO");
String strCpyNm    = (String)pageContext.getAttribute("CPY_NM");
String strCuUseYn  = StrUtil.nvl((String)pageContext.getAttribute("CU_USE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
String FEE_MOD_YN         = StrUtil.nvl((String)pageContext.getAttribute("FEE_MOD_YN"), "N");

session.setAttribute("csrf_token", csrf_token);
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

ArrayList<CompanyVO> arrMyCompanies  = new CustomerBean().CT_MYCOMPANY_LIST_PROC(intCpyId, Integer.parseInt(strPrsId)); // MY PARTNERS
ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().CT_MY_PAYMETHOD_PROC(intCpyId);  // MY GUARANTEES

/*** for edit mode ***/
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
String strPageTitle  = (isEditMode) ? "판매계약서 수정" : "판매계약서 작성";
String strBlockWords = ConfigurationMgr.getInstance().getString("TRADE_BLOCK_ITEM_NM"); // 거래불가품목명
strBlockWords = "\"" + strBlockWords.replaceAll(",", "\", \"") + "\"";
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title><%=strPageTitle %></title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion()%>">
<link rel="stylesheet" type="text/css" href="ContractReg.css?<%=DateTimeUtil.getCurrentDateTime()%>" />
<style>

</style>
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
function checkBuyer() {
  var buyer = $("select[name='buyer_cpy_id']").val();
  $("input[name='mp_pay_cpy']").prop("checked", false);
  if (buyer.split("____")[2] == "S") {
    $("input[name='mp_pay_cpy'][value='1']").prop("checked", true);
  } else {
    $("input[name='mp_pay_cpy'][value='2']").prop("checked", true);
  }
}
function check() {

  var buyer = $("select[name='buyer_cpy_id']").val();
  if (buyer.indexOf("____")<0) {
    showErrorMsg("구매기업을 선택하십시오.");
    $("select[name='buyer_cpy_id']").focus();
    return false;
  }

  var ask_amount = 1 * (($("#item_total_sum").text()).replace(/,/g, ""));
  $("input[name='contract_amt']").val(ask_amount);

  // 품목정보등록여부
  if ($("#bill-item-list tr").length < 1) {
    showErrorMsg("하나 이상의 품목정보가 필요합니다.<br/>세금계산서 첨부를 이용하십시오.");
    return false;
  }
  
  // 품목정보공란점검 & 비경상적거래품목점검
  var is = true;
<%--
  $("#bill-item-list tr td input[name='item_nm']").each(function(idx, item) {
    $(item).css("border", "1px solid #ddd").focus();
    for (var i=0; i<wordtoblock.length; i++) {
      var word = $(item).val();
      word = $.trim(word);
      if (word.length == 0) {
        is = false;
        $(item).css("border", "1px solid #f00").focus();
        showErrorMsg("품목명을 입력하십시오.");
        return is;
      }
      if (word.indexOf(wordtoblock[i])>-1) {
        is = false;
        $(item).css("border", "1px solid #f00").focus();
        showErrorMsg("<strong class='emp'>" + wordtoblock[i] + "</strong><br/><br/>단어가 포함된 품목의 거래는 진행할 수 없습니다.<br/>품목을 확인하십시오.");
        return is;
      }
    }
  });
  return is;
}

--%>

  $("#bill-item-list tr").each(function(){
	  var nmObj   = $(this).find("input[name='item_nm']");
	  var unitObj = $(this).find("input[name='item_unit']"); 
	  var name = $.trim(nmObj.val());
	  var unit = unitObj.length ? $.trim(unitObj.val()) : "";
	  
	  if (!name) {
        nmObj.css("border","1px solid #f00").focus();
        showErrorMsg("품목명을 입력하십시오.");
        is = false;
        return false;
      }
	 
	  if (!unit) {
		unitObj.css("border","1px solid #f00").focus();
        showErrorMsg("단위을 입력하십시오.");
        is = false;
        return false;
      }
	  for (var i=0; i<wordtoblock.length; i++) {
        if (name.indexOf(wordtoblock[i]) > -1) {
            nmObj.css("border","1px solid #f00").focus();
            showErrorMsg("<strong class='emp'>" + wordtoblock[i] + "</strong><br/><br/>단어가 포함된 품목의 거래는 진행할 수 없습니다.");
            is = false;
            return false;
        }
     }	  
  });
  return is;
}

function addItemRow() {
  var str = "";
  str += "<tr>";
  str += "  <td><input type='text' name='item_nm' value=''></td>";
  str += "  <td><input type='number' name='item_qty' value='1'></td>";
  str += "  <td class='mobile_hide'><input type='text' name='item_unit' value=''></td>";
  str += "  <td class='item_amount right' style='padding-right:10px;'></td>";
  str += "  <td class='item_tax right mobile_hide' style='padding-right:10px;'></td>";
  str += "  <td><input type='text' name='item_sum' value='' maxlength='12' class='numput'></td>";
  str += "  <td class='center'>";
  str += "    <a onclick='addItemRow();' class='btn'><i class='fa-solid fa-plus'></i></a>";
  str += "    <a onclick='dropItem(this);' class='btn'><i class='fa fa-trash' aria-hidden='true'></i></a>";
  str += "  </td>";
  str += "</tr>";
  $("#bill-item-list").append(str);
  $(".numput").on("input", function () {
    calcItem(this);
  });
}

$(document).ready(function() {
  <% if (isEditMode) { %>
  // set values for edit mode
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
  <%=(strCuUseYn.equals("Y"))?"$('.scrap_yn_block').show();":"" %>
  
  addItemRow();

});
</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'><%=strPageTitle %></span>
  <span class='more'>
    <a href='ContractReg.jsp' class='btn'>구매계약서</a>
    <a href='ContractsTemp.jsp' class='btn'>임시보관함<span id='temp_contact_cnt'></span></a>
  </span>
</div>

<form name='frmEnt' autocomplete="off">

<input type="hidden" name="csrf_token" id="csrf_token" value="<%=csrf_token%>" />
<input type='hidden' id="seq" name='seq' value='<%=intCtId%>'>

<!-- TOKEN FOR SEND -->
<input type='hidden' name='ctid' value='<%=intCtId%>'>
<input type='hidden' name='token'>

<input type='hidden' name='temp_save' value='0'>
<input type='hidden' name='cttype' value='S'>
<input type='hidden' name='from_code' value='S'>

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
<input type='hidden' name='buyer_related_biz_nos'>
<input type='hidden' name='seller_related_biz_nos' value='<%=strRelatedCompaies%>'>

<!-- 첨부한 세금계산서 키 -->
<input type='hidden' name='sbill_seq'>
<input type='hidden' name='bill_buyer_biz_no'>
<input type='hidden' name='bill_seller_biz_no'>
<input type='hidden' name='bill_max_limit' value='0'>
<input type='hidden' name='contract_amt'>

<div class='hint company' style='margin-bottom:5px;'>목록에서 찾을 수 없다면, 추가 버튼을 클릭해 새로운 거래처를 추가하십시오.<br/>만약 거래불가업체로 등록된 경우라면 내거래처로 등록하셔도 목록에서 찾을 수 없습니다. 고객센터로 문의하십시오.</div>
<ul class='form'>
  <li>
    <label>구매기업</label>
    <select class='select2' name='buyer_cpy_id' onchange='checkBuyer();'>
    <option value='0'></option>
    <%
    if (arrMyCompanies!=null && arrMyCompanies.size()>0) {
      for (CompanyVO mcvo : arrMyCompanies) {
        out.println("<option value='"+mcvo.CPY_ID+"____"+mcvo.CPY_BUSINESS_NO+"____"+mcvo.PAY_CPY+"'>"+mcvo.CPY_NAME+" ("+mcvo.CPY_CEO_NAME+")</option>");
      }
    }
    %>
    </select>
    <a onclick='showPartnerReg();' class='btn mobile_hide' style='vertical-align:middle;'>추가</a>
    <a onclick='toggleHint("company");' class='btn circle mobile_hide' style='vertical-align:middle;'><i class="fa-solid fa-question"></i></a>
  </li>
  <li class='not-has-input'>
    <label>MP수수료부담</label>
    <span <%=FEE_MOD_YN.equals("Y") ? "" : "style='pointer-events:none;opacity:0.5;'"%>>
      <input type='radio' name='mp_pay_cpy' value='2' checked> 구매기업 <input type='radio' name='mp_pay_cpy' value='1'> 판매기업
    </span>
  </li>
  <li class='not-has-input'>
    <label>사업자구분</label>
    <input type='radio' name='tax_biz_type' value='G' checked><strong>일반</strong><span class='mobile_show'><br/><label></label></span>
    <input type='radio' name='tax_biz_type' value='S'><strong>영세</strong><span class='mobile_show'><br/><label></label></span>
    <input type='radio' name='tax_biz_type' value='E'><strong>면세</strong>
  </li>
  <li class='not-has-input'>
    <span class='more scrap_yn_block'><input type='checkbox' name='scrap_yn' value='Y'>철(구리)스크랩 거래</span>
  </li>
</ul>

<!-- items table -->
<table id='items' class='detail'>
  <colgroup>
    <col width='*'/>
    <col width='80'/>
    <col width='80' class='mobile_hide'/>
    <col width='90'/>
    <col width='90' class='mobile_hide'/>
    <col width='100'/>
    <col width='50'/>
  </colgroup>
  <thead>
    <tr>
      <th class='left'>품목</th>
      <th class='right'>수량</th>
      <th class='left mobile_hide'>단위</th>
      <th class='right'>공급가</th>
      <th class='right mobile_hide'>세액</th>
      <th class='right'>총액</th>
      <th>명령</th>
    </tr>
  </thead>
  <tbody id='bill-item-list'>

  </tbody>
  <tfoot>
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

</form>

<p>&nbsp;</p>
<p>&nbsp;</p>

<!-- execute buttons -->
<div class='btns'>
  <a onclick='save(<%=(SIGN_EXCLUDE_YN.equals("Y"))?"goSubmit":"loadCert"%>);'><i class="fa fa-paper-plane" aria-hidden="true"></i> &nbsp;발송하기</a>
  <a onclick='save(goTemporaryList);' style='background-color:#333;'>임시저장</a>
  <a href='javascript:location.reload();' style='background-color:#888;'>다시작성</a>
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

<div id='element_to_pop_up'></div>
<div id='load-for_modify'></div>
<iframe name='work' id='work' style='width:0;height:0;border:0;'></iframe>
<%@ include file="../includes/Footer.jsp" %>