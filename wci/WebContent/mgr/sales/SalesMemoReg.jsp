<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%
request.setCharacterEncoding("utf-8");
String strMemoId = StrUtil.nvl(request.getParameter("mid"), "0");
boolean isEditMode = !strMemoId.equals("0");
String strActionTag = isEditMode ? "수정" : "등록";
int intCid = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String strEncCpyId = IntegerCryptoUtil.crypt(intCid);
%>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js"></script>
<div style='width:100%;'>
<h3>메모 <%=strActionTag %></h3>
<form name='frmMemoReg'>
<input type='hidden' name='cid' value='<%=StrUtil.nvl(request.getParameter("cid"), "0")%>'>
<input type='hidden' name='mid' value='<%=strMemoId %>'>
<input type='hidden' name='contents_html' value=''>
<ul class='form'>
  <li class='wide'>
    <label style='display:block;margin-bottom:8px;'>내용</label>
    <textarea id='contents' style='height:300px;width:calc(100% - 2px);padding:5px;'></textarea>
  </li>
  <li style='margin-top:15px;'>
    <a onclick='registMemo();' class='btn lurian'><%=strActionTag %></a>
  </li>
</ul>
</form>
</div>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/CKEditorSetMini.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type="text/javascript">
function sizeMemoPopup() {
  $("#element_to_pop_up").css({width:"80vw"});
  $(window).trigger("resize"); // bPopup 자체 재정렬 로직(중앙정렬 포함)을 강제로 다시 태움
}
sizeMemoPopup();
setTimeout(sizeMemoPopup, 300); // bPopup 초기 오픈 애니메이션 이후 다시 한번 적용
<% if (isEditMode) { %>
if (typeof memoContents !== 'undefined' && memoContents[<%=strMemoId %>]!=null) {
  CKEDITOR.instances['contents'].setData(memoContents[<%=strMemoId %>]);
}
<% } %>
function registMemo() {
  var strContents = CKEDITOR.instances['contents'].getData();
  if ($.trim(strContents.replace(/<[^>]*>/g, "")) == "") {
    toast("내용을 입력해주세요.");
    return;
  }
  document.frmMemoReg.contents_html.value = strContents;
  var strTarget = <%=isEditMode %> ? "SalesMemoModProc.jsp" : "SalesMemoRegProc.jsp";
  $.post(strTarget, $("form[name='frmMemoReg']").serialize(), function(data) {
    if (data>0) {
      toast("성공했습니다.", 2000, function() {
        $("#element_to_pop_up").load("<%=request.getContextPath()%>/mgr/sales/SalesMemoPerCustomer.jsp?cpy_id=<%=strEncCpyId%>&popup=1");
      });
    } else {
      toast("<%=strActionTag %>하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
</script>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
