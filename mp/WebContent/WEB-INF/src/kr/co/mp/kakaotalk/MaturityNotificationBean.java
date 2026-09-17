package kr.co.mp.kakaotalk;

import java.util.ArrayList;

public class MaturityNotificationBean {
  public ArrayList<MaturityNotificationVO> BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC() {
    return new MaturityNotificationDAO().BAT_7_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC();
  }
  public ArrayList<MaturityNotificationVO> BAT_0_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC() {
    return new MaturityNotificationDAO().BAT_0_DAYS_LEFT_UNTIL_MATURITY_LIST_PROC();
  }
}
