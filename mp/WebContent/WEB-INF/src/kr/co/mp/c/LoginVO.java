package kr.co.mp.c;

public class LoginVO {

  public String CPY_GUBUN;
  public String CPY_ID = "0";
  public String CST_ID;
  public String CPY_BIZ_NO;
  public String CPY_NM;
  public String PRS_ID;
  public String USER_LOGIN;
  public String VALID_IP_YN = "N";
  public String REMOTE_IP;
  public String CU_USE_YN;
  public String CONFIRM_SETTLE_YN;
  public String REVERSE_YN       ;
  public String MOBILE_YN        ;
  public String SIGN_EXCLUDE_YN  ;
  public String CRG_ID;
  public String PAPER_BILL_YN;

  @Override
  public String toString() {
    return "LoginVO [CPY_GUBUN=" + CPY_GUBUN + ", CPY_ID=" + CPY_ID + ", CST_ID=" + CST_ID + ", CPY_BIZ_NO=" + CPY_BIZ_NO + ", CPY_NM="
        + CPY_NM + ", PRS_ID=" + PRS_ID + ", USER_LOGIN=" + USER_LOGIN + ", VALID_IP_YN=" + VALID_IP_YN
        + ", REMOTE_IP=" + REMOTE_IP + ", CU_USE_YN=" + CU_USE_YN + ", CONFIRM_SETTLE_YN=" + CONFIRM_SETTLE_YN
        + ", REVERSE_YN=" + REVERSE_YN + ", MOBILE_YN=" + MOBILE_YN + ", SIGN_EXCLUDE_YN=" + SIGN_EXCLUDE_YN
        + "]";
  }
}
