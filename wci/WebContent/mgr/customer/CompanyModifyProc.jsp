<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("CompanyModifyProc.jsp");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
logger.debug(strCpyId);
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

boolean isError = false;
String strErrorMsg = "";
CompanyVO cvo = new CompanyVO();
PersonVO  pvo = new PersonVO();
try {
  cvo.CPY_ID = intCpyId;
  cvo.CPY_NAME = StrUtil.xss(request.getParameter("cpy_nm"));
  cvo.CPY_GUBUN = StrUtil.extractDigits(request.getParameter("cpy_type"), 1);
  cvo.CPY_CEO_NAME = StrUtil.xss(request.getParameter("cpy_ceo_nm"));
  cvo.CRG_ID = StrUtil.extractDigits(request.getParameter("biz_type"), 1);
  cvo.CPY_INCORPORATE_NO = StrUtil.extractDigits(request.getParameter("cpy_no"), 13);
  cvo.BUSINESS_TYPE = StrUtil.xss(request.getParameter("uptae"));
  cvo.INDUSTRY = StrUtil.xss(request.getParameter("upzong"));
  cvo.CPY_ZIPCODE = StrUtil.extractDigits(request.getParameter("basic_zipcode"), 5);
  cvo.CPY_ADDR = StrUtil.xss(request.getParameter("basic_addr"));
  cvo.CPY_ADDR2 = StrUtil.xss(request.getParameter("basic_addr_b"));
  cvo.CPY_FAX = StrUtil.xss(request.getParameter("fax")); 
  cvo.CPY_BUSINESS_DESC = StrUtil.xss(request.getParameter("desc"));
  cvo.CPY_BUSINESS_NO = StrUtil.xss(request.getParameter("bizno"));
  cvo.CPY_FOUNDYEAR = StrUtil.extractDigits(request.getParameter("found_ymd"), 8);
  cvo.MP_CODE = ConfigurationMgr.getInstance().getString("OWNER_MPCODE");
  cvo.MPTAX_USER_NM = StrUtil.xss(request.getParameter("tax_nm"));
  cvo.MPTAX_EMAIL = StrUtil.xss(request.getParameter("tax_email"));

  cvo.BIZ_DOC_FILE_URL = StrUtil.nvl(request.getParameter("file"));
  if (cvo.BIZ_DOC_FILE_URL.indexOf("____________________")>-1) cvo.BIZ_DOC_FILE_URL = cvo.BIZ_DOC_FILE_URL.split("____________________")[0];
  else cvo.BIZ_DOC_FILE_URL = "";

  pvo.PRS_ID = StrUtil.nvl(request.getParameter("prs_id"), "0");
  pvo.PRS_NAME = StrUtil.xss(request.getParameter("login_nm"));
  pvo.PRS_TEL = StrUtil.xss(request.getParameter("login_tel"));
  pvo.PRS_MOBILE_NO = StrUtil.xss(request.getParameter("login_cell_tel"));
  pvo.PRS_SMS = StrUtil.nvl(request.getParameter("sms_yn"), "0");
  pvo.PRS_EMAIL = StrUtil.xss(request.getParameter("login_email"));

  cvo.SALES_AMT = StrUtil.extractAndFormat(StrUtil.nvl(request.getParameter("sale_amt"), "0").replaceAll("[^0-9]", ""), 13, 3);
  
  if (!isError && !cvo.CPY_GUBUN.equals("1") && !cvo.CPY_GUBUN.equals("2") && !cvo.CPY_GUBUN.equals("3")) {
    strErrorMsg = "회원구분을 확인하십시오.";
    isError = true;
  }
  
  if (!isError && !cvo.CRG_ID.equals("1") && !cvo.CRG_ID.equals("2")) {
    strErrorMsg = "법인/개인사업자 구분을 확인하십시오.";
    isError = true;
  }
  
  if (!isError && cvo.CRG_ID.equals("1") && cvo.CPY_BUSINESS_NO.length()!=10) {
	    strErrorMsg = "사업자등록번호를 확인할 수 없습니다.";
	    isError = true;
  }
  
  if (!isError && cvo.CRG_ID.equals("1") && cvo.CPY_INCORPORATE_NO.length()!=13) {
    strErrorMsg = "법인번호를 확인할 수 없습니다.";
    isError = true;
  }
  
  if (!isError && cvo.CRG_ID.equals("1") && cvo.CPY_ZIPCODE.length()!=5) {
    strErrorMsg = "주소를 확인할 수 없습니다.";
    isError = true;
  }
  
  if (!isError && cvo.CPY_ID>0) {
    CustomerBean bean = new CustomerBean();
    intCpyId = bean.COMPANY_MOD_PROC(cvo, pvo);
    if (intCpyId==0) {
      isError = true;
      strErrorMsg = "수정할 수 없습니다.";
    }
  }
  
} catch (Exception e) {
  logger.error(e.toString());
  isError = true;
  strErrorMsg = "수정할 수 없습니다. 다시 시도하십시오. 문제가 지속되면 고객센터로 문의바랍니다.";
}

if (isError) {
  logger.error(strErrorMsg);
  logger.error(cvo.toString());
  logger.error(pvo.toString());
}
%>
<script>
parent.btnSubmitIsClicked = false;
parent.hideLoading();
<% if (isError) { %>
parent.showAlert("<%=strErrorMsg%>", function(){});
<% } else { %>
parent.callback();
<% } %>
</script>