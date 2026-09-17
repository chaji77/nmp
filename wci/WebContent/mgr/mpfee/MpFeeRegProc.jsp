<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("MpFeeRegProc.jsp");
/*
ArrayList<String> parameterNames = new ArrayList<String>();
Enumeration<String> enumeration = request.getParameterNames();
while (enumeration.hasMoreElements()) {
  String strParameter = (String) enumeration.nextElement();
  System.out.println(strParameter +" : " + request.getParameter(strParameter));
  // System.out.println("= StrUtil.nvl(request.getParameter(\""+strParameter+"\"));");
}
*/
CommissionVO pvo         = new CommissionVO();
pvo.CPY_BUYER            = StrUtil.nvl(request.getParameter("buyer_id"));
pvo.CPY_SELLER           = StrUtil.nvl(request.getParameter("seller_id"));
pvo.PAY_CPY              = StrUtil.nvl(request.getParameter("pay_cpy"), "B");
pvo.PAY_GUBUN            = StrUtil.nvl(request.getParameter("pay_gubun"), "10");
pvo.COMM_METHOD          = StrUtil.nvl(request.getParameter("pay_method"), "A10");

pvo.STD_DAYS             = StrUtil.nvl(request.getParameter("std_days"), "0");
pvo.MTY_STDAYS           = StrUtil.nvl(request.getParameter("mty_stdays"), "0");
pvo.MTY_ENDDAYS          = StrUtil.nvl(request.getParameter("mty_enddays"), "0");
pvo.CPY_COMMISSION_RATE1 = StrUtil.extractAndFormat(request.getParameter("cpy_commission_rate1"), 5, 3);
pvo.CPY_COMMISSION_RATE2 = StrUtil.extractAndFormat(request.getParameter("cpy_commission_rate2"), 5, 3);

pvo.DISCOUNT_RATE        = StrUtil.extractAndFormat(request.getParameter("discount_rate"), 6, 3);
pvo.COMM_DESC            = StrUtil.nvl(request.getParameter("comm_desc")).replaceAll("\r", "<br>");
pvo.CPY_COMMISSION_RATE  = StrUtil.extractAndFormat(request.getParameter("cpy_commission_rate"), 5, 3);
pvo.RECEIVE_MONEY        = StrUtil.nvl(request.getParameter("receive_money"), "0");
pvo.OFFLINE_YN           = StrUtil.nvl(request.getParameter("offline_yn"), "N");

pvo.MAX_YN               = StrUtil.nvl(request.getParameter("max_yn"), "N");
pvo.MODID                = (String) pageContext.getAttribute("SESS_LOGIN_ID");
pvo.START_DT             = StrUtil.nvl(request.getParameter("symd")).replace("-", "");
pvo.END_DT               = StrUtil.nvl(request.getParameter("eymd")).replace("-", "");

pvo.COMM_ID              = Integer.parseInt(StrUtil.nvl(request.getParameter("comm_id"), "0"));

//String strReturnCpyId    = (pvo.PAY_CPY.equals("B")) ? IntegerCryptoUtil.crypt(pvo.CPY_BUYER) : IntegerCryptoUtil.crypt(pvo.CPY_SELLER);
String strReturnCpyId    = IntegerCryptoUtil.crypt(pvo.CPY_BUYER);
logger.debug(pvo.toString());
if (pvo.COMM_ID==0) {
  int intCommId = new CommissionBean().INFO_COMMISSION_ADD_PROC(pvo);
  if (intCommId>0) out.print(strReturnCpyId);
  else out.print(intCommId);
} else {
  new CommissionBean().INFO_COMMISSION_MOD_PROC(pvo);
  out.print(strReturnCpyId);
}
%>