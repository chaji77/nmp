package rcftp;

import java.math.BigDecimal;

/**
 * 
 */
public class ContractVO extends VO {

    public ContractVO(String[] data) {
        try {
            this.SELLER_CODE = validateString(data[0], 5);
            this.TRANSACTION_SEQ_NO = validateString(data[1], 11);
            this.ORDER_TYPE_CD = validateString(data[2], 4);
            this.ORDER_NO = validateString(data[3], 20);
            if (this.ORDER_TYPE_CD.equals("B215")) {
                this.ORDER_SEQ_NO = 0;
                this.CONTRACT_DATE = "";
                this.SELLER_ID = "";
                this.SELLER_BUSINESS_NO = "";
                this.BUYER_ID = "";
                this.BUYER_BUSINESS_NO = "";
                this.TOTAL_CONTRACT_AMT = new BigDecimal(0);
                this.PAYMENT_DUE_DATE = "";
                this.ITEM = "";
                this.SIZE = "";
                this.QUANTITY = new BigDecimal(0);
                this.QUANTITY_UNIT = validateString(data[15], 20);
                this.UNIT_PRICE = new BigDecimal(0);
                this.SUPPLY_AMT = new BigDecimal(0);
                this.TAX_AMT = new BigDecimal(0);
                this.TOTAL_AMT = new BigDecimal(0);
            } else {
                this.ORDER_SEQ_NO = parseInteger(data[4], 1);
                this.CONTRACT_DATE = validateDate(data[5]);  // 날짜 검증 추가
                this.SELLER_ID = validateString(data[6], 13);
                this.SELLER_BUSINESS_NO = validateString(data[7], 10);
                this.BUYER_ID = validateString(data[8], 13);
                this.BUYER_BUSINESS_NO = validateString(data[9], 10);
                this.TOTAL_CONTRACT_AMT = validateNonZeroBigDecimal(data[10], 15, 0);
                this.PAYMENT_DUE_DATE = validateDate(data[11]);  // 날짜 검증 추가
                this.ITEM = validateString(data[12], 100);
                this.SIZE = validateString(data[13], 100);
                this.QUANTITY = validateNonZeroBigDecimal(data[14], 10, 4);
                this.QUANTITY_UNIT = validateString(data[15], 20);
                this.UNIT_PRICE = validateNonZeroBigDecimal(data[16], 15, 2);
                this.SUPPLY_AMT = validateNonZeroBigDecimal(data[17], 15, 0);
                this.TAX_AMT = parseBigDecimal(data[18], 15, 0);
                this.TOTAL_AMT = validateNonZeroBigDecimal(data[19], 15, 0);
            }
            System.out.println(this.toString());
        } catch (Exception e) {
            throw new IllegalArgumentException("데이터 변환 중 오류 발생: " + e.getMessage(), e);
        }
    }

    @Override
    public String toString() {
        return "ContractVO [SELLER_CODE=" + SELLER_CODE + ", TRANSACTION_SEQ_NO=" + TRANSACTION_SEQ_NO
                + ", ORDER_TYPE_CD=" + ORDER_TYPE_CD + ", ORDER_NO=" + ORDER_NO + ", ORDER_SEQ_NO=" + ORDER_SEQ_NO
                + ", CONTRACT_DATE=" + CONTRACT_DATE + ", SELLER_ID=" + SELLER_ID + ", SELLER_BUSINESS_NO="
                + SELLER_BUSINESS_NO + ", BUYER_ID=" + BUYER_ID + ", BUYER_BUSINESS_NO=" + BUYER_BUSINESS_NO
                + ", TOTAL_CONTRACT_AMT=" + TOTAL_CONTRACT_AMT + ", PAYMENT_DUE_DATE=" + PAYMENT_DUE_DATE + ", ITEM="
                + ITEM + ", SIZE=" + SIZE + ", QUANTITY=" + QUANTITY + ", QUANTITY_UNIT=" + QUANTITY_UNIT
                + ", UNIT_PRICE=" + UNIT_PRICE + ", SUPPLY_AMT=" + SUPPLY_AMT + ", TAX_AMT=" + TAX_AMT + ", TOTAL_AMT="
                + TOTAL_AMT + "]";
    }
    

}
