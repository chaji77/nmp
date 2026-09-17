package kr.co.mp.mgr.sales;

import kr.co.mp.common.CommonVO;

public class MastOffCommissionVO extends CommonVO {
  public String CPY_ID; // 회원아이디
  public String SEQNO; // 증가값
  public String END_MONEY; // 받은수수료
  public String RECEIVE_DATE; // 받은날짜
  public String WRITE_ID; // 작성자
  public String WRITE_DATE; // 작성일
  public String MODIFY_ID; // 수정자
  public String MODIFY_DATE; // 수정일
  public String DEL_YN; // 삭제여부
  public String START_DT; // 수수료적용시작일
  public String END_DT; // 수수료적용종료일
  public int    COMM_ID; // 수수료아이디
  public String COMM_METHOD; // 수수료상품코드
  public int    CTID; // 매매계약아이디
  public String CTNO; // 매매계약번호
  
  @Override
  public String toString() {
    return "MastOffCommissionVO [CPY_ID=" + CPY_ID + ", SEQNO=" + SEQNO + ", END_MONEY=" + END_MONEY + ", RECEIVE_DATE="
      + RECEIVE_DATE + ", WRITE_ID=" + WRITE_ID + ", WRITE_DATE=" + WRITE_DATE + ", MODIFY_ID=" + MODIFY_ID
      + ", MODIFY_DATE=" + MODIFY_DATE + ", DEL_YN=" + DEL_YN + ", START_DT=" + START_DT + ", END_DT=" + END_DT
      + ", COMM_ID=" + COMM_ID + ", COMM_METHOD=" + COMM_METHOD + ", CTID=" + CTID + ", CTNO=" + CTNO + "]";
  }

}
