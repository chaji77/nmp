<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.UploadUtil"%>
<%@ page import="kr.co.mp.c.qna.QnaBean" %>
<%@ page import="kr.co.mp.c.qna.QnaVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>

<%
request.setCharacterEncoding("utf-8");

if (request.getHeader("referer").indexOf("qna/QnaReg.jsp") < 0) {
    response.sendRedirect(request.getContextPath());
}

String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strFileTimeStamp = Long.toString(System.currentTimeMillis());
QnaVO vo = new QnaVO(); 
QnaBean bean = new QnaBean();

vo  = bean.C_QNA_DETAIL_PROC(vo.SEQ); 
int mid = Integer.parseInt(request.getParameter("mid"));
vo.SEQ          = mid;
vo.MGR_ID       = (int) pageContext.getAttribute("SESS_MGR_ID");
vo.A_CONTENTS   = StrUtil.nvl(request.getParameter("editor"));
vo.ANS_YN       = StrUtil.nvl(request.getParameter("answered"));

// DB에 저장
if ("N".equals(vo.ANS_YN)) vo.SEQ = bean.C_QNA_ADD_PROC(vo);
else bean.C_QNA_MOD_PROC(vo);



if (vo.SEQ > 0) {
%>
<script>
location.href = "Qnas.jsp?id=<%=IntegerCryptoUtil.crypt(vo.SEQ)%>";
</script>
<%
}
%>