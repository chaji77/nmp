<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.c.*" %>
<!-- MY GUARANTEES -->
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getOnlyDate(String ymdhis) {
  if (StrUtil.nvl(ymdhis).length()>10) return ymdhis.substring(0, 10);
  return ymdhis;
}
%>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

String strDateSeparator = "-";
String strToday = DateTimeUtil.getCurrentDate(strDateSeparator);
ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("GUARANTEE_MASTER_INFO.GUAR_STATUS");
ArrayList<PayMethodVO> arrPayMethods = new GuaranteeBean().M_CT_MY_PAYMETHOD_PROC(intCpyId);  // MY GUARANTEES

LinkedHashMap<String, ArrayList<PayMethodVO>> mapPayGroups = new LinkedHashMap<>();
final Map<String, String> mapMaxValDate = new java.util.HashMap<>();
if (arrPayMethods!=null && arrPayMethods.size()>0) {
  for (PayMethodVO t : arrPayMethods) {
    String strGroupKey = t.BNK_CD+"xx"+t.PAY_ID;
    ArrayList<PayMethodVO> arrGroup = mapPayGroups.get(strGroupKey);
    if (arrGroup==null) {
      arrGroup = new ArrayList<>();
      mapPayGroups.put(strGroupKey, arrGroup);
    }
    arrGroup.add(t);
    if (t.GUAR_VAL_DATE.compareTo(StrUtil.nvl(mapMaxValDate.get(strGroupKey)))>0) mapMaxValDate.put(strGroupKey, t.GUAR_VAL_DATE);
  }
}
List<Map.Entry<String, ArrayList<PayMethodVO>>> arrSortedGroups = new ArrayList<>(mapPayGroups.entrySet());
Collections.sort(arrSortedGroups, new java.util.Comparator<Map.Entry<String, ArrayList<PayMethodVO>>>() {
  public int compare(Map.Entry<String, ArrayList<PayMethodVO>> a, Map.Entry<String, ArrayList<PayMethodVO>> b) {
    return mapMaxValDate.get(b.getKey()).compareTo(mapMaxValDate.get(a.getKey()));
  }
});

