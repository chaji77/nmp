package kr.co.mp.mgr.customer;

import java.util.ArrayList;

public class DirectRelationBean {
	DirectRelationDAO	dao;
	public DirectRelationBean() {
		this.dao = new DirectRelationDAO();
	}
	public ArrayList<DirectRelationVO> M_DIRECT_RELATION_SEARCH_PROC(DirectRelationVO pvo) {
		return dao.M_DIRECT_RELATION_SEARCH_PROC(pvo);
	}
	public int M_DIRECT_RELATION_ADD_PROC(DirectRelationVO pvo) {
		return dao.M_DIRECT_RELATION_ADD_PROC(pvo);
	}
	public DirectRelationVO M_DIRECT_RELATION_DETAIL_PROC(DirectRelationVO pvo) {
		return dao.M_DIRECT_RELATION_DETAIL_PROC(pvo);
	}
	public int M_DIRECT_RELATION_MOD_PROC(DirectRelationVO pvo) {
		return dao.M_DIRECT_RELATION_MOD_PROC(pvo);
	}
}
