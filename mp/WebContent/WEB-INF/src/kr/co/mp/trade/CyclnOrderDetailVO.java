package kr.co.mp.trade;

import java.util.ArrayList;

/**
 * 싸이클론 결제전송관리 상세.
 * CYCLN_ORDER_DETAIL_PROC 가 돌려주는 결과셋 5개를 한 VO 에 담는다.
 */
public class CyclnOrderDetailVO {
  /* (1) 발주계약서정보 */
  public String ORDERNO    = ""; // 매매계약번호
  public String TRADEDATE  = ""; // 거래일자
  public String ORDERNAME  = ""; // 발주계약서명
  public String REQDLVDATE = ""; // 요청납기일
  public String CPYBUYER   = ""; // 구매기업 CPY_ID
  public String BC_NAME    = ""; // 구매기업명
  public String CPYSELLER  = ""; // 판매기업 CPY_ID
  public String SC_NAME    = ""; // 판매기업명
  public String DLVADDRESS   = ""; // 도착지
  public String STATUS       = ""; // 발주계약서 상태
  public String TRX_CLS      = ""; // 거래구분(CL100.TRX_CLS) 01-결제, 02-취소
  public String CQ100_STATUS = ""; // 결제상태(CYCLN_QUEUE.STATUS)

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
