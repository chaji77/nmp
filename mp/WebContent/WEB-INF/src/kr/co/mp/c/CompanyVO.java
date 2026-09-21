package kr.co.mp.c;

import kr.co.mp.common.CommonVO;

public class CompanyVO extends CommonVO {
  public int    CPY_ID; // 회원사id
  public String CST_ID; // 회원사상태
  public String CPY_GUBUN; // 구판매구분
  public String CRG_ID; // 개인법인구분
  public String CPY_NAME; // 회원사명
  public String BUSINESS_TYPE; // 업태
  public String INDUSTRY; // 업종
  public String CPY_FAX; // 팩스번호
  public String CPY_BUSINESS_DESC; // 사업영역
  public String CPY_BUSINESS_NO; // 사업자번호
  public String CPY_INCORPORATE_NO; // 법인번호
  public String CPY_CEO_NAME; // 대표자성명
  public String CPY_CEO_HP; // 대표자휴대폰번호
  public String CPY_CREDATE; // 작성일자
  public String CPY_VALIDATE; // 회원승인일자
  public String CPY_FOUNDYEAR; // 설립년도
  public String MP_CODE; // MP코드
  public String CPY_DISHONOR; // 부도여부
  public String CONFIRM_SETTLE_YN; // 확인결제여부
  public String CPY_ZIPCODE; // 회원사기본우편번호
  public String CPY_ADDR; // 회원사기본주소
  public String CPY_ADDR2; // 회원사기본주소2
  public String MPTAX_USER_NM; // MP세금계산서(담당자)
  public String MPTAX_EMAIL; // MP세금계산서(이메일주소)
  public String MPTAX_MONTH_USE_YN; // 월합사용여부
  public String MPTAX_MONTH_USE_ID; // 월합사용등록자
  public String MPTAX_MONTH_USE_DT; // 월합등록일시
  public String BIZ_DOC_FILE_URL; // 사업자등록증파일경로
  public String CU_USE_YN; // 철/구리 스크랩 업체 여부
  public String LAST_LOGIN_DT;
  public String MOBILE_YN; // 모바일승인여부
  public String REVERSE_YN; // 역발행여부
  public String SIGN_EXCLUDE_YN; // 전자서명예외여부
  public String CPY_MEMO; //특이사항
  public String SELLER_CLEAR_YN; // 판매사사전검증해제여부
  public String FEE_MOD_YN; // 수수료수정가능여부

  public String CPY_CREDIT_GRADE; // 기업신용등급 (COMPANY_SALES_SEARCH_PROC, COMPANY_MOREINFO_PROC)
  public String CPY_INDUSTRY_CODE; // 업종코드 (COMPANY_SALES_SEARCH_PROC, COMPANY_MOREINFO_PROC)

  public String INDUSTRY_DETAIL; // 업종상세 (COMPANY_MOREINFO_PROC)
  public String EXPORT_YN; // 수출여부 (COMPANY_MOREINFO_PROC)
  public String PATENT_YN; // 특허보유여부 (COMPANY_MOREINFO_PROC)
  public String MAINBIZ_YN; // 메인비즈인증여부 (COMPANY_MOREINFO_PROC)
  public String INNOBIZ_YN; // 이노비즈인증여부 (COMPANY_MOREINFO_PROC)
  public String LAB_YN; // 기업부설연구소보유여부 (COMPANY_MOREINFO_PROC)
  public String SALES_YEAR; // 매출연도 (COMPANY_MOREINFO_PROC)
  public String SALES_AMOUNT; // 전년도매출액 (COMPANY_MOREINFO_PROC)
  public String CPY_SCALE; // 기업구분 1=일반,2=외감,3=중견 (COMPANY_MOREINFO_PROC)
  public String EMPLOYEE_COUNT; // 직원수 (COMPANY_MOREINFO_PROC)

  public String YYYY;      // COMPANY_SALES 테이블의 YYYY (COMPANY_SALEAMT_CHECK_PROC에서만 사용)
  public String SALES_AMT; // COMPANY_SALES 테이블의 SALES_AMT
  
  public String PAY_CPY;  // 수수료부과대상 (CT_MYCOMPANY_LIST_PROC)

  public String PHONE; // 담당자 전화번호 (CT_MYCOMPANY_LIST_PROC)

  @Override
  public String toString() {
    return "CompanyVO [CPY_ID=" + CPY_ID + ", CST_ID=" + CST_ID + ", CPY_GUBUN=" + CPY_GUBUN + ", CRG_ID=" + CRG_ID
        + ", CPY_NAME=" + CPY_NAME + ", BUSINESS_TYPE=" + BUSINESS_TYPE + ", INDUSTRY=" + INDUSTRY
        + ", CPY_FAX=" + CPY_FAX + ", CPY_BUSINESS_DESC=" + CPY_BUSINESS_DESC + ", CPY_BUSINESS_NO="
        + CPY_BUSINESS_NO + ", CPY_INCORPORATE_NO=" + CPY_INCORPORATE_NO + ", CPY_CEO_NAME=" + CPY_CEO_NAME
        + ", CPY_CEO_HP=" + CPY_CEO_HP + ", CPY_CREDATE=" + CPY_CREDATE + ", CPY_VALIDATE=" + CPY_VALIDATE 
        + ", CPY_FOUNDYEAR=" + CPY_FOUNDYEAR + ", MP_CODE=" + MP_CODE + ", CPY_DISHONOR=" + CPY_DISHONOR
        + ", CONFIRM_SETTLE_YN=" + CONFIRM_SETTLE_YN + ", CPY_ZIPCODE=" + CPY_ZIPCODE + ", CPY_ADDR=" + CPY_ADDR
        + ", CPY_ADDR2=" + CPY_ADDR2 + ", MPTAX_USER_NM=" + MPTAX_USER_NM + ", MPTAX_EMAIL=" + MPTAX_EMAIL
        + ", MPTAX_MONTH_USE_YN=" + MPTAX_MONTH_USE_YN + ", MPTAX_MONTH_USE_ID=" + MPTAX_MONTH_USE_ID
        + ", MPTAX_MONTH_USE_DT=" + MPTAX_MONTH_USE_DT + ", BIZ_DOC_FILE_URL=" + BIZ_DOC_FILE_URL
        + ", CU_USE_YN=" + CU_USE_YN + ", CPY_MEMO= "+ CPY_MEMO + ", FEE_MOD_YN=" + FEE_MOD_YN + ", EMPLOYEE_COUNT=" + EMPLOYEE_COUNT + "]";
  }


}
