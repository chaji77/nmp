package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class TaxVO extends CommonVO {
	public String SBILL_SEQ     ; 
	public String BILL_NO       ;
	public String APP_NO        ;
	public String BILL_DT       ;
	public String BILL_TYPE     ;
	public String BILL_GUBUN    ;
	public String PAY_TAX_RATE  ;
	public String SCOMP_VENDERNO;
	public String SCOMP_NAME    ;
	public String SCOMP_CEO     ;
	public String SCOMP_ADDRESS ;
	public String SCOMP_TYPE    ;
	public String SCOMP_CLASS   ;
	public String RCOMP_VENDERNO;
	public String RCOMP_NAME    ;
	public String RCOMP_CEO     ;
	public String RCOMP_ADDRESS ;
	public String RCOMP_TYPE    ;
	public String RCOMP_CLASS   ;
	public String PAY_SUM_AMOUNT;
	public String PAY_SUM_TAX   ;
	public String ITEM_NAME     ;
	public String DEL_YN        ;
	public String DEL_DATE      ;
	public int    CPY_ID        ;
	public String REG_DATE      ;
	
	public String SETTLED_AMOUNT; // 결제완료금액
	
	@Override
	public String toString() {
		return "TaxVO [SBILL_SEQ=" + SBILL_SEQ + ", BILL_NO=" + BILL_NO + ", APP_NO=" + APP_NO + ", BILL_DT=" + BILL_DT
				+ ", BILL_TYPE=" + BILL_TYPE + ", BILL_GUBUN=" + BILL_GUBUN + ", PAY_TAX_RATE=" + PAY_TAX_RATE
				+ ", SCOMP_VENDERNO=" + SCOMP_VENDERNO + ", SCOMP_NAME=" + SCOMP_NAME + ", SCOMP_CEO=" + SCOMP_CEO
				+ ", SCOMP_ADDRESS=" + SCOMP_ADDRESS + ", SCOMP_TYPE=" + SCOMP_TYPE + ", SCOMP_CLASS=" + SCOMP_CLASS
				+ ", RCOMP_VENDERNO=" + RCOMP_VENDERNO + ", RCOMP_NAME=" + RCOMP_NAME + ", RCOMP_CEO=" + RCOMP_CEO
				+ ", RCOMP_ADDRESS=" + RCOMP_ADDRESS + ", RCOMP_TYPE=" + RCOMP_TYPE + ", RCOMP_CLASS=" + RCOMP_CLASS
				+ ", PAY_SUM_AMOUNT=" + PAY_SUM_AMOUNT + ", PAY_SUM_TAX=" + PAY_SUM_TAX + ", ITEM_NAME=" + ITEM_NAME
				+ ", DEL_YN=" + DEL_YN + ", DEL_DATE=" + DEL_DATE + ", CPY_ID=" + CPY_ID + ", REG_DATE=" + REG_DATE
				+ "]";
	}
	
	
	
}
