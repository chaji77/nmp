<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.UploadUtil"%>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

NoticeVO vo = new NoticeVO();
String strSeq         = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("id")));
vo.SEQ                = (StrUtil.isOnlyNumeric(strSeq))?Integer.parseInt(strSeq) : 0;
vo.REG_ID             = (int) pageContext.getAttribute("SESS_MGR_ID");
vo.USE_YN             = "N";

/* DB에 저장 */
new NoticeBean().C_NOTICE_MOD_PROC(vo);

%>
<script>
  location.href = "Notices.jsp";
</script>
