<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeAttachVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%
// 로그인이 필요하면 true로 변경하세요.
// @require LoginCheck.jsp
// pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strPage = (StrUtil.nvl(request.getParameter("page"), "1")).replaceAll("-", "");

NoticeBean bean = new NoticeBean();
NoticeVO   vo   = new NoticeVO();
ArrayList<NoticeAttachVO> arrAttach = null;
vo.SEQ = 0;

if (IntegerCryptoUtil.isEncrypted(request.getParameter("nid"))) {
  vo.SEQ = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("nid")));
  vo  = bean.C_NOTICE_DETAIL_PROC(vo.SEQ);
  arrAttach = bean.C_NOTICE_ATTACH_LIST_PROC(vo.SEQ);
} else return;

String strStartYmdhi = StrUtil.nvl(vo.POPUP_START_YMDHM, DateTimeUtil.getCurrentDate("")+"0000");
String strEndYmdhi   = StrUtil.nvl(vo.POPUP_END_YMDHM,   DateTimeUtil.getCurrentDate("")+"0000");
String strStartYmd   = FormatUtil.addSeparatorDate(strStartYmdhi.substring(0, 8));
String strStartHm    = strStartYmdhi.substring(8, 10) + ":" + strStartYmdhi.substring(10, 12);
String strEndYmd     = FormatUtil.addSeparatorDate(strEndYmdhi.substring(0, 8));
String strEndHm      = strEndYmdhi.substring(8, 10) + ":" + strEndYmdhi.substring(10, 12);
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>공지사항</title>
<style>
td {white-space:wrap;}
td.article {padding:40px 20px !important;}
@media only screen and (max-width:767px) {
  td.article {padding:10px;}
}
</style>
<script type="text/javascript">
<!--

//-->
</script>

<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>공지사항</span>
  <span class='more'>
    <a href='Notices.jsp?page=<%=strPage %>' class='btn'>목록</a>
  </span>
</div>

<table class="form list detail" summary="Registration Form">
  <colgroup>
  <col width="100px" class='mobile_hide' />
  <col width="*" />
  </colgroup>
  <tbody>
    <tr>
      <th class='mobile_hide'>제　　목</th>
      <td><strong><%=StrUtil.input(vo.TITLE) %></strong></td>
    </tr>
    <tr>
      <th class='mobile_hide'>등 &nbsp;록 &nbsp;일</th>
      <td><strong><%=(StrUtil.input(vo.REG_DT).split(" ")[0]).replaceAll("-", strDateSeparator) %></strong></td>
    </tr>
    <tr>
      <td colspan='2' class='article'><%=StrUtil.nvl(vo.CONTENTS).replaceAll("&quot;", "'") %></td>
    </tr>
    <%
    if (arrAttach!=null && arrAttach.size()>0) {
    %>
    <tr>
      <th style='border-bottom:0;'>첨부파일</th>
      <td>
        <ul>
        <%
        for (NoticeAttachVO wf : arrAttach) {
          String size = Long.toString(Long.parseLong(StrUtil.nvl(wf.FILE_SIZE, "0"))/1024);
          out.print("<li><a href='" + StrUtil.nvl(wf.FILE_URL) + "'>" + StrUtil.nvl(wf.FILE_NM) + "</a></li>");
        }
        %>
        </ul>
      </td>
    </tr>
    <%
    }
    %>
  </tbody>
</table>

<%@ include file="../../includes/Footer.jsp" %>
