package kr.co.mp.trade;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;

import kr.co.funology.fw.util.StrUtil;

/**
 * 싸이클론 결제전송관리 상세.
 * CYCLN_ORDER_DETAIL_PROC 가 돌려주는 결과셋 5개를 한 VO 에 담는다.
 */
public class CyclnOrderDetailVO {
  /* (1) 발주계약서정보 */
  public String ORDERNO       = ""; // 매매계약번호
  public String TRADEDATE     = ""; // 거래일자
  public String ORDERNAME     = ""; // 발주계약서명
  public String REQDLVDATE    = ""; // 요청납기일
  public String CPYBUYER      = ""; // 구매기업 CPY_ID
  public String BC_NAME       = ""; // 구매기업명
  public String CPYSELLER     = ""; // 판매기업 CPY_ID
  public String SC_NAME       = ""; // 판매기업명
  public String DLVADDRESS    = ""; // 도착지
  public String STATUS        = ""; // 발주계약서 상태
  public String ESTIMATE_TYPE = ""; // 계산서 종류. 1-과세계산서(VAT 포함)
  public String TRX_CLS       = ""; // 거래구분(CL100.TRX_CLS) 01-결제, 02-취소
  public String CQ090_STATUS  = ""; // 결제예정전문 처리상태(CYCLN_QUEUE.STATUS). 은행접수 단계
  public String CQ100_STATUS  = ""; // 결제상태(CYCLN_QUEUE.STATUS)
  public String ROLE          = ""; // 보는 사람의 입장. B-구매기업, S-판매기업
  public String CODE_NM       = ""; // 상태 표시명(CYCLN_ORDER_STATUS)
  public String TMSG_FAIL_YN  = ""; // 마지막 CL080·CL090 전문발송 실패 여부(Y/N)

  /* 변경요청·취소요청 판단용. 거래당사자 상세(CYCLN_ORDER_DETAIL_PER_CPY_ID_PROC)만 채운다. */
  public String C080_TRX_CLS  = ""; // 마지막 매매계약전문(CL080) 거래구분
  public String CQ080_STATUS  = ""; // 마지막 매매계약전문 처리상태
  public String C090_TRX_CLS  = ""; // 마지막 결제예정전문(CL090) 거래구분
  public String HAS_CL100     = ""; // 결제통보(CL100)를 받았으면 Y
  public String CHG_PENDING   = ""; // 변경요청이 상대 승인을 기다리면 Y

  /* 이 상태에서 이 사람이 할 수 있는 조치. CYCLN_ORDER_STATUS 의 Y/N 플래그. */
  public String CAN_CANCEL  = ""; // 취소
  public String CAN_CONFIRM = ""; // 확정
  public String CAN_CHGREQ  = ""; // 변경요청
  public String CAN_CANREQ  = ""; // 취소요청
  public String CAN_CHGCFM  = ""; // 변경승인
  public String CAN_CANCFM  = ""; // 취소승인

  /* 결제정보. 결제전문이 없으면 전부 빈값이다. */
  public String REGTIME        = ""; // 등록일시(CYCLN_ORDER.CRETIME)
  public String PAYTIME        = ""; // 결제일시(CYCLN_SETTLE.CRETIME)
  public String PURC_PRIC      = ""; // 발주계약금액(CL080)
  public String SETL_PLN_PRIC  = ""; // 결제예정금액(CL090)
  public String SETL_PLN_YMD   = ""; // 결제예정일(CL090)
  public String TAX_ISSU_YMD   = ""; // 세금계산서발행일(CL090)
  public String SETL_PRIC      = ""; // 실결제금액(CL100)
  public String SFCP_SETL_PRIC = ""; // 자기자금결제금액(CL100)
  public String BYCA_LOAN_PRIC = ""; // 구매자금대출금액(CL100)
  public String MTR_YMD        = ""; // 만기일, 대출상환날짜(CL100)

