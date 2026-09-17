<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cid");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cid")));
else return;

String[] payId = StrUtil.nvl(request.getParameter("payId")).split("xx");
String bankCode = payId[0];
String paymentId = payId[1];

String action = StrUtil.nvl(request.getParameter("action"));

int intResult = -1;
PayMethodVO pvo = new PayMethodVO();
pvo.CPY_ID 		= intCpyId;
pvo.BNK_CD 		= bankCode;
pvo.PAY_ID 		= paymentId;
pvo.CPY_GUAR_SEQ = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));
pvo.WRITE_ID	= (String)session.getAttribute("SESS_LOGIN_ID");

if (action.equals("extend")) intResult = new GuaranteeBean().GUARANTEE_MASTER_INFO_EXTEND_PROC(pvo);
else if (action.equals("drop")) intResult = new GuaranteeBean().GUARANTEE_MASTER_INFO_DROP_PROC(pvo);
out.print(intResult);
%>