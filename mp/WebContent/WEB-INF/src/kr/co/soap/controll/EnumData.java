package kr.co.soap.controll;

import java.util.HashMap;

import kr.co.funology.fw.mgr.ConfigurationMgr;

public class EnumData {
	
	public static final int longNull = -9999;
    public static final double doubleNull = -9999.0;

    public static final String A211 = "A211"; // 회원 및 한도조회
    public static final String B211 = "B211"; // 매매계약서 전송
    public static final String B213 = "B213"; // 매매계약서 전송 - 변경
    public static final String B215 = "B215"; // 매매계약서 전송 - 취소
    public static final String C211 = "C211"; // 보증신청 전송
    public static final String C213 = "C213"; // 보증신청 전송 - 변경
    public static final String C215 = "C215"; // 보증신청 전송 - 취소
    public static final String C221 = "C221"; // 보증접수 통지
    public static final String C223 = "C223"; // 보증접수 통지 - 변경
    public static final String C225 = "C225"; // 보증접소 통지 - 취소
    public static final String C227 = "C227"; // 보증진행취소통지 - 전송
    public static final String D211 = "D211"; // 보증승인 통지
    public static final String D215 = "D215"; // 보증승인 통지 - 취소
    public static final String E211 = "E211"; // 보증서발급내역 통지
    public static final String F211 = "F211"; // 조건변경통지서 전송
    public static final String F221 = "F221"; // 조건변경통지서 전송
    public static final String F225 = "F225"; // 조건변경통지서취소통지
    public static final String H211 = "H211"; // 보증해지 내역통지
    public static final String H215 = "H215"; // 보증해지 내역취소통지
    public static final String K231 = "K231"; // 결제정보
    public static final String K233 = "K233"; // 결제정보 - 변경
    public static final String K235 = "K235"; // 결제정보 - 취소
    public static final String L211 = "L211"; // 배송정보전송
    public static final String L213 = "L213"; // 배송정보전송 - 변경
    public static final String L215 = "L215"; // 배송정보전송 - 취소
    public static final String M211 = "M211"; // 어음발행내역전송
    public static final String M213 = "M213"; // 어음발행내역전송 - 변경
    public static final String M215 = "M215"; // 어음발행내역전송 - 취소
    public static final String M221 = "M221"; // 어음수취내역전송
    public static final String M225 = "M225"; // 어음수취내역전송-취소
    public static final String CM00 = "CM00"; // 공통전문
    public static final String BB10 = "BB10"; // MP보증신청 전송
    public static final String BB13 = "BB13"; // MP보증변경 신청
    public static final String BB15 = "BB15"; // MP보증신청 취소
    public static final String COMM = "COMM"; // 공통전문

    public static final String K311 = "K311"; // 결제전문번호
    public static final String K312 = "K312"; // 결제회신전문번호
    public static final String K315 = "K315"; // 결제취소전문번호
    public static final String K316 = "K316"; // 결제취소전문번호
    public static final String K321 = "K321"; // 구매물건인수확인전문번호
    public static final String K322 = "K322"; // 구매물건인수확인회신전문번호
    public static final String B311 = "B311"; // 매매계약전문번호
    public static final String B312 = "B312"; // 매매계약회신전문번호
    public static final String A185 = "A185"; // 시스템조회전문번호
    public static final String A186 = "A186"; // 시스템조회회신전문번호
    public static final String A181 = "A181"; // 트랜젝션전문번호
    public static final String A182 = "A182"; // 트랜젝션회신전문번호



    public static final String C211_OK = ",C221,C227,"; // 보증신청단계 경우 들어올 수 있는 전문번호(020)
    //public static final String C213_OK = ",C221,C213,C227,"; // 변경신청단계 경우 들어올 수 있는 전문번호(020)
    public static final String C221_OK = ",C223,C225,D211,"; // 보증접수단계 경우 들어올 수 있는 전문번호(030)
    public static final String C223_OK = ",C223,"; 			// 접수취소단계 경우 들어올 수 있는 전문번호(090)
    public static final String C225_OK = ",C221,"; 		// 접수취소단계 경우 들어올 수 있는 전문번호(020)
    public static final String D211_OK = ",D215,E211,";      // 보증승인단계 경우 들어올 수 있는 전문번호(040)
    //public static final String D215_OK = ",C223,C225,D211,"; // 보증승인취소단계 경우 들어올 수 있는 전문번호(030)
    public static final String E211_OK = ",F211,H211,H215,";      // 보증발급단계 경우 들어올 수 있는 전문번호(050)
    public static final String F221_OK = ",F225,H211,";      // 조건변경 경우 들어올 수 있는 전문번호(050)
    //public static final String F225_OK = ",F221,H211,";      // 조건변경취소 경우 들어올 수 있는 전문번호(050)
    public static final String H211_OK = ",H215,";           // 보증해지 경우 들어올 수 있는 전문번호  (080)

