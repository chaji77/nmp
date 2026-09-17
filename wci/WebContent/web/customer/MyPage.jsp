<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mgr.customer.BusinessPersonVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strCpyId    = (String)pageContext.getAttribute("CPY_ID");
int intCpyId = 0;
if (StrUtil.isOnlyNumeric(strCpyId)) intCpyId = Integer.parseInt(strCpyId);
else return;

CustomerBean bean = new CustomerBean();
CompanyVO cvo = bean.COMPANY_DETAIL_PROC(intCpyId);
ArrayList<PersonVO> arrPersons = bean.PERSON_LIST_PROC(intCpyId);
if (arrPersons==null || arrPersons.size()==0 || arrPersons.get(0).PRS_ID==null) return;
//구매사관리 담당자정보
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

ArrayList<RelationCompanyVO> arrRelationCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intCpyId, "N");

if (cvo.CPY_FOUNDYEAR.length()==8 && StrUtil.isOnlyNumeric(cvo.CPY_FOUNDYEAR)) cvo.CPY_FOUNDYEAR = FormatUtil.addSeparatorDate(cvo.CPY_FOUNDYEAR, ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR"));
%>
<%@ include file="../includes/Header.jsp" %>
<!-- page head block -->
<title>마이페이지</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
span.bullet i {vertical-align:middle;font-size:3em;color:hotpink;margin-right:10px;}
span.alert {text-align:justify;padding-top:3px;line-height:1.4em;}
@media only screen and (max-width:767px) {
  span.alert {padding-top:0;}
}
</style>
<script>

$(document).ready(function(){

});

</script>
<!-- // page head block -->
<%@ include file="../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>마이페이지</span>
  <span class='more'>
    <a href='Managers.jsp' class='btn white'>계정관리로 이동</a>
  </span>
</div>

<div style='display:flex;'>
  <span class='bullet'><i class="fa fa-exclamation-circle" aria-hidden="true"></i></span>
  <span class='alert'>
    <font color='darkred'>전년도 매출액 및 전자세금계산서 상의 정보와 불일치할 경우 거래가 제한</font>될 수 있습니다. <strong>사업자등록증</strong>과 <strong>결산자료</strong>를 기준으로 정확한 정보를 유지하십시오.<br/>
    <strong>비밀번호 수정</strong>은 <a href='Managers.jsp' style='border-bottom:1px solid #555;'>계정관리</a>에서 가능합니다. 
  </span>
</div>


<div class='page-title-block' style='margin-bottom:15px;'>
  <span class='subtitle'>회원정보</span>
  <span class='more'>
    <a href='Modify.jsp' class='btn lurian'>회원정보수정</a>
  </span>
</div>

<ul class='detail'>
  <li class='th'>사업자등록번호</li>
  <li class='td'><%=FormatUtil.addDashBizNo(cvo.CPY_BUSINESS_NO) %></li>
  <li class='th'>회사명</li>
  <li class='td'><%=cvo.CPY_NAME%></li>
  <li class='th'>회사구분</li>
  <li class='td'>
  <%
  if (cvo.CPY_GUBUN.equals("1")) out.print("구매사");
  else if (cvo.CPY_GUBUN.equals("2")) out.print("판매사");
  else out.print("구매&amp;판매사");
  %>
  </li>
  <li class='th'>대표자명</li>
  <li class='td'><%=cvo.CPY_CEO_NAME%></li>
  <li class='th'>기업형태</li>
  <li class='td'>
  <%
  if (cvo.CRG_ID.equals("1")) out.print("법인사업자");
  else out.print("개인사업자");
  %>
  </li>
  <li class='th'>법인등록번호</li>
  <li class='td'><%=cvo.CPY_INCORPORATE_NO%></li>
  <li class='th'>업태</li>
  <li class='td'><%=cvo.BUSINESS_TYPE%></li>
  <li class='th'>종목</li>
  <li class='td'><%=cvo.INDUSTRY%></li>
  <li class='th'>주소</li>
  <li class='td'>[<%=cvo.CPY_ZIPCODE%>] <%=cvo.CPY_ADDR%> <%=cvo.CPY_ADDR2%></li>
  <li class='th'>팩스번호</li>
  <li class='td'><%=cvo.CPY_FAX%></li>
  <li class='th'>설립일</li>
  <li class='td'><%=cvo.CPY_FOUNDYEAR%></li>
  <li class='th'>전년도매출액</li>
  <li class='td'><span style='color:#FF5733;'><%=StrUtil.addComma(cvo.SALES_AMT) %> (백만원)</span></li>
  <li class='th'>담당자명</li>
  <li class='td'><%=pvo.PRS_NAME%> (<%=pvo.PRS_LOGIN%>)</li>
  <li class='th'>메일주소</li>
  <li class='td'><%=pvo.PRS_EMAIL%></li>
  <li class='th'>일반전화번호</li>
  <li class='td'><%=pvo.PRS_TEL %></li>
  <li class='th'>휴대전화번호</li>
  <li class='td'><%=pvo.PRS_MOBILE_NO%></li>
</ul>

<div class='page-title-block' style='margin-bottom:15px;'>
  <span class='subtitle'>MP수수료 세금계산서 정보</span>
</div>

<ul class='detail'>
  <li class='th'>수신담당자</li>
  <li class='td'><%=cvo.MPTAX_USER_NM%></li>
  <li class='th'>수신메일</li>
  <li class='td'><%=cvo.MPTAX_EMAIL%></li>
</ul>

<div class='page-title-block' style='margin-bottom:15px;'>
  <span class='subtitle'>부가정보</span>
</div>

<ul class='detail'>
  <li class='th'>확인결제</li>
  <li class='td'><%=(cvo.CONFIRM_SETTLE_YN.equals("Y"))?"신청":"미신청" %></li>
  <li class='th'>월합세금계산서</li>
  <li class='td'><%=(cvo.MPTAX_MONTH_USE_YN.equals("Y"))?"신청":"미신청" %></li>
  <li class='th'>스크랩 거래</li>
  <li class='td'><%=(cvo.CU_USE_YN.equals("Y"))?"거래 기업으로 등록":"취급하지 않음" %></li>
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
  %></li>
  <li class='th'>모바일 승인</li>
  <li class='td'><%=(cvo.MOBILE_YN.equals("Y"))?"신청":"미신청" %></li>
  <li class='th'>계약서 역발행</li>
  <li class='td'><%=(cvo.REVERSE_YN.equals("Y"))?"신청":"미신청" %></li>
</ul>

<p style='margin-top:10px;'><i class="fa-solid fa-circle-exclamation" style='color:hotpink;'></i> 부가정보는 관리자의 확인 및 등록이 필요합니다. 고객센터(<a href='tel:<%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %>'><%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></a>)로 문의하십시오.</p>

<p>&nbsp;</p>
<p>&nbsp;</p>

<%@ include file="../includes/Footer.jsp" %>