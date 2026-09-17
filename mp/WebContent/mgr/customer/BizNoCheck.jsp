<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeBean" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt(request.getParameter("cpyId"));
String strBizNo = StrUtil.nvl(request.getParameter("bizno"));
if (strBizNo.length()==10) {
	String sellerName = new CompanyNoTradeBean().M_COMPANY_SELLER_NAME_CHECK_PROC(intCpyId, strBizNo);
	out.print(sellerName);
}
%>