  /**
   * 결제가 끝난 건인지 본다. 결제전문이 있고 거래구분이 결제(01)여야 한다.
   * 결제취소(02)는 결제완료로 보지 않는다.
   */
  public boolean isSettled() {
    return "2".equals(StrUtil.nvl(this.CQ100_STATUS)) && "01".equals(StrUtil.nvl(this.TRX_CLS));
  }

  /** 보는 사람이 판매기업인지. */
  public boolean isSeller() {
    return CyclnOrderVO.ROLE_SELLER.equals(StrUtil.nvl(this.ROLE));
  }

  /** 이미 취소된 건인지. */
  public boolean isCancelled() {
    String strStatus = StrUtil.nvl(this.STATUS).trim();
    return CyclnOrderVO.STATUS_BUYER_CANCEL.equals(strStatus)
        || CyclnOrderVO.STATUS_SELLER_CANCEL.equals(strStatus);
  }

  /**
   * 판매기업이 아직 승인하지 않은 건인지.
   * 승인해야 CL080 전문이 처음 생기고 발주계약금액이 채워지므로, 비어 있으면 승인 전이다.
   */
  public boolean isBeforeConfirm() {
    return StrUtil.nvl(this.PURC_PRIC).trim().equals("");
  }

  /**
   * 판매기업이 승인할 수 있는 건인지.
   * 상태별 확정 가능 여부는 CYCLN_ORDER_STATUS 가 정하고 프로시저가 역할에 맞게 돌려준다.
   * 결제전문이 이미 처리된 건은 금액이 바뀌면 안 되므로 막는다.
   */
  public boolean canConfirm() {
    return isSeller() && "Y".equals(StrUtil.nvl(this.CAN_CONFIRM))
        && StrUtil.nvl(this.CQ100_STATUS).trim().equals("");
  }

  /** 구매기업이 발주계약서를 고칠 수 있는 건인지. 판매기업 승인 전까지만 된다. */
  public boolean canModify() {
    return !isSeller() && isBeforeConfirm() && !isCancelled();
  }

  /**
   * 발주가 확정된 건인지. 판매기업 승인으로 들어가는 상태다.
   * 승인 뒤 변경요청(020·025)을 거친 건도 확정으로 본다. 변경이 끝나면 그 상태로 다음 단계를 간다.
   */
  public boolean isConfirmed() {
    String strStatus = StrUtil.nvl(this.STATUS).trim();
    return CyclnOrderVO.STATUS_CONFIRMED.equals(strStatus)
        || CyclnOrderVO.STATUS_BUYER_CHGREQ.equals(strStatus)
        || CyclnOrderVO.STATUS_SELLER_CHGREQ.equals(strStatus);
  }

  /** 취소요청(030·035)한 건인지. 이 상태에서는 남은 취소전문 말고는 더 진행하지 않는다. */
  public boolean isCancelRequested() {
    String strStatus = StrUtil.nvl(this.STATUS).trim();
    return CyclnOrderVO.STATUS_SELLER_CANREQ.equals(strStatus)
        || CyclnOrderVO.STATUS_BUYER_CANREQ.equals(strStatus);
  }

  /** 변경요청이 상대 승인을 기다리는지. */
  public boolean isChgPending() {
    return "Y".equals(StrUtil.nvl(this.CHG_PENDING).trim());
  }

  /** 기다리는 변경요청을 이 사람이 낸 것인지. 020 은 구매기업, 025 는 판매기업이 낸 요청이다. */
  public boolean isChgRequester() {
    String strStatus = StrUtil.nvl(this.STATUS).trim();
    return isSeller() ? CyclnOrderVO.STATUS_SELLER_CHGREQ.equals(strStatus)
                      : CyclnOrderVO.STATUS_BUYER_CHGREQ.equals(strStatus);
  }

  /** 결제통보(CL100)를 받았는지. 받으면 변경도 취소도 할 수 없다. */
  public boolean hasCl100() {
    return "Y".equals(StrUtil.nvl(this.HAS_CL100).trim());
  }

