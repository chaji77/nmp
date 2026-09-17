package kr.co.mp.firstbill;

import kr.co.funology.fw.util.FormatUtil;
import kr.co.funology.fw.util.StrUtil;

public class InvoiceUtil {


    public static String getStatus(InvoiceVO vo) {
        String str = "[오류] " + Integer.toString(vo.BILL_STATUS);
        // 내부코드
        if (vo.BILL_STATUS == 0) str = "발행신청";
        if (vo.BILL_STATUS == 9) str = "발급취소";
        // 바로빌코드
        if (vo.BILL_STATUS == 1000) str = "발행대기";
        if (vo.BILL_STATUS == 5031) str = "발행취소";
        if (vo.BILL_STATUS == 3014) str = "발행완료";
        // 국세청코드
        if (vo.BILL_STATUS == 1) str = "국세청전송전";
        if (vo.BILL_STATUS == 2) str = "국세청전송중";
        if (vo.BILL_STATUS == 3) str = "국세청전송중";
        if (vo.BILL_STATUS == 4) str = "국세청전송완료";
        if (vo.BILL_STATUS == 5) str = "국세청전송실패";
        return str;
    }

    /**
     * 발행방향
     *
     * @param vo
     * @return
     */
    public static String getIssueType(InvoiceVO vo) {
        String str = "";
        if (vo.intPurposeType == 1) str = "정발행";
        if (vo.intPurposeType == 2) str = "역발행";
        return str;
    }

    /**
     * 과세/면세/영세
     *
     * @param vo
     * @return
     */
    public static String getChargeType(InvoiceVO vo) {
        String str = "과세";
        if (vo.intInvoiceType == 1 || vo.intInvoiceType == 4) {
            if (vo.intTaxType == 2) str = "영세";
        } else {
            if (vo.intTaxType == 3) str = "면세";
        }
        return str;
    }

    /**
     * 계산서종류
     *
     * @param vo
     * @return
     */
    public static String getInvoiceType(InvoiceVO vo) {
        String str = "";
        if (vo.intInvoiceType == 1) str = "전자세금계산서";
        if (vo.intInvoiceType == 2) str = "전자계산서";
        if (vo.intInvoiceType == 4) str = "위수탁세금계산서";
        if (vo.intInvoiceType == 5) str = "위수탁계산서";
        return str;
    }

    /**
     * 청구/영수구분
     *
     * @param vo
     * @return
     */
    public static String getPurposeType(InvoiceVO vo) {
        String str = "";
        if (vo.intPurposeType == 1) str = "영수";
        if (vo.intPurposeType == 2) str = "청구";
        return str;
    }

    /**
     * 수정분류
     *
     * @param vo
     * @return
     */
    public static String getTaxType(InvoiceVO vo) {
        String str = "일반세금계산서";
        if (vo.strModifyCode.equals("1")) str = "기재사항의 착오 정정";
        if (vo.strModifyCode.equals("2")) str = "공급가액의 변동";
        if (vo.strModifyCode.equals("3")) str = "재화의 환입";
        if (vo.strModifyCode.equals("4")) str = "계약의 해제";
        if (vo.strModifyCode.equals("5")) str = "내국신용장 사후개설";
        if (vo.strModifyCode.equals("6")) str = "착오에 의한 이중발행";
        return str;
    }

    public static String getBizNo(String strBizNo) {
        strBizNo = StrUtil.nvl(strBizNo);
        if (strBizNo.length()==10) {
            return FormatUtil.addDashBizNo(strBizNo);
        } else if (strBizNo.length()>10) {
            return strBizNo.substring(0, 6) + "-" + strBizNo.substring(6);
        } else return strBizNo;
    }

}
