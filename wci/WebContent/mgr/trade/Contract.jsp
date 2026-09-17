<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.CtItemVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.trade.UnusualTransactionVO" %>
<%@ page import="kr.co.mp.trade.TransactionResultVO" %>
<%@ page import="kr.co.mp.trade.SignVO" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getSignData(String strSignId, ArrayList<SignVO> a) {
  if (a!=null && a.size()>0) {
    for (SignVO s : a) {
      if (s.SGN_ID.equals(strSignId)) return s.SGN_DESC;
    }
  }
  return "";
}
%>
<%
request.setCharacterEncoding("utf-8");

int intCtId = 0;
try {
  intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
} catch (Exception e) {
  System.out.println("Error@Contract.jsp : " + StrUtil.nvl(request.getParameter("seq")));
}

TradeBean bean = new TradeBean();
CtHeaderVO vo = bean.CT_HEADER_DETAIL_PROC(intCtId);
ArrayList<CtItemVO> arr = bean.CT_ITEM_LIST_PROC(intCtId);
ArrayList<UnusualTransactionVO> arrUnusuals = bean.UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(Integer.toString(intCtId), "Y");
ArrayList<SignVO> arrSigns = bean.SIGNINFO_LIST_BY_CTID_PROC(intCtId);
if (vo==null) return;

ArrayList<TransactionResultVO> arrK311Results = null;
if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) {
  arrK311Results = bean.RECEIVE_XML_K311_LIST_BY_CTNO_PROC(vo.CTNO);
}
// Managers
CustomerBean customer = new CustomerBean();
ArrayList<PersonVO> arrBuyerPersons  = customer.PERSON_LIST_PROC(Integer.parseInt(vo.CPYBUYER));
ArrayList<PersonVO> arrSellerPersons = customer.PERSON_LIST_PROC(Integer.parseInt(vo.CPYSELLER));

// Tax Invoice
InvoiceVO invoice = InvoiceDAO.T_BILL_BY_CTID_PROC(intCtId);

String strMpFeeCpyId = IntegerCryptoUtil.crypt((vo.MPPAYCPY.equals("1")) ? vo.CPYSELLER : vo.CPYBUYER);
String strCpyId      = IntegerCryptoUtil.crypt(vo.CPYBUYER);

%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>매매계약서</title>

