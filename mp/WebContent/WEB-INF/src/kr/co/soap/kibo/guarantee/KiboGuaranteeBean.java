package kr.co.soap.kibo.guarantee;

import java.math.BigDecimal;
import java.util.Map;

import org.apache.log4j.Logger;

/**
 * 기보(KIBO) 담보보증 Bean
 * 신보 GuaranteeBean 과 동일한 패턴
 *
 * 전문별 상태코드 처리:
 * C221/C223 -> 030(접수)
 * C225/C227 -> 090(취소)
 * D211      -> 040(승인)
 * D215      -> 030(접수 복구)
 * E211      -> 050(발급)
 * F211      -> 상태변경 없음, CHG_EXPIREYMD 업데이트
 * F215      -> 상태변경 없음
 * H211      -> 080(해지)
 * H215      -> 050(발급 복구)
 *
 * 신보와 핵심 차이:
 * - XML 태그에 "sb:" prefix 없음
 * - F211 PK = CApplicationNO (신보 F221은 ApplicationNO)
 * - F211 EApplicationNO = KIBO_GUARANTEE 조인키
 * - H211 GuaranteeExpiration (신보는 LoanExpirationDate)
 * - H211 JobDate (신보에 없음)
 * - H211 ClearCode 없음
 */
public class KiboGuaranteeBean {

    private KiboGuaranteeDAO dao = new KiboGuaranteeDAO();
    private Logger logger = Logger.getLogger(this.getClass());

