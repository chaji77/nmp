<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = StrUtil.nvl(request.getParameter("cid"));
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cid")));
else return;

String strTargetCpyId = StrUtil.nvl(request.getParameter("targetId"));
int intTargetCpyId = 0;
if (IntegerCryptoUtil.isEncrypted(strTargetCpyId)) {
  intTargetCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(strTargetCpyId));
}
int intResult = 0;
if (intTargetCpyId>0) {
  try {
    intResult = new CustomerBean().CT_MYCOMPANY_DROP_PROC(intCpyId, intTargetCpyId);
  } catch (Exception e) {
    e.printStackTrace();
  }
}
out.print(intResult);
%>