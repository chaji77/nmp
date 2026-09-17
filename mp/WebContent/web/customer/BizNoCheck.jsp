<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
String strBizNo = StrUtil.nvl(request.getParameter("bizno"));
if (strBizNo.length()==10) {
  int intCpyId = new CustomerBean().COMPANY_BIZNO_CHECK_PROC(strBizNo);
  if (intCpyId>0) out.print("Y");
  else out.print(IntegerCryptoUtil.crypt(strBizNo));
}
else out.print("E");
%>