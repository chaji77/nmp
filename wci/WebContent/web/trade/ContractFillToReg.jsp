<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.WebPageCtrlUtil" %>
<%@ page import="kr.co.mp.common.MobileUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.CtItemVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ page import="kr.co.mp.c.RelationCompanyVO" %>
<%@ page import="kr.co.mp.c.RelationCompanyBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
Logger logger = Logger.getLogger(this.getClass());
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
int intCtId = 0;
try {
  intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
} catch (Exception e) {
  logger.debug("No Logging CpyId : " + StrUtil.nvl(request.getParameter("seq")));
}
if (intCtId==0) return;

String MOBILE_YN          = StrUtil.nvl((String)pageContext.getAttribute("MOBILE_YN"), "N");
String SIGN_EXCLUDE_YN    = StrUtil.nvl((String)pageContext.getAttribute("SIGN_EXCLUDE_YN"), "N");
if (MOBILE_YN.equals("Y") && MobileUtil.isMobile(request)) SIGN_EXCLUDE_YN = "Y"; // MOBILE APPROVAL IS REGISTERED, AND IF IT IS A MOBILE ENVIRONMENT, THE SIGNATURE IS EXCLUDED.

TradeBean bean = new TradeBean();
CtHeaderVO vo = bean.CT_HEADER_DETAIL_PROC(intCtId);
ArrayList<CtItemVO> arr = bean.CT_ITEM_LIST_PROC(intCtId);

String strError = "<script>showAlert('사용할 수 없는 매매계약서입니다.',function(){location.href='"+request.getContextPath()+"/web/trade/index.jsp';});</script>";

if (vo==null || StrUtil.nvl(vo.CTID).equals("") || arr==null || arr.size()==0) {
  System.out.println(vo.toString());
  out.print(strError);
  return;
}
if (!vo.CPYBUYER.equals(strCpyId) && !vo.CPYSELLER.equals(strCpyId)) {
  out.print(strError);
  return;
}

StringBuffer sbItems = new StringBuffer();
if (arr!=null && arr.size()>0) {
  for (CtItemVO ivo : arr) {
    sbItems.append("<input type='hidden' name='item_qty' value='"+ivo.QTY+"'>");
    sbItems.append("<tr>");
    sbItems.append("<td><input type='text' name='item_nm' value='"+ivo.ITEMNAME+"'></td>");
    sbItems.append("<td class='item_cnt right mobile_hide' style='padding-right:10px;'>"+StrUtil.addComma(ivo.QTY)+"</td>");
    sbItems.append("<td><input type='text' name='item_unit' value='"+StrUtil.input(ivo.UNIT)+"'></td>");
    sbItems.append("<td class='item_amount right' style='padding-right:10px;'>"+StrUtil.addComma(ivo.SUPPLYAMT)+"</td>");
    sbItems.append("<td class='item_tax right mobile_hide' style='padding-right:10px;'>"+StrUtil.addComma(ivo.TAXAMT)+"</td>");
    sbItems.append("<td><input type='text' name='item_sum' value='"+StrUtil.addComma(ivo.TOTALAMT)+"' maxlength='12' class='numput'></td>");
    sbItems.append("<td class='center'><a onclick='dropItem(this);' class='btn'><i class='fa fa-trash' aria-hidden='true'></i></a></td>");
    sbItems.append("</tr>");
  }
}

String strRelatedCompaies = "0000000000";
if (!vo.CPYSELLER.equals("0") && StrUtil.isOnlyNumeric(vo.CPYSELLER)) {
  int intTargetCpyId = Integer.parseInt(vo.CPYSELLER);
  ArrayList<RelationCompanyVO> arrRelatedCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intTargetCpyId, "Y");
  if (arrRelatedCompanies!=null && arrRelatedCompanies.size()>0) {
    for (RelationCompanyVO v : arrRelatedCompanies) {
      strRelatedCompaies += "," + v.RELATIONBIZNO;
    }
  }
}

%>
<script>
$("input[name='cttype']").val("<%=StrUtil.nvl(vo.CTTYPE, "B")%>");
$("input[name='sbill_seq']").val("<%=vo.SBILL_SEQ%>"); // 세금계산서일련번호
$("input[name='contract_amt']").val("<%=StrUtil.addComma(vo.TOTALCONTRACTAMT)%>"); // 계약금액
$("input[name='bill_buyer_biz_no']").val("<%=vo.BUYER_BIZ_NO%>"); // 공급받는자사업자번호
$("input[name='bill_seller_biz_no']").val("<%=vo.SELLER_BIZ_NO%>"); // 공급자사업자번호
$("input[name='seller_related_biz_nos']").val("<%=strRelatedCompaies%>"); // add headquarters/branch information of seller
$("input[name='bill_app_no']").val("<%=vo.TAXAPPROVALNO %>"); // 승인번호
$("input[name='bill_ymd']").val("<%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.BILL_DT)) %>"); // 작성일
$("input[name='bill_amt']").val("<%=StrUtil.addCommaAfterRound(vo.BILL_SUM) %>"); // 합계금액
$("input[name='bill_max_limit']").val("<%=StrUtil.addCommaAfterRound(vo.BILL_SUM) %>"); // 합계금액
$("input[name='tax_biz_type'][value='<%=vo.TAXBIZTYPE%>']").prop("checked", true);

