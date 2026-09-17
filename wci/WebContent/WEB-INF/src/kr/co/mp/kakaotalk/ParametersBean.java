package kr.co.mp.kakaotalk;

import java.util.ArrayList;

public class ParametersBean {
  public ArrayList<ParametersVO> TALK_FOR_SETTLED_PROC(int intBillSeq) {
    if (intBillSeq==0) return null;
    return new ParametersDAO().TALK_FOR_SETTLED_PROC(intBillSeq);
  }
  public ParametersVO TALK_FOR_RESET_PASSWORD_PROC(String strLoginId) {
	return new ParametersDAO().TALK_FOR_RESET_PASSWORD_PROC(strLoginId);
  }
  public ParametersVO TALK_FOR_CANCEL_CONTRACT_PROC(int intCtId) {
	if (intCtId==0) return null;
	return new ParametersDAO().TALK_FOR_CANCEL_CONTRACT_PROC(intCtId);
  }
  public ParametersVO TALK_FOR_TRANSACTION_INFO_PROC(int intCtid) {
	if (intCtid==0) return null;
	return new ParametersDAO().TALK_FOR_TRANSACTION_INFO_PROC(intCtid);
  }
}
