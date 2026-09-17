package kr.co.mp.trade;

import java.util.ArrayList;
import java.util.List;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.tax.TaxInvoiceVO;
import kr.co.funology.fw.util.tax.TaxLineItemVO;
/**
 * 세금계산서XML을 데이터베이스에 추가하기 위한 클래스
 */
public class TaxBean {

  TaxDAO dao;
  public TaxBean() {
    this.dao = new TaxDAO();
  }
  
  /**
   * 세금계산서XML을 데이터베이스 마스터 테이블 컬럼에 맞춘다.
   * 
   * @param ovo 세금계산서XML을 파싱한 VO
   * @param strItemName 주요품목
   * @param intCpyId 등록회원사아이디
   * @return
   */
  private TaxVO changeTaxProtocolToDatabaseColume(TaxInvoiceVO ovo, String strItemName, int intCpyId) {
    TaxVO v = new TaxVO();
    v.BILL_NO        = StrUtil.nvl(ovo.id);
    v.APP_NO         = StrUtil.nvl(ovo.issueId);
    v.BILL_DT        = StrUtil.nvl(ovo.issueDateTime).substring(0,8);
    v.BILL_TYPE      = StrUtil.nvl(ovo.typeCode).substring(0,2);
    v.BILL_GUBUN     = StrUtil.nvl(ovo.purposeCode);
    v.PAY_TAX_RATE   = StrUtil.nvl(ovo.typeCode).substring(2,4);
    v.SCOMP_VENDERNO = StrUtil.nvl(ovo.invoicerRegistrationId);
    v.SCOMP_NAME     = StrUtil.nvl(ovo.invoicerName);
    v.SCOMP_CEO      = StrUtil.nvl(ovo.invoicerSpecifiedPerson);
    v.SCOMP_ADDRESS  = StrUtil.nvl(ovo.invoicerSpecifiedAddress);
    v.SCOMP_TYPE     = StrUtil.nvl(ovo.invoicerTypeCode);
    v.SCOMP_CLASS    = StrUtil.nvl(ovo.invoicerClassificationCode);
    v.RCOMP_VENDERNO = StrUtil.nvl(ovo.invoiceeRegistrationId);
    v.RCOMP_NAME     = StrUtil.nvl(ovo.invoiceeName);
    v.RCOMP_CEO      = StrUtil.nvl(ovo.invoiceeSpecifiedPerson);
    v.RCOMP_ADDRESS  = StrUtil.nvl(ovo.invoiceeSpecifiedAddress);
    v.RCOMP_TYPE     = StrUtil.nvl(ovo.invoiceeTypeCode);
    v.RCOMP_CLASS    = StrUtil.nvl(ovo.invoiceeClassificationCode);
    v.PAY_SUM_AMOUNT = StrUtil.nvl(ovo.totalAmount);
    v.PAY_SUM_TAX    = StrUtil.nvl(ovo.taxAmount);
    v.ITEM_NAME      = StrUtil.nvl(strItemName).replaceAll("\"", "");
    v.CPY_ID         = intCpyId; 
    return v;
  }
  /**
   * 세금계산서XML의 품목정보를 데이터베이스 컬럼에 맞춘다.
   * 
   * @param lineItems 세금계산서 품목정보를 파싱한 VO배열
   * @return
   */
  private String changeTaxItemProtocolToXml(List<TaxLineItemVO> lineItems) {
    String strXml = "<Items>";
    if (lineItems!=null && lineItems.size()>0) {
      for (int i=0; i<lineItems.size();) {
        TaxLineItemVO v = lineItems.remove(i);
        Double dblPrice;
        String strPrice = StrUtil.nvl(v.invoiceAmount);
        String strCnt  = StrUtil.nvl(v.chargeableUnitQuantity, "1");
        if (StrUtil.isOnlyNumeric(v.invoiceAmount) && StrUtil.isOnlyNumeric(strCnt)) {
          dblPrice = Double.parseDouble(v.invoiceAmount) / Double.parseDouble(strCnt);
          strPrice = String.format("%.0f", dblPrice);
        }
        if (!StrUtil.isOnlyNumeric(v.sequenceNumeric)) v.sequenceNumeric = Integer.toString((i+1));
        strXml += "<Item>";
        strXml += "<ITEM_SEQ>"+v.sequenceNumeric+"</ITEM_SEQ>";
        strXml += "<ITEM_NAME>"+StrUtil.nvl(v.nameText).replaceAll("&amp;", "&").replaceAll("&", "&amp;").replace("외", "").replaceAll("\"", "")+"</ITEM_NAME>"; // 왜?
        strXml += "<ITEM_PRICE>"+strPrice+"</ITEM_PRICE>";
        strXml += "<ITEM_CNT>"+strCnt+"</ITEM_CNT>";
        strXml += "<ITEM_UNIT>"+StrUtil.nvl(v.informationText, "건")+"</ITEM_UNIT>";
        strXml += "<ITEM_AMOUNT>"+v.invoiceAmount+"</ITEM_AMOUNT>";
        strXml += "<ITEM_TAX>"+v.totalTax+"</ITEM_TAX>";
        strXml += "<ITEM_DT>"+v.purchaseExpiryDateTime+"</ITEM_DT>";
        strXml += "</Item>";
      }
    }
    strXml += "</Items>";
    return strXml;
  }
  /**
   * 대표품목을 추출한다.
   * 
   * @param lineItems
   * @return
   */
  private String getMainItemName(List<TaxLineItemVO> lineItems) {
    String str = "";
    if (lineItems!=null && lineItems.size()>0) {
      str = StrUtil.nvl(lineItems.get(0).nameText).replaceAll("\"", "");
    }
    return str;
  }
  /**
   * 세금계산서정보를 디비에 저장한다
   * @param ovo 세금계산서 정보
   * @param intCpyId 회원사아이디
   * @return 매매계약용 세금계산서정보(CT_BILL_MASTER)의 SBILL_SEQ
   */
  public int CT_BILL_ADD_PROC(TaxInvoiceVO ovo, int intCpyId) {
    TaxVO vo = this.changeTaxProtocolToDatabaseColume(ovo, getMainItemName(ovo.lineItems), intCpyId);
    String strItemXml = this.changeTaxItemProtocolToXml(ovo.lineItems);
    return this.dao.CT_BILL_ADD_PROC(vo, strItemXml);
  }
  /**
   * 매매계약에 사용할 세금계산서정보를 가져온다
   * @param intPage 페이지
   * @param intRowCnt 페이지당 출력항목수
   * @param intCpyId 회원사아이디
   * @param intTargetCpyId 대상회원사아이디
   * @param strStartYmd 검색시작일
   * @param strEndYmd 검색마감일
   * @return 매매계약에 사용할 세금계산서정보
   */
  public ArrayList<TaxVO> CT_BILL_FOR_TRADE_LIST_PROC(int intPage, int intRowCnt, int intCpyId, int intTargetCpyId, String strStartYmd, String strEndYmd) {
    if (intCpyId>0) return this.dao.CT_BILL_FOR_TRADE_LIST_PROC(intPage, intRowCnt, intCpyId, intTargetCpyId, strStartYmd, strEndYmd);
    return null;
  }
  /**
   * 매매계약에 사용할 세금계산서의 상세정보를 가져온다.
   * 
   * @param strBillSeq 매매계약용 세금계산서정보의 SBILL_SEQ
   * @return 세금계산서 상세정보
   */
  public TaxVO CT_BILL_MASTER_DETAIL_PROC(String strBillSeq) {
    return this.dao.CT_BILL_MASTER_DETAIL_PROC(strBillSeq);
  }
  /**
   * 매매계약에 사용할 세금계산서의 품목을 가져온다.
   * 
   * @param strBillSeq 매매계약용 세금계산서정보의 SBILL_SEQ
   * @return 세금계산서의 품목
   */
  public ArrayList<TaxItemVO> CT_BILL_ITEM_DETAIL_PROC(String strBillSeq) {
    return this.dao.CT_BILL_ITEM_DETAIL_PROC(strBillSeq);
  }
  /**
   * 매매계약에 사용할 세금계산서를 삭제한다.
   * 
   * @param strBillSeq 매매계약용 세금계산서정보의 SBILL_SEQ
   * @return 삭제되었으면 Y
   */
  public String CT_BILL_DROP_PROC(String strBillSeq) {
    return this.dao.CT_BILL_DROP_PROC(strBillSeq);
  }
  
}
