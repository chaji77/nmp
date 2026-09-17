package kr.co.mp.mgr;

import java.util.ArrayList;

public class StaticBean {
  public static ArrayList<StaticVO> STAT_PROC(String strStartYm, String strEndYm) {
    return StaticDAO.STAT_PROC(strStartYm, strEndYm);
  }
}
