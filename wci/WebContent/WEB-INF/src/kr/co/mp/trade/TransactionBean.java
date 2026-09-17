package kr.co.mp.trade;

import java.util.ArrayList;

public class TransactionBean {
  public static ArrayList<TransactionResultVO> SEND_XML_B311_LIST_BY_CTID_PROC(int intCtId) {
    return TransactionDAO.SEND_XML_B311_LIST_BY_CTID_PROC(intCtId);
  }
}