$('#bill-item-list').html("<%=sbItems.toString()%>"); // 품목정보
$('#item_total_amount').text("<%=StrUtil.addComma(vo.SUPPLYAMT)%>"); // 공급가 합계금액
$('#item_total_tax').text("<%=StrUtil.addComma(vo.TAXAMT)%>"); // 부가세 합계금액
$('#item_total_sum').text("<%=StrUtil.addComma(vo.TOTALCONTRACTAMT)%>"); // 계약금액

/* set readonly to partner-selector @ContractReg.jsp */
$(".cannot-changable").hide();
$("#items tfoot").show();

$("input[name='maturity_ymd']").val("<%=FormatUtil.addSeparatorDate(vo.MTYDATE, "-")%>");
$("#maturity-cnt span").html("[ <%=DateTimeUtil.diff(DateTimeUtil.getCurrentDate("/"), FormatUtil.addSeparatorDate(StrUtil.nvl(vo.MTYDATE)), "/")+1 %>일 ]");
$("#maturity-cnt").show();

/************** PAYMENT **************/
$("select[name='bnk_pay_id']").val('<%=vo.BNK_CD %>____<%=vo.PAY_ID %>');

/************** SELLER **************/
var temp_seller_cpy_val = "";
$("select[name='seller_cpy_id'] option").each(
  function(){
    if (this.value.indexOf('<%=vo.CPYSELLER%>____')>-1) {
      temp_seller_cpy_val = this.value;
    }
  }
);
$("select[name='seller_cpy_id']").val(temp_seller_cpy_val);

/* For contracts received from vendors not registered with my business partner */
if (temp_seller_cpy_val == "") { 
  temp_seller_cpy_val = '<%=vo.CPYSELLER%>____<%=vo.SELLER_BIZ_NO%>____N';
  $("select[name='seller_cpy_id']").append("<option value="+temp_seller_cpy_val+" selected><%=StrUtil.nvl(vo.SELLER_NM) %> (<%=FormatUtil.addDashBizNo(vo.SELLER_BIZ_NO) %>, <%=vo.SELLER_CEO_NM %>)</option>");
}
$("select[name='seller_cpy_id']").prop("disabled", true);
checkSeller();

/************** BUYER **************/
/* If you are drafting a sales contract */
if (window.location.href.indexOf("ContractRegForSeller")) {
  var addBtn = "<a onclick='addItemRow();' class='btn'><i class='fa-solid fa-plus'></i></a> ";
  $("#bill-item-list tr>td:last-child").prepend(addBtn);
  
  var temp_buyer_cpy_val = "";
  $("select[name='buyer_cpy_id'] option").each(
    function(){
      if (this.value.indexOf('<%=vo.CPYBUYER%>____')>-1) {
        temp_buyer_cpy_val = this.value;
      }
    }
  );
  $("select[name='buyer_cpy_id']").val(temp_buyer_cpy_val);
}

/************** MPPAY **************/
$("input[name='mp_pay_cpy'][value='<%=vo.MPPAYCPY %>']").prop("checked", true);

$(".numput").on("input", function () {
  calcItem(this);
});

/************** REVERSE ORDER **************/
<%
if (StrUtil.nvl(vo.CTTYPE).equals("S") && StrUtil.nvl(vo.STATUS).equals("020")) {
  String strTitle = "계약승인";
%>
  document.title = '<%=strTitle%>';
  $("div.page-title-block span.title").text('<%=strTitle%>');
  $("input[name='permmit_bill_items_yn']").val("N");
  $("input[name='mp_pay_cpy'], input[name='tax_biz_type']").prop("disabled", true);
  $("#bill-item-list input").prop("readonly", true);
  $("#items tfoot").show();
  $("div.btns").html("<a onclick='save(<%=(SIGN_EXCLUDE_YN.equals("Y"))?"goSubmit":"loadCert"%>);'><i class='fa fa-paper-plane'></i> &nbsp;승인</a>");
<%
}
%>

hideSpinner();
</script>

