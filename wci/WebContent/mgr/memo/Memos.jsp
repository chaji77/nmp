<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

int intTotalCnt = 0;
String strMyYn = StrUtil.nvl(request.getParameter("my"), "N");
String strManagerId = (String) pageContext.getAttribute("SESS_LOGIN_ID");

MemoVO pvo      = new MemoVO();
pvo.PAGE        = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT     = 20;
pvo.CPY_ID      = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.TO_USER_ID  = (strMyYn.equals("Y")) ? strManagerId : "";
pvo.ACTIVE_DESC = StrUtil.nvl(request.getParameter("kw"), "");
pvo.WRITE_ID    = StrUtil.nvl(request.getParameter("w"));
String strCpyNm = StrUtil.nvl(request.getParameter("cpy_nm"));

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("ACTIVE_MANAGEMENT.ACTIVE_KIND");
ArrayList<MemoVO> arrMemos = new MemoBean().ACTIVE_MANAGEMENT_LIST_PROC(pvo);

ManagerVO pmvo = new ManagerVO();
pmvo.PAGE      = 1;
pmvo.ROW_CNT   = 1000;
pmvo.USER_NM   = "";
ArrayList<ManagerVO> arrManager = new ManagerBean().M_MANAGER_LIST_PROC(pmvo);

%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>메모(상담)관리</title>
<style>
table.detail td {vertical-align:top;}
span.to {color:darkgreen;font-weight:bold;}
</style>
<script>
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "Memos.jsp";
  document.frmSearch.target = "_top";
  document.frmSearch.submit();
}
function editMemo(intCpyId, intActiveId) {
  closePopup();
  //$("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/mgr/memo/MemoReg.jsp?cid='+intCpyId+'&aid='+intActiveId});
  var strUrl = strContextPath+'/mgr/memo/MemoReg.jsp?cid='+intCpyId+'&aid='+intActiveId;
  window.open(strUrl, "_memo_", 'width=500,height=900,scrollbars=yes,resizable=no');
}
function dropMemo(aid) {
  showCustomConfirm("삭제하시겠습니까?", function() {
    $.post(strContextPath + "/mgr/memo/MemoDropProc.jsp", {'aid':aid}, function(data) {
      if (data!="0") {
        toast("삭제하였습니다.", 1000, function() {
          window.location.reload();
        });
      } else {
        toast("삭제하지 못했습니다. 잠시 후 다시 시도하십시오.");
      }
    });
  }, function() {});
}