<style>
ul.detail a:not(.btn) {text-decoration: underline;}
ul.detail i {background-color:#00789e;color:#fff;padding:3px 5px;}
ul.detail li ul li {border:0;padding:0 0 8px 0;}
</style>
<script>
function checkLimit(booShowMsg) {
  $.ajax({
    url: strContextPath + "/web/transaction/A311.jsp", 
    type: 'post',
    data:{'cpy_id':'<%=IntegerCryptoUtil.crypt(vo.CPYBUYER)%>','bank_cd':'<%=vo.BNK_CD%>','pay_cd':'<%=vo.PAY_ID%>'}, 
    async: true,
    success: function(data) {
      var json = JSON.parse($.trim(data));
    intLimitSum = json.limit;
    json.msg = "<h4 style='margin-top:0;padding-top:0;'>"+$("select[name='bnk_pay_id'] option:selected").text()+" 한도조회결과</h4>" + json.msg;
    if (!json.is || booShowMsg) showAlert(json.msg);
    },
    beforeSend: function() {
      showSpinner("보증기관 및 은행과 통신하고 있습니다.<br/>잠시 기다려주세요.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
function openTaxBill(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'<%=request.getContextPath()%>/common/Tax.jsp?seq='+seq});
}
function calc(ctid) {
  $.post("<%=request.getContextPath()%>/mgr/mpfee/CalcCommission.jsp", {'ctid':ctid}, function(data) {
    showAlert(data);
  });
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
function showChangeStatusLog(seq) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:'ContractChangeStatusLog.jsp?seq='+seq});
}
function goTradePage(strCpyId) {
  document.frmCompanyHead.cpy_id.value = strCpyId;
  document.frmCompanyHead.action = "<%=request.getContextPath()%>/mgr/trade/ContractsPerCustomer.jsp";
  document.frmCompanyHead.submit();
}
function goMpFeePage() {
  document.frmCompanyHead.cpy_id.value = "<%=strMpFeeCpyId%>";
  document.frmCompanyHead.action = "<%=request.getContextPath()%>/mgr/mpfee/MpFeePerCustomer.jsp";
  document.frmCompanyHead.submit();
}
function goModifyPage() {
  document.frmCompanyHead.cpy_id.value = "<%=strCpyId%>";
  document.frmCompanyHead.action = "<%=request.getContextPath()%>/mgr/trade/ContractReg.jsp";
  document.frmCompanyHead.submit();
}
function checkAbnormal() {
  showSpinner("불러오고있습니다.");
  $("#ifmContract").attr("src", "ContractReg.jsp?cpy_id=<%=strMpFeeCpyId%>&seq=<%=intCtId%>");
}
function viewTaxInvoice(seq) {
  window.open('<%=request.getContextPath()%>/mgr/etax/InvoiceView.jsp?seq='+seq,'invoice','width=850,height=600,left=100,top=100,scrollbars=no,resizable=no');
}
function publishTaxInvoice() {
  showSpinner("발행신청하고 있습니다.");
  $.post("<%=request.getContextPath()%>/mgr/etax/TaxPublishByCtid.jsp", {'ctid':'<%=intCtId%>'}, function(data){
    hideSpinner();
    if (data>0) window.location.reload();
    else showAlert("발행하지 못했습니다. 잠시 후 시도하십시오.");
  });
}
function showTransactionResult(intCtId) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath + '/mgr/trade/TransactionResult.jsp?seq='+intCtId});
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
$(document).ready(function() {
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
  <span class='title'>매매계약서</span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
    <a onclick='goModifyPage();' class='btn lurian'>수정</a>
    <a onclick='checkAbnormal();' class='btn darkred'>이상거래검증</a>
  </span>
</div>

<form name='frmCompanyHead' method='post'>
<input type='hidden' name='cpy_id'     value=''>
<input type='hidden' name='cpy_gubun'  value='<%=(vo.MPPAYCPY.equals("1")) ? "S":"B"%>'>
<input type='hidden' name='cpy_biz_no' value='<%=(vo.MPPAYCPY.equals("1")) ? vo.SELLER_BIZ_NO:vo.BUYER_BIZ_NO%>'>
<input type='hidden' name='cpy_name'   value='<%=(vo.MPPAYCPY.equals("1")) ? StrUtil.nvl(vo.SELLER_NM):StrUtil.nvl(vo.BUYER_NM)%>'>
<input type='hidden' name='cu_use_yn'  value='<%=StrUtil.nvl(vo.CU_USE_YN)%>'>
<input type='hidden' name='seq'        value='<%=intCtId%>'>
</form>

<form name='frmEnt' method='post'>
<input type='hidden' name='seq' value='<%=intCtId%>'>
<!-- 전자서명 필수값 -->
<input type="hidden" id='bizno' name='bizno' value=''>
<input type='hidden' id='sgn_id' name='sgn_id'><!-- 결과값 : 0000 is validated -->
<input type='hidden' id='signdata' name='signdata'><!-- 결과값 : 서명값 -->
</form>

<h3>결제정보</h3>

<ul class='detail'>
  <li class='th'>계약아이디</li>
  <li class='td'><%=StrUtil.nvl(vo.CTID) %>
    <% 
    if (StrUtil.nvl(vo.CTNO).length()>10) { 
    %>
    [ <strong><%=StrUtil.nvl(vo.CTNO) %></strong> ]
    <% 
    }
    String strCtIdAndCtNo = "매매계약번호 : " + StrUtil.nvl(vo.CTID) + ((StrUtil.nvl(vo.CTNO).length()>10)?" [ " + StrUtil.nvl(vo.CTNO)+" ]":"");
    %>
    <a onclick='getMemoWindow(<%=IntegerCryptoUtil.crypt(strMpFeeCpyId) %>, "<%=strCtIdAndCtNo %>");' class='btn'>메모</a>
  </li>
  <li class='th'>MP세금계산서</li>
  <li class='td'>
    <% 
    if (invoice.BILL_SEQ!=null) {
      out.print("<a href='javascript:viewTaxInvoice("+invoice.BILL_SEQ+");'>"+InvoiceUtil.getStatus(invoice)+" ("+StrUtil.addComma(StrUtil.extractInteger(invoice.strAmountTotal))+"원)</a>");
    }
    if (invoice.BILL_SEQ==null && "060,070".contains(vo.STATUS)) {
      out.print("<a onclick='publishTaxInvoice();' class='btn'>자동발행 실패시 수기발행</a>");
    }
    %>
  </li>
  <li class='th'>구매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.BUYER_NM) %> (<%=FormatUtil.addDashBizNo(vo.BUYER_BIZ_NO) %>, <%=vo.BUYER_CEO_NM %>) <a onclick='goTradePage("<%=IntegerCryptoUtil.crypt(vo.CPYBUYER)%>");' class='btn white'>이동</a></li>
  <li class='th'>판매기업</li>
  <li class='td'><%=StrUtil.nvl(vo.SELLER_NM) %> (<%=FormatUtil.addDashBizNo(vo.SELLER_BIZ_NO) %>, <%=vo.SELLER_CEO_NM %>) <a onclick='goTradePage("<%=IntegerCryptoUtil.crypt(vo.CPYSELLER)%>");' class='btn white'>이동</a></li>
  <li class='th'>결제금액</li>
  <li class='td'><strong style='color:red;'><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></strong>원</li>
  <li class='th'>만기(대출상환)일</li>
  <li class='td'>
    <% 
    if (StrUtil.nvl(vo.MTYDATE).equals("")) out.print("구매사 지정");
    else out.print(FormatUtil.addSeparatorDate(StrUtil.nvl(vo.MTYDATE)) + " [" + (DateTimeUtil.diff(FormatUtil.addSeparatorDate(StrUtil.nvl(vo.TRADEDATE, DateTimeUtil.getCurrentDate(""))), FormatUtil.addSeparatorDate(StrUtil.nvl(vo.MTYDATE)), "/")+1) + "일]");
    %>
  </li>
  <li class='th'>결제은행/수단</li>
  <li class='td'>
    <%
    if (StrUtil.nvl(vo.BNK_NAME).equals("")) out.print("구매사 지정");
    else {
      out.print(StrUtil.nvl(vo.BNK_NAME) + " " + StrUtil.nvl(vo.PAY_SDESC));
      out.print(" <a onclick='checkLimit(true);' class='btn lurian'>한도조회</a>");
    }
    %>
  </li>
  <li class='th'>MP수수료부담</li>
  <li class='td'>
    <%=(vo.MPPAYCPY.equals("1"))?"판매기업":"구매기업"%>
    <a onclick='goMpFeePage();' class='btn'>수수료관리</a>
  </li>
  <li class='th'>계약일</li>
  <li class='td'><%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.TRADEDATE)) %></li>
  <li class='th'>MP수수료</li>
  <li class='td'><%=StrUtil.addComma(StrUtil.extractInteger(vo.MPFEE_TOTALAMT)) %> <i class='fa-solid fa-calculator' onclick='calc(<%=vo.CTID%>);' style='cursor:pointer;'></i></li>
  <li class='th'>계약서구분</li>
  <li class='td'><%=(StrUtil.nvl(vo.CTTYPE).equals("B"))?"구매계약서":"판매계약서" %></li>
  <li class='th'>직거래구분</li>
  <li class='td'><%=(StrUtil.nvl(vo.DIRTYPE).equals("D"))?"직거래":"매매계약서거래" %></li>
  <li class='th'>결제방식</li>
  <li class='td'><%=(StrUtil.nvl(vo.CONFIRM_SETTLE_YN).equals("Y"))?"확인결제":"바로결제" %></li>
  <li class='th'>진행상태</li>
  <li class='td'>
    <strong style='color:blue;'>
    <% if (vo.STATUS.equals("030") || vo.STATUS.equals("040") || vo.STATUS.equals("050") || vo.STATUS.equals("060") || vo.STATUS.equals("070") || vo.STATUS.equals("080") || vo.STATUS.equals("090")) { %>
    <a onclick='showTransactionResult(<%=vo.CTID%>);' class='underline'><%=vo.CODE_NM %></a>
    <% } else { %>
    <%=vo.CODE_NM %>
    <% } %>
    </strong>
    <%
    if (vo.STATUS.equals("060") || vo.STATUS.equals("070")) {
      if (arrK311Results!=null && arrK311Results.size()>0) {
        for (TransactionResultVO tvo : arrK311Results) {
          if (tvo.ORDERNO.equals(vo.CTNO)) {
            out.print(" (" + FormatUtil.addSeparatorDate(tvo.TRANSACTIONDATE) + ") ");
          }
        }
      }
    }
    if (vo.STATUS.equals("040") || (vo.STATUS.equals("050") && vo.BNK_CD.equals("TB"))) {
      out.println("<a onclick='cancelTransaction(\""+IntegerCryptoUtil.crypt(vo.CTID)+"\");' class='btn darkred'>전송취소</a>");
    }
    if (vo.STATUS.equals("030") || vo.STATUS.equals("707")) {
      out.println("<a onclick='sendTransaction(\"N\",\""+IntegerCryptoUtil.crypt(vo.CTID)+"\", \""+CryptoDESUtil.encrypt(vo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "")+"\");' class='btn lurian'>재전송</a>");
      out.println("<a onclick='sendTransaction(\"Y\",\""+IntegerCryptoUtil.crypt(vo.CTID)+"\", \""+CryptoDESUtil.encrypt(vo.CTID+"cjdmasmRlsrmeosnsqlcdms").replaceAll("[^a-zA-Z]", "")+"\");' class='btn white'>결변재전송</a>");
    }
    %>
    
    <a onclick='openChangeStatusWindow(<%=vo.CTID%>);' class='btn darkred'>상태변경</a>
    <a onclick='showChangeStatusLog(<%=vo.CTID%>);' class='btn'>상태변경로그</a>
  </li>
  <li class='th'>구매기업담당자</li>
  <li class='td'>
    <ul>
      <li><a onclick='getSMSWindow(<%=vo.CPYBUYER%>);' class='btn lurian'>문자</a> <a onclick='getMailWindow(<%=vo.CPYBUYER%>);' class='btn white'>메일</a></li>
      <%
      if (arrBuyerPersons!=null && arrBuyerPersons.size()>0) {
        for (PersonVO v : arrBuyerPersons) {
          out.println("<li>" + StrUtil.nvl(v.PRS_NAME) + " (<a href='tel:"+StrUtil.nvl(v.PRS_MOBILE_NO)+"'>"+StrUtil.nvl(v.PRS_MOBILE_NO)+"</a>, "+StrUtil.nvl(v.PRS_TEL)+")</li>");
        }
      }
      %>
    </ul>
  </li>
  <li class='th'>판매기업담당자</li>
  <li class='td'>
    <ul>
      <li><a onclick='getSMSWindow(<%=vo.CPYSELLER%>);' class='btn lurian'>문자</a> <a onclick='getMailWindow(<%=vo.CPYSELLER%>);' class='btn white'>메일</a></li>
      <%
      if (arrSellerPersons!=null && arrSellerPersons.size()>0) {
        for (PersonVO v : arrSellerPersons) {
          out.println("<li>" + StrUtil.nvl(v.PRS_NAME) + " (<a href='tel:"+StrUtil.nvl(v.PRS_MOBILE_NO)+"'>"+StrUtil.nvl(v.PRS_MOBILE_NO)+"</a>, "+StrUtil.nvl(v.PRS_TEL)+")</li>");
        }
      }
      %>
    </ul>
  </li>
