package kr.co.mp.mgr.customer;

import java.util.ArrayList;

public class CompanyNoTradeBean {
	CompanyNoTradeDAO	dao;
	public CompanyNoTradeBean() {
		this.dao = new CompanyNoTradeDAO();
	}
	public ArrayList<CompanyNoTradeVO> M_COMPANY_NO_TRADE_LIST_PROC(int intCpyId, int seqNo) {
		return dao.M_COMPANY_NO_TRADE_LIST_PROC(intCpyId, seqNo);
	}
	public CompanyNoTradeVO M_COMPANY_BUYER_CHECK_PROC(int intCpyId) {
		return dao.M_COMPANY_BUYER_CHECK_PROC(intCpyId);
	}
	public String M_COMPANY_SELLER_NAME_CHECK_PROC(int intCpyId, String cpyBizNo) {
		return dao.M_COMPANY_SELLER_NAME_CHECK_PROC(intCpyId, cpyBizNo);
	}
	public int M_COMPANY_NO_TRADE_ADD_PROC(CompanyNoTradeVO vo) {
		return dao.M_COMPANY_NO_TRADE_ADD_PROC(vo);
	}
	public int M_COMPANY_NO_TRADE_MOD_PROC(CompanyNoTradeVO vo) {
		return dao.M_COMPANY_NO_TRADE_MOD_PROC(vo);
	}
}
