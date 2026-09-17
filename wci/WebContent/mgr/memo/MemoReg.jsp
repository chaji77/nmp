<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%@ page import="com.google.gson.Gson" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String strText = StrUtil.nvl(request.getParameter("txt"));
if (intCpyId==0) return;

//ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("ACTIVE_MANAGEMENT.ACTIVE_KIND");
ArrayList<CodeVO> arrCategoryCodes = new MemoBean().M_COMPANY_MEMO_CATEGORY_LIST_PROC();
ArrayList<CodeVO> arrLoanCategoryCodes = new ArrayList<CodeVO>();
ArrayList<CodeVO> arrGurCategoryCodes = new ArrayList<CodeVO>();
ArrayList<CodeVO> arrEtcCategoryCodes = new ArrayList<CodeVO>();
ArrayList<CodeVO> arrMemoCategoryCodes = new ArrayList<CodeVO>();
for (CodeVO vo : arrCategoryCodes) {
  if (vo.MEMO_CATEGORY.equals("LON")) arrLoanCategoryCodes.add(vo);
  else if (vo.MEMO_CATEGORY.equals("GUR")) arrGurCategoryCodes.add(vo);
  else if (vo.MEMO_CATEGORY.equals("ETC")) arrEtcCategoryCodes.add(vo);
  else if (vo.MEMO_CATEGORY.equals("MEMO")) arrMemoCategoryCodes.add(vo);
}

Gson gson = new Gson();
String jsonCodeList = gson.toJson(arrCategoryCodes);
String jsonLonList = gson.toJson(arrLoanCategoryCodes);
String jsonGurList = gson.toJson(arrGurCategoryCodes);
String jsonEtcList = gson.toJson(arrEtcCategoryCodes);
String jsonMemoList = gson.toJson(arrMemoCategoryCodes);

ManagerVO pvo = new ManagerVO();
pvo.PAGE      = 1;
pvo.ROW_CNT   = 2000;
pvo.USER_NM   = "";
ArrayList<ManagerVO> arrManagers = new ManagerBean().M_MANAGER_LIST_PROC(pvo);

