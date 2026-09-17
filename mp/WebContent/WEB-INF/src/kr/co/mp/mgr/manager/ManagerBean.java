package kr.co.mp.mgr.manager;

import java.util.ArrayList;

public class ManagerBean {
  private ManagerDAO dao;
  public ManagerBean() {
   this.dao = new ManagerDAO();
  }
  public int M_MANAGER_ADD_PROC(ManagerVO vo) {
    return this.dao.M_MANAGER_ADD_PROC(vo);
  }
  public ManagerVO M_MANAGER_DETAIL_PROC(int intManId) {
    return this.dao.M_MANAGER_DETAIL_PROC(intManId);
  }
  public int M_MANAGER_MOD_PROC(ManagerVO vo) {
    return this.dao.M_MANAGER_MOD_PROC(vo);
  }
  public int M_MANAGER_DROP_PROC(ManagerVO vo) {
    return this.dao.M_MANAGER_DROP_PROC(vo);
  }
  public ArrayList<ManagerVO> M_MANAGER_LIST_PROC(ManagerVO vo) {
    return this.dao.M_MANAGER_LIST_PROC(vo);
  }
  public ManagerVO M_MANAGER_LOGIN_PROC(ManagerVO vo) {
    return this.dao.M_MANAGER_LOGIN_PROC(vo);
  }
}
