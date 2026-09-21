package kr.co.mp.c.regreq;

import java.util.ArrayList;

import kr.co.funology.fw.util.DateTimeUtil;

public class RegReqBean {
	private RegReqDAO dao;
	public RegReqBean() {
		this.dao = new RegReqDAO();
	}
	public int COMPANY_REG_REQ_ADD_PROC(RegReqVO vo) {
		return this.dao.COMPANY_REG_REQ_ADD_PROC(vo);
	}
	public int COMPANY_REG_REQ_MOD_PROC(RegReqVO vo) {
		return this.dao.COMPANY_REG_REQ_MOD_PROC(vo);
	}
	public ArrayList<RegReqVO> COMPANY_REG_REQ_LIST_PROC(RegReqVO vo) {
		return this.dao.COMPANY_REG_REQ_LIST_PROC(vo);
	}
	// 삭제: DEL_DATE만 채워서 MOD_PROC 호출 (프로시저가 DEL_DATE 존재시 다른 필드 무시)
	public int COMPANY_REG_REQ_DROP_PROC(int intSeq) {
		RegReqVO vo = new RegReqVO();
		vo.SEQ = intSeq;
		vo.DEL_DATE = DateTimeUtil.getCurrentDate("-") + " " + DateTimeUtil.getCurrentTime();
		return this.dao.COMPANY_REG_REQ_MOD_PROC(vo);
	}
}
