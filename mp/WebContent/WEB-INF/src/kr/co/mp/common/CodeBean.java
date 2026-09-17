package kr.co.mp.common;

import java.util.ArrayList;

public class CodeBean {
  public static ArrayList<CodeVO> C_CODE_PROC(String strCodeGrpCd) {
    return CodeDAO.C_CODE_PROC(strCodeGrpCd);
  }
  public static ArrayList<CodeVO> C_CODE_LIST_PROC() {
    return CodeDAO.C_CODE_LIST_PROC();
  }
  public static ArrayList<BankVO> BANK_LIST_PROC() {
    return CodeDAO.BANK_LIST_PROC();
  }
}
