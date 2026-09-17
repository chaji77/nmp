<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strTargetCpyId = StrUtil.nvl(request.getParameter("cid"));
int intTargetCpyId = 0;
if (IntegerCryptoUtil.isEncrypted(strTargetCpyId)) {
  intTargetCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(strTargetCpyId));
}
int intResult = 0;
if (intTargetCpyId>0) {
  try {
    int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
    intResult = new CustomerBean().CT_MYCOMPANY_DROP_PROC(intCpyId, intTargetCpyId);
  } catch (Exception e) {
    e.printStackTrace();
  }
}
out.print(intResult);
%>