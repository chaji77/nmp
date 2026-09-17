package rcftp;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class VO {

    /* CONTRACT */
    protected String SELLER_CODE;
    protected String TRANSACTION_SEQ_NO;
    protected String ORDER_TYPE_CD;
    protected String ORDER_NO;
    protected int ORDER_SEQ_NO;
    protected String CONTRACT_DATE;
    protected String SELLER_ID;
    protected String SELLER_BUSINESS_NO;
    protected String BUYER_ID;
    protected String BUYER_BUSINESS_NO;
    protected BigDecimal TOTAL_CONTRACT_AMT;
    protected String PAYMENT_DUE_DATE;
    protected String ITEM;
    protected String SIZE;
    protected BigDecimal QUANTITY;
    protected String QUANTITY_UNIT;
    protected BigDecimal UNIT_PRICE;
    protected BigDecimal SUPPLY_AMT;
    protected BigDecimal TAX_AMT;
    protected BigDecimal TOTAL_AMT;
    
    /* SETTLEMENT */
    protected String SETTLE_TYPE_CD;
    protected int SETTLE_SEQ_NO;
    protected BigDecimal PAYMENT_AMT;
    protected String PAYMENT_DATE;
	
    // 날짜 검증 (YYYYMMDD 형식 및 유효한 날짜인지 확인)
    protected String validateDate(String value) {
        if (value == null || !value.matches("\\d{8}")) {
            throw new IllegalArgumentException("올바른 날짜 형식이 아님 (YYYYMMDD): " + value);
        }

        DateTimeFormatter formatter = DateTimeFormatter.BASIC_ISO_DATE; // "YYYYMMDD" 형식
        try {
            LocalDate.parse(value, formatter);
            return value;
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("유효하지 않은 날짜: " + value);
        }
    }
    
    // 정수 변환 (기본값 지원)
    protected int parseInteger(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            System.err.println("숫자 변환 오류 (Integer): " + value + " -> 기본값 " + defaultValue + " 사용");
            return defaultValue;
        }
    }

    // BigDecimal 변환 (자리수 제한 포함)
    protected BigDecimal parseBigDecimal(String value, int precision, int scale) {
        try {
            BigDecimal number = new BigDecimal(value);
            // 자리수 초과 시 자동 조정
            if (number.precision() > precision) {
                System.err.println("자리수 초과 (BigDecimal): " + value + " -> " + precision + "자리로 제한됨");
                number = number.setScale(scale, RoundingMode.HALF_UP);
            }
            return number.setScale(scale, RoundingMode.HALF_UP);
        } catch (NumberFormatException | NullPointerException e) {
            System.err.println("숫자 변환 오류 (BigDecimal): " + value + " -> 기본값 0 사용");
            return BigDecimal.ZERO.setScale(scale, RoundingMode.HALF_UP);
        }
    }
    
    protected BigDecimal validateNonZeroBigDecimal(String value, int precision, int scale) {
        BigDecimal number = parseBigDecimal(value, precision, scale);
        if (number.compareTo(BigDecimal.ZERO) == 0) {
            throw new IllegalArgumentException("0의 값이 허용되지 않는 필드에서 0이 입력됨: " + value);
        }
        return number;
    }

    protected String validateString(String value, int maxByteLength) {
        if (value == null || value.trim().isEmpty()) {
            return "UNKNOWN"; // 기본값
        }
        
        // 특수문자 제거 (영문, 한글, 숫자, 공백만 허용)
        String cleaned = value.replaceAll("[^a-zA-Z0-9가-힣 ]", "").trim();
        
        // 현재 바이트 크기 확인
        byte[] byteData = cleaned.getBytes(StandardCharsets.UTF_8);
        
        // 바이트 길이가 maxByteLength 초과하면 자르기
        if (byteData.length > maxByteLength) {
            System.err.println("문자열 바이트 길이 초과: " + cleaned + " -> " + maxByteLength + " 바이트로 제한됨");
            cleaned = trimToMaxBytes(cleaned, maxByteLength);
        }
        
        return cleaned;
    }

    // 문자열을 UTF-8 바이트 기준으로 maxByteLength 이하로 자르기
    protected String trimToMaxBytes(String text, int maxByteLength) {
        int byteCount = 0;
        StringBuilder sb = new StringBuilder();
        
        for (char ch : text.toCharArray()) {
            byte[] charBytes = String.valueOf(ch).getBytes(StandardCharsets.UTF_8);
            if (byteCount + charBytes.length > maxByteLength) {
                break;
            }
            byteCount += charBytes.length;
            sb.append(ch);
        }
        return sb.toString();
    }
}
