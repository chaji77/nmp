package kr.co.mp.trade;

import java.util.ArrayList;

public class TradeStatusBean {
  public static ArrayList<TradeStatusVO> CT_HEADER_STATUS_PER_CPY_ID_PROC(int intCpyId) {
	  return new TradeStatusDAO().CT_HEADER_STATUS_PER_CPY_ID_PROC(intCpyId);
  }
  public String[] CT_HEADER_PID_STATUS_PER_CTID_PROC(int intCtid) {
	  return new TradeStatusDAO().CT_HEADER_PID_STATUS_PER_CTID_PROC(intCtid);
  }
}
