<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeVO" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeBean" %>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoVO" %>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoBean" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

// 부도여부코드
ArrayList<CodeVO> arrDishonorCodes = CodeBean.C_CODE_PROC("COMPANY.CPY_DISHONOR");

CustomerBean bean = new CustomerBean();
// 회원사정보
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
String strCpyMemo = bean.COMPANY_MEMO_PROC(intCpyId);
// 담당자정보
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
if (arrPersons==null || arrPersons.size()==0 || arrPersons.get(0).PRS_ID==null) return;
// 별도MP수수료정보
CompanyMpFeeInfoVO mpvo = new CompanyMpFeeInfoBean().COMPANY_MPFEE_INFO_PROC(intCpyId);
session.setAttribute("mpvo", mpvo);
// 본지사정보
ArrayList<RelationCompanyVO> arrRelationCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intCpyId, "N");
// 거래불가업체정보
ArrayList<CompanyNoTradeVO> arrNoTradeCompanies = new CompanyNoTradeBean().M_COMPANY_NO_TRADE_LIST_PROC(intCpyId, 0);
// 구매사관리 담당자정보
ArrayList<BusinessPersonVO> arrBusinessPersons = new MgrCustomerBean().M_BUSINESS_PERSON_LIST_PROC(intCpyId);

PersonVO pvo = new PersonVO();
if (arrBusinessPersons != null && arrBusinessPersons.size() > 0) {
    Set<Integer> b = new HashSet<Integer>();
    for (int i = 0; i < arrBusinessPersons.size(); i++) {
        BusinessPersonVO bp = arrBusinessPersons.get(i);
        b.add(bp.PRS_ID);
    }
    for (int i = 0; i < arrPersons.size(); i++) {
        PersonVO p = arrPersons.get(i);
        if (!b.contains(Integer.parseInt(p.PRS_ID)) && !StrUtil.nvl(p.PRS_LOGIN).equals("")) {
            pvo = arrPersons.remove(i);
            break;
        }
    }
} else {
    for (int i = 0; i < arrPersons.size(); i++) {
        PersonVO p = arrPersons.get(i);
        if (p.PRS_LOGIN != null && !p.PRS_LOGIN.trim().isEmpty()) {
            pvo = arrPersons.remove(i);
            break;
        }
    }
}
if (cvo.CPY_FOUNDYEAR.length()==8 && StrUtil.isOnlyNumeric(cvo.CPY_FOUNDYEAR)) cvo.CPY_FOUNDYEAR = FormatUtil.addSeparatorDate(cvo.CPY_FOUNDYEAR, ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"));
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>회원정보</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>

<style>
li.emp {background-color:#fee !important;}
td.emp {color:red;}
</style>
<script>
function goEditPage() {
  location.href = "CompanyModify.jsp?<%=strCpyId%>";
}
function getDishonorPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyDishonor.jsp?cid=<%=intCpyId%>&dishonor=<%=cvo.CPY_DISHONOR%>'});
}
function registDishonor() {
  $.post("CompanyDishonorRegProc.jsp", $("form[name='frmDishonor']").serialize(), function(data) {
  location.reload(true);  
  });
}
function getSalesPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanySales.jsp?cid=<%=intCpyId%>'});
}
function showSalesForm() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanySalesReg.jsp?cid=<%=intCpyId%>'});
}
function registSales() {
  $.post("CompanySalesRegProc.jsp", $("form[name='frmSales']").serialize(), function(data) {
    location.reload(true);
  });
}
function goLogin() {
  $.post(strContextPath + "/common/UUID.jsp", $("#frmEnt").serialize(), function(data){
    $.post('<%=request.getContextPath()%>/web/LoginProc.jsp', {
      'csrf_token':data,
      'login_id':'<%=pvo.PRS_LOGIN%>',
      'login_pw':$("input[name='prs_passwd']").val()}, function(data){ 
        if (data>0) {
          window.open('about:blank').location.href = "<%=request.getContextPath()%>/index.jsp";
        } else console.log(data);
    });    
  });
  

}
function resetPassword() {
  showCustomConfirm("비밀번호를 재발급하시겠습니까?", function(){
    $.post("ResetPassword.jsp", {'bizno':'<%=cvo.CPY_BUSINESS_NO%>','uid':'<%=pvo.PRS_LOGIN%>','email':'<%=pvo.PRS_EMAIL%>'}, function(data) {
      $("input[name='prs_passwd']").val($.trim(data));
      $.post("<%=request.getContextPath()%>/common/kakaotalk/Send.jsp", {'tcd':'M015', 'loginId':'<%=pvo.PRS_LOGIN%>'}, function(data) {
        if (data=="SUCCESS") {
          showAlert("회원에게 새로운 비밀번호("+$("input[name='prs_passwd']").val()+")를 카카오톡으로 전송하였습니다.");
        } else {
          showAlert("회원에게 카카오톡 메시지를 발송하지 못했습니다. 새로운 비밀번호는 "+$("input[name='prs_passwd']").val()+"입니다");
        }
      });
    });
  }, function(){});
}
function approveReg() {
  $.post("<%=request.getContextPath()%>/mgr/customer/CompanyApproveRegProc.jsp", {'cid':'<%=strCpyId%>'}, function(data) {
  if (data==0) location.reload();
  else showAlert("승인 불가합니다.");
  });
}
function getConfirmSettlePage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.CONFIRM_SETTLE_YN%>&title=settle'});
}
function getFeeModPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyFeeModReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.FEE_MOD_YN%>'});
}
function getMPTaxMonthPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.MPTAX_MONTH_USE_YN%>&title=mptax'});
}
function getScrapPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.CU_USE_YN%>&title=scrap'});
}
function goRelationCompanyMenu() {
  location.href = "RelationCompanies.jsp?cpy_id=<%=strCpyId%>";
}
function getMobileApprovalPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.MOBILE_YN%>&title=mobile'});
}
function getMpfeeRegPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyMpfeeReg.jsp?cid=<%=intCpyId%>'});
}
function getContractReversedPage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.REVERSE_YN%>&title=reverse'});
}
function editAdditionalInfo() {
  $.post("CompanyAdditionalRegProc.jsp", $("form[name='frmUseYN']").serialize(), function(data) {
  location.reload(true); 
  });
}
function getBusinessPersonPage(strBuyCid) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'BusinessPersonReg.jsp?cid=<%=intCpyId%>&buyCid=' + strBuyCid});
}
function removeBusinessPerson(strBuyCid, intPrsId) {
  showCustomConfirm("삭제하시겠습니까?", function() {
    $.post("BusinessPersonDropProc.jsp", {'cid':'<%=IntegerCryptoUtil.crypt(intCpyId)%>', 'buyCid':strBuyCid, 'prs_id':intPrsId}, function(data) {
      if (data!=-1) location.reload(true);
      else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
    });  
  });
}
function showNoTradePage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyNoTradeReg.jsp?cid=<%=intCpyId%>&cnm=' + encodeURIComponent('<%=cvo.CPY_NAME%>') + '&bizno=<%=cvo.CPY_BUSINESS_NO%>'});
}
function registNoTrade() {
  if ($("form[name='frmNoTrade'] input[name='sellerName']").val().trim() == "") {
  toast("판매사를 선택해주세요.");
  } else {
  $.post("CompanyNoTradeRegProc.jsp", $("form[name='frmNoTrade']").serialize(), function(data) {
    if(data==0) toast("사업자번호를 정확히 확인하여 선택하십시오.");
    else if (data==1) location.reload(true); 
    else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
  });
  }
}
function getSignExcludePage() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyAdditionalReg.jsp?cid=<%=intCpyId%>&yn=<%=cvo.SIGN_EXCLUDE_YN%>&title=sign'});
}
function modifyNoTradeCompany(seqNo) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyNoTradeReg.jsp?cid=<%=intCpyId%>&seqNo='+seqNo});
}
function getManagerPage(pid) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/ManagerReg.jsp?cid=<%=intCpyId%>&pid='+pid});
}
function modifyManager() {
  $.post("<%=request.getContextPath()%>/mgr/customer/ManagerRegProc.jsp", $("form[name='frmManager']").serialize(), function(data) {
    if (data>0) location.reload(true);
    else toast("<%=ConfigurationMgr.getInstance().getString("ERR_MSG") %>");
  });
}
function removeManager(pid) {
  $.post("<%=request.getContextPath()%>/mgr/customer/ManagerDropProc.jsp", {'cid':<%=intCpyId%>, 'pid':pid}, function(data) {
  if (data>0) location.reload(true);
  else toast("삭제할 수 없습니다.", 3000);
  });
}
$(document).ready(function(){

});
function editMpfeeInfo() {
  $.post("CompanyMpfeeRegProc.jsp", $("form[name='frmMpfeeReg']").serialize(), function(data) {
  location.reload(true);
 });
}
function getCompanyMemoRegPage(){
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'CompanyMemoReg.jsp?cid=<%=intCpyId%>'})
}