function searchCompany() {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/customer/CompaniesForPopup.jsp'});
}
function choiceCompany(obj) {
  document.frmSearch.cid.value = $(obj).attr("cid");
  document.frmSearch.cpy_nm.value = $(obj).text();
  closePopup();
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
<%
if (arrMemos!=null && arrMemos.size()>0) {
  for (MemoVO t : arrMemos) {
    if (t.COMMENT_YN.equals("Y")) {
%>
  loadComments(<%=t.ACTIVE_ID %>);
<%
    }
  }
}
%>
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>메모(상담)관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'>검색</a>
  </span>
</div>

<form name='frmSearch' method="post" autocomplete="off">
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cid' value='<%=pvo.CPY_ID%>'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>회원사</label>
          <input type='search' name='cpy_nm' readOnly placeholder='회원사' onclick='searchCompany();' onchange='goPage(1);' value='<%=strCpyNm%>'>
        </li>
        <li>
          <label>내용검색</label>
          <input type='search' name='kw' placeholder='내용검색' onchange='goPage(1);' value='<%=pvo.ACTIVE_DESC%>' maxlength='30'>
        </li>
        <li>
          <label>작성자</label>
          <select name='w' onchange='goPage(1);'>
            <option value=''>전체　　　　　　　　　</option>
          <%
          if (arrManager!=null && arrManager.size()>0) {
            for (ManagerVO m : arrManager) {
              out.print("<option value='"+m.LOGIN_ID+"'");
              if (pvo.WRITE_ID.equals(m.LOGIN_ID)) out.print(" selected");
              out.println(">"+m.USER_NM+"</option>");
            }
          }
          %>
          </select>
        </li>
        <li>
          <label></label>
          <input type='checkbox' name='my' value='Y' onclick='goPage(1);' <%=(strMyYn.equals("Y"))?" checked":"" %> style='width:auto !important;min-width:0;'> 나에게 온 메모
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'>
      <a onclick='javascript:goPage(1);'><i class="fa-solid fa-magnifying-glass" style='font-size:1.7em;margin-right:10px;'></i></a>
      <a href='Memos.jsp'><i class="fa-solid fa-rotate-right" style='font-size:1.7em;margin-right:10px;'></i></a>
    </td>
  </tr>
</tbody>
</table>
</form>

<%
if (pvo.CPY_ID>0) {
%>
<div style='padding:10px 0 20px 0;text-align:right;'>
  <%=strCpyNm %> <a onclick='getMemoWindow(<%=pvo.CPY_ID%>);' class='btn' style='padding:10px'>메모 등록</a>
</div>
<%
}
%>

<table class='detail'>
  <thead>
    <tr>
      <th class='left mobile_hide'>분류</th>
      <th class='left mobile_hide'>회사명</th>
      <th class='left mobile_hide'>사업자번호</th>
      <th class='left'>내용</th>
      <th class='left mobile_hide'>작성자</th>
      <th class='mobile_hide'>작성일시</th>
      <th class='left' style='width:10%;'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arrMemos!=null && arrMemos.size()>0) {
  String strCodeName = "";
  for (MemoVO t : arrMemos) {
    intTotalCnt = t.TOTAL_CNT;
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO c : arrCodes) {
        if (c.CODE_CD.trim().equals(t.ACTIVE_KIND.trim())) strCodeName = c.CODE_NM;
      }
    }
    String strDesc = HtmlWhiteListUtil.filter(t.ACTIVE_DESC).replaceAll("&quot;", "");
    if (!pvo.ACTIVE_DESC.equals("")) strDesc = strDesc.replaceAll(pvo.ACTIVE_DESC, "<mark>"+pvo.ACTIVE_DESC+"</mark>");
    String toUser  = StrUtil.nvl(t.TO_USER_NM, "");
    if (!toUser.equals("")) toUser = "<span class='to'><i class='fa-solid fa-location-dot'></i> "+toUser+"</span> ";
%>
    <tr id='memo_row_<%=t.ACTIVE_ID %>'>
      <td class='mobile_hide'><%=strCodeName %></td>
      <td class='mobile_hide'><a href='<%=request.getContextPath() %>/mgr/customer/Company.jsp?cpy_id=<%=IntegerCryptoUtil.crypt(t.CPY_ID) %>'><%=t.CPY_NAME %></a></td>
      <td class='mobile_hide'><%=FormatUtil.addDashBizNo(t.CPY_BUSINESS_NO) %></td>
      <td style='white-space:wrap;'><div class='mobile_show'><%=strCodeName %><br/><%=t.USER_NM  %> (<%=t.WRITE_DATE.substring(0, 16) %>)<br/></div><%=toUser%><%=strDesc %></td>
      <td class='mobile_hide'><%=t.USER_NM  %></td>
      <td class='center mobile_hide'><%=t.WRITE_DATE.substring(0, 16) %></td>
      <td class='left'>
        <a href='<%=request.getContextPath() %>/mgr/memo/MemosPerCustomer.jsp?cpy_id=<%=IntegerCryptoUtil.crypt(t.CPY_ID) %>' class='btn'>상세</a>
        <a onclick='addComment(<%=t.ACTIVE_ID %>);' class='btn'>댓글추가</a><div class='mobile_show'><br><br></div>
        <% if (strManagerId.equals(t.WRITE_ID)) { %>
        <a onclick='editMemo(<%=t.CPY_ID %>, <%=t.ACTIVE_ID %>);' class='btn lurian'>수정</a>
        <a onclick='dropMemo(<%=t.ACTIVE_ID %>);' class='btn darkred'>삭제</a>
        <% } %>
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