<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.MastOffCommissionVO" %>
<%@ page import="kr.co.mp.mgr.sales.CommissionBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getCompanyName(String id, String strComNm, String strBizNo) {
  if (id.equals("0")) return "모든기업";
  return strComNm + "(" + strBizNo + ")";
}
String getPayGubunName(String strPayGubun) {
  if (strPayGubun.equals("10")) return "구매자금/카드(론)";
  if (strPayGubun.equals("20")) return "종통대";
  return "글로벌구매카드";
}
String getCommMethodName(String strCommMethod, ArrayList<CodeVO> arrCodes) {
  if (arrCodes!=null && arrCodes.size()>0) {
    for (CodeVO c : arrCodes) {
       if (c.CODE_CD.equals(strCommMethod)) return c.CODE_NM;
    }
  }
  return "";
}
%>
<%
request.setCharacterEncoding("utf-8");

String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

int intPage     = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
int intRowCnt   = 20;
int intTotalCnt = 0;

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("INFO_COMMISSION.COMM_METHOD");
String strCommId = StrUtil.nvl(request.getParameter("commid"), "0");
CommissionBean bean = new CommissionBean();
ArrayList<CommissionVO> arr  = bean.INFO_COMMISSION_LIST_PER_CPY_ID_PROC(intCpyId);
ArrayList<MastOffCommissionVO> arrMast = bean.MAST_OFF_COMMISSION_LIST_PER_CPY_ID_PROC(intCpyId, intPage, intRowCnt);
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>수수료</title>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/static/css/regist.css?<%=DateTimeUtil.getCurrentResourceVersion() %>">
<style>
td {line-height:2em;vertical-align:top;}
td.memo {line-height:1.2em;}
span.role {padding:3px;border:1px solid #ddd;color:#888;}
@media only screen and (max-width:767px) {
  td.memo {line-height:1.5em;min-width:290px;}
  span.role {padding:1px;}
}
</style>

<script>
function numberToKorean(num) {
  if (typeof num !== 'number' || isNaN(num)) throw new Error('유효한 숫자를 입력해주세요.');
  const units = ['', '만', '억', '조', '경'];
  const digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
  const positions = ['', '십', '백', '천'];
  if (num === 0) return '영';
  let result = '';
  let unitIndex = 0;
  while (num > 0) {
    let part = num % 10000; // 4자리씩 나눔
    num = Math.floor(num / 10000);
    if (part > 0) {
      let partStr = '';
      let positionIndex = 0;
      while (part > 0) {
        let digit = part % 10;
        if (digit > 0) partStr = digits[digit] + positions[positionIndex] + partStr;
        part = Math.floor(part / 10);
        positionIndex++;
      }
      result = partStr + units[unitIndex] + result;
    }
    unitIndex++;
  }
  return result;
}
function goPage(p) {
  document.frmEnt.page.value = p;
  document.frmEnt.submit();
}
function drop(commid) {
  showCustomConfirm("삭제하시겠습니까?", function(){
    $.post("<%=request.getContextPath()%>/mgr/mpfee/MpFeeDropProc.jsp", {'commid':commid}, function(data){
     if (data==1) window.location.reload();
     else showAlert("삭제할 수 없습니다.");
    });
  }, function(){});
}
function renew(commid) {
  showCustomConfirm("같은 조건으로 적용기간을 갱신하시겠습니까?", function(){
    $.post("<%=request.getContextPath()%>/mgr/mpfee/RenewProc.jsp", {'commid':commid}, function(data){
     if (data==1) window.location.reload();
     else showAlert("갱신할 수 없습니다.");
    });
  }, function(){});
}
function showAddMastCommissionWindow(commid) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/mgr/mpfee/MastOffCommissionReg.jsp?commid='+commid});
}
function addMastCommission() {
  $.post("MastOffCommissionRegProc.jsp", $("form[name='frmMastOffCommission']").serialize(), function(data) {
    if (data!="0") window.location.reload();
    else toast("등록할 수 없습니다. 잠시 후 시도하십시오.");
  });
}
function dropMastOff(seq) {
  showCustomConfirm("삭제하시겠습니까?", function() {
    $.post("MastOffCommissionDropProc.jsp", {'seq':seq}, function(data) {
      window.location.reload();
    });
  }, function(){});
} 
function goRegPage() { // frmCompanyHead is in CompanyHeader
  document.frmCompanyHead.action = '<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp';
  document.frmCompanyHead.submit();
}
$(document).ready(function(){

});
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>수수료</span>
  <span class='more'>
    <a onclick='goRegPage();' class='btn'>신규등록</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="3" />
