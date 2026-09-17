<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.mp.c.faq.FAQBean" %>
<%@ page import="kr.co.mp.c.faq.FAQVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>

<%
request.setCharacterEncoding("utf-8");
int intResult = -1;
String strId = request.getParameter("id");
strId = (IntegerCryptoUtil.isEncrypted(strId)) ? IntegerCryptoUtil.crypt(strId) : null;

/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("faq/FAQReg.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

FAQVO vo = new FAQVO(); // 저장할 내용을 담을 VO 선언

String strCAT_ID = request.getParameter("category");
vo.CAT_ID	= StrUtil.isOnlyNumeric(strCAT_ID) ? Integer.parseInt(strCAT_ID) : 0;
vo.TITLE  	= StrUtil.nvl(request.getParameter("title"));
vo.CONTENTS = StrUtil.nvl(request.getParameter("editor"));
vo.REG_ID   = (int) pageContext.getAttribute("SESS_MGR_ID");

FAQBean bean = new FAQBean();

if (strId!=null) {
	vo.SEQ = Integer.parseInt(strId);
	intResult = bean.C_FAQ_MOD_PROC(vo);
} else {
	intResult = bean.C_FAQ_ADD_PROC(vo);
}

out.print(intResult);
%>