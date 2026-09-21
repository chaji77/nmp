package kr.co.mp.mgr.memo;

import kr.co.mp.common.CommonVO;

public class MemoVO extends CommonVO {
  public String ACTIVE_ID; // 상담ID
  public String ACTIVE_KIND; // 상담분류
  public String WRITE_ID; // 작성자아이디
  public String WRITE_DATE; // 작성일시
  public int    CPY_ID; // 회원사ID
  public String CALL_TYPE; // 통화유형
  public String ACTIVE_DESC; // 상담내용

  public String USER_NM;
  public String TO_USER_ID;
  public String TO_USER_NM;
  public String CPY_NAME;
  public String CPY_BUSINESS_NO;
  public String COMMENT_YN;
}