  /** 마지막 매매계약전문(CL080)이 은행에서 정상 처리된 등록·변경 전문인지. */
  public boolean isCl080Done() {
    return "2".equals(StrUtil.nvl(this.CQ080_STATUS).trim())
        && !CyclnOrderVO.TRX_CANCEL.equals(StrUtil.nvl(this.C080_TRX_CLS).trim());
  }

  /**
   * 은행에 살아 있는 매매계약이 있는지. 마지막 전문이 정상 처리됐거나,
   * 변경(02) 전문만 실패해 앞서 처리된 계약이 그대로 남아 있는 경우다.
   * 변경 실패 뒤에도 다시 변경요청하거나 취소할 수 있게 한다.
   */
  public boolean isCl080Alive() {
    String strQ080 = StrUtil.nvl(this.CQ080_STATUS).trim();
    return isCl080Done()
        || ("9".equals(strQ080) && CyclnOrderVO.TRX_CHANGE.equals(StrUtil.nvl(this.C080_TRX_CLS).trim()));
  }

  /** 결제예정전문(CL090)이 한 건이라도 나갔는지. 전문이 없으면 거래구분이 비어 온다. */
  public boolean hasCl090() {
    return !StrUtil.nvl(this.C090_TRX_CLS).trim().equals("");
  }

  /** 마지막 결제예정전문이 취소 전문인지. */
  public boolean isCl090Cancelled() {
    return CyclnOrderVO.TRX_CANCEL.equals(StrUtil.nvl(this.C090_TRX_CLS).trim());
  }

  /**
   * 변경요청을 낼 수 있는지. 매매계약전문(CL080)이 정상 처리된 뒤, 결제예정전문(CL090)이 나가기 전까지만 된다.
   * 상대의 변경요청을 기다리는 동안에는 받은 쪽만 내용을 다시 고쳐 요청할 수 있다.
   */
  public boolean canChgReq() {
    return isConfirmed() && isCl080Alive() && !hasCl090() && !hasCl100()
        && !(isChgPending() && isChgRequester());
  }

  /** 상대가 낸 변경요청을 승인할 수 있는지. 승인하면 CL080 변경(02) 전문이 나간다. */
  public boolean canChgCfm() {
    return isConfirmed() && isCl080Alive() && !hasCl090() && !hasCl100()
        && isChgPending() && !isChgRequester();
  }

  /**
   * 지금 보내야 할 취소전문. 취소할 수 없으면 빈 문자열이다.
   *   - 결제통보(CL100)를 받았으면 취소할 수 없다.
   *   - 결제예정전문(CL090)이 정상 처리돼 있으면 CL090 부터 취소한다.
   *   - CL090 이 없거나 그 취소가 정상 처리됐으면 CL080 을 취소한다.
   *   - 앞 전문이 은행 처리를 기다리는 중이면 기다린다.
   * 취소요청(030·035)한 뒤에도 CL080 취소가 남았으면 이어서 보낼 수 있다.
   */
  public String getCancelKncd() {
    if (hasCl100()) return "";
    if (!isConfirmed() && !isCancelRequested()) return "";
    String strQ090 = StrUtil.nvl(this.CQ090_STATUS).trim();
    if (hasCl090() && !isCl090Cancelled()) {
      // 접수 중이면 기다리고, 접수가 실패한 건은 은행에 없으니 CL080 만 취소한다.
      if (strQ090.equals("2")) return isCancelRequested() ? "" : "CL090";
      if (!strQ090.equals("9")) return "";
    } else if (isCl090Cancelled() && !strQ090.equals("2")) {
      return ""; // CL090 취소가 끝나야 CL080 을 취소한다
    }
    return isCl080Alive() ? "CL080" : "";
  }

  /** 취소요청 버튼을 보일지. */
  public boolean canCancelReq() {
    return !getCancelKncd().equals("");
  }

