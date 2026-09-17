package kr.co.mp.mptax;

import kr.co.mp.c.CompanyVO;

public class BillReceiverVO extends CompanyVO {
  public String CTNO           ;
  public String TRADEDATE      ;
  public String MPFEE_SUPPLYAMT;
  public String MPFEE_TAXAMT   ;
  public String MPFEE_TOTALAMT ;
  public int    CNT            ;
  public int    PURPOSE_TYPE   ;
}
