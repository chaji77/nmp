<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoVO" %>
<%@ page import="kr.co.mp.c.mpfee.CompanyMpFeeInfoBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%@ page import="kr.co.mp.c.*" %>
<%
response.setCharacterEncoding("UTF-8");
int intResult = -1;
String cid = request.getParameter("cid");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
CompanyMpFeeInfoBean bean = new CompanyMpFeeInfoBean();

String bizno = request.getParameter("bizno");
String biznm = request.getParameter("biznm");
String ceonm = request.getParameter("ceonm");
String business_type = request.getParameter("business_type");
String industry = request.getParameter("industry");
String zipcode = request.getParameter("basic_zipcode");
String addr = request.getParameter("basic_addr");
String addr2 = request.getParameter("basic_addr2");
String regid = String.valueOf(pageContext.getAttribute("SESS_MGR_ID"));
String use_yn = request.getParameter("use_yn");

int cpyId = -1;
if (cid != null && !cid.trim().isEmpty()){
	cpyId = Integer.parseInt(cid);
}

CompanyMpFeeInfoVO mpvo = new CompanyMpFeeInfoVO();
mpvo.BIZNO = bizno;
mpvo.BIZNM = biznm;
mpvo.CEONM = ceonm;
mpvo.BUSINESS_TYPE = business_type;
mpvo.INDUSTRY = industry;
mpvo.ZIPCODE = zipcode;
mpvo.ADDR = addr;
mpvo.ADDR2 = addr2;
mpvo.USE_YN = use_yn;
mpvo.REG_ID = regid;
mpvo.CPY_ID = Integer.parseInt(cid);

CompanyMpFeeInfoVO exMpfeeInfo = bean.COMPANY_MPFEE_INFO_PROC(cpyId);
int result = 0;
if ( exMpfeeInfo.CPY_ID == 0) {
    result = bean.COMPANY_MPFEE_INFO_ADD_PROC(mpvo);  
} else {
    result = bean.COMPANY_MPFEE_INFO_MOD_PROC(mpvo);
} 
out.print(intResult);
%>
