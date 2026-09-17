<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("RelationCompanyRegProc.jsp");

String seqNo = request.getParameter("seqNo");
seqNo = seqNo!="" ? seqNo : null;

boolean isError = false;
String strErrorMsg = "";

int intResult = -1;

RelationCompanyVO pvo = new RelationCompanyVO();

try {
	pvo.CPY_ID = StrUtil.nvl(request.getParameter("cid"), "0");
	pvo.RELATIONBIZNO = StrUtil.nvl(request.getParameter("bizno"));
	pvo.USE_YN = StrUtil.nvl(request.getParameter("useYN"));
	pvo.CRETIME = DateTimeUtil.getCurrentDateTime();
	pvo.CREUSER = (String) pageContext.getAttribute("SESS_MGR_NM");
	pvo.LASTTIME = DateTimeUtil.getCurrentDateTime();
	pvo.LASTUSER = (String) pageContext.getAttribute("SESS_MGR_NM");
	pvo.PRO_RESULT = StrUtil.getParameter(StrUtil.xss(request.getParameter("result")), "", 400);
	pvo.LOANTYPE = StrUtil.nvl(request.getParameter("loanType"));
	
	if (!isError && pvo.RELATIONBIZNO.length() != 10) {
		strErrorMsg = "사업자번호를 정확히 입력해주세요.";
		isError = true;
	}
	
	if (!isError && !pvo.LOANTYPE.equals("KODIT") && !pvo.LOANTYPE.equals("KIBO") && !pvo.LOANTYPE.equals("KOREG") && !pvo.LOANTYPE.equals("NOGUAR")) {
		strErrorMsg = "기금을 선택해주세요.";
		isError = true;
	}
	
	if (!isError && !pvo.USE_YN.equals("Y") && !pvo.USE_YN.equals("N")) {
		strErrorMsg = "사용유무를 선택해주세요.";
		isError = true;
	}
	
	if (!isError && pvo.CPY_ID != "0") {
		MgrCustomerBean bean = new MgrCustomerBean();
		
		if (seqNo != null) {
			pvo.SEQNO = seqNo;
			pvo.LASTTIME = DateTimeUtil.getCurrentDateTime();
			pvo.LASTUSER = (String) pageContext.getAttribute("SESS_MGR_NM");
			intResult = bean.M_RELATION_COMPANY_MOD_PROC(pvo);
		} else intResult = bean.M_RELATION_COMPANY_ADD_PROC(pvo);
	}
} catch(Exception e) {
	  logger.error(e.toString());
	  isError = true;
	  strErrorMsg = "다시 시도하십시오. 문제가 지속되면 고객센터로 문의바랍니다.";
}

  if (isError) out.print(strErrorMsg);
%>