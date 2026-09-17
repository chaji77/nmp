<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.mp.c.faq.FAQVO" %>
<%@ page import="kr.co.mp.c.faq.FAQBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intResult = -1;

/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("faq/FAQs.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

String strId = request.getParameter("id");
strId = (IntegerCryptoUtil.isEncrypted(strId)) ? IntegerCryptoUtil.crypt(strId) : null;

if(strId!=null) {
	FAQVO vo = new FAQVO();
	vo.SEQ                = Integer.parseInt(strId);
	vo.REG_ID             = (int) pageContext.getAttribute("SESS_MGR_ID");
	intResult = new FAQBean().C_FAQ_DROP_PROC(vo);
}
out.print(intResult);
%>