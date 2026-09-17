<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.UnusualTransactionVO" %>
<%@ page import="kr.co.mp.trade.TransactionResultVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
WebPageCtrlUtil.setHistoryBack(request, session);

String strCpyId = request.getParameter("cpy_id");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cpy_id")));
else return;

CtHeaderVO pvo     = new CtHeaderVO();
pvo.PAGE           = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT        = 20;
pvo.STATUS         = StrUtil.nvl(request.getParameter("status"), "");
pvo.CTNO           = StrUtil.nvl(request.getParameter("ctno"), "");
pvo.SBDATE         = StrUtil.nvl(request.getParameter("sbdate"), "R");
String strStartYmd = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 180, "-"));
String strEndYmd   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
if (!pvo.CTNO.equals("")) {
  strStartYmd = "1970-07-28";
  strEndYmd   = DateTimeUtil.getCurrentDate("-");
}
int intTotalCnt    = 0;

TradeBean bean = new TradeBean();
ArrayList<CtHeaderVO> arr = null;
ArrayList<UnusualTransactionVO> arrUnusuals = null;
ArrayList<TransactionResultVO> arrK311Results = null;
try {
  arr = bean.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, 0, "A", 0);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;
  String strCtIds = "";
  String strCtNos = "";
  for (CtHeaderVO v : arr) {
    strCtIds += ","+v.CTID;
    strCtNos += ","+v.CTNO;
  }
  if (strCtIds.length()>1) {
    strCtIds = strCtIds.substring(1);
    arrUnusuals = bean.UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(strCtIds, "Y");
  }
  if (strCtNos.length()>1) {
    strCtNos = strCtNos.substring(1);
    arrK311Results = bean.RECEIVE_XML_K311_LIST_BY_CTNO_PROC(strCtNos);
  }
} catch (Exception e) {
  arr = null;
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>거래</title>
<style>
span.w {padding:2px 5px;border:1px solid #ddd;color:#888;}
table.detail td {line-height:1.7em;vertical-align:top;}
table.detail td a.underline {border-bottom:1px solid #00f;color:#00f;}
table.detail td a.btn {padding:2px 6px;}
table.detail td p {display:block;width:100%;}
table.detail .unusual {display:none;}
table.detail .unusual p {line-height:1.7em;}
table.detail td span {padding:2px 5px;}
span.not-solve {background-color:red;color:white;}
span.not-solve:hover {background-color:hotpink;}
.commands {max-width:200px;white-space:wrap;}
.commands a {white-space:nowrap;margin-bottom:10px;}
</style>

<script>
function goDetail(ctid) {
  document.frmSearch.seq.value = ctid;
  document.frmSearch.target = "_contract_";
  document.frmSearch.action = "Contract.jsp";
  document.frmSearch.submit();
}
function goPage(p) {
  document.frmSearch.page.value = p;
  document.frmSearch.action = "ContractsPerCustomer.jsp";
  document.frmSearch.submit();
}
function calc(ctid) {
  $.post("<%=request.getContextPath()%>/mgr/mpfee/CalcCommission.jsp", {'ctid':ctid}, function(data) {
    showAlert(data);
  });
}
function openTaxBill(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/common/Tax.jsp?seq='+seq});
}
function openUnusal(obj) {
  var is = ($(obj).closest("tr").next("tr").children("td")).is(":visible");
  if (!is) ($(obj).closest("tr").next("tr").children("td")).show();
  else ($(obj).closest("tr").next("tr").children("td")).hide();
}
function openReleasePage(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'UnusualReg.jsp?seq='+seq});
}
function openChangeStatusWindow(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'StatusChange.jsp?seq='+seq});
}
function changeStatus() {
  $.post("StatusChangeProc.jsp", $("form[name='frmStatusChange']").serialize(), function(data) {
    window.location.reload();
  });
}
function checkAbnormal(strMpFeeCpyId, intCtId) {
  showSpinner("불러오고있습니다.");
  $("#ifmContract").attr("src", "ContractReg.jsp?cpy_id="+strMpFeeCpyId+"&seq="+intCtId);
}
function showTransactionResult(intCtId) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'/mp/mgr/trade/TransactionResult.jsp?seq='+intCtId});
}
function cancelTransaction(encid) {
  $.ajax({
    url:strContextPath + "/web/transaction/B315.jsp", 
    type: 'post',
    data:{'ctid':encid}, 
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        showAlert(json.msg, function() {
          window.location.reload();
        });
      } else showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendTransaction(edityn, encid, token) {
  $.ajax({
    url:strContextPath + "/web/transaction/B311.jsp", 
    type: 'post',
    data:{'ctid':encid,'token':token,'edit_settle_due_date_yn':edityn}, 
    async: true,
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        showAlert(json.msg, function() {
          window.location.reload();
        });
      } else showAlert("전송하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
    },
    beforeSend: function() {
      showSpinner("전송중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendMessage(tid, cpyid, ctid) {
  $.ajax({
    url:"<%=request.getContextPath()%>/common/kakaotalk/Send.jsp", 
    type: 'post',
    data:{"tid":tid,"cpyid":cpyid,"ctid":ctid}, 
    async: true,
    success: function(data) {
      if (data=="SUCCESS") showAlert("전송되었습니다.");
      else showAlert(data);
    },
    beforeSend: function() {
      showSpinner("전송하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendA211(ctid) {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A211.jsp", 
    type: 'post',
    data:{"ctid":ctid}, 
    async: true,
    success: function(data) {
      showAlert(data);
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function sendA411(ctid) {
  $.ajax({
    url:"<%=request.getContextPath()%>/web/transaction/A411.jsp", 
    type: 'post',
    data:{"ctid":ctid, "strSellerClearYn":"Y"},
    async: true,
    success: function(data) {
      if (data=="Y") showAlert("판매사사전검증차단해제등록되었습니다.");
      else showAlert("판매사사전검증차단중입니다.");
    },
    beforeSend: function() {
      showSpinner("조회하고 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
$(document).ready(function(){
  $("a.magnify").on("click", function() {
    if ($("table.searchbox").is(":visible")) $("table.searchbox").slideUp();
    else $("table.searchbox").slideDown();
  });
  $('#ifmContract').on( 'load', function() {
    setTimeout(function() {
      $("#ifmContract").get(0).contentWindow.checkAbnormal();
    }, 500);
  });
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래</span>
  <span class='more'>
    <a class='btn white magnify mobile_show'>검색</a>
  </span>
</div>

<jsp:include page="../customer/CompanyHeader.jsp">
  <jsp:param name="cpy_id" value="<%=intCpyId%>" />
  <jsp:param name="menuidx" value="4" />
</jsp:include>

<form name='frmSearch' method='post'>
<input type='hidden' name='page' value='<%=pvo.PAGE%>'>
<input type='hidden' name='cpy_id' value='<%=strCpyId%>'>
<input type='hidden' name='seq' value='0'>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>계약번호</label>
          <input type='search' name='ctno' placeholder='계약번호' value='<%=pvo.CTNO%>' onkeydown="if(event.key === 'Enter'){ javascript:goPage(1); }">
        </li>
        <li class='search-option-status'>
          <label>검색기준일</label>
          <select name='sbdate' onChange="goPage(1);">
            <option value="R" <%=(pvo.SBDATE.equals("R"))?"selected":""%>>거래일</option>
            <option value="C" <%=(pvo.SBDATE.equals("C"))?"selected":""%>>계약일</option>
            <option value="S" <%=(pvo.SBDATE.equals("S"))?"selected":""%>>결제예정일</option>
            <option value="M" <%=(pvo.SBDATE.equals("M"))?"selected":""%>>만기일</option>
          </select>
        </li>
        <li>
          <label>검색기간</label>
          <input type='date' name='start_ymd' value='<%=strStartYmd %>' style='width:auto;'>
          <input type='date' name='end_ymd' value='<%=strEndYmd %>' style='width:auto;'>
        </li>
        <li class='search-option-status'>
          <label>진행상태</label>
          <select name='status' onChange="goPage(1);">
            <option value=''>전체</option>
            <option value="010" <%=(pvo.STATUS.equals("010"))?"selected":""%>>임시보관</option>
            <option value="020" <%=(pvo.STATUS.equals("020"))?"selected":""%>>승인대기</option>
            <option value="025" <%=(pvo.STATUS.equals("025"))?"selected":""%>>계약승인(결제대기)</option>
            <option value="707" <%=(pvo.STATUS.equals("707"))?"selected":""%>>전송대기</option>
            <option value="040" <%=(pvo.STATUS.equals("040"))?"selected":""%>>계약승인(결제중)</option>
            <option value="050" <%=(pvo.STATUS.equals("050"))?"selected":""%>>은행추심완료</option>
            <option value="060" <%=(pvo.STATUS.equals("060"))?"selected":""%>>결제완료</option>
            <option value="030" <%=(pvo.STATUS.equals("030"))?"selected":""%>>전송오류</option>
            <option value="080" <%=(pvo.STATUS.equals("080"))?"selected":""%>>취소</option>
            <option value="090" <%=(pvo.STATUS.equals("090"))?"selected":""%>>삭제</option>
          </select>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn' style='text-align:right;'><img class='magnify' onclick='javascript:goPage(1);'></td>
  </tr>
</tbody>
</table>
</form>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>계약일/거래일</th>
      <th class='left'>결제예정일</th>
      <th class='left'>만기일</th>
      <th class='left'>계약아이디/계약번호</th>
      <th class='left'>결제수단/세금계산서</th>
      <th class='left'>구매기업/판매기업</th>
      <th class='right'>결제금액/수수료</th>
      <th class='left'>진행상태</th>
      <th class='left'>이상거래</th>
      <th class='left'>관리</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CtHeaderVO vo : arr) {
    int intUnusual      = 0;
    int intTotalUnusual = 0;
    String strUnusual   = "";
    String strMpFeeAmt  = "<i class='fa-solid fa-calculator' onclick='calc("+vo.CTID+");' style='cursor:pointer;'></i>";
    if (!StrUtil.nvl(vo.MPFEE_TOTALAMT).equals("")) strMpFeeAmt = StrUtil.addComma(vo.MPFEE_TOTALAMT) + " " + strMpFeeAmt;
    if (arrUnusuals!=null && arrUnusuals.size()>0) {
      for (UnusualTransactionVO uvo : arrUnusuals) {
        if (uvo.CTID.equals(vo.CTID)) {
          strUnusual += "<p><a onclick='openReleasePage("+uvo.SEQ+");' class='btn'>관리</a> ";
          strUnusual += (uvo.USE_YN.equals("N")) ? "<font color='red'>[진행]</font> " : "[해제] ";
          strUnusual += StrUtil.nvl(uvo.CONTENT).replaceAll("<br/>", ". ");
          intTotalUnusual++;
          if (uvo.USE_YN.equals("N")) intUnusual++;
          if (uvo.USE_YN.equals("N") && uvo.SECTION.equals("KD009")) {
            strUnusual += " <a onclick='sendA211("+vo.CTID+");' class='btn'>사전검증조회</a> <a onclick='sendA411("+vo.CTID+");' class='btn'>사전검증해제등록</a>";
          }
          strUnusual += "</p>";
        }
      }
    }
%>
    <tr>
      <td class='left'><%=FormatUtil.addSeparatorDate(vo.CONTRACTDATE) %><br/><%=FormatUtil.addSeparatorDate(vo.REGDATE) %></td>
      <td class='left'><%=FormatUtil.addSeparatorDate(vo.SETTLEDUEDATE) %>
        <% if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) { %>
        <br/><a onclick='sendMessage("M006", <%=vo.CPYBUYER %>, <%=vo.CTID %>);' class='btn white'>알림</a>
        <% } %>
      </td>
      <td class='left'><%=FormatUtil.addSeparatorDate(vo.MTYDATE) %>
        <% if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) { %>
        <br/><a onclick='sendMessage("M005", <%=vo.CPYBUYER %>, <%=vo.CTID %>);' class='btn white'>알림</a><% } %>
      </td>
      <td class='left'><a onclick='goDetail(<%=vo.CTID%>);' class='underline'><strong><%=vo.CTID%></strong></a><br/><%=vo.CTNO %></td>
      <td class='left' style='max-width:200px;white-space:wrap;'><%=vo.BNK_NAME %> <%=vo.PAY_SDESC %><br/><a onclick='openTaxBill(<%=vo.SBILL_SEQ%>);' class='underline'><%=vo.TAXAPPROVALNO %></a></td>
      <td class='left'>
        <%=vo.BUYER_NM %><%=(vo.CTTYPE.equals("B"))?" <span class='w'>작성</span>":"" %><%=(StrUtil.nvl(vo.MPPAYCPY).equals("2"))?" <span class='w'>부담</span>":"" %><br/>
        <%=vo.SELLER_NM %><%=(vo.CTTYPE.equals("S"))?" <span class='w'>작성</span>":"" %><%=(StrUtil.nvl(vo.MPPAYCPY).equals("1"))?" <span class='w'>부담</span>":"" %>
      </td>
      <td class='right'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %><br/><%=strMpFeeAmt %></td>
      <td class='left'>
        <% if (vo.STATUS.equals("030") || vo.STATUS.equals("040") || vo.STATUS.equals("050") || vo.STATUS.equals("060") || vo.STATUS.equals("070") || vo.STATUS.equals("707") || vo.STATUS.equals("080") || vo.STATUS.equals("090")) { %>
        <a onclick='showTransactionResult(<%=vo.CTID%>);' class='underline'><%=vo.CODE_NM %></a>
        <% } else { %>
        <%=vo.CODE_NM %>
        <% } %>
        <% 
        if (vo.STATUS.equals("040") || (vo.STATUS.equals("050") && vo.BNK_CD.equals("TB"))) {
          out.println("<a onclick='cancelTransaction(\""+IntegerCryptoUtil.crypt(vo.CTID)+"\");' class='btn darkred'>전송취소</a>");
        }
        if (vo.STATUS.equals("030") || vo.STATUS.equals("707")) {
          out.println("<a onclick='sendTransaction(\"N\",\""+IntegerCryptoUtil.crypt(vo.CTID)+"\", \""+CryptoDESUtil.encrypt(vo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "")+"\");' class='btn lurian'>재전송</a>");
          out.println("<a onclick='sendTransaction(\"Y\",\""+IntegerCryptoUtil.crypt(vo.CTID)+"\", \""+CryptoDESUtil.encrypt(vo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "")+"\");' class='btn white'>결변재전송</a>");
        }
        if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) {
          if (arrK311Results!=null && arrK311Results.size()>0) {
            for (TransactionResultVO tvo : arrK311Results) {
              if (tvo.ORDERNO.equals(vo.CTNO)) {
                out.print("<br/><i class='fa-solid fa-arrow-down'></i> " + FormatUtil.addSeparatorDate(tvo.TRANSACTIONDATE));
              }
            }
          }
        }
        %>
        
      </td>
      <td>
      <%
      if (intTotalUnusual!=0) {
        out.print("<a onclick='openUnusal(this);'>");
        if (intUnusual>0) out.print("<span class='not-solve'>미해결 " + intUnusual + "</span>");
        out.print("<span>해결 " + (intTotalUnusual-intUnusual) + "</span>");
        out.print("</a>");
      }
      %>
      </td>
      <td class='left commands'>
         <% if (!"060,070".contains(vo.STATUS)) { %>
         <a onclick='openChangeStatusWindow(<%=vo.CTID%>);' class='btn lurian'>상태변경</a>
         <a onclick='checkAbnormal("<%=IntegerCryptoUtil.crypt(vo.CPYBUYER) %>", <%=vo.CTID%>);' class='btn white'>이상거래검증</a>
         <% } %>
      </td>
    </tr>
    <% if (!strUnusual.equals("")) { %>
    <tr><td colspan='10' class='unusual'><%=strUnusual %></td></tr>
    <% } %>
<%
  }
} else out.println("<tr><td colspan='10' class='noentry'>검색조건에 맞는 계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<div id="paging">
  <script>
  getPaging('goPage','<%=pvo.PAGE%>', '<%=intTotalCnt%>', '<%=pvo.ROW_CNT%>', 5, '');
  </script>
</div>


<iframe id='ifmContract'></iframe>
<%@ include file="../Footer.jsp" %>