package kr.co.soap.kibo.guarantee;

import java.math.BigDecimal;

/**
 * 기보(KIBO) 담보보증 VO 클래스
 *
 * 신보(GuaranteeVO)와 차이점:
 * - 전문 prefix: sb: → 없음 (일반 태그명)
 * - C211: 신청전송(MP→기보), C221: 접수통지(기보→MP)
 * - F211: 조건변경 (신보 F221에 해당)
 *         PK가 CApplicationNO (새 신청번호) + EApplicationNO (원 보증신청번호)
 * - H211: 보증해지
 *         LoanExpirationDate → GuaranteeExpiration
 *         ClearCode 없음, JobDate(처리일) 추가
 */
public class KiboGuaranteeVO {

    // ─────────────────────────────────────────
    // 공통 헤더 VO
    // ─────────────────────────────────────────
    public static class CommonVO {
        public String TransactionID     = "";
        public String CodeType          = "";
        public String TransactionLength = "";
        public String Sender            = "";
        public String TransactionSEQNO  = "";
        public String Receiver          = "";
        public String TransactionNO     = "";
        public String TransactionDate   = "";
        public String TransactionTime   = "";
        public String ResponseCode      = "";
        public String ResponseMessage   = "";
        public String UserField         = "";
    }

    // ─────────────────────────────────────────
    // C221 VO (보증접수통지 / 접수변경 / 취소)
    // C221: 기보→MP 접수통지  -> STATUS 030(접수)
    // C223: 접수변경           -> STATUS 030(접수)
    // C225: 보증신청취소       -> STATUS 090(취소)
    // C227: 보증진행취소       -> STATUS 090(취소)
    // ─────────────────────────────────────────
    public static class C221VO extends CommonVO {
        public String EApplicationNO            = "";   // 보증신청번호 (KIBO_GUARANTEE.APPLNO 조인키)
        public String SeqNO                     = "";
        public String GuaranteeNO               = "";
        public String ID                        = "";   // 구매기업 ID
        public String BusinessNO                = "";   // 구매기업 사업자번호
        public String CustomerNO                = "";
        public String RegistrationDate          = "";
        public String GuaranteeCode             = "";
        public String CurrencyCode              = "";
        public BigDecimal ApplicationAMT        = BigDecimal.ZERO;
        public BigDecimal GuaranteeRate         = BigDecimal.ZERO;
        public String GuaranteeExpirationText   = "";
        public String GuaranteeType             = "";
        public String LoanPurpose               = "";
        public String GuaranteeWay              = "";
        public String FavoriteDate              = "";
        public String ApplicantName             = "";
        public String ApplicantTelno            = "";
        public String ApplicantEmail            = "";
        public String SellerID                  = "";
        public String SellerBusinessNO          = "";
        public String CancelDate                = "";
        public String CancelReason              = "";
    }

    // ─────────────────────────────────────────
    // D211 VO (보증승인통지)
    // D211: 승인 -> STATUS 040(승인)
    // D215: 승인취소 -> STATUS 030(접수로 복구)
    // ─────────────────────────────────────────
    public static class D211VO extends CommonVO {
        public String EApplicationNO    = "";
        public String SeqNO             = "";
        public String ID                = "";
        public String BusinessNO        = "";
        public String GuaranteeNO       = "";
        public String ApprovalDate      = "";
        public BigDecimal ApprovalAMT   = BigDecimal.ZERO;
        public String CancelDate        = "";
        public String CancelReason      = "";
        public String CustomerNO        = "";
        public String CurrencyCode      = "";
    }

    // ─────────────────────────────────────────
    // E211 VO (보증서발급내역)
    // E211: 발급 -> STATUS 050(발급)
    // ─────────────────────────────────────────
    public static class E211VO extends CommonVO {
        public String EApplicationNO            = "";
        public String SeqNO                     = "";
        public String GuaranteeNO               = "";
        public String GuaranteeKind             = "";
        public String ID                        = "";
        public String BusinessNO                = "";
        public String CustomerNO                = "";
        public String IssueDate                 = "";
        public String GuaranteeAMTText          = "";
        public BigDecimal GuaranteeAMT          = BigDecimal.ZERO;
        public String GuaranteeExpirationDate   = "";
        public String GuaranteeType             = "";
        public String Creditor                  = "";
        public int    ConditionCount            = 0;
        public String GuaranteeMaxAMTText       = "";
        public String[] Conditions              = new String[0];
    }

    // ─────────────────────────────────────────
    // F211 VO (조건변경통지 - 신보의 F221에 해당)
    // F211: 조건변경 -> STATUS 변경없음, CHG_EXPIREYMD 업데이트
    // F215: 조건변경취소 -> 상태변경없음
    //
    // 신보 F221과 핵심 차이:
    //   - CApplicationNO: F211 신청번호 (PK)
    //   - EApplicationNO: 원 보증서 신청번호 (KIBO_GUARANTEE 조인키)
    //   - GuaranteeNO: 보증번호
    //   - KCGFBranch → FundBranchName
    //   - IssueInformation, GuaranteeInformation 없음
    // ─────────────────────────────────────────
    public static class F211VO extends CommonVO {
        public String CApplicationNO    = "";   // F211 변경신청번호 (PK)
        public String EApplicationNO    = "";   // 원 보증서 신청번호
        public String SeqNO             = "";
        public String ID                = "";
        public String BusinessNO        = "";
        public String CustomerNO        = "";
        public String CGuaranteeNO      = "";
        public String GuaranteeNO       = "";   // 보증번호
        public String ChiefName         = "";
        public String FundBranchName    = "";
        public String TELNO             = "";
        public String TeamCode          = "";
        public String TeamMember        = "";
        public String BranchAddress     = "";
        public String GuaranteeCaution1 = "";
        public String GuaranteeCaution2 = "";
        public int    Ccount            = 0;
        // 조건변경 상세
        public String[] CArticles       = new String[0];
        public String[] Befores         = new String[0];
        public String[] Afters          = new String[0];
        public String[] ChgYNs          = new String[0];
    }

    // ─────────────────────────────────────────
    // H211 VO (보증해지)
    // H211: 해지  -> STATUS 080(해지)
    // H215: 해지취소 -> STATUS 050(발급으로 복구)
    //
    // 신보 H211과 핵심 차이:
    //   - LoanExpirationDate → GuaranteeExpiration
    //   - ClearCode 없음
    //   - JobDate(해지처리일) 추가
    // ─────────────────────────────────────────
    public static class H211VO extends CommonVO {
        public String EApplicationNO        = "";
        public String SeqNO                 = "";
        public String ID                    = "";
        public String BusinessNO            = "";
        public String SellerID              = "";
        public String SellerBusinessNO      = "";
        public String GuaranteeNO           = "";
        public String LoanDate              = "";
        public String GuaranteeExpiration   = "";   // 신보의 LoanExpirationDate
        public String GuaranteeType         = "";
        public BigDecimal GuaranteeAMT      = BigDecimal.ZERO;
        public String JobDate               = "";   // 해지처리일 (신보에 없음)
        public BigDecimal ClearAMT          = BigDecimal.ZERO;
        public BigDecimal GuaranteeBalance  = BigDecimal.ZERO;
        public String CancelDate            = "";
        public String CancelReason          = "";
    }
}