  /** 누른 쪽에 맞는 취소요청 상태코드. 이미 취소요청한 건이면 처음 요청한 쪽을 그대로 둔다. */
  public String getCancelReqStatus() {
    if (isCancelRequested()) return StrUtil.nvl(this.STATUS).trim();
    return isSeller() ? CyclnOrderVO.STATUS_SELLER_CANREQ : CyclnOrderVO.STATUS_BUYER_CANREQ;
  }

  /** 누른 쪽에 맞는 변경요청 상태코드. */
  public String getChgReqStatus() {
    return isSeller() ? CyclnOrderVO.STATUS_SELLER_CHGREQ : CyclnOrderVO.STATUS_BUYER_CHGREQ;
  }

  /** 은행에 결제예정정보를 접수했는지. CL090 전문이 나가면 결제예정금액이 채워진다. */
  public boolean isPaymentSent() {
    return !StrUtil.nvl(this.SETL_PLN_PRIC).trim().equals("");
  }

  /**
   * 구매기업이 은행에 결제를 접수할 수 있는 건인지.
   * 발주가 확정된 뒤 한 번만 보낸다. 보내고 나면 은행접수 단계로 넘어간다.
   */
  public boolean canPay() {
    return !isSeller() && isConfirmed() && !isBeforeConfirm() && !isPaymentSent()
        && isCl080Done() && !isChgPending(); // 변경요청이 승인돼 CL080 변경전문까지 끝나야 한다
  }

  /** 취소할 수 있는 건인지. 승인 전이면 구매·판매 양쪽 다 취소할 수 있다. */
  public boolean canCancel() {
    return isBeforeConfirm() && !isCancelled();
  }

  /** 누른 쪽에 맞는 취소 상태코드. */
  public String getCancelStatus() {
    return isSeller() ? CyclnOrderVO.STATUS_SELLER_CANCEL : CyclnOrderVO.STATUS_BUYER_CANCEL;
  }

  /*
   * 관리자 상세(CYCLN_ORDER_DETAIL_PROC) 용. 전문 목록(CL080·CL090·CL100)으로 판단한다.
   * 목록은 요청일·일련번호 순이라 마지막 행이 최근 전문이다.
   */

  /** 전문 종류별 마지막 행의 {거래구분, 처리상태}. 전문이 없으면 null. */
  private String[] lastTmsg(String strKncd) {
    if ("CL080".equals(strKncd) && !this.CL080.isEmpty()) {
      Cl080VO r = this.CL080.get(this.CL080.size()-1);
      return new String[] {StrUtil.nvl(r.TRX_CLS).trim(), StrUtil.nvl(r.STATUS).trim()};
    }
    if ("CL090".equals(strKncd) && !this.CL090.isEmpty()) {
      Cl090VO r = this.CL090.get(this.CL090.size()-1);
      return new String[] {StrUtil.nvl(r.TRX_CLS).trim(), StrUtil.nvl(r.STATUS).trim()};
    }
    return null;
  }

  /** 마지막 전문이 은행 처리에 실패했는지. 관리자 재전송 버튼을 보인다. */
  public boolean isTmsgFailed(String strKncd) {
    String[] t = lastTmsg(strKncd);
    return t!=null && t[1].equals("9");
  }

  /**
   * 관리자 상태값 변경 버튼을 보일지. 결제통보(CL100) 전이고, 마지막 전문이 정상 처리된 등록·변경 전문이어야 한다.
   * 순서(CL090 먼저 취소)는 누를 때 getAdminCancelError 로 알린다.
   */
  public boolean canAdminCancel(String strKncd) {
    String[] t = lastTmsg(strKncd);
    return this.CL100.isEmpty() && t!=null && t[1].equals("2") && !t[0].equals(CyclnOrderVO.TRX_CANCEL);
  }

