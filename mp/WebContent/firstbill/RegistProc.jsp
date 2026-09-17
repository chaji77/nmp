<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%!
void dropRegistInfo(int intCpyId) {
  BillUserDAO.BILL_USER_DROP_PROC(intCpyId);
}
%>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("RegistProc.jsp");
logger.debug(StrUtil.nvl(request.getParameter("bizno")));
/*
ArrayList<String> parameterNames = new ArrayList<String>();
Enumeration<String> enumeration = request.getParameterNames();
while (enumeration.hasMoreElements()) {
  String strParameter = (String) enumeration.nextElement();
  System.out.println(strParameter +" : " + request.getParameter(strParameter));
}
*/
int intUserSeq  = 0;
int intResult   = 0;
boolean isError = false;
String strErrorMsg = "";
BillUserVO cvo = new BillUserVO();
try {
  cvo.CPY_ID = 0;
  cvo.CORPNUM = StrUtil.extractDigits(request.getParameter("bizno"), 10);
  cvo.CORPNAME = StrUtil.xss(request.getParameter("cpy_nm"));
  cvo.CEONAME = StrUtil.xss(request.getParameter("cpy_ceo_nm"));
  cvo.BIZTYPE = StrUtil.xss(request.getParameter("uptae"));
  cvo.BIZCLASS = StrUtil.xss(request.getParameter("upzong"));
  cvo.ADDR1 = StrUtil.xss(request.getParameter("basic_addr"));
  cvo.ADDR2 = StrUtil.xss(request.getParameter("basic_addr_b"));
  cvo.MEMBERNAME = StrUtil.xss(request.getParameter("login_nm"));
  cvo.EMAIL = StrUtil.xss(request.getParameter("login_email"));
  cvo.ID = StrUtil.xss(request.getParameter("login_id"));
  cvo.PWD = StrUtil.nvl(request.getParameter("login_pw"));
  cvo.TEL = StrUtil.xss(request.getParameter("login_tel"));
  
  if (!isError && cvo.CORPNUM.length()!=10) {
    strErrorMsg = "사업자번호를 확인할 수 없습니다.";
    isError = true;
  }
 
  if (!isError) {
    int intDuplicated = BillUserDAO.BILL_CORPNUM_CHECK_PROC(cvo.CORPNUM);
    if (intDuplicated>0) {
      isError = true;
      strErrorMsg = "이미 가입된 사업자입니다.";
    }
    if (intDuplicated==0) {
      intDuplicated = BillUserDAO.BILL_ID_CHECK_PROC(cvo.ID);
      if (intDuplicated>0) {
        isError = true;
        strErrorMsg = "이미 가입된 아이디입니다.";
      }
    }
    if (intDuplicated==0) {
      intUserSeq = BillUserDAO.BILL_USER_ADD_PROC(cvo);
      if (intUserSeq==0) {
        isError = true;
        strErrorMsg = "가입할 수 없습니다. 고객센터로 문의바랍니다.";
      } else {
        BillUserVO v = BillUserDAO.BILL_USER_DETAIL_PROC(intUserSeq);
        BaroBill b   = new BaroBill(v);
        intResult    = b.RegistCorp();
        System.out.println("RegistCorp : " + intResult);
        if (intResult!=1) {
          isError = true;
          if (intResult == -32000) {
            intResult = b.AddUserTopCorp();
            System.out.println("AddUserTopCorp : " + intResult);
            if (intResult==1) isError = false;
            else {
              dropRegistInfo(v.CPY_ID);
              if (intResult==-32015) strErrorMsg = "서비스 공급업자에 이미 이용 중인 아이디입니다.<br/>다른 아이디를 이용하십시오.";
              else strErrorMsg = "이용할 수 없습니다.<br/>다른 연계사와 연계되어 있습니다.";
            }
          }
          else if (intResult == -32017) {
            dropRegistInfo(v.CPY_ID);
            strErrorMsg = "사용할 수 없는 아이디입니다.";
          } else {
            dropRegistInfo(v.CPY_ID);
            strErrorMsg = "가입할 수 없습니다.<br/>오류번호는 "+intResult+"입니다.<br/>오류번호로 고객센터에 문의바랍니다.";
          }
        }
      }
    }
  }
  
} catch (Exception e) {
  logger.error(e.toString());
  isError = true;
  strErrorMsg = "가입할 수 없습니다. 다시 시도하십시오. 문제가 지속되면 고객센터로 문의바랍니다.";
}

if (isError) {
  logger.error(strErrorMsg);
  logger.error(cvo.toString());
}
%>
<script>
parent.btnSubmitIsClicked = false;
parent.hideLoading();
<% 
  if (isError) {
    if (intResult==-32015) out.println("parent.initDuplicateCheck();");
    out.println("parent.showAlert('"+strErrorMsg+"', function(){});");
  } else { 
    out.println("parent.callback();");
  } 
%>
</script>