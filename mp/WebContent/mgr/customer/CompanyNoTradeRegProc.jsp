<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeVO" %>
<%@ page import="kr.co.mp.mgr.customer.CompanyNoTradeBean" %>
<%
request.setCharacterEncoding("utf-8");
/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("customer/Company.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

String seqNo = request.getParameter("seqNo");
seqNo = seqNo!="" ? seqNo : null;

CompanyNoTradeVO pvo = new CompanyNoTradeVO();
CompanyNoTradeBean bean = new CompanyNoTradeBean();
int intResult = -1;

pvo.BUYER_BIZ_NO = StrUtil.nvl(request.getParameter("buyerBizNo"));
pvo.BUYER_NAME = StrUtil.nvl(request.getParameter("buyerName"));
pvo.SELLER_BIZ_NO = StrUtil.nvl(request.getParameter("bizno"));
pvo.SELLER_NAME = StrUtil.nvl(request.getParameter("sellerName"));
pvo.ETC = StrUtil.getParameter(StrUtil.xss(request.getParameter("etc")), "", 1000);
pvo.DEL_YN = StrUtil.nvl(request.getParameter("yn"), "N");

if (seqNo!=null) {
	pvo.SEQNO = seqNo;
	intResult = bean.M_COMPANY_NO_TRADE_MOD_PROC(pvo);
} else {
	intResult = bean.M_COMPANY_NO_TRADE_ADD_PROC(pvo);
}
out.print(intResult);
%>