package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class PayMethodVO extends CommonVO {
    public int CPY_ID;
    public String BNK_CD;
    public String PAY_ID;
    public String PAY_DESC;
    public String PAY_SDESC;
    public String BNK_NAME;
    public String GUAR_GUBUN;
    public String GUAR_STATUS;
    
    public String GUAR_CRA_DATE ;
    public String GUAR_EXP_DATE ;
    public String GUAR_VAL_DATE ;
    public String GUAR_TOTAL_AMT;
    public String MEMO          ;
    public String WRITE_DATE    ;
    public String WRITE_ID      ;
    public String MODIFY_DATE   ;
    public String MODIFY_ID     ;
    public String CHANGE_AMT    ;
    
    public long   SUM_AMT;
    public int    CPY_GUAR_SEQ;
    public String CPY_NAME;
    public String CPY_BUSINESS_NO;
    
	/* GuaranteeLocation */
    public int 	  GUAR_LOC;
    public String GUAR_LOC_DESC;
    public String GUAR_LOC_GUBUN; 
}
