package kr.co.soap.controll;

import java.text.SimpleDateFormat;
import java.util.Date;

import kr.co.funology.fw.util.DateTimeUtil;

public class SequenceGenerator {

    private static volatile SequenceGenerator instance; // 싱글톤 패턴을 위한 인스턴스 변수
    private final String datePattern = "yyyyMMdd"; // 날짜 형식 지정 (예: 20231221)

    private SequenceGenerator() {} // private 생성자 (외부에서 인스턴스 생성 불가)

    // 싱글톤 인스턴스 반환 메서드
    public static SequenceGenerator getInstance() {
        if (instance == null) { // 인스턴스가 null인 경우 초기화
            synchronized (SequenceGenerator.class) { // 동기화 블록으로 다중 쓰레드 환경에서 안전하게 처리
                if (instance == null) { // 다시 null 여부 확인 후 인스턴스 생성
                    instance = new SequenceGenerator();
                }
            }
        }
        return instance; // 인스턴스 반환
    }

    // TRA_CD 시퀀스 생성 (공통 메서드 호출)
    public synchronized String generateTraCd() throws SequenceGenerationException {
        return generateSequence("", "", "");
    }

    // TAX_NO 시퀀스 생성 (공통 메서드 호출)
    public synchronized String generateTaxNo() throws SequenceGenerationException {
        return generateSequence("", "", "");
    }

    // NOTICE_NO 시퀀스 생성 (공통 메서드 호출)
    public synchronized String generateNoticeNo() throws SequenceGenerationException {
        return generateSequence("", "", "");
    }

    // 시퀀스 생성 로직 (공통 처리)
    private String generateSequence(String prefix, String tableName, String columnName) throws SequenceGenerationException {
        try {
            String today = getCurrentDate(); // 현재 날짜 가져오기
            String maxValue = getMaxValue(prefix, tableName, columnName); // DB에서 최대값 조회

            // 최대값이 없거나 날짜가 오늘 날짜와 다르면 초기값 반환
            if (maxValue == null || !maxValue.startsWith(today)) {
                return prefix + today + "0001"; // 초기값: 접두사 + 오늘 날짜 + 0001
            }

            // 최대값이 존재하면 시퀀스 증가
            String serialPart = maxValue.substring(today.length()); // 날짜 이후의 숫자 부분 추출
            int nextSerial = Integer.parseInt(serialPart) + 1; // 숫자 증가

            return prefix + today + String.format("%04d", nextSerial); // 새로운 시퀀스 생성
        } catch (Exception e) {
            // 예외 발생 시 사용자 정의 예외로 변환하여 던지기
            throw new SequenceGenerationException("Error generating sequence for " + prefix, e);
        }
    }

    // 현재 날짜를 지정된 형식으로 반환하는 메서드
    private String getCurrentDate() {
        return new SimpleDateFormat(datePattern).format(new Date());
    }

    // 데이터베이스에서 최대값을 조회하는 메서드 (현재는 Mock 구현)
    private String getMaxValue(String prefix, String tableName, String columnName) {
        // 이 메서드는 실제 데이터베이스 쿼리를 실행하여 최대값을 조회해야 함
        // 현재는 null을 반환 (Mock 구현)
        return null;
    }

    // 사용자 정의 예외 클래스
    public static class SequenceGenerationException extends Exception {
        public SequenceGenerationException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    // DailySeqNo 시퀀스 생성 로직
    private String dailySeqNO(String seqNO) throws SequenceGenerationException {
        try {
            String yyyymmddhhmmss = DateTimeUtil.getCurrentDateTime();
            String yyyymmdd = yyyymmddhhmmss.substring(0, 8);

            SoapCommonBean bean = new SoapCommonBean();
            String seq = bean.GET_INFO_SEQUENCE_DAILY_NEXTSEQ(seqNO); // 일별 시퀀스 조회

            if (seqNO.equals(EnumData.GRT_APPLICATION_NO)) {
                return EnumData.MPCODE + "-" + yyyymmdd + "-" + seq;
            } else if (seqNO.equals(EnumData.TRANS_SEQ_NO)) {
                return seq;
            } else if (seqNO.equals(EnumData.CASH_SEQ_NO)) {
                return EnumData.FIRST_CASH + yyyymmdd.substring(2) + seq;
            } else {
                return seq;
            }
        } catch (Exception e) {
            throw new SequenceGenerationException("Error generating daily sequence for " + seqNO, e);
        }
    }

    public String getTransSeqNO() throws SequenceGenerationException {
        return dailySeqNO(EnumData.TRANS_SEQ_NO);
    }
}
