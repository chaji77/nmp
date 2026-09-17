package kr.co.mp.c.faq;

import java.util.ArrayList;

public class FAQBean {
	private FAQDAO dao;
	public FAQBean() {
		this.dao = new FAQDAO();
	}
	public ArrayList<FAQVO> C_FAQ_CAT_LIST_PROC() {
		return this.dao.C_FAQ_CAT_LIST_PROC();
	}
	public int C_FAQ_ADD_PROC(FAQVO vo) {
		return dao.C_FAQ_ADD_PROC(vo);
	}
	public FAQVO C_FAQ_DETAIL_PROC(int intSeq) {
		return dao.C_FAQ_DETAIL_PROC(intSeq);
	}
	public int C_FAQ_DROP_PROC(FAQVO vo) {
		return dao.C_FAQ_DROP_PROC(vo);
	}
	public ArrayList<FAQVO> C_FAQ_LIST_PROC(FAQVO vo, String strSearchWord) {
		return dao.C_FAQ_LIST_PROC(vo, strSearchWord);
	}
	public int C_FAQ_MOD_PROC(FAQVO vo) {
		return dao.C_FAQ_MOD_PROC(vo);
	}
}
