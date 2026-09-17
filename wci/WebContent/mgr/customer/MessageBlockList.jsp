<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.kakaotalk.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
BlockVO pvo  = new BlockVO();
pvo.CPY_ID   = StrUtil.nvl(request.getParameter("cpy_id"), "0");
pvo.PAGE     = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT  = 20;
pvo.CPY_NAME = "";
pvo.PHONE_NO = "";
pvo.EMAIL    = "";
String strCpyNm  = StrUtil.nvl(request.getParameter("cpy_nm"));

ArrayList<BlockVO> arr = null;
String strActionCode = StrUtil.nvl(request.getParameter("page_type"), "list");
if (!strActionCode.equals("list")) pvo.PAGE = 1;
if (strActionCode.equals("drop")) {
  arr = BlockBean.COMPANY_SMS_MAIL_BLOCK_DROP_PROC(pvo);
  pvo.PAGE = 1;
  strCpyNm = "";
  pvo.CPY_ID = "0";
}
else if (strActionCode.equals("add")) {
  pvo.PAGE = 1;
  pvo.REG_NM = (String)pageContext.getAttribute("SESS_MGR_NM");
  arr = BlockBean.COMPANY_SMS_MAIL_BLOCK_ADD_PROC(pvo);
}
else arr = BlockBean.COMPANY_SMS_MAIL_BLOCK_LIST_PROC(pvo);


int intTotalCnt  = 0;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>문자/메일전송차단관리</title>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/pop.js"></script>

<script>
function goPage(p) {
  document.frmSearch.page_type.value = "list";
  document.frmSearch.page.value = p;
  document.frmSearch.action = "MessageBlockList.jsp";
  document.frmSearch.submit();
}
function add() {
  document.frmSearch.page_type.value = "add";
  document.frmSearch.action = "MessageBlockList.jsp";
  document.frmSearch.submit();
}
function drop(cid) {
  document.frmSearch.page_type.value = "drop";
  document.frmSearch.cpy_id.value = cid;
  document.frmSearch.action = "MessageBlockList.jsp";
  document.frmSearch.submit();
}

function searchCompany() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch.cpy_id.value = $(obj).attr("cid");
  document.frmSearch.cpy_nm.value = $(obj).text();
  closePopup();
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>문자/메일전송차단관리</span>
  <span class='more'>
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='page_type' value='list'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cpy_id' value='<%=pvo.CPY_ID%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>회원사</label>
          <input type='search' name='cpy_nm' readOnly placeholder='회원사' onclick='searchCompany();' onchange='goPage(1);' value='<%=strCpyNm%>'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='MessageBlockList.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>
<p><i class="fa fa-asterisk" aria-hidden="true"></i> 추가등록하시려면, 먼저 검색하십시오.</p>
<p>&nbsp;</p>

<table style='border-top:2px solid #ddd;min-width:100%;'>
  <thead class='mobile_hide'>
    <tr>
      <th class='left'>회사명</th>
      <th class='left'>사업자번호</th>
      <th class='left'>등록자</th>
      <th class='left'>등록일시</th>
      <th class='right'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (BlockVO vo : arr) {
    intTotalCnt = vo.TOTAL_CNT;
%>
    <tr class='mobile_hide'>
      <td><%=vo.CPY_NAME %></td>
      <td><%=FormatUtil.addDashBizNo(vo.CPY_BUSINESS_NO) %></td>
      <td><%=vo.REG_NM %></td>
      <td><%=vo.REG_DT %></td>
      <td class='right'>
        <a class='btn darkred' onclick='drop(<%=vo.CPY_ID %>)'>삭제</a>
      </td>
    </tr>
<%
  }
} else {
  if (!pvo.CPY_ID.equals("0")) {
%>
    <tr>
      <td colspan='5' style='text-align:center;height:200px;'>
        <%=strCpyNm %><br/><br/>
        <a onclick='add();' class='btn'>차단등록</a>
      </td>
    </tr>
<%
  }
}
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>