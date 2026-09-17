package kr.co.mp.c.notice;

import kr.co.mp.common.CommonVO;

public class NoticeVO extends CommonVO {

  public int    SEQ;
  public String TITLE;
  public int    REG_ID;
  public String REG_DT;
  public String POPUP_YN;
  public int    POPUP_WIDTH;
  public int    POPUP_HEIGHT;
  public String POPUP_START_YMDHM;
  public String POPUP_END_YMDHM;
  public String USE_YN;
  public String CONTENTS;

  public String USER_NM;
  public String FILES;

  @Override
  public String toString() {
    return "NoticeVO [SEQ=" + SEQ + ", TITLE=" + TITLE + ", REG_ID=" + REG_ID + ", REG_DT=" + REG_DT + ", POPUP_YN="
         + POPUP_YN + ", POPUP_WIDTH=" + POPUP_WIDTH + ", POPUP_HEIGHT=" + POPUP_HEIGHT + ", POPUP_START_YMDHM="
         + POPUP_START_YMDHM + ", POPUP_END_YMDHM=" + POPUP_END_YMDHM + ", USE_YN=" + USE_YN + ", CONTENTS="
         + CONTENTS + ", USER_NM=" + USER_NM + "]";
  }

}