  /**
   * 관리자 취소(상태값 변경)를 막는 사유. 할 수 있으면 빈 문자열.
   * 결제예정정보(CL090)가 은행에 살아 있으면 매매계약정보(CL080)보다 먼저 취소해야 한다.
   * 접수에 실패한 CL090 은 은행에 없으므로 막지 않는다.
   */
  public String getAdminCancelError(String strKncd) {
    if (!this.CL100.isEmpty()) return "결제통보를 받은 건은 상태를 바꿀 수 없습니다.";
    if (!canAdminCancel(strKncd)) return "전문 처리가 완료된 건만 상태를 바꿀 수 있습니다. 화면을 새로 고치십시오.";
    if ("CL080".equals(strKncd)) {
      String[] t090 = lastTmsg("CL090");
      if (t090!=null) {
        boolean isCancel = t090[0].equals(CyclnOrderVO.TRX_CANCEL);
        if (!isCancel && !t090[1].equals("9")) return "결제예정정보를 먼저 취소해주세요.";
        if (isCancel && !t090[1].equals("2"))  return "결제예정정보 취소가 완료된 뒤에 취소할 수 있습니다.";
      }
    }
    return "";
  }

  /** CL080 전문에 실을 대표품목. 첫 제품명 20자. */
  public String getPurcItem() {
    if (this.ITEMS.isEmpty()) return "";
    String strTitle = StrUtil.nvl(this.ITEMS.get(0).PRD_TITLE).trim();
    return (strTitle.length()>20) ? strTitle.substring(0, 20) : strTitle;
  }

  /**
   * 실결제금액 중 구매자금대출이 차지하는 비율. '100' 처럼 % 기호 없이 돌려준다.
   * 계산할 수 없으면 빈 문자열.
   */
  public String getLoanRate() {
    try {
      BigDecimal bdSetl = new BigDecimal(StrUtil.nvl(this.SETL_PRIC, "0"));
      BigDecimal bdLoan = new BigDecimal(StrUtil.nvl(this.BYCA_LOAN_PRIC, "0"));
      if (bdSetl.compareTo(BigDecimal.ZERO)==0) return "";
      // 소수 첫째자리까지 보고 의미없는 끝자리 0 은 버린다. 100.0 은 100 이 된다.
      return bdLoan.multiply(new BigDecimal("100"))
                   .divide(bdSetl, 1, RoundingMode.HALF_UP)
                   .stripTrailingZeros().toPlainString();
    } catch (NumberFormatException e) {
      return "";
    }
  }

  /**
   * 세금계산서 종류(CYCLN_ORDER.ESTIMATE_TYPE, tinyint). {코드, 표시명}
   * 과세(1)만 총액에 부가세가 포함된다. 0 과 NULL 은 미지정이다.
   */
  public static final String[][] ESTIMATE_TYPES = {
      {"1", "과세계산서"  }
    , {"2", "영세율계산서"}
    , {"3", "면세계산서"  }
  };

  /** 계산서 종류 표시명. 미지정(0, NULL)이거나 정의에 없으면 '-'. */
  public static String getEstimateTypeNm(String strType) {
    String strCode = (strType==null) ? "" : strType.trim();
    for (String[] f : ESTIMATE_TYPES) {
      if (f[0].equals(strCode)) return f[1];
    }
    return "-";
  }

  /** 이 주문의 계산서 종류 표시명. */
  public String getEstimateTypeNm() {
    return getEstimateTypeNm(this.ESTIMATE_TYPE);
  }

  public ArrayList<ItemVO>  ITEMS = new ArrayList<ItemVO>();  // (2) 제품 목록
  public ArrayList<Cl080VO> CL080 = new ArrayList<Cl080VO>(); // (3) 매매계약정보
  public ArrayList<Cl090VO> CL090 = new ArrayList<Cl090VO>(); // (4) 결제예정정보
  public ArrayList<Cl100VO> CL100 = new ArrayList<Cl100VO>(); // (5) 결제통보

