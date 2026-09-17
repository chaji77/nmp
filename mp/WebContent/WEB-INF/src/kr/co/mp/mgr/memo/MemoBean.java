package kr.co.mp.mgr.memo;

import java.util.ArrayList;

import kr.co.mp.common.CodeVO;

public class MemoBean {
  MemoDAO dao;
  public MemoBean() {
    this.dao = new MemoDAO();
  }
  public ArrayList<MemoVO> ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC(MemoVO pvo) {
    return this.dao.ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC(pvo);
  }
  public int ACTIVE_MANAGEMENT_ADD_PROC(MemoVO pvo) {
    return this.dao.ACTIVE_MANAGEMENT_ADD_PROC(pvo);
  }
  public int ACTIVE_MANAGEMENT_DROP_PROC(int intActiveId) {
    return this.dao.ACTIVE_MANAGEMENT_DROP_PROC(intActiveId);
  }
  public MemoVO ACTIVE_MANAGEMENT_DETAIL_PROC(int intActiveId) {
    return this.dao.ACTIVE_MANAGEMENT_DETAIL_PROC(intActiveId);
  }
  public int ACTIVE_MANAGEMENT_MOD_PROC(MemoVO pvo) {
    return this.dao.ACTIVE_MANAGEMENT_MOD_PROC(pvo);
  }
  public ArrayList<CodeVO> M_COMPANY_MEMO_CATEGORY_LIST_PROC() {
    return this.dao.M_COMPANY_MEMO_CATEGORY_LIST_PROC();
  }
  public ArrayList<MemoVO> ACTIVE_MANAGEMENT_LIST_PROC(MemoVO pvo) {
    return this.dao.ACTIVE_MANAGEMENT_LIST_PROC(pvo);
  }
}