boolean isEditMode = false;
MemoVO mvo = new MemoVO();
if (request.getParameter("aid")!=null) {
  mvo = new MemoBean().ACTIVE_MANAGEMENT_DETAIL_PROC(Integer.parseInt(request.getParameter("aid")));
  isEditMode = true;
}
String strActionTag = (!isEditMode) ? "등록":"수정";
%>
<%@ include file="../Header.jsp" %>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/plugin/select2.css?<%=DateTimeUtil.getCurrentResourceVersion()%>"/>
<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/ckeditor/ckeditor.js"></script>
<script type='text/javascript' src="<%=request.getContextPath()%>/static/plugin/select2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<script type='text/javascript'>
var categories  = <%=jsonCodeList%>;
var lonCategory = <%=jsonLonList%>;
var gurCategory = <%=jsonGurList%>;
var etcCategory = <%=jsonEtcList%>;
var memoCategory = <%=jsonMemoList%>;
function setSelectOptions(options, value) {
  var select = $("select[name='active_kind']");
  select.empty();
  
  options.forEach(function(item) {
	var option = $('<option></option>').val(item.CODE_CD).text(item.CODE_NM);
	select.append(option);
  });
  
  select.val(value).trigger('change');	
}
function getCategoryOptions(category) {
  switch (category) {
  case 'LON':
	return { options: lonCategory, radioIndex: 0 };
  case 'GUR':
	return { options: gurCategory, radioIndex: 1 };
  case 'ETC':
	return { options: etcCategory, radioIndex: 2 };
  case 'MEMO':
	return { options: memoCategory, radioIndex: 3 };
  default:
	return { options: [], radioIndex: -1 };
  }
}
function setRadioAndCategory(category) {
  var { options, radioIndex } = getCategoryOptions(category);
  if (radioIndex >= 0) {
	$("input[name='code_type']").eq(radioIndex).prop("checked", true);
  }
  setSelectOptions(options, options[0].CODE_CD);
}
function readCategory() {
  var activeKind = categories.find(function(item) {
	return item.CODE_CD == <%=mvo.ACTIVE_KIND%>;
  });
  setRadioAndCategory(activeKind.MEMO_CATEGORY);
  
  var select = $("select[name='active_kind']");
  select.val(<%=mvo.ACTIVE_KIND%>).trigger('change');
}
function changeCategory(category) {
  var options = [];
  switch (category) {
  case 1:
	options = lonCategory;
	break;
  case 2:
	options = gurCategory;
	break;
  case 3:
	options = etcCategory;
	break;
  case 4:
	options = memoCategory;
	break;
  default:
	options = [];
  }
  setSelectOptions(options, options[0].CODE_CD);
}
function writeMemo() {
  document.frmMemoReg.active_desc.value = CKEDITOR.instances['contents'].getData();
  console.log(document.frmMemoReg.active_desc.value);
  $.post(strContextPath + "/mgr/memo/MemoRegProc.jsp", $("form[name='frmMemoReg']").serialize(), function(data) {
    if (data!="0") {
      toast("<%=strActionTag%>하였습니다.", 1000, function() {
        // closePopup();
        // if ($(".memo-page").is(":visible")) window.location.reload();
        window.close();
        window.opener.location.reload();
      });
    } else {
      toast("<%=strActionTag%>하지 못했습니다. 잠시 후 다시 시도하십시오.");
    }
  });
}
function fill() {
  $("input[name='aid']").val(<%=mvo.ACTIVE_ID%>);
  $("input[name='call_type'][value='" + <%=mvo.CALL_TYPE%> + "']").prop("checked", true);
  <%-- $("#contents").val("<%=mvo.ACTIVE_DESC%>"); --%>
  $("select[name='to_user_id']").val("<%=mvo.TO_USER_ID%>").trigger('change');
  readCategory();
}
$(document).ready(function() {
  $("select[name='active_kind'],select[name='to_user_id']").select2();
<% if (request.getParameter("aid")!=null) { 
	out.print("fill();");
   } else {
%>
  $("input[name='code_type']").first().prop("checked", true).click();
<%
   }
%>
});
</script>
</head>
<body style='padding:20px;'>
<h3>메모<%=strActionTag %></h3>
<form name='frmMemoReg' method='post' autocomplete='off'>
<input type='hidden' name='cid' value='<%=intCpyId%>'>
<input type='hidden' name='aid'>
<input type='hidden' name='active_desc' value=''>
<ul>
  <li>
    <input type='radio' name='code_type' value='1' style='width:auto;' onclick='changeCategory(1)'>MP1
    <input type='radio' name='code_type' value='2' style='width:auto;' onclick='changeCategory(2)'>담보보증
    <input type='radio' name='code_type' value='3' style='width:auto;' onclick='changeCategory(3)'>거래 외 
    <input type='radio' name='code_type' value='4' style='width:auto;' onclick='changeCategory(4)'>메모
  </li>
  <li>&nbsp;</li>
  <li>
    <select name='active_kind' style='width:100%;'>
  
   <%--  <%
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO v : arrCodes) {
        out.println("<option value='"+v.CODE_CD+"'>"+v.CODE_NM+"</option>");
      }
    }
    %> --%>
    </select>
  </li>
  <li style='margin-top:5px;'>
    <input type='radio' name='call_type' value='1' style='width:auto;' checked> 인바운드
    <input type='radio' name='call_type' value='2' style='width:auto;'> 아웃바운드
  </li>
  <li>&nbsp;</li>
  <li><textarea id="contents" style="height:300px;width:calc(100% - 2px);">
  <%
  if (isEditMode) out.println(mvo.ACTIVE_DESC);
  else out.println(!strText.equals("undefined")?strText:"");
  %>
  </textarea><li>
  <li style='margin-top:5px;'>
    <select name='to_user_id' style='width:100%;'>
    <option value=''></option>
    <%
    if (arrManagers!=null && arrManagers.size()>0) {
      for (ManagerVO v : arrManagers) {
        out.println("<option value='"+v.LOGIN_ID+"'>TO. "+v.USER_NM+"</option>");
      }
    }
    %>
    </select>
  </li>
</ul>
<div class='btns'><a onclick='writeMemo();'><%=strActionTag %></a></div>
</form>

<script type="text/javascript" src="<%=request.getContextPath() %>/static/js/CKEditorSetMini.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

  <!-- close
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>
  -->
</body>
