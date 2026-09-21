package kr.co.mp.mgr.memo;

import kr.co.mp.common.CommonVO;

public class CommentVO extends CommonVO {
  public int    COMMENT_ID; // 댓글ID
  public int    ACTIVE_ID; // 상담ID
  public String COMMENT_DESC; // 댓글내용
  public String WRITE_ID; // 작성자아이디
  public String WRITE_DATE; // 작성일시

  public String USER_NM;
}