    // INFO_SEQUENCE TABLE KEY VALUE
    public static final String GRT_APPLICATION_NO = "001";   // 보증신청번호 시퀀스 키값
    public static final String TRANS_SEQ_NO       = "002";   // 트랜젝션 시퀀스 키값
    public static final String TRADE_SEQ_NO       = "003";   // 주문번호 시퀀스 키값
    public static final String CASH_SEQ_NO        = "004";   // 현금 시퀀스 키값
    public static final String FIRST_CASH         = "C";     // 현금번호 앞

    public static final String FIRST_GRT   = "TH";          // 주문번호 앞

    public static final String MPCODE   = ConfigurationMgr.getInstance().getString("OWNER_MPCODE");          // MP CODE
    public static final String KCGFCODE = "0760000";          // 기금코드
    public static final String KIBOCODE = "0770000";          // 기금코드

    public static final String MP_APPLICATION_STATUS   = "010";// MP신청 상태
    public static final String KCGF_APPLICATION_STATUS = "020";// 신보신청 상태
    public static final String REGIST_STATUS           = "030";// 접수 상태
    public static final String APRROVAL_STATUS         = "040";// 승인 상태
    public static final String ISSUE_NO_STATUS         = "045";// 발급 상태
    public static final String ISSUE_STATUS            = "050";// 발급 상태(수신동의 후)
    public static final String CLEAR_STATUS            = "080";// 해지 상태
    public static final String CANCEL_STATUS           = "090";// 취소 상태

    public static final String GRT_TYPE                = "02";// 근보증
    public static final String PER_GRT_TYPE            = "01";// 개별보증

    public static final String ISS                		= "ISS";// 발행
    public static final String RCV            			= "RCV";// 수취

    public static final String CHGTYPE10      			= "10";// 신규
    public static final String CHGTYPE20      			= "20";// 기한연장
    public static final String CHGTYPE30      			= "30";// 감액
    public static final String CHGTYPE40      			= "40";// 일부해지
    public static final String CHGTYPE90      			= "90";// 신규조건

    public static final String SYS_BIGBEAM    			= "이엠투";// 자동 처리자

    public static final String SYS_KIBO    			= "기술보증기금";// 자동 처리자

    public static final String SUCCESS    			    = "1";// 자동 처리자
    public static final String FAIL    			    = "0";// 자동 처리자

    public static final HashMap getStatusDesc() {
	     HashMap map = new HashMap();
	     map.put(MP_APPLICATION_STATUS, "MP신청");
	     map.put(KCGF_APPLICATION_STATUS, "기금신청");
	     map.put(REGIST_STATUS, "접수");
	     map.put(APRROVAL_STATUS, "승인");
	     map.put(ISSUE_STATUS, "발급");
	     map.put(CLEAR_STATUS, "해지");
	     map.put(CANCEL_STATUS, "취소");

	     return map;
    }

    public static final HashMap getTransactionnoDesc() {
	     HashMap map = new HashMap();
	     map.put(A211, "회원 및 한도조회");
	     map.put(B211, "매매계약서신규");
	     map.put(B213, "매매계약서변경");
	     map.put(B215, "매매계약서취소");
	     map.put(C211, "보증신청신규");
	     map.put(C213, "보증신청변경");
	     map.put(C215, "보증신청취소");
	     map.put(C221, "보증접수통지");
	     map.put(C223, "보증접수변경");
	     map.put(C225, "보증접수취소");
	     map.put(C227, "보증진행취소통지");
	     map.put(D211, "보증승인통지");
	     map.put(D215, "보증승인취소");
	     map.put(E211, "보증서발급");
	     map.put(F221, "조건변경통지");
	     map.put(F225, "조건변경통지취소");
	     map.put(H211, "보증해지");
	     map.put(H215, "보증해지취소");
	     map.put(K231, "결제신규");
	     map.put(K233, "결제변경");
	     map.put(K235, "결제취소");
	     map.put(L211, "배송전송");
	     map.put(L213, "배송변경");
	     map.put(L215, "배송취소");
	     map.put(M211, "어음발행");
	     map.put(M213, "어음발행변경");
	     map.put(M215, "어음발행취소");
	     map.put(M221, "어음수취");
	     map.put(M225, "어음수취취소");
	     map.put(CM00, "공통전문");
	     map.put(BB10, "MP보증신청");
	     map.put(BB13, "MP보증변경");
	     map.put(BB15, "MP보증취소");
	     return map;
    }
}
