package rcftp;

import java.math.BigDecimal;

public class SettleVO extends VO {

    public SettleVO(String[] data) {
        try {
            this.SELLER_CODE = validateString(data[0], 5);
            this.TRANSACTION_SEQ_NO = validateString(data[1], 11);
            this.SETTLE_TYPE_CD = validateString(data[2], 4);
            this.ORDER_NO = validateString(data[3], 20);
            this.SETTLE_SEQ_NO = parseInteger(data[4], 1);
            if (this.SETTLE_TYPE_CD.equals("K235")) {
                this.PAYMENT_AMT  = new BigDecimal(0);
                this.PAYMENT_DATE = "";
            } else {
                this.PAYMENT_AMT  = validateNonZeroBigDecimal(data[5], 15, 0);
                this.PAYMENT_DATE = validateDate(data[6]);
            }
            System.out.println(this.toString());
        } catch (Exception e) {
            throw new IllegalArgumentException("데이터 변환 중 오류 발생: " + e.getMessage(), e);
        }
    }

    @Override
    public String toString() {
        return "SettleVO [SELLER_CODE=" + SELLER_CODE + ", TRANSACTION_SEQ_NO=" + TRANSACTION_SEQ_NO
                + ", SETTLE_TYPE_CD=" + SETTLE_TYPE_CD + ", ORDER_NO=" + ORDER_NO + ", SETTLE_SEQ_NO=" + SETTLE_SEQ_NO
                + ", PAYMENT_AMT=" + PAYMENT_AMT + ", PAYMENT_DATE=" + PAYMENT_DATE + "]";
    }
}
