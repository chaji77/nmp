package kr.co.mp.mptax;

import java.util.ArrayList;

public class InvoiceVO {

    public int intIssueDirection = 1; //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
    public int intInvoiceType    = 1; //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서

    //intInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
    //intInvoiceType 이 2,5 일 때 : 3-면세
    public int intTaxType        = 1;

    public int intTaxCalcType    = 1; //세율계산방법 : 1-절상, 2-절사, 3-반올림
    public int intPurposeType    = 1; //1-영수, 2-청구

    //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
    public String strModifyCode  = "";

    public String strAmountTotal = ""; //공급가액 총액
    public String strTaxTotal    = ""; //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
    public String strTotalAmount = ""; //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
    public String strCash        = ""; //현금
    public String strWriteDate   = ""; //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.

    public String strSerialNum   = "";

    public String strToBizNo     = "";
    public String strToCorpNm    = "";
    public String strToCeo       = "";
    public String strToManager   = "";
    public String strToAddr      = "";
    public String strToBizType   = "";
    public String strToBizClass  = "";
    public String strToTel       = "";
    public String strToEmail     = "";
    
    public String strRemark      = "";

    public ArrayList<TradeItem> arrTradeItem;

    public class TradeItem {
      public String strPurchaseExpiry = "";        //YYYYMMDD
      public String strName = "";
      public String strInformation = "";
      public String strChargeableUnit = "";
      public String strUnitPrice = "";
      public String strAmount = "";
      public String strTax = "";
      public String strDescription = "";
    }

    /***** ADDITIONAL *****/
    public String BILL_SEQ             ;
    public String BILL_SENDER_KEY      ;
    public int    BILL_STATUS          ;
    public String CTIDS                ;
    public int    CPY_ID               ;
    public int    REG_ID               ;
    public String DEP_NM               ;
    public String EMP_NM               ;
    public int    TCNT                 ;
    public String SUM_TOTAL			   ;
    public String INVOICER_CORP_NUM    ;
    public String INVOICER_CORP_NAME   ;
    public String INVOICER_CEO_NAME    ;
    public String INVOICER_ADDR        ;
    public String INVOICER_BIZ_TYPE    ;
    public String INVOICER_BIZ_CLASS   ;
    public String INVOICER_CONTACT_NAME;
    public String INVOICER_TEL         ;
    public String INVOICER_HP          ;
    public String INVOICER_EMAIL       ;
    public String INVOICE_KEY          ;
    
    
    public String toString() {
    	StringBuffer sb = new StringBuffer();
        sb.append("intIssueDirection       : " + Integer.toString(intIssueDirection));
        sb.append("\nintInvoiceType        : " + Integer.toString(intInvoiceType));
        sb.append("\nintTaxType            : " + Integer.toString(intTaxType));
        sb.append("\nintTaxCalcType        : " + Integer.toString(intTaxCalcType));
        sb.append("\nintPurposeType        : " + Integer.toString(intPurposeType));
        sb.append("\nstrModifyCode         : " + strModifyCode);
        sb.append("\nstrAmountTotal        : " + strAmountTotal ); //공급가액 총액
        sb.append("\nstrTaxTotal           : " + strTaxTotal    ); //세액 총액 intInvoiceType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
        sb.append("\nstrTotalAmount        : " + strTotalAmount ); //합계금액 : 공급가액 총액 + 세액합계 와 일치해야 합니다.
        sb.append("\nstrCash               : " + strCash        ); //현금
        sb.append("\nstrWriteDate          : " + strWriteDate   ); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.
        sb.append("\nstrSerialNum          : " + strSerialNum   );
        sb.append("\nstrToBizNo            : " + strToBizNo     );
        sb.append("\nstrToCorpNm           : " + strToCorpNm    );
        sb.append("\nstrToCeo              : " + strToCeo       );
        sb.append("\nstrToManager          : " + strToManager   );
        sb.append("\nstrToAddr             : " + strToAddr      );
        sb.append("\nstrToBizType          : " + strToBizType   );
        sb.append("\nstrToBizClass         : " + strToBizClass  );
        sb.append("\nstrToTel              : " + strToTel       );
        sb.append("\nstrToEmail            : " + strToEmail     );
        sb.append("\nBILL_SEQ              : " + BILL_SEQ             );
        sb.append("\nBILL_SENDER_KEY       : " + BILL_SENDER_KEY      );
        sb.append("\nBILL_STATUS           : " + BILL_STATUS          );
        sb.append("\nCTIDS                 : " + CTIDS              );
        sb.append("\nCPY_ID                : " + Integer.toString(CPY_ID));
        sb.append("\nREG_ID                : " + Integer.toString(REG_ID));
        sb.append("\nDEP_NM                : " + DEP_NM               );
        sb.append("\nEMP_NM                : " + EMP_NM               );
        sb.append("\nTCNT                  : " + Integer.toString(TCNT));
        sb.append("\nSUM_TOTAL             : " + SUM_TOTAL);
        sb.append("\nINVOICER_CORP_NUM     : " + INVOICER_CORP_NUM    );
        sb.append("\nINVOICER_CORP_NAME    : " + INVOICER_CORP_NAME   );
        sb.append("\nINVOICER_CEO_NAME     : " + INVOICER_CEO_NAME    );
        sb.append("\nINVOICER_ADDR         : " + INVOICER_ADDR        );
        sb.append("\nINVOICER_BIZ_TYPE     : " + INVOICER_BIZ_TYPE    );
        sb.append("\nINVOICER_BIZ_CLASS    : " + INVOICER_BIZ_CLASS   );
        sb.append("\nINVOICER_CONTACT_NAME : " + INVOICER_CONTACT_NAME);
        sb.append("\nINVOICER_TEL          : " + INVOICER_TEL         );
        sb.append("\nINVOICER_HP           : " + INVOICER_HP          );
        sb.append("\nINVOICER_EMAIL        : " + INVOICER_EMAIL       );    	
    	
        for (TradeItem i : arrTradeItem) {
            sb.append("\nITEM.strPurchaseExpiry: " + i.strPurchaseExpiry);
            sb.append("\nITEM.strName          : " + i.strName          );
            sb.append("\nITEM.strInformation   : " + i.strInformation   );
            sb.append("\nITEM.strChargeableUnit: " + i.strChargeableUnit);
            sb.append("\nITEM.strUnitPrice     : " + i.strUnitPrice     );
            sb.append("\nITEM.strAmount        : " + i.strAmount        );
            sb.append("\nITEM.strTax           : " + i.strTax           );
            sb.append("\nITEM.strDescription   : " + i.strDescription   );
        }
    	return sb.toString();
    }

}
