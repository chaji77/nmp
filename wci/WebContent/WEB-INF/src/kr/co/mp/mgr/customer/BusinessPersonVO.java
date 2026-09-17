package kr.co.mp.mgr.customer;

public class BusinessPersonVO {
  public int CPY_ID;            //판매사아이디
  public int BUY_CPY_ID;        //구매사아이디
  public int PRS_ID;            //담당자아이디
  public String USE_YN;         //사용여부
  
  public String PRS_NAME;       //담당자이름
  public String PRS_LOGIN;      //담당자아이디
  public String PRS_TEL;        //전화번호
  public String PRS_EMAIL;      //이메일
  public String PRS_MOBILE_NO;  //휴대전화

  public String BUY_COMPANY;    //구매사명(관리업체)
  public int ORIGIN_BUY_CPY_ID; //구매사아이디(수정용)
}
