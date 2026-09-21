package kr.co.mp.mgr;

import java.util.ArrayList;

public class DailyRevenueBean {
  public static ArrayList<DailyRevenueVO> DAILY_REVENUE_PROC(String strStartYm, String strEndYm) {
    return DailyRevenueDAO.DAILY_REVENUE_PROC(strStartYm, strEndYm);
  }
}
