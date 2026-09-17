package kr.co.soap.kodit.guarantee;

import java.math.BigDecimal;

/**
 * 담보보증 VO 클래스
 */
public class GuaranteeVO {

    // ─────────────────────────────────────────
    // 공통 헤더 VO
    // ─────────────────────────────────────────
    public static class CommonVO {
        public String TransactionSEQNO  = "";
        public String TransactionNO     = "";
        public String Sender            = "";
        public String Receiver          = "";
        public String TransactionDate   = "";
        public String TransactionTime   = "";
        public String ResponseCode      = "";
        public String UserField         = "";
    }

    // ─────────────────────────────────────────
    // C221 VO (보증신청 접수/변경/취소)
    // ─────────────────────────────────────────
    public static class C221VO extends CommonVO {
        public String ApplicationNO             = "";
        public String SeqNO                     = "";
        public String GuaranteeNO               = "";
        public String BuyerID                   = "";
        public String BuyerBusinessNO           = "";
        public String SellerID                  = "";
        public String SellerBusinessNO          = "";
        public String RegistrationDate          = "";
        public BigDecimal ApplicationAMT        = BigDecimal.ZERO;
        public String GuaranteeExpirationText   = "";
        public String GuaranteeType             = "";
        public String CancelDate                = "";
        public String CancelReason              = "";
    }

    // ─────────────────────────────────────────
    // D211 VO (보증승인 통지/취소)
    // ─────────────────────────────────────────
    public static class D211VO extends CommonVO {
        public String ApplicationNO     = "";
        public String SeqNO             = "";
        public String ID                = "";
        public String BusinessNO        = "";
        public String GuaranteeNO       = "";
        public String ApprovalDate      = "";
        public BigDecimal ApprovalAMT   = BigDecimal.ZERO;
        public String CancelDate        = "";
        public String CancelReason      = "";
    }

    // ─────────────────────────────────────────
    // E211 VO (보증서 발급내역)
    // ─────────────────────────────────────────
    public static class E211VO extends CommonVO {
        public String ApplicationNO             = "";
        public String SeqNO                     = "";
        public String GuaranteeNO               = "";
        public String GuaranteeCode             = "";
        public String BuyerID                   = "";
        public String BuyerBusinessNO           = "";
        public String IssueDate                 = "";
        public BigDecimal GuaranteeAMT          = BigDecimal.ZERO;
        public String GuaranteeExpirationDate   = "";
        public String GuaranteeType             = "";
        public String Creditor                  = "";
        public int    ConditionCount            = 0;
        public String[] Conditions              = new String[0]; // 조건목록
    }

    // ─────────────────────────────────────────
    // F221 VO (조건변경 통지서)
    // ─────────────────────────────────────────
    public static class F221VO extends CommonVO {
        public String ApplicationNO             = "";
        public String SeqNO                     = "";
        public String ID                        = "";
        public String BusinessNO                = "";
        public String CustomerNO                = "";
        public String CGuaranteeNO              = "";
        public String BankText                  = "";
        public String CompanyNameText           = "";
        public String CEONameText               = "";
        public String Address                   = "";
        public String GuaranteeNO               = "";
        public String GuaranteeDate             = "";
        public String GuaranteeExpirationDate   = "";
        public String GuaranteeAMTText          = "";
        public String CissueDate                = "";
        public String ChiefName                 = "";
        public String KCGFBranch                = "";
        public String TELNO                     = "";
        public String TeamCode                  = "";
        public String TeamMember                = "";
        public String BranchAddress             = "";
        public String IssueInformation          = "";
        public int    CCount                    = 0;
        public String CancelDate                = "";
        // 조건변경 상세
        public String[] CArticles               = new String[0];
        public String[] Befores                 = new String[0];
        public String[] Afters                  = new String[0];
    }

    // ─────────────────────────────────────────
    // H211 VO (보증해지)
    // ─────────────────────────────────────────
    public static class H211VO extends CommonVO {
        public String ApplicationNO             = "";
        public String SeqNO                     = "";
        public String BuyerID                   = "";
        public String BuyerBusinessNO           = "";
        public String SellerID                  = "";
        public String SellerBusinessNO          = "";
        public String GuaranteeNO               = "";
        public String LoanDate                  = "";
        public String LoanExpirationDate        = "";
        public String GuaranteeType             = "";
        public BigDecimal GuaranteeAMT          = BigDecimal.ZERO;
        public BigDecimal ClearAMT              = BigDecimal.ZERO;
        public String ClearCode                 = "";
        public BigDecimal GuaranteeBalance      = BigDecimal.ZERO;
        public String CancelDate                = "";
        public String CancelReason              = "";
    }
}