</ul>

<h3>첨부세금계산서 정보</h3>

<ul class='detail'>
  <li class='th'>세금계산서 승인번호</li>
  <li class='td'>
    <%
    if (StrUtil.nvl(vo.TAXAPPROVALNO).equals("")) out.print("");
    else out.print("<a onclick='openTaxBill("+StrUtil.nvl(vo.SBILL_SEQ)+");'>"+StrUtil.nvl(vo.TAXAPPROVALNO)+" <i class='fa-regular fa-file'></i></a>");
    %>
  </li>
  <li class='th'>작성일</li>
  <li class='td'><%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.BILL_DT)) %></li>
  <li class='th'>발행금액</li>
  <li class='td'><%=StrUtil.addComma(vo.BILL_SUM) %>원</li>
  <li class='th'>구분</li>
  <li class='td'><%=StrUtil.nvl(vo.TAXTYPE_NM) %> <%=(StrUtil.nvl(vo.CU_USE_YN).equals("Y"))?", 스크랩 거래":"" %></li>
</ul>

<h3>품목정보</h3>

<!-- items table -->
<table id='items' class='detail'>
  <colgroup>
    <col width='*'/>
    <col width='80' class='mobile_hide'/>
    <col width='80' class='mobile_hide'/>
    <col width='90'/>
    <col width='90' class='mobile_hide'/>
    <col width='100'/>
  </colgroup>
  <thead>
    <tr>
      <th class='left'>품목</th>
      <th class='right mobile_hide'>수량</th>
      <th class='left mobile_hide'>단위</th>
      <th class='right'>공급가</th>
      <th class='right mobile_hide'>세액</th>
      <th class='right'>총액</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CtItemVO ivo : arr) {
%>
    <tr>
      <td><%=StrUtil.nvl(ivo.ITEMNAME) %></td>
      <td class='right mobile_hide'><%=StrUtil.addComma(ivo.QTY) %></td>
      <td class=' mobile_hide'><%=StrUtil.nvl(ivo.UNIT) %></td>
      <td class='right'><%=StrUtil.addComma(ivo.SUPPLYAMT) %></td>
      <td class='right mobile_hide'><%=StrUtil.addComma(ivo.TAXAMT) %></td>
      <td class='right'><%=StrUtil.addComma(ivo.TOTALAMT) %></td>
    </tr>
<%
  }
}
%>    
  </tbody>
