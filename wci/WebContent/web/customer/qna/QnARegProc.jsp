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
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
QnaVO vo = new QnaVO(); 
QnaBean bean = new QnaBean();
vo.SEQ          = Integer.parseInt(StrUtil.nvl(request.getParameter("mid"), "0"));
vo.Q_TITLE      = StrUtil.xss(request.getParameter("title"));
vo.CPY_ID       = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
vo.REG_NM       = (String)pageContext.getAttribute("USER_LOGIN");
vo.Q_CONTENTS   = StrUtil.nvl(request.getParameter("contents"));

// DB에 저장
if (vo.SEQ == 0) vo.SEQ = bean.C_QNA_CUSTOMER_ADD_PROC(vo);
else bean.C_QNA_CUSTOMER_MOD_PROC(vo);
%>
<script>
location.href = "index.jsp";
</script>
