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

/* 작성페이지에서 접근하지 않으면 튕겨낸다 */
if (request.getHeader("referer").indexOf("notice/NoticeReg.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strFileTimeStamp = Long.toString(System.currentTimeMillis());      // 내용을 저장할 파일명을 TIMESTAMP로 처리
NoticeVO vo = new NoticeVO(); // 저장할 내용을 담을 VO 선언
StringBuffer xmlFiles   = new StringBuffer();
try {
  String[] arrFiles = request.getParameterValues("file");
  String PIMS_SEPARATOR           = "____________________";
  
  StringBuffer sb = new StringBuffer();
  if(arrFiles!=null && arrFiles.length>0){
    for (int i=0; i<arrFiles.length; i++) {
      String[] arr = arrFiles[i].split(PIMS_SEPARATOR);
      String[] arr2 = arr[0].split("/");
      String strFileName = arr2[arr2.length-1];
      sb.append("<NODE FILE_NM='"+strFileName.replaceAll("&", "&amp;")+"' FILE_SIZE='"+arr[1]+"' FILE_URL='"+arr[0].replaceAll("&", "&amp;")+"'/>");
    }
    xmlFiles = sb;
  }
} catch(Exception e) {}

/* DB에 저장할 내용을 VO에 저장 */
String strSeq         = IntegerCryptoUtil.crypt(StrUtil.nvl(request.getParameter("seq")));
vo.SEQ                = (StrUtil.isOnlyNumeric(strSeq))?Integer.parseInt(strSeq) : 0;
vo.TITLE              = StrUtil.nvl(request.getParameter("title"));
vo.REG_ID             = (int) pageContext.getAttribute("SESS_MGR_ID");
vo.POPUP_YN           = StrUtil.nvl(request.getParameter("popup_yn"));
vo.POPUP_WIDTH        = Integer.parseInt(StrUtil.nvl(request.getParameter("popup_width"), "0"));
vo.POPUP_HEIGHT       = Integer.parseInt(StrUtil.nvl(request.getParameter("popup_height"), "0"));
vo.POPUP_START_YMDHM  = StrUtil.nvl(request.getParameter("strStartYmd")).replaceAll(strDateSeparator, "") + StrUtil.nvl(request.getParameter("strStartHm")).replaceAll(":", "");
vo.POPUP_END_YMDHM    = StrUtil.nvl(request.getParameter("strEndYmd")).replaceAll(strDateSeparator, "") + StrUtil.nvl(request.getParameter("strEndHm")).replaceAll(":", "");
vo.FILES              = xmlFiles.toString();
vo.CONTENTS           = StrUtil.nvl(request.getParameter("editor"));

System.out.println(vo.toString());

/* DB에 저장 */
NoticeBean bean       = new NoticeBean();
if (vo.SEQ==0) vo.SEQ = bean.C_NOTICE_ADD_PROC(vo);
else bean.C_NOTICE_MOD_PROC(vo);

if (vo.SEQ>0) {
%>
<script>
  location.href = "Notice.jsp?id=<%=IntegerCryptoUtil.crypt(vo.SEQ)%>";
</script>
<%
}
%>
