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

QnaVO vo = new QnaVO();
System.out.println(vo.toString());
String strSeq         = StrUtil.nvl(request.getParameter("id"), "0");
vo.SEQ                = (StrUtil.isOnlyNumeric(strSeq))?Integer.parseInt(strSeq) : 0;

QnaBean qnaBean = new QnaBean();
int result = qnaBean.C_QNA_DROP_PROC(vo);

%>
<script>
  location.href = "Qnas.jsp";
</script>
