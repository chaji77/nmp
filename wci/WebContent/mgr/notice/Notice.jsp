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
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");

NoticeBean bean = new NoticeBean();
NoticeVO   vo   = new NoticeVO();
ArrayList<NoticeAttachVO> arrAttach = null;
vo.SEQ = 0;

String strId = StrUtil.nvl(request.getParameter("id"), "0");
if (IntegerCryptoUtil.isEncrypted(strId)) {
  vo.SEQ = Integer.parseInt(IntegerCryptoUtil.crypt(strId));
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
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>공지사항관리</title>

<script type="text/javascript">
<!--
function goPage(c) {
  var page = (c==1) ? "NoticeReg.jsp" : "NoticeDropProc.jsp";
  if (c==1) {
    document.frmEnt.action = page;
    document.frmEnt.submit();
  } else {
    showCustomConfirm("정말 삭제할까요?", function() {
      document.frmEnt.action = page;
      document.frmEnt.submit();
	}, function(){});
  }
}
//-->
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>공지사항</span>
  <span class='more'>
    <a onclick='goHistoryBack();' class='btn'>목록</a>
    <a onclick='goPage(1);' class='btn lurian'>수정</a>
    <a onclick='goPage(2);' class='btn darkred'>삭제</a>
  </span>
</div>

<form name='frmEnt' method='post'>
<input type='hidden' name='id' value='<%=strId%>'>
</form>

<table class="form list detail" summary="Registration Form">
  <colgroup>
  <col width="100px" />
  <col width="40%" />
  <col width="100px" />
  <col width="*" />
  </colgroup>
  <tbody>
    <tr>
      <th>제목</th>
      <td colspan='3'><%=StrUtil.input(vo.TITLE) %></td>
    </tr>
    <tr>
      <th>팝업게시여부</th>
      <td><%=(StrUtil.nvl(vo.POPUP_YN, "N").equals("Y"))?"게시":"" %></td>
      <th>팝업게시일정</th>
      <td><%=strStartYmd %> <%=strStartHm%> ~ <%=strEndYmd %> <%=strEndHm%></td>
    </tr>
    <tr>
      <th>팝업크기</th>
      <td colspan='3'><%=vo.POPUP_WIDTH %> * <%=vo.POPUP_HEIGHT %></td>
    </tr>
    <tr>
      <th style='border-bottom:0;'>첨부파일</th>
      <td colspan='3'>
        <ul>
        <%
        if (arrAttach!=null && arrAttach.size()>0) {
          for (NoticeAttachVO wf : arrAttach) {
            String size = Long.toString(Long.parseLong(StrUtil.nvl(wf.FILE_SIZE, "0"))/1024);
            out.print("<li><a href='" + StrUtil.nvl(wf.FILE_URL) + "'>" + StrUtil.nvl(wf.FILE_NM) + "</a></li>");
          }
        }
        %>
        </ul>
      </td>
    </tr>
    <tr>
      <td colspan='4'><%=StrUtil.nvl(vo.CONTENTS).replaceAll("&quot;", "'") %></td>
    </tr>
  </tbody>
</table>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<%@ include file="../Footer.jsp" %>