    // ─────────────────────────────────────────
    // C221/C223/C225/C227 처리 (보증접수통지)
    // ─────────────────────────────────────────
    public int processC221(String transNO, Map<String, String> ht) {
        try {
            KiboGuaranteeVO.C221VO vo = new KiboGuaranteeVO.C221VO();

            vo.TransactionSEQNO         = get(ht, "TransactionSEQNO");
            vo.TransactionNO            = transNO;
            vo.TransactionID            = get(ht, "TransactionID");
            vo.CodeType                 = get(ht, "CodeType");
            vo.TransactionLength        = get(ht, "TransactionLength");
            vo.Sender                   = get(ht, "Sender");
            vo.Receiver                 = get(ht, "Receiver");
            vo.TransactionDate          = get(ht, "TransactionDate");
            vo.TransactionTime          = get(ht, "TransactionTime");
            vo.ResponseCode             = get(ht, "ResponseCode");
            vo.UserField                = get(ht, "UserField");
            vo.EApplicationNO           = get(ht, "EApplicationNO");
            vo.GuaranteeNO              = get(ht, "GuaranteeNO");
            vo.ID                       = get(ht, "ID");
            vo.BusinessNO               = get(ht, "BusinessNO");
            vo.CustomerNO               = get(ht, "CustomerNO");
            vo.RegistrationDate         = get(ht, "RegisterationDate");   // 오타 주의
            vo.GuaranteeCode            = get(ht, "GuaranteeCode");
            vo.CurrencyCode             = get(ht, "CurrencyCode");
            vo.ApplicationAMT           = toBigDecimal(get(ht, "ApplicationAMT"));
            vo.GuaranteeRate            = toBigDecimal(get(ht, "GuaranteeRate"));
            vo.GuaranteeExpirationText  = get(ht, "GuaranteeExpirationText");
            vo.GuaranteeType            = get(ht, "GuaranteeType");
            vo.LoanPurpose              = get(ht, "LoanPurpose");
            vo.GuaranteeWay             = get(ht, "GuaranteeWay");
            vo.FavoriteDate             = get(ht, "FavoriteDate");
            vo.ApplicantName            = get(ht, "ApplicantName");
            vo.ApplicantTelno           = get(ht, "ApplicantTelno");
            vo.ApplicantEmail           = get(ht, "ApplicantEmail");
            vo.SellerID                 = get(ht, "SellerID");
            vo.SellerBusinessNO         = get(ht, "SellerBusinessNO");
            vo.CancelDate               = get(ht, "CancelDate");
            vo.CancelReason             = get(ht, "CancelReason");

            // SeqNO 채번 (KIBO_XML_C221 기준)
            vo.SeqNO = dao.getNextSeqNo("KIBO_XML_C221", "EApplicationNO", vo.EApplicationNO);

            // KIBO_XML_C221 INSERT
            dao.receiveXmlC221(vo);

            // KIBO_GUARANTEE 상태 업데이트
            // C221/C223: 030(접수), C225/C227: 090(취소)
            String status = ("C225".equals(transNO) || "C227".equals(transNO)) ? "090" : "030";
            dao.updateKiboGuarantee(
                vo.EApplicationNO, transNO, status,
                vo.GuaranteeNO,
                vo.ApplicationAMT,
                "", "", ""
            );

            // KIBO_GUARANTEE_STATUS INSERT
            dao.addKiboGuaranteeStatus(
                vo.EApplicationNO, transNO,
                vo.ApplicationAMT,
                transNO + " 기보 보증접수처리"
            );

            logger.info("[KiboGuaranteeBean] " + transNO + " 처리완료: " + vo.EApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[KiboGuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // D211/D215 처리 (보증승인통지)
    // ─────────────────────────────────────────
    public int processD211(String transNO, Map<String, String> ht) {
        try {
            KiboGuaranteeVO.D211VO vo = new KiboGuaranteeVO.D211VO();

            vo.TransactionSEQNO = get(ht, "TransactionSEQNO");
            vo.TransactionNO    = transNO;
            vo.TransactionID    = get(ht, "TransactionID");
            vo.CodeType         = get(ht, "CodeType");
            vo.TransactionLength= get(ht, "TransactionLength");
            vo.Sender           = get(ht, "Sender");
            vo.Receiver         = get(ht, "Receiver");
            vo.TransactionDate  = get(ht, "TransactionDate");
            vo.TransactionTime  = get(ht, "TransactionTime");
            vo.ResponseCode     = get(ht, "ResponseCode");
            vo.UserField        = get(ht, "UserField");
            vo.EApplicationNO   = get(ht, "EApplicationNO");
            vo.ID               = get(ht, "ID");
            vo.BusinessNO       = get(ht, "BusinessNO");
            vo.GuaranteeNO      = get(ht, "GuaranteeNO");
            vo.ApprovalDate     = get(ht, "ApprovalDate");
            vo.ApprovalAMT      = toBigDecimal(get(ht, "ApprovalAMT"));
            vo.CancelDate       = get(ht, "CancelDate");
            vo.CancelReason     = get(ht, "CancelReason");
            vo.CustomerNO       = get(ht, "CustomerNO");
            vo.CurrencyCode     = get(ht, "CurrencyCode");

            vo.SeqNO = dao.getNextSeqNo("KIBO_XML_D211", "EApplicationNO", vo.EApplicationNO);

            // KIBO_XML_D211 INSERT
            dao.receiveXmlD211(vo);

            // KIBO_GUARANTEE 상태 업데이트
            String status = "D215".equals(transNO) ? "030" : "040";
            dao.updateKiboGuarantee(
                vo.EApplicationNO, transNO, status,
                "", vo.ApprovalAMT,
                "", "", ""
            );

            // KIBO_GUARANTEE_STATUS INSERT
            dao.addKiboGuaranteeStatus(
                vo.EApplicationNO, transNO,
                vo.ApprovalAMT,
                transNO + " 기보 보증승인처리"
            );

            logger.info("[KiboGuaranteeBean] " + transNO + " 처리완료: " + vo.EApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[KiboGuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // E211 처리 (보증서발급내역)
    // ─────────────────────────────────────────
    public int processE211(String transNO, Map<String, String> ht) {
        try {
            KiboGuaranteeVO.E211VO vo = new KiboGuaranteeVO.E211VO();

            vo.TransactionSEQNO         = get(ht, "TransactionSEQNO");
            vo.TransactionNO            = transNO;
            vo.TransactionID            = get(ht, "TransactionID");
            vo.CodeType                 = get(ht, "CodeType");
            vo.TransactionLength        = get(ht, "TransactionLength");
            vo.Sender                   = get(ht, "Sender");
            vo.Receiver                 = get(ht, "Receiver");
            vo.TransactionDate          = get(ht, "TransactionDate");
            vo.TransactionTime          = get(ht, "TransactionTime");
            vo.ResponseCode             = get(ht, "ResponseCode");
            vo.UserField                = get(ht, "UserField");
            vo.EApplicationNO           = get(ht, "EApplicationNO");
            vo.GuaranteeNO              = get(ht, "GuaranteeNO");
            vo.GuaranteeKind            = get(ht, "GuaranteeKind");
            vo.ID                       = get(ht, "ID");
            vo.BusinessNO               = get(ht, "BusinessNO");
            vo.CustomerNO               = get(ht, "CustomerNO");
            vo.IssueDate                = get(ht, "IssueDate");
            vo.GuaranteeAMTText         = get(ht, "GuaranteeAMTText");
            vo.GuaranteeAMT             = toBigDecimal(get(ht, "GUARANTEEAMTEXT"));
            vo.GuaranteeExpirationDate  = get(ht, "GuaranteeExpirationDate");
            vo.GuaranteeType            = get(ht, "GuaranteeType");
            vo.Creditor                 = get(ht, "Creditor");
            vo.ConditionCount           = toInt(get(ht, "ConditionCount"));
            vo.GuaranteeMaxAMTText      = get(ht, "GuaranteeMaxAMTText");

            // 조건 파싱
            String condRaw = get(ht, "Condition");
            if (!condRaw.isEmpty()) {
                vo.Conditions = condRaw.split("&");
            }

            vo.SeqNO = dao.getNextSeqNo("KIBO_XML_E211", "EApplicationNO", vo.EApplicationNO);

            // KIBO_XML_E211 INSERT
            dao.receiveXmlE211(vo);

            // KIBO_XML_E211_CONDITION INSERT
            for (int c = 0; c < vo.Conditions.length; c++) {
                dao.receiveXmlE211Condition(
                    vo.EApplicationNO, vo.SeqNO,
                    c + 1, vo.Conditions[c]
                );
            }

            // KIBO_GUARANTEE 상태 업데이트 -> 050(발급)
            dao.updateKiboGuarantee(
                vo.EApplicationNO, transNO, "050",
                vo.GuaranteeNO, vo.GuaranteeAMT,
                vo.IssueDate,   // 발급일 -> ISSUEYMD, FIRST_EXPIREYMD
                "", ""
            );

            // KIBO_GUARANTEE_STATUS INSERT
            dao.addKiboGuaranteeStatus(
                vo.EApplicationNO, transNO,
                vo.GuaranteeAMT,
                transNO + " 기보 보증발급처리"
            );

            logger.info("[KiboGuaranteeBean] " + transNO + " 처리완료: " + vo.EApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[KiboGuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

     // ─────────────────────────────────────────
    // F211/F215 처리 수정본
    // 실제 기보 XML 구조 반영:
    //   - <IndivPart> (DataPart 아님)
    //   - <CcountInfoList Ccount="01"> (속성값)
    //   - <CcountInfo><CArticle><Before><After> (ChgYN 없음)
    //   - Before/After 날짜: "2026-07-02" 형식 (하이픈 포함)
    // ─────────────────────────────────────────
       public int processF211(String transNO, Map<String, String> ht) {
        try {
            KiboGuaranteeVO.F211VO vo = new KiboGuaranteeVO.F211VO();

            vo.TransactionSEQNO = get(ht, "TransactionSEQNO");
            vo.TransactionNO    = transNO;
            vo.TransactionID    = get(ht, "TransactionID");
            vo.CodeType         = get(ht, "CodeType");
            vo.TransactionLength= get(ht, "TransactionLength");
            vo.Sender           = get(ht, "Sender");
            vo.Receiver         = get(ht, "Receiver");
            vo.TransactionDate  = get(ht, "TransactionDate");
            vo.TransactionTime  = get(ht, "TransactionTime");
            vo.ResponseCode     = get(ht, "ResponseCode");
            vo.UserField        = get(ht, "UserField");
            vo.CApplicationNO   = get(ht, "CApplicationNO");
            vo.EApplicationNO   = get(ht, "EApplicationNO");
            vo.ID               = get(ht, "ID");
            vo.BusinessNO       = get(ht, "BusinessNO");
            vo.CustomerNO       = get(ht, "CustomerNO");
            vo.CGuaranteeNO     = get(ht, "CGuaranteeNO");
            vo.GuaranteeNO      = get(ht, "GuaranteeNO");
            vo.ChiefName        = get(ht, "ChiefName");
            vo.FundBranchName   = get(ht, "FundBranchName");
            vo.TELNO            = get(ht, "TELNO");
            vo.TeamCode         = get(ht, "TeamCode");
            vo.TeamMember       = get(ht, "TeamMember");
            vo.BranchAddress    = get(ht, "BranchAddress");
            vo.GuaranteeCaution1= get(ht, "GuaranteeCaution1");
            vo.GuaranteeCaution2= get(ht, "GuaranteeCaution2");
            vo.Ccount           = toInt(get(ht, "Ccount"));

            // 조건변경 상세 파싱
            String cArticleRaw = get(ht, "CArticle");
            String beforeRaw   = get(ht, "Before");
            String afterRaw    = get(ht, "After");
            String chgYNRaw    = get(ht, "ChgYN");

            if (!cArticleRaw.isEmpty()) {
                vo.CArticles = cArticleRaw.split("&");
                vo.Befores   = beforeRaw.split("&");
                vo.Afters    = afterRaw.split("&");
                vo.ChgYNs    = chgYNRaw.isEmpty() ? new String[0] : chgYNRaw.split("&");
            }

            // EApplicationNO 없으면 GuaranteeNO 로 조회
            if (vo.EApplicationNO.isEmpty()) {
                vo.EApplicationNO = dao.findApplNoByGrtNo(vo.GuaranteeNO);
            }
            if (vo.EApplicationNO.isEmpty()) {
                logger.error("[KiboGuaranteeBean] F211 EApplicationNO 없음 - GuaranteeNO: "
                             + vo.GuaranteeNO);
                return -1;
            }

            vo.SeqNO = dao.getNextSeqNo("KIBO_XML_F211", "CApplicationNO", vo.CApplicationNO);

            // KIBO_XML_F211 INSERT
            dao.receiveXmlF211(vo);

            // KIBO_XML_F211_CONDITION INSERT
            for (int c = 0; c < vo.CArticles.length; c++) {
                dao.receiveXmlF211Condition(
                    vo.CApplicationNO, vo.SeqNO, c + 1,
                    vo.CArticles[c].trim(),
                    c < vo.Befores.length ? vo.Befores[c].trim() : "",
                    c < vo.Afters.length  ? vo.Afters[c].trim()  : "",
                    c < vo.ChgYNs.length  ? vo.ChgYNs[c].trim()  : ""
                );
            }

            // ─────────────────────────────────────────
            // CHG_EXPIREYMD 추출
            // CArticle 한글이 깨질 수 있으므로 한글 비교 대신
            // After 값에서 날짜 형식(YYYYMMDD 8자리)을 직접 추출
            // 기보 F211 특성: 조건변경은 보증기한 1건이 대부분
            // After 값 예: "2027-07-02                "
            // ─────────────────────────────────────────
            String chgExpireYmd = "";
            for (int c = 0; c < vo.Afters.length; c++) {
                String afterVal = vo.Afters[c].trim();
                // 숫자만 추출
                String digitsOnly = afterVal.replaceAll("[^0-9]", "");
                if (digitsOnly.length() == 8) {
                    // YYYYMMDD 형식 검증 (년도 2000~2099)
                    String yr = digitsOnly.substring(0, 4);
                    if (yr.startsWith("20")) {
                        chgExpireYmd = digitsOnly;
                        logger.info("[KiboGuaranteeBean] F211 CHG_EXPIREYMD: " + chgExpireYmd);
                        break;
                    }
                }
            }

            dao.updateKiboGuarantee(
                vo.EApplicationNO, transNO, "",
                "", null, "", chgExpireYmd, ""
            );

            // KIBO_GUARANTEE_STATUS INSERT
            dao.addKiboGuaranteeStatus(
                vo.EApplicationNO, transNO,
                null,
                transNO + " 기보 조건변경처리"
            );

            logger.info("[KiboGuaranteeBean] " + transNO + " 처리완료: CApplicationNO=" +
                        vo.CApplicationNO + " / EApplicationNO=" + vo.EApplicationNO +
                        " / CHG_EXPIREYMD=" + chgExpireYmd);
            return 1;

        } catch (Exception e) {
            logger.error("[KiboGuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }



    // ─────────────────────────────────────────
    // H211/H215 처리 (보증해지)
    // 신보와 차이: GuaranteeExpiration, JobDate, ClearCode없음
    // ─────────────────────────────────────────
    public int processH211(String transNO, Map<String, String> ht) {
        try {
            KiboGuaranteeVO.H211VO vo = new KiboGuaranteeVO.H211VO();

            vo.TransactionSEQNO     = get(ht, "TransactionSEQNO");
            vo.TransactionNO        = transNO;
            vo.TransactionID        = get(ht, "TransactionID");
            vo.CodeType             = get(ht, "CodeType");
            vo.TransactionLength    = get(ht, "TransactionLength");
            vo.Sender               = get(ht, "Sender");
            vo.Receiver             = get(ht, "Receiver");
            vo.TransactionDate      = get(ht, "TransactionDate");
            vo.TransactionTime      = get(ht, "TransactionTime");
            vo.ResponseCode         = get(ht, "ResponseCode");
            vo.UserField            = get(ht, "UserField");
            vo.EApplicationNO       = get(ht, "EApplicationNO");
            vo.ID                   = get(ht, "ID");
            vo.BusinessNO           = get(ht, "BusinessNO");
            vo.SellerID             = get(ht, "SellerID");
            vo.SellerBusinessNO     = get(ht, "SellerBusinessNO");
            vo.GuaranteeNO          = get(ht, "GuaranteeNO");
            vo.LoanDate             = get(ht, "LoanDate");
            // 신보 LoanExpirationDate → 기보 GuaranteeExpiration
            vo.GuaranteeExpiration  = get(ht, "GuaranteeExpiration");
            vo.GuaranteeType        = get(ht, "GuaranteeType");
            vo.GuaranteeAMT         = toBigDecimal(get(ht, "GuaranteeAMT"));
            // 기보 추가 필드
            vo.JobDate              = get(ht, "JobDate");
            vo.ClearAMT             = toBigDecimal(get(ht, "ClearAMT"));
            vo.GuaranteeBalance     = toBigDecimal(get(ht, "GuaranteeBalance"));
            vo.CancelDate           = get(ht, "CancelDate");
            vo.CancelReason         = get(ht, "CancelReason");

            vo.SeqNO = dao.getNextSeqNo("KIBO_XML_H211", "EApplicationNO", vo.EApplicationNO);

            // KIBO_XML_H211 INSERT
            dao.receiveXmlH211(vo);

            // KIBO_GUARANTEE 상태 업데이트
            String status = "H215".equals(transNO) ? "050" : "080";
            String clearYmd = "H211".equals(transNO) ? vo.TransactionDate : "";
            dao.updateKiboGuarantee(
                vo.EApplicationNO, transNO, status,
                "", null,
                "", "", clearYmd
            );

            // KIBO_GUARANTEE_STATUS INSERT
            dao.addKiboGuaranteeStatus(
                vo.EApplicationNO, transNO,
                vo.ClearAMT,
                transNO + " 기보 보증해지처리"
            );

            logger.info("[KiboGuaranteeBean] " + transNO + " 처리완료: " + vo.EApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[KiboGuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // 전각문자 날짜 변환
    // ─────────────────────────────────────────
    private String convertFullWidthDate(String fullWidthDate) {
        if (fullWidthDate == null || fullWidthDate.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : fullWidthDate.toCharArray()) {
            if (c >= '０' && c <= '９') {
                sb.append((char)('0' + (c - '０')));
            }
        }
        return sb.toString();
    }

    // ─────────────────────────────────────────
    // 유틸
    // 신보는 "sb:TagName" 이지만 기보는 태그명 직접 사용
    // ─────────────────────────────────────────
    private String get(Map<String, String> map, String key) {
        String val = map.get(key);
        if (val != null && val.contains("&")) {
            if (key.equals("CArticle") || key.equals("Before") ||
                key.equals("After")    || key.equals("ChgYN")  ||
                key.equals("Condition")) {
                return val;
            }
            return val.substring(0, val.indexOf("&"));
        }
        return val != null ? val : "";
    }

    private BigDecimal toBigDecimal(String val) {
        try { return new BigDecimal(val.trim()); }
        catch (Exception e) { return BigDecimal.ZERO; }
    }

    private int toInt(String val) {
        try { return Integer.parseInt(val.trim()); }
        catch (Exception e) { return 0; }
    }
}
