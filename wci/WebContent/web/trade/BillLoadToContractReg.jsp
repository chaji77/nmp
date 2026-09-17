<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxItemVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = StrUtil.nvl(request.getParameter("seq"));
// System.out.println(strBillSeq);
TaxBean bean = new TaxBean();
TaxVO t = new TaxVO();
BigDecimal fsum   = new BigDecimal(0);
BigDecimal fa_sum = new BigDecimal(0);
BigDecimal fv_sum = new BigDecimal(0);
StringBuffer sbItems = new StringBuffer();
ArrayList<TaxItemVO> arr= new ArrayList<>();
if (StrUtil.isOnlyNumeric(strBillSeq)) {
  t = bean.CT_BILL_MASTER_DETAIL_PROC(strBillSeq);
  arr = bean.CT_BILL_ITEM_DETAIL_PROC(strBillSeq);
  BigDecimal fa = (StrUtil.isOnlyNumeric(t.PAY_SUM_AMOUNT)) ? new BigDecimal(t.PAY_SUM_AMOUNT) : new BigDecimal(0);
  BigDecimal fv = (StrUtil.isOnlyNumeric(t.PAY_SUM_TAX)) ? new BigDecimal(t.PAY_SUM_TAX) : new BigDecimal(0);
  fsum = fa.add(fv);
  if (arr!=null && arr.size()>0) {
    for (TaxItemVO ivo : arr) {
      BigDecimal ia = (StrUtil.isOnlyNumeric(ivo.ITEM_AMOUNT)) ? new BigDecimal(ivo.ITEM_AMOUNT) : new BigDecimal(0);
      BigDecimal iv = (StrUtil.isOnlyNumeric(ivo.ITEM_TAX)) ? new BigDecimal(ivo.ITEM_TAX) : new BigDecimal(0);
      fa_sum.add(ia);
      fv_sum.add(iv);
      BigDecimal isum = ia.add(iv);
      sbItems.append("<tr class='load_mode_tr'>");
      sbItems.append("<input type='hidden' name='item_qty' value='"+ivo.ITEM_CNT+"'>");
      sbItems.append("<td><input type='text' name='item_nm' value='"+StrUtil.input(ivo.ITEM_NAME)+"' readonly></td>");
      sbItems.append("<td class='item_cnt right mobile_hide' style='padding-right:10px;'>"+StrUtil.addComma(ivo.ITEM_CNT)+"</td>");
      sbItems.append("<td><input type='text' name='item_unit' value='"+StrUtil.input(ivo.ITEM_UNIT)+"'></td>");
      sbItems.append("<td class='item_amount right' style='padding-right:10px;'>"+StrUtil.addCommaAfterRound(ivo.ITEM_AMOUNT)+"</td>");
      sbItems.append("<td class='item_tax right mobile_hide' style='padding-right:10px;'>"+StrUtil.addCommaAfterRound(ivo.ITEM_TAX)+"</td>");
      sbItems.append("<td><input type='text' name='item_sum' value='"+StrUtil.addCommaAfterRound(isum.toPlainString())+"' maxlength='12' class='numput'></td>");
      sbItems.append("<td class='center'><a onclick='dropItem(this);' class='btn'><i class='fa fa-trash' aria-hidden='true'></i></a></td>");
      sbItems.append("</tr>");
    }
  }
}
// System.out.println(sbItems.toString());

String strTaxBizType = "G";
if (t.BILL_TYPE.equals("03")) strTaxBizType = "E";
if (t.PAY_TAX_RATE.equals("02")) strTaxBizType = "S";
%>
<script>
/* set default values ​​for selected tax invoices @ContractReg.jsp */
$("input[name='sbill_seq']").val("<%=strBillSeq%>"); // 세금계산서일련번호
$("input[name='bill_app_no']").val("<%=StrUtil.nvl(t.APP_NO)%>"); // 승인번호
$("input[name='bill_ymd']").val("<%=FormatUtil.addSeparatorDate(StrUtil.nvl(t.BILL_DT)) %>"); // 작성일
$("input[name='bill_amt']").val("<%=StrUtil.addCommaAfterRound(fsum.toPlainString()) %>"); // 발행금액
if ($("input[name='permmit_bill_items_yn']").val()!="N") {
  $('#bill-item-list').html("<%=sbItems.toString()%>"); // 품목정보
  $('#item_total_amount').text("<%=StrUtil.addCommaAfterRound(fa_sum.toPlainString())%>"); // 공급가 합계금액
  $('#item_total_tax').text("<%=StrUtil.addCommaAfterRound(fv_sum.toPlainString())%>"); // 부가세 합계금액
  $('#item_total_sum').text("<%=StrUtil.addCommaAfterRound(fsum.toPlainString())%>"); // 발행금액
  $("input:radio[name='tax_biz_type']:input[value='<%=strTaxBizType%>']").prop("checked", true);
}
$("a.btnItemWriteMode").hide();

toggleBills(); // close tax invoice window$
hideLoading(); // hide loading spinner
changeTaxRate();

/* set readonly to partner-selector @ContractReg.jsp */
$(".cannot-changable").hide();
$("select[name='seller_cpy_id']").prop("disabled", true);
$("#items tfoot").show();

/* input event for item's total amount */
$(".numput").on("input", function () {
  calcItem(this);
});
</script>