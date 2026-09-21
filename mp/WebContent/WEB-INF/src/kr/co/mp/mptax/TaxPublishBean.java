package kr.co.mp.mptax;

import org.apache.log4j.Logger;

import kr.co.funology.fw.util.StrUtil;
import kr.co.mp.kakaotalk.TalkCtrl;

public class TaxPublishBean {

  private static final Logger logger = Logger.getLogger(TaxPublishBean.class);

  public static class PublishResult {
    public int successCount = 0;
    public int failCount    = 0;
  }

  /**
   * billSeq 목록을 세금계산서로 발행한다. (TaxPublishProc.jsp, 자동발행 트리거 공용)
   */
  public PublishResult publish(String[] billSeqs) {
    PublishResult result = new PublishResult();
    if (billSeqs == null) return result;

    InvoiceDAO dao = new InvoiceDAO();
    Tax tax;
    try {
      tax = new Tax();
    } catch (Exception e) {
      logger.error("Tax 클라이언트 초기화 실패", e);
      result.failCount = billSeqs.length;
      return result;
    }

    for (String seqStr : billSeqs) {
      if (!StrUtil.isOnlyNumeric(seqStr)) continue;
      int billSeq = Integer.parseInt(seqStr);
      try {
        InvoiceVO vo = dao.T_BILL_DETAIL_PROC(billSeq);
        int taxResult = tax.RegistAndIssueTaxInvoice(vo);
        dao.T_BILL_UPDATE_STATUS_PROC(billSeq, taxResult, "");

        if (taxResult == 1) {
          result.successCount++;
          TalkCtrl.sendBySystem("M003", 0, 0, billSeq);
        } else {
          result.failCount++;
          logger.warn("계산서 발행 실패 billSeq=" + billSeq + " taxResult=" + taxResult);
        }
      } catch (Exception e) {
        result.failCount++;
        logger.error("계산서 발행 중 예외 발생 billSeq=" + billSeq, e);
      }
    }
    return result;
  }
}
