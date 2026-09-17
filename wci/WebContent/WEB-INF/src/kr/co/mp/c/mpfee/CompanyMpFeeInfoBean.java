package kr.co.mp.c.mpfee;

public class CompanyMpFeeInfoBean {
  public CompanyMpFeeInfoVO COMPANY_MPFEE_INFO_PROC(int intCpyId) {
    return new CompanyMpFeeInfoDAO().COMPANY_MPFEE_INFO_PROC(intCpyId);
  }
  public int COMPANY_MPFEE_INFO_ADD_PROC(CompanyMpFeeInfoVO mpvo) {
	  return new CompanyMpFeeInfoDAO().COMPANY_MPFEE_INFO_ADD_PROC(mpvo);
  }
  public int COMPANY_MPFEE_INFO_MOD_PROC(CompanyMpFeeInfoVO mpvo) {
	  return new CompanyMpFeeInfoDAO().COMPANY_MPFEE_INFO_MOD_PROC(mpvo);
  }
}
