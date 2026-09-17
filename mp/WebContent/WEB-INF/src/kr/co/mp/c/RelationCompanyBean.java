package kr.co.mp.c;

import java.util.ArrayList;

import kr.co.funology.fw.util.StrUtil;

public class RelationCompanyBean {
	
  RelationCompanyDAO dao;
  public RelationCompanyBean() {
    this.dao = new RelationCompanyDAO();
  }
  public ArrayList<RelationCompanyVO> RELATION_COMPANY_DETAIL_PROC(int intCpyId, String strContainSelfYn) {
    return this.dao.RELATION_COMPANY_DETAIL_PROC(intCpyId, StrUtil.nvl(strContainSelfYn, "N"));
  }

  public int COMPANY_RELATION_EXCEPT_PROC(int intBuyerId, int intSellerCpyId) {
    return this.dao.COMPANY_RELATION_EXCEPT_PROC(intBuyerId, intSellerCpyId);
  }
}
