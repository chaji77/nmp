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
  public String CQ100_STATUS  = ""; // 결제상태(CYCLN_QUEUE.STATUS)
  public String ROLE          = ""; // 보는 사람의 입장. B-구매기업, S-판매기업
  public String CODE_NM       = ""; // 상태 표시명(CYCLN_ORDER_STATUS)

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
   * 제품 금액을 고칠 수 있는지 본다.
   * 변경요청이나 변경승인을 하려면 값을 고쳐야 하므로 그 두 플래그가 기준이다.
   */
  public boolean isItemEditable() {
    return "Y".equals(this.CAN_CHGREQ) || "Y".equals(this.CAN_CHGCFM);
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

  /** 제품 목록 */
  public static class ItemVO {
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
