package kr.co.mp.c.qna;

import java.util.ArrayList;


public class QnaBean {
	private QnaDAO dao;
	public QnaBean() {
		this.dao = new QnaDAO();
	}
	public int C_QNA_ADD_PROC(QnaVO vo) {
		return this.dao.C_QNA_ADD_PROC(vo);
	}
	public int C_QNA_MOD_PROC(QnaVO vo) {
		return this.dao.C_QNA_MOD_PROC(vo);
	}
	public int C_QNA_DROP_PROC(QnaVO vo) {
		return this.dao.C_QNA_DROP_PROC(vo);
	}
	public QnaVO C_QNA_DETAIL_PROC(int intSeq) {
		return this.dao.C_QNA_DETAIL_PROC(intSeq);
	}
	public ArrayList<QnaVO> C_QNA_LIST_PROC(QnaVO vo) {
		return this.dao.C_QNA_LIST_PROC(vo);
	}
	public int C_QNA_CUSTOMER_ADD_PROC(QnaVO vo) {
		return this.dao.C_QNA_CUSTOMER_ADD_PROC(vo);
	}
	public  int C_QNA_CUSTOMER_MOD_PROC(QnaVO vo) {
		return this.dao.C_QNA_CUSTOMER_MOD_PROC(vo);
	}
}
