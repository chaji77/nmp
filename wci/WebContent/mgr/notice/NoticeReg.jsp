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
String strActionName = "등록";

NoticeBean bean = new NoticeBean();
NoticeVO   vo   = new NoticeVO();
ArrayList<NoticeAttachVO> arrAttach = null;
vo.SEQ = 0;

if (IntegerCryptoUtil.isEncrypted(request.getParameter("id"))) {
  vo.SEQ = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("id")));
  vo  = bean.C_NOTICE_DETAIL_PROC(vo.SEQ);
  arrAttach = bean.C_NOTICE_ATTACH_LIST_PROC(vo.SEQ);
  strActionName = "수정";
}

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

<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
<script type='text/javascript' src="<%=request.getContextPath() %>/static/js/uploader.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>

<script type="text/javascript">
<!--

//for upload
<%
if (arrAttach!=null && arrAttach.size()>0) {
  out.print("var oFiles = [");
  for (NoticeAttachVO wf : arrAttach) {
    String size = Long.toString(Long.parseLong(StrUtil.nvl(wf.FILE_SIZE, "0"))/1024);
    out.print("['" + StrUtil.nvl(wf.FILE_URL) + "','" + StrUtil.nvl(wf.FILE_NM) + "', '"+StrUtil.nvl(wf.FILE_SIZE, "0")+"','" + size + "'],");
  }
  out.print("];");
} else {
  out.println("var oFiles;");
}
%>
var urlUpload = "UploadFileProc.jsp";
var urlDragDrop = "DragUploadFileProc.jsp";

$(document).ready(function(){
  $("input[name='strStartYmd'], input[name='strEndYmd']").datepicker({changeYear:true,changeMonth:true,dateFormat:"yy<%=strDateSeparator%>mm<%=strDateSeparator%>dd"});
  initUploadForm(urlUpload, urlDragDrop, oFiles); // for upload
  $(document).on("keyup", "input[type='number']", function() {
    $(this).val( $(this).val().replace(/[^0-9]/gi,"") );
    var maxlength = $(this).attr("maxlength");
    if ($(this).val().length>maxlength) $(this).val($(this).val().substring(0,maxlength));
  });
});

function changeNumber(obj) {
    $(this).val( $(this).val().replace(/[^0-9]/gi,"") );
    var maxlength = $(this).attr("maxlength");
    if ($(this).val().length>maxlength) $(this).val($(this).val().substring(0,maxlength));
}

function checkPopupSchedule() {
  var sh = $("input[name='strStartHour']").val();
  var s = $("input[name='strStartYmd']").val() + $("input[name='strStartHour']").val() + $("input[name='strStartMin']").val();
}

function goSubmit() {
  if (check()==true) {
    showLoading();

    $("input[id='file']").each(function(){ // for upload
      this.checked = true;
    });

    document.frmEnt.action  = "./NoticeRegProc.jsp";
    document.frmEnt.method  = "post";
    // document.frmEnt.enctype = "multipart/form-data";
    document.frmEnt.submit();
  }
}

 function check() {
  document.frmEnt.title.value = $.trim(document.frmEnt.title.value.replace(/(<([^>]+)>)/ig,""));
  if (document.frmEnt.title.value.trim().length<2) {
    toast("제목을 입력하십시오.");
    document.frmEnt.title.focus();
    return false;
  }
  document.frmEnt.editor.value = CKEDITOR.instances['contents'].getData();
  return true;
}

//-->
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>공지사항 <%=strActionName%></span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<form name='frmEnt' id='frmEnt' autocomplete="off">
<input type='hidden' name='seq' value='<%=IntegerCryptoUtil.crypt(vo.SEQ)%>'>
<input type='hidden' name='editor' value=''>
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
      <td colspan='3'><input type='text' name='title' maxlength='50' value='<%=StrUtil.input(vo.TITLE) %>'></td>
    </tr>
    <tr>
      <th>팝업게시여부</th>
      <td><input type='checkbox' name='popup_yn' value='Y' <%=(StrUtil.nvl(vo.POPUP_YN, "N").equals("Y"))?"checked":"" %>> 게시</td>
      <th>팝업게시일정</th>
      <td><input type='text' name='strStartYmd' value='<%=strStartYmd %>' class='popup_item' style='width:100px;'>
          <input type='time' name='strStartHm'  value='<%=strStartHm%>' maxlength='5' class='popup_item' style='width:110px;'>
          ~
          <input type='text' name='strEndYmd'  value='<%=strEndYmd %>'  class='popup_item' style='width:100px;'>
          <input type='time' name='strEndHm'   value='<%=strEndHm%>' maxlength='5' class='popup_item' style='width:110px;'>
      </td>
    </tr>
    <tr>
      <th>팝업크기</th>
      <td colspan='3'>
        <input type='number' name='popup_width'  value='<%=vo.POPUP_WIDTH %>' min='0' class='popup_item' style='width:120px;' placeholder='너비'>
        <input type='number' name='popup_height' value='<%=vo.POPUP_HEIGHT %>' min='0' class='popup_item' style='width:120px;' placeholder='높이'>
      </td>
    </tr>
    <tr>
      <th style='border-bottom:0;'>첨부파일</th>
      <td colspan='3' class='dragdropplace' style='border-bottom:0;'></td>
    </tr>
  </tbody>
</table>
<div><textarea id="contents" style="height:400px;width:calc(100% - 2px);"><%=StrUtil.nvl(vo.CONTENTS) %></textarea></div>
</form>
<div class='btns'>
  <a href='javascript:goSubmit();'><%=strActionName%></a>
  <a onclick='history.go(-1);' class='cancel'>취소</a>
</div>

<%=WebPageCtrlUtil.getHistoryBack(session) %>

<iframe name="work" id="work" height="0" width="0" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>
<script type="text/javascript" src='<%=request.getContextPath() %>/static/js/CKEditorSet.js?<%=DateTimeUtil.getCurrentResourceVersion() %>' charset='utf-8'></script>
