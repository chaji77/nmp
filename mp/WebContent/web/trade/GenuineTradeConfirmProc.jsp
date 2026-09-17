<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.AbnormalTransactionDAO" %>
<%
request.setCharacterEncoding("utf-8");
int intCtId     = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));
String strGubun = StrUtil.nvl(request.getParameter("gubun"));
int intCnt = 0;
if (StrUtil.nvl(request.getParameter("sgn_id")).equals("0000")) {
  String strSignData = StrUtil.nvl(request.getParameter("signdata"));
  if (strSignData.length()>0) {
    intCnt = AbnormalTransactionDAO.UNUSUAL_TRANSACTION_KD001_RELEASE_ADD_PROC(intCtId, strGubun, strSignData);
  }
}
out.print(intCnt);
%>