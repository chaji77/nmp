package jnditest;
import java.util.ArrayList;

public class CodeBean {
  public static ArrayList<CodeVO> C_CODE_LIST_PROC() {
    return CodeDAO.C_CODE_LIST_PROC();
  }
}
