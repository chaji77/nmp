<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.notice.NoticeVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeAttachVO" %>
<%@ page import="kr.co.mp.c.notice.NoticeBean" %>
<%
ArrayList<NoticeVO> arrPopups = new NoticeBean().removeNoticeExcluded(request);

if (arrPopups!=null && arrPopups.size()>0) {
%>
<style>
div.layer-popup-block {
  max-width: 100%;
  position: fixed;
  top: 230px;
  margin: 0;
  z-index: 3;
}
ul.layer-popup {
  display: flex;
  flex-flow: row wrap;
  justify-content: left;
}
ul.layer-popup li {
  z-index: 200;
  padding: 20px;
  /* border: 1px solid #888; */
  background-color: white;
  margin-right: 10px;
  margin-bottom: 10px;
  min-width: 200px;
  min-height: 200px;
  max-width: 500px;
  max-height: 500px;
  text-align: left;
  box-shadow: 0 3px 6px rgba(0,0,0,0.1), 0 3px 6px rgba(0,0,0,0.2);
}
</style>
<script>
/* 팝업창닫기 */
function closePopupNotice(obj, booAllDayOption) {
  if (booAllDayOption) {
    var nid = $(obj).parent().parent().attr("nid");
    var max_age = 60*60*24;
    document.cookie = "exclude_nid_"+(Date.now())+"="+nid+"; path=<%=request.getContextPath()%>; max-age="+max_age;
  }
  $(obj).parent().parent().remove();
}
function goNoticeAtPopupNotice(obj) {
  location.href = "<%=request.getContextPath()%>/web/customer/notice/Notice.jsp?nid=" + $(obj).parent().attr("nid");
}
</script>

<div class='layer-popup-block'>
  <ul class='layer-popup'>
<%
  for (NoticeVO nvo : arrPopups) {
   int w = nvo.POPUP_WIDTH + 20;
   int h = nvo.POPUP_HEIGHT + 68;
%>
  <li style='width:<%=w %>px;height:<%=h %>px;position:relative;' nid='<%=IntegerCryptoUtil.crypt(nvo.SEQ)%>'>
    <div style='width:100%;height: 34px;'><span class='more close' onclick='closePopupNotice(this, false);'></span></div>
    <div style='padding: 0 4px; height:<%=(h - 58) %>px;overflow: auto;cursor:pointer;' onclick='goNoticeAtPopupNotice(this);'><%=StrUtil.removeHrefAttribute(StrUtil.nvl(nvo.CONTENTS)).replaceAll("&quot;", "'") %></div>
    <div style='position:absolute;bottom: 10px;height: 24px;'><input type='checkbox' onclick='closePopupNotice(this, true);'> 하루동안 열지 않기</div>
  </li>
<%
  }
%>
  </ul>
</div>
<%
}
%>