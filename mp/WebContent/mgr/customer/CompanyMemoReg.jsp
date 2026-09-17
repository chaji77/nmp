<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.c.*" %>
<%
    request.setCharacterEncoding("utf-8");
    int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
    String strText = StrUtil.nvl(request.getParameter("txt"));
    if (intCpyId == 0) return;
    CustomerBean bean = new CustomerBean();
    String strCpyMemo = bean.COMPANY_MEMO_PROC(intCpyId);
    String strActionName = (!strCpyMemo.isEmpty()) ? "수정" : "등록";
%>

<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/static/plugin/select2.css?<%= DateTimeUtil.getCurrentResourceVersion() %>" />
<script type="text/javascript" src="<%= request.getContextPath() %>/static/js/ckeditor/ckeditor.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/static/plugin/select2.js?<%= DateTimeUtil.getCurrentResourceVersion() %>"></script>

<script>
    function writeMemo() {
       CKEDITOR.instances['contents'].updateElement(); 

        let serializedData = $("form[name='frmMemoReg']").serialize()
         $.post(strContextPath + "/mgr/customer/CompanyMemoRegProc.jsp", serializedData, function(data) {
        	 if (data != "0") {
                toast("<%=strActionName%>하였습니다.", 1000, function() {
                closePopup();
                window.location.reload();
                });
            } else {
                toast("<%=strActionName%>하지 못했습니다. 잠시 후 다시 시도하십시오.");
            }
        }); 
    }
    $(document).ready(function() {
        if (CKEDITOR.instances['contents']) {
            CKEDITOR.instances['contents'].on('instanceReady', function() {
                let memoContent = "<%= HtmlWhiteListUtil.filter(strCpyMemo).replace("\n", "\\n").replace("\"", "\\\"") %>";
                CKEDITOR.instances['contents'].setData(memoContent);
            });
        }
    });
   
</script>

<h3>특이사항</h3>

<form name="frmMemoReg" method="post" autocomplete="off">
<input type='hidden' name='cid' value='<%=intCpyId%>'>
    <ul>
        <li style="margin-top:5px;"></li>
        <li>&nbsp;</li>
        <li>
            <textarea name="txt" id="contents" style="height:300px;width:calc(100% - 2px);"></textarea>
        </li>
    </ul>

    <div class="btns">
        <a onclick="writeMemo();"><%=strActionName%></a>
    </div>
</form>


<script type="text/javascript" 
        src="<%= request.getContextPath() %>/static/js/CKEditorSetMini.js?<%= DateTimeUtil.getCurrentResourceVersion() %>">
</script>


<i class="fa-solid fa-xmark bpopup-close-btn" onclick="closePopup();"></i>
