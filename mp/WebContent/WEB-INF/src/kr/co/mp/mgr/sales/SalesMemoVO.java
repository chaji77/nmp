package kr.co.mp.mgr.sales;

import kr.co.mp.common.CommonVO;

public class SalesMemoVO extends CommonVO {
  public int    MEMO_ID; // 메모ID
  public String WRITE_ID; // 작성자아이디
  public String WRITE_DATE; // 작성일시
  public String CONTENTS; // 내용
  public String DEL_DATE; // 삭제일자 (SALES_MEMO_MOD_PROC 삭제호출에서만 사용)
  public int    CPY_ID; // 회원사ID

  public String USER_NM; // 작성자명
  public String CPY_NAME; // 회원사명
  public String CPY_BUSINESS_NO; // 사업자번호
}