</jsp:include>

<div style='text-align:right;padding-bottom:10px;'><i class="fa-solid fa-asterisk"></i> 적용기간만기가 30일 이내인 경우, 갱신 버튼이 활성화됩니다.</div>

<table style='border-top:2px solid #ddd;min-width:100%;'>
  <thead class='mobile_hide'>
    <tr>
      <th class='left'>구매사<br/>판매사</th>
      <th class='left'>계산방식<br/>결제구분</th>
      <th class='right'>기준일수<br/>만기계산일</th>
      <th class='right'>기본요율<br>할인율</th>
      <th class='right'>비례요율</th>
      <th class='left'>적용기간</th>
      <th class='right'>청구총액<br/>수금총액</th>
      <th class='left'>등록자<br/>등록일시</th>
      <th class='left'>메모</th>
      <th class='right'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CommissionVO vo : arr) {
    String strMty    = (!vo.MTY_ENDDAYS.equals("0")) ? "<br/>" + vo.MTY_STDAYS + " ~ " + vo.MTY_ENDDAYS : "";
%>
    <tr class='mobile_hide'>
      <td>
        <span class='role'>구매</span> <%=getCompanyName(vo.CPY_BUYER, vo.BUYER_NM, vo.BUYER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? " <font color='red'>[부담]</font>" : "" %><br/>
        <span class='role'>판매</span> <%=getCompanyName(vo.CPY_SELLER, vo.SELLER_NM, vo.SELLER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? "" : " <font color='red'>[부담]</font>" %>
      </td>
      <td><strong><%=getCommMethodName(vo.COMM_METHOD, arrCodes) %></strong><%=(vo.MAX_YN.equals("Y"))?" [연맥스] ":"" %><br/><%=getPayGubunName(vo.PAY_GUBUN) %></td>
      <td class='right'><%=vo.STD_DAYS %><%=strMty %></td>
      <td class='right'><%=vo.CPY_COMMISSION_RATE %><br/><%=vo.DISCOUNT_RATE %></td>
      <td class='right'><%=vo.CPY_COMMISSION_RATE1 %><br/><%=vo.CPY_COMMISSION_RATE2 %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.START_DT, ".") %> ~ <%=FormatUtil.addSeparatorDate(vo.END_DT, ".") %></td>
      <td class='right'><%=StrUtil.addComma(StrUtil.extractInteger(vo.RECEIVE_MONEY)) %><br/><%=StrUtil.addComma(StrUtil.extractInteger(vo.END_MONEY)) %><%=(vo.OFFLINE_YN.equals("Y"))?"<br/>오프라인징수":"" %></td>
      <td><%=vo.MODID %><br/><%=FormatUtil.addSeparatorDateTime(vo.MODDATE, ".") %></td>
      <td class='memo'><%=vo.COMM_DESC.replaceAll("\r", "<br/>") %></td>
      <td class='right'>
        <a href='<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp?commid=<%=vo.COMM_ID %>' class='btn lurian'>수정</a>
        <a class='btn darkred' onclick='drop(<%=vo.COMM_ID %>)'>삭제</a>
        <% if (!vo.START_DT.equals("") && !vo.END_DT.equals("") && DateTimeUtil.diff(null, vo.END_DT, "")<30) { %>
        <a class='btn' onclick='renew(<%=vo.COMM_ID %>)'>갱신</a>
        <% } %>
      </td>
    </tr>
    <tr class='mobile_show'>
      <td class='memo'>
        <span class='role'>구매</span> <%=getCompanyName(vo.CPY_BUYER, vo.BUYER_NM, vo.BUYER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? " <font color='red'>[부담]</font>" : "" %><br/>
        <span class='role'>판매</span> <%=getCompanyName(vo.CPY_SELLER, vo.SELLER_NM, vo.SELLER_BIZ_NO) %><%=(vo.PAY_CPY.equals("B")) ? "" : " <font color='red'>[부담]</font>" %><br/>
        <span class='role'>방식</span> <%=getCommMethodName(vo.COMM_METHOD, arrCodes) %><br/>
        <div style='margin-top:10px;padding-top:10px;border-top:1px solid #ddd;'><%=vo.COMM_DESC.replaceAll("\r", "<br/>") %></div>
      </td>
      <td class='right'>
        <a href='<%=request.getContextPath() %>/mgr/mpfee/MpFeeReg.jsp?commid=<%=vo.COMM_ID %>' class='btn lurian'>수정</a>
        <br/><a class='btn darkred' onclick='drop(<%=vo.COMM_ID %>)'>삭제</a>
        <% if (!vo.START_DT.equals("") && !vo.END_DT.equals("") && DateTimeUtil.diff(null, vo.END_DT, "")<30) { %>
        <br/><a class='btn' onclick='renew(<%=vo.COMM_ID %>)'>갱신</a>
        <% } %>
      </td>
    </tr>
<%
  }
}
%>
  </tbody>
</table>


<div>
  <h3>별도수수료 징수내역</h3>
  <span class='more' style='margin-top:-34px;'>
    
  </span>
</div>

<table style='border-top:2px solid #ddd;'>
  <thead class='mobile_hide'>
    <tr>
      <th class='left'>상품구분</th>
      <th class='left'>적용기간</th>
      <th class='left'>매매계약서번호</th>
      <th class='right'>받은금액</th>
      <th class='left'>등록자</th>
      <th class='right'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arrMast!=null && arrMast.size()>0) {
  for (MastOffCommissionVO vo : arrMast) {
    intTotalCnt = vo.TOTAL_CNT;
    System.out.println(StrUtil.extractInteger(vo.END_MONEY));
%>
    <tr class='mobile_hide'>
      <td><%=getCommMethodName(vo.COMM_METHOD, arrCodes) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.START_DT, ".") %> ~ <%=FormatUtil.addSeparatorDate(vo.END_DT, ".") %></td>
      <td><%=vo.CTNO %></td>
      <td class='right'><%=StrUtil.addComma(StrUtil.extractInteger(vo.END_MONEY)) %></td>
      <td><%=vo.WRITE_ID %> (<%=vo.WRITE_DATE %>)</td>
      <td class='right'>
        <% if (!StrUtil.extractInteger(vo.END_MONEY).equals("0")) { %>
        <a onclick='dropMastOff(<%=vo.SEQNO %>)' class='btn darkred'>삭제</a>
        <% } %>
        <a onclick='showAddMastCommissionWindow(<%=vo.COMM_ID %>)' class='btn'>추가</a>
      </td>
    </tr>
    <tr class='mobile_show'>
      <td class='memo'>
        <span class='role'>방식</span> <%=getCommMethodName(vo.COMM_METHOD, arrCodes) %><br/>
        <span class='role'>기간</span> <%=FormatUtil.addSeparatorDate(vo.START_DT, ".") %> ~ <%=FormatUtil.addSeparatorDate(vo.END_DT, ".") %><br/>
        <span class='role'>번호</span> <%=vo.CTNO %><br/>
        <span class='role'>금액</span> <%=StrUtil.addComma(StrUtil.extractInteger(vo.END_MONEY)) %>
      </td>
      <td class='right'>
        <% if (!StrUtil.extractInteger(vo.END_MONEY).equals("0")) { %>
        <a onclick='dropMastOff(<%=vo.SEQNO %>)' class='btn darkred'>삭제</a>
        <% } %>
        <a onclick='showAddMastCommissionWindow(<%=vo.COMM_ID %>)' class='btn'>추가</a>
      </td>
    </tr>
<%
  }
}
%>
  </tbody>
</table>

<form name='frmEnt' method='post'>
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
<input type='hidden' name='page' value='<%=intPage%>'>
</form>

<div id="paging">
  <script>
  getPaging('goPage','<%=intPage%>', '<%=intTotalCnt%>', '<%=intRowCnt%>', 5, '');
  </script>
</div>

<%@ include file="../Footer.jsp" %>



