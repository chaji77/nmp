package kr.co.mp.mgr.salesrep;

import java.util.ArrayList;

public class SalesrepBean {
	private SalesrepDAO dao;
	
	public SalesrepBean() {
	  this.dao = new SalesrepDAO();
	}
	public int M_SALESREP_ADD_PROC(SalesrepVO vo) {
	  return this.dao.M_SALESREP_ADD_PROC(vo);
	}
	public SalesrepVO M_SALESREP_DETAIL_PROC(int intSalesrepId) {
	  return this.dao.M_SALESREP_DETAIL_PROC(intSalesrepId);
	}
	public int M_SALESREP_MOD_PROC(SalesrepVO vo) {
	  return this.dao.M_SALESREP_MOD_PROC(vo);
	}
	public int M_SALESREP_DROP_PROC(SalesrepVO vo) {
	  return this.dao.M_SALESREP_DROP_PROC(vo);
	}
	public ArrayList<SalesrepVO> M_SALESREP_LIST_PROC(SalesrepVO vo) {
	  return this.dao.M_SALESREP_LIST_PROC(vo);
	}	
}