function sendA211() {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A211.jsp", 
    type: 'post',
    data:{"seller_cpy_id":"<%=intCpyId%>"
         ,"strBuyerId":"<%=cvo.CPY_INCORPORATE_NO%>"
         ,"strBuyerBizNo":"<%=cvo.CPY_BUSINESS_NO%>"
         ,"strSellerId":"<%=cvo.CPY_INCORPORATE_NO%>"
         ,"strSellerBizNo":"<%=cvo.CPY_BUSINESS_NO%>"}, 
    async: true,
    success: function(data) {
      showAlert(data);
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendA411() {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A411.jsp", 
    type: 'post',
    data:{"seller_cpy_id":"<%=intCpyId%>"
         ,"strBuyerId":"<%=cvo.CPY_INCORPORATE_NO%>"
         ,"strBuyerBizNo":"<%=cvo.CPY_BUSINESS_NO%>"
         ,"strSellerId":"<%=cvo.CPY_INCORPORATE_NO%>"
         ,"strSellerBizNo":"<%=cvo.CPY_BUSINESS_NO%>"
         ,"strSellerClearYn":"Y"},
    async: true,
    success: function(data) {
      if (data=="Y") showAlert("판매사사전검증차단해제등록되었습니다.");
      else showAlert("판매사사전검증차단중입니다.");
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function saveToLegacy() {
  $.ajax({
    url:"SaveCompanyInfoToLegacyProc.jsp", 
    type: 'post',
    data:{"cpy_id":"<%=strCpyId%>"},
    async: true,
    success: function(data) {
      showAlert(data);
    },
    beforeSend: function() {
      showSpinner("실행하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}

</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>회원정보</span>
  <span class='more'>
    <a onclick='goEditPage()' class='btn lurian'>수정</a>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<jsp:include page="./CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="1" />
</jsp:include>

<input type='hidden' name='prs_passwd' value='<%=CryptoDESUtil.decrypt(pvo.PRS_PASSWD) %>'>


<div class='page-title-block'>
  <span class='subtitle'>기본정보</span>
  <span class='more'><a onclick='saveToLegacy();' class='btn lurian'>담보디비에 복제</a></span>
</div>

<ul class='detail'>
  <li class='th'>사업자등록번호</li>
  <li class='td'><%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %></li>
  <li class='th'>회사명</li>
  <li class='td'><%=cvo.CPY_NAME%></li>
  <li class='th'>회사구분</li>
  <li class='td'><%
  if (cvo.CPY_GUBUN.equals("1")) out.print("구매사");
  else if (cvo.CPY_GUBUN.equals("2")) out.print("판매사");
  else out.print("구매&amp;판매사");
  %></li>
  <li class='th'></li>
  <li class='td'></li>
  <li class='th'>대표자명</li>
  <li class='td'><%=cvo.CPY_CEO_NAME%></li>
  <li class='th'>대표자 휴대폰번호</li>
  <li class='td'><%=cvo.CPY_CEO_HP%></li>
  <li class='th'>기업형태</li>
  <li class='td'><%
  if (cvo.CRG_ID.equals("1")) out.print("법인사업자");
  else out.print("개인사업자");
  %></li>
  <li class='th'>법인등록번호</li>
  <li class='td'><%=cvo.CPY_INCORPORATE_NO%></li>
  <li class='th'>업태</li>
  <li class='td'><%=cvo.BUSINESS_TYPE%></li>
  <li class='th'>종목</li>
  <li class='td'><%=cvo.INDUSTRY%></li>
  <li class='th'>주소</li>
  <li class='td'>[<%=cvo.CPY_ZIPCODE%>] <%=cvo.CPY_ADDR%> <%=cvo.CPY_ADDR2%></li>
  <li class='th'>팩스</li>
  <li class='td'><%=cvo.CPY_FAX%></li>
  <li class='th'>첨부파일</li>
  <li class='td'>
  <% if (cvo.BIZ_DOC_FILE_URL!=null && cvo.BIZ_DOC_FILE_URL.length()>10) { %>
      <a href="<%=cvo.BIZ_DOC_FILE_URL %>" target="_new"><%=cvo.BIZ_DOC_FILE_URL.substring((cvo.BIZ_DOC_FILE_URL.lastIndexOf("/")+1)) %></a>
  <% } %>
  </li>
  <li class='th emp'>부도여부</li>
  <li class='td'>
  <%
  if (cvo.CPY_DISHONOR==null || cvo.CPY_DISHONOR.equals("")) out.print("");
  else {
    for (CodeVO c : arrDishonorCodes) {
      if (c.CODE_CD.trim().equals(cvo.CPY_DISHONOR)) out.print(c.CODE_NM);
    }
  }
  %>
  <a href='javascript:getDishonorPage();' class='btn'>관리</a>
  </li>
  <li class='th'>설립일</li>
  <li class='td'><%=cvo.CPY_FOUNDYEAR%></li>
  <li class='th emp'>전년도매출액</li>
  <li class='td'><%=StrUtil.addComma(cvo.SALES_AMT) %> (백만원) <a href='javascript:getSalesPage();' class='btn'>매출액</a></li>
  <li class='th'>로그인계정</li>
  <li class='td'><%=pvo.PRS_LOGIN%></li>
  <li class='th'>관리</li>
  <li class='td'><a href='javascript:goLogin();' class='btn'>로그인</a> <a href='javascript:resetPassword()' class='btn'>비번재발급</a> 
  <% if (cvo.CST_ID.equals("1")) {%> <a href='javascript:approveReg()' class='btn'>등록승인</a> <%} %></li>
  <li class='th'>최근로그인</li>
  <li class='td'><%=cvo.LAST_LOGIN_DT %></li>
  <li class='th'>담당자</li>
  <li class='td'><%=pvo.PRS_NAME%> <%=pvo.PRS_PSTN%> (<a href='mailto:<%=pvo.PRS_EMAIL%>'><%=pvo.PRS_EMAIL%></a>)</li>
  <li class='th'>기업설명</li>
  <li class='td'><%=StrUtil.nvl(cvo.CPY_BUSINESS_DESC) %></li>
  <li class='th'>휴대전화번호</li>
  <li class='td'><a href='tel:<%=pvo.PRS_MOBILE_NO%>'><%=pvo.PRS_MOBILE_NO%></a></li>
  <li class='th'>일반전화번호</li>
  <li class='td'><a href='tel:<%=pvo.PRS_TEL %>'><%=pvo.PRS_TEL %></a></li>
  <li class='th'>내선번호</li>
  <li class='td'><a href='tel:<%=pvo.PRS_EXTN %>'><%=pvo.PRS_EXTN %></a></li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>부가정보</span>
</div>

<ul class='detail'>
  <li class='th'>확인결제</li>
  <li class='td'><%=(cvo.CONFIRM_SETTLE_YN.equals("Y"))?"신청":"미신청" %> <a href='javascript:getConfirmSettlePage();' class='btn'>수정</a></li>
  <li class='th'>월합세금계산서</li>
  <li class='td'><%=(cvo.MPTAX_MONTH_USE_YN.equals("Y"))?"신청":"미신청" %> <%=(cvo.MPTAX_MONTH_USE_YN.equals("Y"))?"("+StrUtil.getParameter(cvo.MPTAX_MONTH_USE_DT, "", 9)+")":"" %> <a href='javascript:getMPTaxMonthPage();' class='btn'>수정</a></li> 
  <li class='th'>스크랩 거래</li>
  <li class='td'><%=(cvo.CU_USE_YN.equals("Y"))?"거래 기업으로 등록":"취급하지 않음" %> <a href='javascript:getScrapPage();' class='btn'>수정</a></li>
  <li class='th'>본·지사 사업자</li>
  <li class='td'><%
  if (arrRelationCompanies==null || arrRelationCompanies.size()==0) out.print("미등록");
  else {
    String strRelationCompanies = "";
    for (RelationCompanyVO rv : arrRelationCompanies) {
      strRelationCompanies += ", " + FormatUtil.addDashBizNo(rv.RELATIONBIZNO);
    }
    out.print(strRelationCompanies.substring(2));
  }
  %> <a onclick='goRelationCompanyMenu();' class='btn'>관리</a></li>
  <li class='th'>모바일 승인</li>
  <li class='td'><%=(cvo.MOBILE_YN.equals("Y"))?"신청":"미신청" %> <a href='javascript:getMobileApprovalPage();' class='btn'>수정</a></li>
  <li class='th'>계약서 역발행</li>
  <li class='td'><%=(cvo.REVERSE_YN.equals("Y"))?"신청":"미신청" %> <a href='javascript:getContractReversedPage();' class='btn'>수정</a></li>
  <li class='th'>전자서명예외</li>
  <li class='td'><%=(cvo.SIGN_EXCLUDE_YN.equals("Y"))?"신청":"미신청" %> <a href='javascript:getSignExcludePage();' class='btn'>수정</a></li>
  <li class='th'>사전검증차단</li>
  <li class='td'>
    <%=(StrUtil.nvl(cvo.SELLER_CLEAR_YN).equals("Y"))?"해제":"차단(미검증)" %>
    <a onclick='sendA211();' class='btn'>사전검증조회</a>
    <a onclick='sendA411();' class='btn'>사전검증해제등록</a>
  </li>
  <li class='th'>수수료 수정가능 여부</li>
  <li class='td'><%=(cvo.FEE_MOD_YN.equals("Y"))?"수정가능":"수정불가" %> <a href='javascript:getFeeModPage();' class='btn'>수정</a></li>
  <li class='th'></li>
  <li class='td'></li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>특이사항</span>
  <span class='more'><a href='javascript:getCompanyMemoRegPage();' class='btn'>등록/수정</a></span>
</div>
<table class='detail'>
<thead class='mobile_hide'>
  <tr>
    <th class='left'>특이사항</th>
  </tr>
</thead>
<tbody>
    <tr>
    <% 
    if (!strCpyMemo.trim().isEmpty()) { 
        String strDesc = HtmlWhiteListUtil.filter(strCpyMemo);
        strDesc = strDesc.replaceAll("&quot;", "\""); 
        strDesc = strDesc.replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&");
    %>
      <td><%=strDesc %></td>
       <% }  else { out.println("<tr><td colspan='1' class='noentry'>없음</td></tr>"); }%>
    </tr>
</tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>구매사관리 담당자</span>
  <span class='more'><a href='javascript:getBusinessPersonPage();' class='btn'>담당자 추가</a></span>
</div>

<table class='detail'>
<thead>
  <tr>
    <th class='left'>관리업체</th>
    <th class='left mobile_hide'>담당자</th>
    <th class='left mobile_hide'>아이디</th>
    <th class='left mobile_hide'>전화번호</th>
    <th class='left mobile_hide'>핸드폰</th>
    <th class='left mobile_hide'>이메일</th>
    <th class='center'>명령</th>
  </tr>
</thead>
<tbody>
<%
if (arrBusinessPersons !=null && arrBusinessPersons.size()>0) {
  for (BusinessPersonVO bv : arrBusinessPersons) {
%>
  <tr>
    <td>
      <%=bv.BUY_COMPANY %>
      <span class='mobile_show'><br/><%=StrUtil.nvl(bv.PRS_NAME) %> (<%=StrUtil.nvl(bv.PRS_LOGIN) %>)</span>
    </td>
    <td class='mobile_hide'><%=StrUtil.nvl(bv.PRS_NAME) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(bv.PRS_LOGIN) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(bv.PRS_TEL) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(bv.PRS_MOBILE_NO) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(bv.PRS_EMAIL) %></td>
    <td class='center' width='70'>
      <!-- a class='btn lurian' onclick='getBusinessPersonPage("<%=IntegerCryptoUtil.crypt(bv.BUY_CPY_ID)%>")'>수정</a -->
      <a class='btn darkred' onclick='removeBusinessPerson("<%=IntegerCryptoUtil.crypt(bv.BUY_CPY_ID)%>", <%=bv.PRS_ID%>)'>삭제</a></td>
  </tr>
<%
  }
}
%>
</tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>거래불가업체</span>
  <span class='more'><a href='javascript:showNoTradePage();' class='btn'>업체추가</a></span>
</div>

<table class='detail'>
<thead class='mobile_hide'>
  <tr>
    <th class='left'>판매사</th>
    <th class='left'>판매사 사업자번호</th>
    <th class='left'>비고</th>
    <th class='left'>적용여부</th>
    <th>명령</th>
  </tr>
</thead>
<tbody>
<%
if (arrNoTradeCompanies!=null && arrNoTradeCompanies.size()>0) {
  for (CompanyNoTradeVO nv : arrNoTradeCompanies) {
%>
  <tr>
    <td width='*'>
      <%=StrUtil.nvl(nv.SELLER_NAME) %>
      <span class='mobile_show'> (<%=StrUtil.nvl(nv.SELLER_BIZ_NO) %>)</span>
      <div class='mobile_show'><br/><%=(nv.DEL_YN.equals("N"))?"적용":"미적용" %></div>
    <td class='mobile_hide'><%=FormatUtil.addDashBizNo(nv.SELLER_BIZ_NO) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(nv.ETC) %></td>
    <td class='mobile_hide <%=(nv.DEL_YN.equals("N") ? "emp": "")%>'><%=(nv.DEL_YN.equals("N"))?"적용":"미적용" %></td>
    <td class='center' width='70'>
      <a onclick='modifyNoTradeCompany("<%=nv.SEQNO %>");' class='btn lurian'>수정</a>
    </td>
  </tr>
<%
  }
} else { out.println("<tr><td colspan='5' class='noentry'>없음</td></tr>"); }
%>
</tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>MP수수료별도발행처</span>
  <span class='more'><a href='javascript:getMpfeeRegPage();' class='btn'>별도발행처등록/수정</a></span>
</div>

<ul class='detail'>
  <li class='th'>사업자 번호</li>
  <li class='td'><%=StrUtil.nvl(mpvo.BIZNO)%></li>
  <li class='th'>회사명</li>
  <li class='td'><%=StrUtil.nvl(mpvo.BIZNM)%></li>
  <li class='th'>대표자명</li>
  <li class='td'><%=StrUtil.nvl(mpvo.CEONM)%></li>
  <li class='th'>업태</li>
  <li class='td'><%=StrUtil.nvl(mpvo.BUSINESS_TYPE)%></li>
  <li class='th'>업종</li>
  <li class='td'><%=StrUtil.nvl(mpvo.INDUSTRY)%></li>
  <li class='th'>주소</li>
  <li class='td'>[<%=StrUtil.nvl(mpvo.ZIPCODE)%>] <%=StrUtil.nvl(mpvo.ADDR)%> <%=StrUtil.nvl(mpvo.ADDR2)%></li>
  <li class='th'>사용여부</li>
  <li class='td'><%="Y".equals(StrUtil.nvl(mpvo.USE_YN))? "사용":"미사용" %></li>
  <li class='th mobile_hide'></li>
  <li class='td mobile_hide'></li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>MP세금계산서 담당자</span>
  <span class='more'></span>
</div>

<ul class='detail'>
  <li class='th'>수신담당자</li>
  <li class='td'><%=cvo.MPTAX_USER_NM%></li>
  <li class='th'>수신메일</li>
  <li class='td'><%=cvo.MPTAX_EMAIL%></li>
</ul>

<p>&nbsp;</p>
<p>&nbsp;</p>

<div class='page-title-block'>
  <span class='subtitle'>추가담당자</span>
  <span class='more'></span>
</div>

<table class='detail'>
<thead class='mobile_hide'>
  <tr>
    <th class='left'>성명</th>
    <th class='left'>로그인아이디</th>
    <th class='left'>휴대전화</th>
    <th class='left'>일반전화</th>
    <th class='left'>이메일</th>
    <th class='left'>직위</th>
    <th class='left'>내선번호</th>
    <th>명령</th>
  </tr>
</thead>
<tbody>
<%
if (arrPersons!=null && arrPersons.size()>0) {
  for (PersonVO v : arrPersons) {
%>
  <tr>
    <td width='*'>
      <%=StrUtil.nvl(v.PRS_NAME) %>
      <span class='mobile_show'> (<%=StrUtil.nvl(v.PRS_LOGIN) %>)</span>
      <div class='mobile_show'><br/><%=StrUtil.nvl(v.PRS_MOBILE_NO) %></div>
      <div class='mobile_show'><br/><%=StrUtil.nvl(v.PRS_EMAIL) %></div>
    </td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_LOGIN) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_MOBILE_NO) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_TEL) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_EMAIL) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_PSTN) %></td>
    <td class='mobile_hide'><%=StrUtil.nvl(v.PRS_EXTN) %></td>
    <td class='center' width='70'>
      <a onclick='getManagerPage("<%=IntegerCryptoUtil.crypt(v.PRS_ID)%>");' class='btn lurian'>수정</a>
      <a onclick='removeManager("<%=IntegerCryptoUtil.crypt(v.PRS_ID)%>");' class='btn darkred'>삭제</a>
    </td>
  </tr>
<%
  }
} else { out.println("<tr><td colspan='8' class='noentry'>없음</td></tr>"); }
%>
</tbody>
</table>


<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>