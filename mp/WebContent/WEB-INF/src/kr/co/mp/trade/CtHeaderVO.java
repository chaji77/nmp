package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class CtHeaderVO extends CommonVO {
  public String CTID; // 매매계약ID
  public String CTNO; // 매매계약번호
  public String CTTYPE; // 매매계약서구분(B-구매,S-판매)
  public String DIRTYPE; // 직거래구분(D-직거래, C-매매계약서거래)
  public String REGDATE; //거래일
  public String TRADEDATE; // 거래일자(전송일)
  public String CONTRACTDATE; // 매매계약일
  public String CPYBUYER; // 구매기업ID
  public String CPYSELLER; // 판매기업ID
  public String TAXBIZTYPE; // 사업자구분(G-일반, S-영세, E-면세)
  public String SUPPLYAMT; // 공급가액
  public String TAXAMT; // 세액
  public String TOTALCONTRACTAMT; // 총계약금액
  public String MPPAYCPY; // 수수료징수구분코드(1-판매기업, 2-구매기업)
  public String MPFEERATE; // 수수료율(소수점세째자리)
  public String MPFEE_SUPPLYAMT; // MP수수료-공급가액
  public String MPFEE_TAXAMT; // MP수수료-세액
  public String MPFEE_TOTALAMT; // MP수수료-총합계
  public String PAY_ID; // 결제수단
  public String BNK_CD; // 은행코드
  public String MTYDATE; // 만기일
  public String TRADETYPE; // 거래구분(1-보호거래, 2-일반거래)
  public String STATUS; // 상태
  public String REGUSER; // 작성자
  public String REGTIME; // 작성일시
  public String SENDUSER; // 발송자
  public String SENDTIME; // 발송일시
  public String LASTTIME; // 최종처리일시
  public String CHGREQ; // 변경요청구분(요청-REQ, 완료-END)
  public String CHGREQUSER; // 변경요청자
  public String CHGREQTIME; // 변경요청일시
  public String CHGUSER; // 변경완료자
  public String CHGTIME; // 변경완료일시
  public String CANUSER; // 취소자
  public String CANTIME; // 취소일시
  public String APRUSER; // 승인자
  public String APPRTIME; // 승인일시
  public String SGN_ID; // 구매사서명아이디(SIGNINFO)
  public String SETTLEDATE; // 결제일
  public String SETTLEAMT; // 결제금액
  public String SETTLEDUEDATE; // 결제예정일
  public String CONFIRM_SETTLE_YN; // 결제방식(Y:확인결제 / N:바로결제)
  public String SBILL_SEQ; // 전자세금계산서 일련번호
  public String TAXAPPROVALNO; // 전자세금계산서 승인번호
  public String BUYER_IP; // 구매사아이피(CT_HEADER_ETC에서가져옴)
  public String SELLER_IP; // 판매사아이피(CT_HEADER_ETC에서가져옴)
  public String SELLER_APP_SGN_ID; // 판매사서명아이디(SIGNINFO)
  public String CU_USE_YN; // 구리,철 스크랩 거래 여부
  public String BILL_DT; // 세금계산서작성일
  
  /* FOR LIST/DETAIL */
  public String BUYER_NM;
  public String SELLER_NM;
  public String BNK_NAME;
  public String PAY_SDESC;
  public String CODE_NM; // NAME OF STATUS
  public String SBDATE = "C"; // 검색기준일(C=CONTRACTDATE,S=SETTLEDUEDATE,M=MTYDATE)

  /* FOR DETAIL */
  public String BUYER_BIZ_NO;
  public String BUYER_CEO_NM;
  public String SELLER_BIZ_NO;
  public String SELLER_CEO_NM;
  public String TAXTYPE_NM;
  public String REG_NM;
  public String APR_NM;
  public String BUYER_SGN;
  public String SELLER_SGN;
  public String BILL_SUM;

  /* For ContractMaturityComming */
  public String TOTAL_SUM;
  
  @Override
  public String toString() {
	return "CtHeaderVO [CTID=" + CTID + ", CTNO=" + CTNO + ", CTTYPE=" + CTTYPE + ", DIRTYPE=" + DIRTYPE
			+ ", TRADEDATE=" + TRADEDATE + ", CONTRACTDATE=" + CONTRACTDATE + ", CPYBUYER=" + CPYBUYER + ", CPYSELLER="
			+ CPYSELLER + ", TAXBIZTYPE=" + TAXBIZTYPE + ", SUPPLYAMT=" + SUPPLYAMT + ", TAXAMT=" + TAXAMT
			+ ", TOTALCONTRACTAMT=" + TOTALCONTRACTAMT + ", MPPAYCPY=" + MPPAYCPY + ", MPFEERATE=" + MPFEERATE
			+ ", MPFEE_SUPPLYAMT=" + MPFEE_SUPPLYAMT + ", MPFEE_TAXAMT=" + MPFEE_TAXAMT + ", MPFEE_TOTALAMT="
			+ MPFEE_TOTALAMT + ", PAY_ID=" + PAY_ID + ", BNK_CD=" + BNK_CD + ", MTYDATE=" + MTYDATE + ", TRADETYPE="
			+ TRADETYPE + ", STATUS=" + STATUS + ", REGUSER=" + REGUSER + ", REGTIME=" + REGTIME + ", SENDUSER="
			+ SENDUSER + ", SENDTIME=" + SENDTIME + ", LASTTIME=" + LASTTIME + ", CHGREQ=" + CHGREQ + ", CHGREQUSER="
			+ CHGREQUSER + ", CHGREQTIME=" + CHGREQTIME + ", CHGUSER=" + CHGUSER + ", CHGTIME=" + CHGTIME + ", CANUSER="
			+ CANUSER + ", CANTIME=" + CANTIME + ", APRUSER=" + APRUSER + ", APPRTIME=" + APPRTIME + ", SGN_ID="
			+ SGN_ID + ", SETTLEDATE=" + SETTLEDATE + ", SETTLEAMT=" + SETTLEAMT + ", SETTLEDUEDATE=" + SETTLEDUEDATE
			+ ", CONFIRM_SETTLE_YN=" + CONFIRM_SETTLE_YN + ", SBILL_SEQ=" + SBILL_SEQ + ", TAXAPPROVALNO=" + TAXAPPROVALNO + ", BUYER_IP=" + BUYER_IP
			+ ", SELLER_IP=" + SELLER_IP + ", SELLER_APP_SGN_ID=" + SELLER_APP_SGN_ID + ", CU_USE_YN=" + CU_USE_YN
			+ "]";
  }
}