  /**
   * 승인할 때 넘길 제품정보를 프로시저가 XML 로 읽을 &lt;NODE .../&gt; 문자열로 만든다.
   * 발주계약서 등록(CyclnOrderRegVO.setXml)과 같은 방식이다.
   *
   * SEQNO 는 CYCLN_ORDER_ITEM 의 키이므로 호출측에서 채워 넘겨야 한다.
   */
  public static String setXml(ArrayList<ItemVO> arr) {
    StringBuffer sb = new StringBuffer();
    if (arr!=null) {
      for (ItemVO v : arr) {
        sb.append("<NODE ");
        sb.append("SEQNO=\""       + CyclnOrderRegVO.esc(v.SEQNO)       + "\" ");
        sb.append("QTY=\""         + CyclnOrderRegVO.esc(v.QTY)         + "\" ");
        sb.append("PRICE=\""       + CyclnOrderRegVO.esc(v.PRICE)       + "\" ");
        sb.append("SUPPLYAMT=\""   + CyclnOrderRegVO.esc(v.SUPPLYAMT)   + "\" ");
        sb.append("TAXAMT=\""      + CyclnOrderRegVO.esc(v.TAXAMT)      + "\" ");
        sb.append("TOTALAMT=\""    + CyclnOrderRegVO.esc(v.TOTALAMT)    + "\" ");
        sb.append("DESCRIPTION=\"" + CyclnOrderRegVO.esc(v.DESCRIPTION) + "\" />");
      }
    }
    return sb.toString();
  }

  /** 제품 목록 */
  public static class ItemVO {
    public String SEQNO       = ""; // 일련번호 3자리. CYCLN_ORDER_ITEM 의 키
    public String PRD_ID      = ""; // 제품코드
    public String PRD_TITLE   = ""; // 제품명
    public String REQQTY      = ""; // 요청수량(수정 대상이라 단위를 빼고 숫자만)
    public String UNIT        = ""; // 단위
    public String REQPRICE    = ""; // 요청단가
    public String QTY         = ""; // 납품수량(단위포함)
    public String PRICE       = ""; // 납품단가
    public String SUPPLYAMT   = ""; // 공급가액
    public String TAXAMT      = ""; // 세액
    public String TOTALAMT    = ""; // 합계금액
    public String DESCRIPTION = ""; // 기타제품사양
  }

  /** 매매계약정보 CL080 */
  public static class Cl080VO {
    public String REQ_YMD   = ""; // 전문요청일
    public String PURC_ITEM = ""; // 거래품목
    public String DLVR_YMD  = ""; // 납품기한
    public String PURC_PRIC = ""; // 매매금액
    public String LOAN_YN   = ""; // 대출여부
    public String TRX_CLS   = ""; // 거래구분
    public String STATUS    = ""; // 상태
  }

  /** 결제예정정보 CL090 */
  public static class Cl090VO {
    public String REQ_YMD       = ""; // 전문요청일
    public String PURC_PRIC     = ""; // 매매금액
    public String SETL_PLN_YMD  = ""; // 결제예정일
    public String SETL_PLN_PRIC = ""; // 결제예정금액
    public String TAX_ISSU_YMD  = ""; // 세금계산서 발행일
    public String TRX_CLS       = ""; // 거래구분
    public String STATUS        = ""; // 상태
  }

  /** 결제통보 CL100 */
  public static class Cl100VO {
    public String REQ_YMD        = ""; // 전문요청일
    public String MTR_YMD        = ""; // 만기일
    public String SETL_PRIC      = ""; // 결제금액
    public String SFCP_SETL_PRIC = ""; // 자기자금결제금액
    public String BYCA_LOAN_PRIC = ""; // 구매자금대출금액
    public String FEE_AMT        = ""; // 수수료
    public String TRX_CLS        = ""; // 거래구분
    public String STATUS         = ""; // 상태
  }
}
