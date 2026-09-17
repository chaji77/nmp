<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
QnaBean bean = new QnaBean();
QnaVO   vo   = new QnaVO();
vo.SEQ = 0;

String strId = StrUtil.nvl(request.getParameter("mid"), "0");
if (IntegerCryptoUtil.isEncrypted(strId)) {
  int intseq = Integer.parseInt(IntegerCryptoUtil.crypt(strId));
  vo  = bean.C_QNA_DETAIL_PROC(intseq);
} else {
  response.sendRedirect("index.jsp"); 
  return; 
}

int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
if (intCpyId != vo.CPY_ID) {
  out.println("<script>alert('자신의 문의만 삭제할 수 있습니다.');location.href='index.jsp';</script>");
  return;
}
bean.C_QNA_DROP_PROC(vo);
%>
<script>
location.href='index.jsp';
</script>