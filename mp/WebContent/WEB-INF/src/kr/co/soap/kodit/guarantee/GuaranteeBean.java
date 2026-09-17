package kr.co.soap.kodit.guarantee;

import java.math.BigDecimal;
import java.util.Map;

import org.apache.log4j.Logger;

/**
 * 담보보증 Bean
 * XML Map -> VO 변환 + DB 저장
 * 
 * [상태코드]
 * 010: MP신청
 * 020: 기금신청
 * 030: 접수
 * 040: 승인
 * 045: 발급대기
 * 050: 발급
 * 080: 해지
 * 090: 취소
 */
public class GuaranteeBean {

    private GuaranteeDAO dao = new GuaranteeDAO();
    private Logger logger = Logger.getLogger(this.getClass());

    // ─────────────────────────────────────────
    // C221/C223/C225/C227 처리
    // C221: 보증접수통지   -> 030(접수)
    // C223: 보증접수변경   -> 030(접수)
    // C225: 보증신청취소   -> 090(취소)
    // C227: 보증진행취소   -> 090(취소)
    // ─────────────────────────────────────────
    public int processC221(String transNO, Map<String, String> ht) {
        try {
            GuaranteeVO.C221VO vo = new GuaranteeVO.C221VO();

            vo.TransactionSEQNO         = get(ht, "sb:TransactionSEQNO");
            vo.TransactionNO            = transNO;
            vo.Sender                   = get(ht, "sb:Sender");
            vo.Receiver                 = get(ht, "sb:Receiver");
            vo.TransactionDate          = get(ht, "sb:TransactionDate");
            vo.TransactionTime          = get(ht, "sb:TransactionTime");
            vo.ResponseCode             = get(ht, "sb:ResponseCode");
            vo.UserField                = get(ht, "sb:UserField");
            vo.ApplicationNO            = get(ht, "sb:ApplicationNO");
            vo.GuaranteeNO              = get(ht, "sb:GuaranteeNO");
            vo.BuyerID                  = get(ht, "sb:BuyerID");
            vo.BuyerBusinessNO          = get(ht, "sb:BuyerBusinessNO");
            vo.SellerID                 = get(ht, "sb:SellerID");
            vo.SellerBusinessNO         = get(ht, "sb:SellerBusinessNO");
            vo.RegistrationDate         = get(ht, "sb:RegistrationDate");
            vo.ApplicationAMT           = toBigDecimal(get(ht, "sb:ApplicationAMT"));
            vo.GuaranteeExpirationText  = get(ht, "sb:GuaranteeExpirationText");
            vo.GuaranteeType            = get(ht, "sb:GuaranteeType");
            vo.CancelDate               = get(ht, "sb:CancelDate");
            vo.CancelReason             = get(ht, "sb:CancelReason");

            vo.SeqNO = dao.getNextSeqNo("XML_C221", "ApplicationNO", vo.ApplicationNO);

            // XML_C221 INSERT
            dao.receiveXmlC221(vo);

            // INFO_GUARANTEE 상태 업데이트
            // C221/C223: 030(접수), C225/C227: 090(취소)
            String status = ("C225".equals(transNO) || "C227".equals(transNO)) ? "090" : "030";
            dao.updateInfoGuarantee(
                vo.ApplicationNO, transNO, status,
                vo.GuaranteeNO,
                vo.ApplicationAMT,
                "", "", ""
            );

            // INFO_GUARANTEE_STATUS INSERT
            dao.addInfoGuaranteeStatus(
                vo.ApplicationNO, transNO,
                vo.ApplicationAMT,
                transNO + " 보증신청처리"
            );

            logger.info("[GuaranteeBean] " + transNO + " 처리완료: " + vo.ApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[GuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // D211/D215 처리
    // D211: 보증승인통지   -> 040(승인)
    // D215: 보증승인취소   -> 030(접수로 복구)
    // ─────────────────────────────────────────
    public int processD211(String transNO, Map<String, String> ht) {
        try {
            GuaranteeVO.D211VO vo = new GuaranteeVO.D211VO();

            vo.TransactionSEQNO = get(ht, "sb:TransactionSEQNO");
            vo.TransactionNO    = transNO;
            vo.Sender           = get(ht, "sb:Sender");
            vo.Receiver         = get(ht, "sb:Receiver");
            vo.TransactionDate  = get(ht, "sb:TransactionDate");
            vo.TransactionTime  = get(ht, "sb:TransactionTime");
            vo.ResponseCode     = get(ht, "sb:ResponseCode");
            vo.UserField        = get(ht, "sb:UserField");
            vo.ApplicationNO    = get(ht, "sb:ApplicationNO");
            vo.ID               = get(ht, "sb:ID");
            vo.BusinessNO       = get(ht, "sb:BusinessNO");
            vo.GuaranteeNO      = get(ht, "sb:GuaranteeNO");
            vo.ApprovalDate     = get(ht, "sb:ApprovalDate");
            vo.ApprovalAMT      = toBigDecimal(get(ht, "sb:ApprovalAMT"));
            vo.CancelDate       = get(ht, "sb:CancelDate");
            vo.CancelReason     = get(ht, "sb:CancelReason");

            vo.SeqNO = dao.getNextSeqNo("XML_D211", "ApplicationNO", vo.ApplicationNO);

            // XML_D211 INSERT
            dao.receiveXmlD211(vo);

            // INFO_GUARANTEE 상태 업데이트
            // D211: 040(승인), D215: 030(접수로 복구)
            String status = "D215".equals(transNO) ? "030" : "040";
            dao.updateInfoGuarantee(
                vo.ApplicationNO, transNO, status,
                "", vo.ApprovalAMT,
                "", "", ""
            );

            // INFO_GUARANTEE_STATUS INSERT
            dao.addInfoGuaranteeStatus(
                vo.ApplicationNO, transNO,
                vo.ApprovalAMT,
                transNO + " 보증승인처리"
            );

            logger.info("[GuaranteeBean] " + transNO + " 처리완료: " + vo.ApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[GuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // E211/E221/E225 처리
    // E211: 보증서발급내역 -> 050(발급)
    // E221: 보증서발급     -> 050(발급)
    // E225: 보증서발급취소 -> 045(발급대기로 복구)
    // ─────────────────────────────────────────
    public int processE211(String transNO, Map<String, String> ht) {
        try {
            GuaranteeVO.E211VO vo = new GuaranteeVO.E211VO();

            vo.TransactionSEQNO         = get(ht, "sb:TransactionSEQNO");
            vo.TransactionNO            = transNO;
            vo.Sender                   = get(ht, "sb:Sender");
            vo.Receiver                 = get(ht, "sb:Receiver");
            vo.TransactionDate          = get(ht, "sb:TransactionDate");
            vo.TransactionTime          = get(ht, "sb:TransactionTime");
            vo.ResponseCode             = get(ht, "sb:ResponseCode");
            vo.UserField                = get(ht, "sb:UserField");
            vo.ApplicationNO            = get(ht, "sb:ApplicationNO");
            vo.GuaranteeNO              = get(ht, "sb:GuaranteeNO");
            vo.GuaranteeCode            = get(ht, "sb:GuaranteeCode");
            vo.BuyerID                  = get(ht, "sb:BuyerID");
            vo.BuyerBusinessNO          = get(ht, "sb:BuyerBusinessNO");
            vo.IssueDate                = get(ht, "sb:IssueDate");
            vo.GuaranteeAMT             = toBigDecimal(get(ht, "sb:GuaranteeAMT"));
            vo.GuaranteeExpirationDate  = get(ht, "sb:GuaranteeExpirationDate");
            vo.GuaranteeType            = get(ht, "sb:GuaranteeType");
            vo.Creditor                 = get(ht, "sb:Creditor");
            vo.ConditionCount           = toInt(get(ht, "sb:ConditionCount"));

            // 조건 파싱 (& 구분자로 연결된 값 분리)
            String condRaw = get(ht, "sb:Condition");
            if (!condRaw.isEmpty()) {
                vo.Conditions = condRaw.split("&");
            }

            vo.SeqNO = dao.getNextSeqNo("XML_E211", "ApplicationNO", vo.ApplicationNO);

            // XML_E211 INSERT
            dao.receiveXmlE211(vo);

            // XML_E211_CONDITION INSERT
            for (int c = 0; c < vo.Conditions.length; c++) {
                dao.receiveXmlE211Condition(
                    vo.ApplicationNO, vo.SeqNO,
                    c + 1, vo.Conditions[c]
                );
            }

            // INFO_GUARANTEE 상태 업데이트
            // E211/E221: 050(발급), E225: 045(발급대기로 복구)
            String status = "E225".equals(transNO) ? "045" : "050";
            dao.updateInfoGuarantee(
                vo.ApplicationNO, transNO, status,
                vo.GuaranteeNO, vo.GuaranteeAMT,
                vo.IssueDate,
                vo.GuaranteeExpirationDate, ""
            );

            // INFO_GUARANTEE_STATUS INSERT
            dao.addInfoGuaranteeStatus(
                vo.ApplicationNO, transNO,
                vo.GuaranteeAMT,
                transNO + " 보증서발급처리"
            );

            logger.info("[GuaranteeBean] " + transNO + " 처리완료: " + vo.ApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[GuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // F221/F225 처리 (조건변경)
    // F221: 조건변경통지
    // F225: 조건변경취소
    // ApplicationNO 없으면 GuaranteeNO 로 DB 조회
    // ─────────────────────────────────────────
    public int processF221(String transNO, Map<String, String> ht) {
        try {
            GuaranteeVO.F221VO vo = new GuaranteeVO.F221VO();

            vo.TransactionSEQNO         = get(ht, "sb:TransactionSEQNO");
            vo.TransactionNO            = transNO;
            vo.Sender                   = get(ht, "sb:Sender");
            vo.Receiver                 = get(ht, "sb:Receiver");
            vo.TransactionDate          = get(ht, "sb:TransactionDate");
            vo.TransactionTime          = get(ht, "sb:TransactionTime");
            vo.ResponseCode             = get(ht, "sb:ResponseCode");
            vo.UserField                = get(ht, "sb:UserField");
            vo.ApplicationNO            = get(ht, "sb:ApplicationNO");
            vo.ID                       = get(ht, "sb:ID");
            vo.BusinessNO               = get(ht, "sb:BusinessNO");
            vo.CustomerNO               = get(ht, "sb:CustomerNO");
            vo.CGuaranteeNO             = get(ht, "sb:CGuaranteeNO");
            vo.BankText                 = get(ht, "sb:BankText");
            vo.CompanyNameText          = get(ht, "sb:CompanyNameText");
            vo.CEONameText              = get(ht, "sb:CEONameText");
            vo.Address                  = get(ht, "sb:Address");
            vo.GuaranteeNO              = get(ht, "sb:GuaranteeNO");
            vo.GuaranteeDate            = get(ht, "sb:GuaranteeDate");
            vo.GuaranteeExpirationDate  = get(ht, "sb:GuaranteeExpirationDate");
            vo.GuaranteeAMTText         = get(ht, "sb:GuaranteeAMTText");
            vo.CissueDate               = get(ht, "sb:CIssueDate");
            vo.ChiefName                = get(ht, "sb:ChiefName");
            vo.KCGFBranch               = get(ht, "sb:KCGFBranch");
            vo.TELNO                    = get(ht, "sb:TELNO");
            vo.TeamCode                 = get(ht, "sb:TeamCode");
            vo.TeamMember               = get(ht, "sb:TeamMember");
            vo.BranchAddress            = get(ht, "sb:BranchAddress");
            vo.IssueInformation         = get(ht, "sb:IssueInformation");
            vo.CCount                   = toInt(get(ht, "sb:CCount"));
            vo.CancelDate               = get(ht, "sb:CancelDate");

            // 조건변경 상세 파싱 (& 구분자)
            String cArticleRaw = get(ht, "sb:CArticle");
            String beforeRaw   = get(ht, "sb:Before");
            String afterRaw    = get(ht, "sb:After");
            if (!cArticleRaw.isEmpty()) {
                vo.CArticles = cArticleRaw.split("&");
                vo.Befores   = beforeRaw.split("&");
                vo.Afters    = afterRaw.split("&");
            }

            // ApplicationNO 없으면 GuaranteeNO 로 DB 조회 (dao 통해서)
            if (vo.ApplicationNO.isEmpty()) {
                vo.ApplicationNO = dao.findApplNoByGrtNo(vo.GuaranteeNO);
            }

            // ApplicationNO 조회 실패 시 처리 중단
            // 파일 로그는 이미 저장됨 -> 나중에 수동 처리 가능
            if (vo.ApplicationNO.isEmpty()) {
                logger.error("[GuaranteeBean] F221 ApplicationNO 없음 - GuaranteeNO: "
                             + vo.GuaranteeNO);
                return -1;
            }

            vo.SeqNO = dao.getNextSeqNo("XML_F221", "ApplicationNO", vo.ApplicationNO);

            // XML_F221 INSERT
            dao.receiveXmlF221(vo);

            // XML_F221_CONDITION INSERT
            for (int c = 0; c < vo.CArticles.length; c++) {
                dao.receiveXmlF221Condition(
                    vo.ApplicationNO, vo.SeqNO, c + 1,
                    vo.CArticles[c],
                    c < vo.Befores.length ? vo.Befores[c] : "",
                    c < vo.Afters.length  ? vo.Afters[c]  : ""
                );
            }

            // INFO_GUARANTEE 보증만료일 업데이트 (보증기한 변경 시)
            String chgExpireYmd = "";
            for (int c = 0; c < vo.CArticles.length; c++) {
                if ("보증기한".equals(vo.CArticles[c]) && c < vo.Afters.length) {
                    chgExpireYmd = convertFullWidthDate(vo.Afters[c]);
                    break;
                }
            }

            dao.updateInfoGuarantee(
                vo.ApplicationNO, transNO, "",
                "", null, "", chgExpireYmd, ""
            );

            // INFO_GUARANTEE_STATUS INSERT
            dao.addInfoGuaranteeStatus(
                vo.ApplicationNO, transNO,
                null,
                transNO + " 조건변경처리"
            );

            logger.info("[GuaranteeBean] " + transNO + " 처리완료: " + vo.ApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[GuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // H211/H215 처리
    // H211: 보증해지   -> 080(해지)
    // H215: 보증해지취소 -> 050(발급으로 복구)
    // ─────────────────────────────────────────
    public int processH211(String transNO, Map<String, String> ht) {
        try {
            GuaranteeVO.H211VO vo = new GuaranteeVO.H211VO();

            vo.TransactionSEQNO     = get(ht, "sb:TransactionSEQNO");
            vo.TransactionNO        = transNO;
            vo.Sender               = get(ht, "sb:Sender");
            vo.Receiver             = get(ht, "sb:Receiver");
            vo.TransactionDate      = get(ht, "sb:TransactionDate");
            vo.TransactionTime      = get(ht, "sb:TransactionTime");
            vo.ResponseCode         = get(ht, "sb:ResponseCode");
            vo.UserField            = get(ht, "sb:UserField");
            vo.ApplicationNO        = get(ht, "sb:ApplicationNO");
            vo.BuyerID              = get(ht, "sb:BuyerID");
            vo.BuyerBusinessNO      = get(ht, "sb:BuyerBusinessNO");
            vo.SellerID             = get(ht, "sb:SellerID");
            vo.SellerBusinessNO     = get(ht, "sb:SellerBusinessNO");
            vo.GuaranteeNO          = get(ht, "sb:GuaranteeNO");
            vo.LoanDate             = get(ht, "sb:LoanDate");
            vo.LoanExpirationDate   = get(ht, "sb:LoanExpirationDate");
            vo.GuaranteeType        = get(ht, "sb:GuaranteeType");
            vo.GuaranteeAMT         = toBigDecimal(get(ht, "sb:GuaranteeAMT"));
            vo.ClearAMT             = toBigDecimal(get(ht, "sb:ClearAMT"));
            vo.ClearCode            = get(ht, "sb:ClearCode");
            vo.GuaranteeBalance     = toBigDecimal(get(ht, "sb:GuaranteeBalance"));
            vo.CancelDate           = get(ht, "sb:CancelDate");
            vo.CancelReason         = get(ht, "sb:CancelReason");

            vo.SeqNO = dao.getNextSeqNo("XML_H211", "ApplicationNO", vo.ApplicationNO);

            // XML_H211 INSERT
            dao.receiveXmlH211(vo);

            // INFO_GUARANTEE 상태 업데이트
            // H211: 080(해지), H215: 050(발급으로 복구)
            String status = "H215".equals(transNO) ? "050" : "080";
            dao.updateInfoGuarantee(
                vo.ApplicationNO, transNO, status,
                "", null,
                "", "", vo.TransactionDate
            );

            // INFO_GUARANTEE_STATUS INSERT
            dao.addInfoGuaranteeStatus(
                vo.ApplicationNO, transNO,
                vo.ClearAMT,
                transNO + " 보증해지처리"
            );

            logger.info("[GuaranteeBean] " + transNO + " 처리완료: " + vo.ApplicationNO);
            return 1;

        } catch (Exception e) {
            logger.error("[GuaranteeBean] " + transNO + " 처리오류: " + e.toString());
            return -1;
        }
    }

    // ─────────────────────────────────────────
    // 전각문자 날짜 변환
    // ２０２７－０６－０３ -> 20270603
    // ─────────────────────────────────────────
    private String convertFullWidthDate(String fullWidthDate) {
        if (fullWidthDate == null || fullWidthDate.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : fullWidthDate.toCharArray()) {
            if (c >= '０' && c <= '９') {
                sb.append((char)('0' + (c - '０')));
            }
            // 구분자(－ 또는 -) 는 제거
        }
        return sb.toString();
    }

    // ─────────────────────────────────────────
    // 유틸
    // ─────────────────────────────────────────
    private String get(Map<String, String> map, String key) {
        String val = map.get(key);
        if (val != null && val.contains("&")) {
            // Condition, CArticle, Before, After 는 반복태그이므로 그대로 반환
            if (key.contains("Condition") || key.contains("CArticle")
                    || key.contains("Before") || key.contains("After")) {
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
