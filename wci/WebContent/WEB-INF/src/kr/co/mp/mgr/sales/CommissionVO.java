package kr.co.mp.mgr.sales;

import kr.co.mp.common.CommonVO;

public class CommissionVO extends CommonVO {
  public int    COMM_ID; // 수수료아이디
  public String CPY_BUYER; // 구매사아이디
  public String CPY_SELLER; // 판매사아이디(0은 모든 판매사)
  public String PAY_CPY = "S"; // 수수료부담주체
  public String PAY_GUBUN; // 수수료부과대상상품구분
  public String COMM_METHOD; // 수수료상품코드
  public String STD_DAYS = "0"; // 기준일수
  public String MTY_STDAYS = "0"; // 만기계산시작일
  public String MTY_ENDDAYS = "0"; // 만기계산종료일
  public String CPY_COMMISSION_RATE1 = "0"; // 비율수수료1
  public String CPY_COMMISSION_RATE2 = "0"; // 비율수수료2
  public String DISCOUNT_RATE = "0"; // 할인율
  public String COMM_DESC; // 비고
  public String USE_YN; // 사용여부
  public String CREDATE; // 생성일
  public String CPY_COMMISSION_RATE = "0"; // 수수료율
  public String RECEIVE_MONEY = "0"; // 받은수수료
  public String OFFLINE_YN; // 오프라인징수여부
  public String MAX_YN; // 연맥스적용여부
  public String MODDATE; // 수정일
  public String MODID; // 수정자

 // FOR CALC
  public String SETTLE_AMT = "0";
  public String DIFF = "0";
  public String MIN_FEE_AMT = "0";
  public String SUM_END_MONEY = "0";
  
  // FOR MAST_OFF_COMMISSION
  public String START_DT;
  public String END_DT;
  
  // FOR DETAIL
  public String BUYER_NM;
  public String BUYER_BIZ_NO;
  public String SELLER_NM;
  public String SELLER_BIZ_NO;
  public String END_MONEY;
  
  // FOR CHECK CALCULATE MPFEE
  public String MPFEE_TOTALAMT;
  
  // FOR SEARCH
  public String SBDATE;
  
  @Override
  public String toString() {
  return "CommissionVO [COMM_ID=" + COMM_ID + ", CPY_BUYER=" + CPY_BUYER + ", CPY_SELLER=" + CPY_SELLER + ", PAY_CPY="
      + PAY_CPY + ", PAY_GUBUN=" + PAY_GUBUN + ", COMM_METHOD=" + COMM_METHOD + ", STD_DAYS=" + STD_DAYS
      + ", MTY_STDAYS=" + MTY_STDAYS + ", MTY_ENDDAYS=" + MTY_ENDDAYS + ", CPY_COMMISSION_RATE1="
      + CPY_COMMISSION_RATE1 + ", CPY_COMMISSION_RATE2=" + CPY_COMMISSION_RATE2 + ", DISCOUNT_RATE="
      + DISCOUNT_RATE + ", COMM_DESC=" + COMM_DESC + ", USE_YN=" + USE_YN + ", CREDATE=" + CREDATE
      + ", CPY_COMMISSION_RATE=" + CPY_COMMISSION_RATE + ", RECEIVE_MONEY=" + RECEIVE_MONEY + ", OFFLINE_YN="
      + OFFLINE_YN + ", MAX_YN=" + MAX_YN + ", MODDATE=" + MODDATE + ", MODID=" + MODID + ", SETTLE_AMT="
      + SETTLE_AMT + ", DIFF=" + DIFF + ", MIN_FEE_AMT=" + MIN_FEE_AMT + ", SUM_END_MONEY=" + SUM_END_MONEY
      + ", START_DT=" + START_DT + ", END_DT=" + END_DT + ", BUYER_NM=" + BUYER_NM + ", BUYER_BIZ_NO="
      + BUYER_BIZ_NO + ", SELLER_NM=" + SELLER_NM + ", SELLER_BIZ_NO=" + SELLER_BIZ_NO + ", END_MONEY="
      + END_MONEY + "]";
}

  

}
