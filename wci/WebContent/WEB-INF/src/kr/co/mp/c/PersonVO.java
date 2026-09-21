package kr.co.mp.c;

public class PersonVO {
	public String PRS_ID; // 사용자ID
	public String CPY_ID; // 회원사ID
	public String PRS_NAME; // 이름
	public String PRS_TEL; // 전화번호
	public String PRS_LOGIN; // 로그인ID
	public String PRS_PASSWD; // 로그인암호
	public String PRS_EMAIL; // 이메일
	public String PRS_MOBILE_NO; // 핸드폰번호
	public String PRS_SMS; // 문자메세지
	public String PRS_PSTN; // 담당자 직위
	public String PRS_EXTN; // 내선번호
	
	@Override
	public String toString() {
		return "PersonVO [PRS_ID=" + PRS_ID + ", CPY_ID=" + CPY_ID + ", PRS_NAME=" + PRS_NAME + ", PRS_TEL=" + PRS_TEL
				+ ", PRS_LOGIN=" + PRS_LOGIN + ", PRS_PASSWD=" + PRS_PASSWD + ", PRS_EMAIL=" + PRS_EMAIL
				+ ", PRS_MOBILE_NO=" + PRS_MOBILE_NO + ", PRS_SMS=" + PRS_SMS
				+ ", PRS_PSTN=" + PRS_PSTN + ", PRS_EXTN=" + PRS_EXTN + "]";
	}
}