long lngTotalGuaranteeAmt = 0L;
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>보증서정보</title>
<style>
.current {background-color:#eef;}
body {display:flex;flex-direction:column;}
main {flex:1 0 auto;}
footer {flex-shrink:0;}
</style>
<script>
function add() {
  location.href = "GuaranteeReg.jsp?cpy_id=<%=strCpyId%>";
}
function extend(pid, seq) {
  showCustomConfirm("연장하시겠습니까?", function() {
	$.post("<%=request.getContextPath()%>/mgr/customer/GuaranteeExtendOrDropProc.jsp", {'cid':'<%=strCpyId%>', 'payId':pid, 'seq': seq, 'action':'extend'}, function(data){
		if (data==0) showAlert("연장된 보증서가 있습니다.");
		else window.location.reload();
	})
  }, function(){});
}
function drop(obj, seq) {
  var pid = $(obj).parent().parent().attr("payid");
  showCustomConfirm("삭제하시겠습니까?", function() {
	$.post("<%=request.getContextPath()%>/mgr/customer/GuaranteeExtendOrDropProc.jsp", {'cid':'<%=strCpyId%>', 'payId':pid, 'seq': seq, 'action':'drop'}, function(data){
		if (data==0) window.location.reload();
	    else showAlert("삭제할 수 없습니다.");
	})
  }, function(){});
}
function modify(obj, seq) {
  var pid = $(obj).parent().parent().attr("payid");
  location.href = "GuaranteeReg.jsp?cpy_id=<%=strCpyId%>&payId="+pid+"&seq="+seq;
}
function a311() {
  var s = $("select[name='payment']").val();
  if (s.indexOf("xx")>-1) {
    var bp = s.split("xx");
    $.ajax({
      url:strContextPath + "/web/transaction/A311.jsp", 
      type: 'post',
      data:{'cpy_id':'<%=strCpyId%>','bank_cd':bp[0],'pay_cd':bp[1]}, 
      async: true,
      success: function(data) {
        var json = JSON.parse($.trim(data));
        intLimitSum = json.limit;
        json.msg = "<h4 style='margin-top:0;padding-top:0;'>"+$("select[name='bnk_pay_id'] option:selected").text()+" 한도조회결과</h4>" + json.msg;
        showAlert(json.msg);
      },
      beforeSend: function() {
        showSpinner("응답을 기다리고 있습니다.");
      },
      complete: function() {
        hideSpinner();
      }
    });
  } else toast("걸제수단을 먼저 선택하세요.");
 
}
$(document).ready(function(){
  $("select[name='payment']").on("change", function() {
    var val = $(this).val();
    $("table.detail>tbody>tr").show();
    $("div.pay-group").each(function(idx, item){
      if (val=="" || $(item).attr("payid")==val) {
        $(item).show();
      } else $(item).hide();
    });
    $("input[name='only-valid']").prop("checked", false);
  });
  function applyOnlyValidFilter() {
    if ($("input[name='only-valid']").is(":checked")) {
      $("table.detail>tbody>tr").hide();
      $("table.detail>tbody>tr.current").show();
    } else {
      $("select[name='payment']").change();
    }
  }
  $("input[name='only-valid']").on("click", applyOnlyValidFilter);
  applyOnlyValidFilter();
});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>보증서정보</span>
  <span class='more'>
    <a onclick='add()' class='btn'>등록</a>
  </span>
</div>

<jsp:include page="./CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="2" />
</jsp:include>


<div style='padding:0 0 20px 0;line-height:2em;'>
  <input type='checkbox' name='only-valid' checked> 유효보증
  <select name='payment' style='width:200px;'>
  <option value='' selected>---선택---</option>
<%
for (Map.Entry<String, ArrayList<PayMethodVO>> e : arrSortedGroups) {
  PayMethodVO tFirst = e.getValue().get(0);
%>
  <option value='<%=e.getKey()%>'><%=tFirst.BNK_NAME%> <%=tFirst.PAY_SDESC%></option>
<%
}
%>
  </select>
  <a onclick='a311();' class='btn'>한도조회</a>
  <span class='more' style='font-weight:bold;font-size:1.2em;'>보증총액 <span id='total-amt'></span>원</span>
</div>

<%
for (Map.Entry<String, ArrayList<PayMethodVO>> ent : arrSortedGroups) {
  ArrayList<PayMethodVO> arrGroup = ent.getValue();
  PayMethodVO tFirst = arrGroup.get(0);
  String strFirstCodeName = tFirst.GUAR_STATUS;
  if (arrCodes!=null && arrCodes.size()>0) {
    for (CodeVO c : arrCodes) {
      if (c.CODE_CD.trim().equals(tFirst.GUAR_STATUS.trim())) strFirstCodeName = c.CODE_NM;
    }
  }
  String strFirstStatus = tFirst.GUAR_STATUS.trim();
  String strStatusColor = (strFirstStatus.equals("110") || strFirstStatus.equals("52") || strFirstStatus.equals("54")) ? "color:red;" : "";
%>
<div class='pay-group' payid='<%=ent.getKey()%>'>
<h4 style='<%=strStatusColor%>'><%=tFirst.BNK_NAME%> <%=tFirst.PAY_SDESC%> (<%=strFirstCodeName%>) <a onclick='extend("<%=ent.getKey()%>", <%=tFirst.CPY_GUAR_SEQ %>)' class='btn'>연장</a></h4>
<table class='detail'>
  <thead>
    <tr>
      <th class='left mobile_only'>내용</th>
      <th class='mobile_hide' style='width:12%;'>보증기간</th>
      <th class='mobile_hide' style='width:7%;'>유효만기일</th>
      <th class='right mobile_hide' style='width:7%;'>보증액</th>
      <th class='right mobile_hide' style='width:7%;'>변동액</th>
      <th class='left mobile_hide' style='width:32%;'>메모</th>
      <th class='left mobile_hide' style='width:12%;'>등록</th>
      <th class='left mobile_hide' style='width:12%;'>수정</th>
      <th style='width:10%;'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
  String strPayCode = ent.getKey();
  for (PayMethodVO t : arrGroup) {
    String strCodeName = t.GUAR_STATUS;
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO c : arrCodes) {
        if (c.CODE_CD.trim().equals(t.GUAR_STATUS.trim())) strCodeName = c.CODE_NM;
      }
    }
    String strFrom    = t.GUAR_CRA_DATE.substring(0, 10);
    String strTo      = t.GUAR_EXP_DATE.substring(0, 10);
    String strCurrent = "";
    if (DateTimeUtil.isDateBetween(strToday, strFrom, strTo, strDateSeparator)) {
      strCurrent = "current";
      lngTotalGuaranteeAmt += Long.parseLong(StrUtil.extractDigits(t.GUAR_TOTAL_AMT, 17));
    }
%>

    <tr payid='<%=strPayCode%>' class='<%=strCurrent%>'>
      <td class='mobile_only' style='white-space:wrap;'>
        <br/>유효만기일 : <%=t.GUAR_VAL_DATE.substring(0, 10)  %>
        <br/>보증액 : <%=StrUtil.addCommaAfterRound(t.GUAR_TOTAL_AMT) %>원
        <br/><br/><span style='border-top:1px solid #ddd;padding-top:10px;'><%=t.MEMO %></span>
      </td>
      <td class='center mobile_hide'><%=strFrom  %> ~ <%=strTo  %></td>
      <td class='center mobile_hide'><%=t.GUAR_VAL_DATE.substring(0, 10)  %></td>
      <td class='right mobile_hide'><%=StrUtil.addCommaAfterRound(t.GUAR_TOTAL_AMT) %></td>
      <td class='right mobile_hide'><%=StrUtil.addCommaAfterRound(t.CHANGE_AMT) %></td>
      <td class='mobile_hide' style='white-space:wrap;'><%=t.MEMO %></td>
      <td class='mobile_hide'><%=t.WRITE_ID %> (<%=getOnlyDate(t.WRITE_DATE) %>)</td>
      <td class='mobile_hide'><%=(t.MODIFY_ID + " (" + getOnlyDate(t.MODIFY_DATE) +")").replace(" ()", "") %></td>
      <td class='center'><a onclick='modify(this, <%=t.CPY_GUAR_SEQ %>);' class='btn lurian'>수정</a> <a onclick='drop(this, <%=t.CPY_GUAR_SEQ %>)' class='btn darkred'>삭제</a>
      </td>
    </tr>
<%
  }
%>
  </tbody>
</table>
</div>
<%
}
%>
<script>
$("#total-amt").text("<%=StrUtil.addComma(lngTotalGuaranteeAmt)%>");
</script>

<%@ include file="../Footer.jsp" %>