</table>

<h3>진행정보</h3>

<ul class='detail'>
  <li class='th'>구매사아이피</li>
  <li class='td'><%=StrUtil.nvl(vo.BUYER_IP) %></li>
  <li class='th'>구매사서명</li>
  <li class='td'><%=getSignData(StrUtil.nvl(vo.SGN_ID), arrSigns) %></li>
  <li class='th'>판매자아이피</li>
  <li class='td'><%=StrUtil.nvl(vo.SELLER_IP) %></li>
  <li class='th'>판매사서명</li>
  <li class='td'><%=getSignData(StrUtil.nvl(vo.SELLER_APP_SGN_ID), arrSigns) %></li>
</ul>

<%
if (arrUnusuals!=null && arrUnusuals.size()>0) {
%>
<h3>이상거래</h3>
<ul style='border-top:1px solid #ddd;'>
<%
  for (UnusualTransactionVO uvo : arrUnusuals) {
    String strBtn = "<a onclick='openReleasePage("+uvo.SEQ+");' class='btn darkred'>관리</a>";
    String strReleasedPre = (uvo.USE_YN.equals("N")) ? "<font color='red'>[진행]</font> " : "<font color='#777'>[해제]</font> ";
    String strReleased = (uvo.USE_YN.equals("N")) ? "" : "[해제 : "+uvo.USE_ID+", "+uvo.USE_TIME+"]";
%>
  <li style='padding:10px 0;border-bottom:1px solid #ddd;line-height:1.5em;'>
    <span style='display:inline-block;vertical-align:top;'><%=strReleasedPre%><%=uvo.CONTENT %></span>
    <span style='display:inline-block;vertical-align:top;margin-left:30px;'><%=strBtn %> <%=strReleased %></span>
  </li>
<%
  }
%>
</ul>
<%
}
%>

<p>&nbsp;</p>

<div class='btns'>

</div>

<iframe id='ifmContract'></iframe>
<%=WebPageCtrlUtil.getHistoryBack(session) %>
<%@ include file="../Footer.jsp" %>