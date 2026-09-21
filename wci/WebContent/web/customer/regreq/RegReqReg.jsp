<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.c.regreq.RegReqVO" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyNm = (String)pageContext.getAttribute("CPY_NM");

String strSeq  = StrUtil.nvl(request.getParameter("seq"));
boolean isEdit = !strSeq.isEmpty() && IntegerCryptoUtil.isEncrypted(strSeq);
String strAction = isEdit ? "수정" : "등록";

String strSellCpyName = StrUtil.input(request.getParameter("sellCpyName"));
String strSellPrsName = StrUtil.input(request.getParameter("sellPrsName"));
String strSellPhone   = StrUtil.input(request.getParameter("sellPhone"));
String strSellFax     = StrUtil.input(request.getParameter("sellFax"));
String strSellEmail   = StrUtil.input(request.getParameter("sellEmail"));
String strBizNo       = StrUtil.input(request.getParameter("bizNo"));
String strTradeDate   = StrUtil.input(request.getParameter("tradeDate"));
String strMemo        = StrUtil.input(request.getParameter("memo")).replaceAll("<br>", "\n");
String strFeePay      = StrUtil.nvl(request.getParameter("feePay"));
%>
<style>
/* 거래처추가/계약서작성 화면 등에서 재사용될 때도 박스 모양이 유지되게 !important로 강제 */
#element_to_pop_up {
  width:40vw !important;
  background-color:white !important;
  border-radius:15px !important;
  padding:20px 20px 60px !important;
  min-width:300px !important;
  min-height:480px !important;
  height:auto !important;
}
.bpopup-close-btn {clear:both;position:absolute;left:calc(50% - 10px);margin-top:15px;cursor:pointer;font-size:2em;}
</style>
<h3>판매기업 등록요청 <%=strAction%></h3>
<form name='frmRegReqReg'>
<input type='hidden' name='seq' value='<%=isEdit ? strSeq : ""%>'>
<ul class='form'>
  <li>
    <label>구매기업</label>
    <input type='text' value='<%=StrUtil.nvl(strCpyNm)%>' readonly>
  </li>
  <li>
    <label>판매기업명<span style='color:red;'>*</span></label>
    <input type='text' name='sellCpyName' value='<%=strSellCpyName%>' maxlength='100' required>
  </li>
  <li>
    <label>판매기업 담당자명</label>
    <input type='text' name='sellPrsName' value='<%=strSellPrsName%>' maxlength='20'>
  </li>
  <li>
    <label>판매기업 연락처<span style='color:red;'>*</span></label>
    <input type='text' name='sellPhone' value='<%=strSellPhone%>' maxlength='15' placeholder='- 없이 입력' required>
  </li>
  <li>
    <label>팩스</label>
    <input type='text' name='sellFax' value='<%=strSellFax%>' maxlength='15' placeholder='- 없이 입력'>
  </li>
  <li>
    <label>이메일</label>
    <input type='text' name='sellEmail' value='<%=strSellEmail%>' maxlength='100'>
  </li>
  <li>
    <label>판매기업 사업자번호<span style='color:red;'>*</span></label>
    <input type='text' name='sellCpyBusinessNo' value='<%=strBizNo%>' maxlength='10' placeholder='- 없이 입력' required>
  </li>
  <li>
    <label>거래예정일</label>
    <input type='date' name='tradeDate' value='<%=strTradeDate%>'>
  </li>
  <li>
    <label>수수료부담</label>
    <select name='feePay'>
      <option value=''>선택안함</option>
<%
for (Map.Entry<Integer, String> entry : RegReqVO.getFeePayMap().entrySet()) {
%>
      <option value='<%=entry.getKey()%>' <%= String.valueOf(entry.getKey()).equals(strFeePay) ? "selected" : "" %>><%=entry.getValue()%></option>
<%
}
%>
    </select>
  </li>
  <li class='wide' style='margin-top:10px;'>
    <label>비고</label>
    <textarea name='memo' maxlength='500' style='height:100px;width:calc(100% - 2px);padding:5px;margin-top:5px;'><%=strMemo%></textarea>
  </li>
  <li class='wide' style='margin-top:15px;text-align:center;'>
    <a onclick='goRegReqSubmit();' class='btn lurian'><%=strAction%></a>
  </li>
</ul>
</form>

<script>
function goRegReqSubmit() {
  if ($.trim(document.frmRegReqReg.sellCpyName.value) == '') {
    toast("판매기업명을 입력해주세요.");
    return;
  }
  if ($.trim(document.frmRegReqReg.sellPhone.value) == '') {
    toast("연락처를 입력해주세요.");
    return;
  }
  if ($.trim(document.frmRegReqReg.sellCpyBusinessNo.value) == '') {
    toast("사업자번호를 입력해주세요.");
    return;
  }
  var isEdit = document.frmRegReqReg.seq.value != '';
  var basePath = "<%=request.getContextPath()%>/web/customer/regreq/";
  var target = basePath + (isEdit ? "RegReqModProc.jsp" : "RegReqRegProc.jsp");
  $.post(target, $("form[name='frmRegReqReg']").serialize(), function(data) {
    if (data > 0) {
      location.href = basePath + "index.jsp";
    } else {
      toast((isEdit ? "수정" : "등록") + "하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
</script>

<!-- close -->
<i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
