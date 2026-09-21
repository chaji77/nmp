package kr.co.soap.kibo;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.soap.controll.kibo.CommonElement;
import kr.co.soap.kibo.guarantee.KiboGuaranteeBean;
import kr.co.soap.kibo.loan.emtnet.EmtNetRcvBM;

/**
 * 기보(KIBO) 담보보증 전문 수신 서블릿
 *
 * [변경내용]
 * 기존: 담보보증 전문 → 3번 서버(210.112.124.3:7770) 포워딩
 * 변경: 담보보증 전문 → 자체 DB 처리 (KIBO_* 테이블)
 *
 * [담보보증 전문번호]
 * C221/C223/C225/C227: 보증접수통지/변경/취소
 * D211/D215:           보증승인통지/취소
 * E211:                보증서발급내역
 * F211/F215:           조건변경통지/취소  (신보의 F221/F225)
 * H211/H215:           보증해지/취소
 *
 * [기존 유지]
 * A187:                 수신확인
 * K311/K315 등:         대출보증 → EmtNetRcvBM 처리
 */
@WebServlet(name="KiboResponseTransaction", urlPatterns="/KiboResponseTransaction")
public class KiboResponseTransaction extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(KiboResponseTransaction.class);
    private KiboGuaranteeBean guaranteeBean = new KiboGuaranteeBean();

    // 문자 인코딩 변환
    private String asc2ksc(String str) {
        if (str == null) return "";
        try {
            return new String(str.getBytes("8859_1"), "KSC5601");
        } catch (Exception e) {
            logger.error("asc2ksc 변환 오류", e);
            return str;
        }
    }

    // XML 유효하지 않은 문자 제거
    private String stripNonValidXMLCharacters(String in) {
        if (in == null || in.isEmpty()) return "";
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < in.length(); i++) {
            char c = in.charAt(i);
            if ((c == 0x9) || (c == 0xA) || (c == 0xD) ||
                ((c >= 0x20) && (c <= 0xD7FF)) ||
                ((c >= 0xE000) && (c <= 0xFFFD)) ||
                ((c >= 0x10000) && (c <= 0x10FFFF))) {
                out.append(c);
            } else {
                out.append(" ");
            }
        }
        return out.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html; charset=utf-8");
        PrintWriter out = response.getWriter();

        String ts = new SimpleDateFormat("HHmmssSSS").format(new Date());

        try {
            Enumeration<?> paramNames = request.getParameterNames();
            Hashtable<String, String> hash = new Hashtable<>();
            while (paramNames.hasMoreElements()) {
                String name = (String) paramNames.nextElement();
                String value = asc2ksc(request.getParameter(name));
                hash.put(name, value);
            }

            String inXML = (String) hash.get("inXML");
            logger.debug("[KiboResponseTransaction] inXML = [" + inXML + "]");

            Document doc = null;
            try {
                doc = XMLEasyUtil.parseXMLDocument(inXML, "utf-8");
            } catch (Exception e) {
                inXML = stripNonValidXMLCharacters(inXML);
                doc = XMLEasyUtil.parseXMLDocument(inXML, "utf-8");
            }

            // 공통 헤더 파싱
            CommonElement reqCommonElement = new CommonElement(doc);
            String transNO = reqCommonElement.getTransactionNO();
            logger.info("[KiboResponseTransaction] 수신전문: " + transNO);

            // 파일 로그 저장
            saveXmlLog(ts, inXML, transNO, "RECV");

            String ret = "";

            // ── A187: 수신확인 (기존 유지)
            if ("A187".equals(transNO)) {
                ret = buildA187Response(reqCommonElement);
            }
            // ── 대출보증 전문 (기존 유지: EmtNetRcvBM)
            else if (isLoanTransaction(transNO)) {
                if (reqCommonElement.getOrderNO() != null) {
                    EmtNetRcvBM rcvBM = new EmtNetRcvBM();
                    ret = rcvBM.receiveBM(inXML);
                }
            }
            // ── 담보보증 전문 (신규: 자체 DB 처리)
            else if (isGuaranteeTransaction(transNO)) {
                // XML → HashMap 변환 (태그명 → 값)
                Map<String, String> ht = parseXmlToMap(doc);
                ret = processGuarantee(transNO, ht, reqCommonElement);
            }
            else {
                logger.warn("[KiboResponseTransaction] 미처리 전문: " + transNO);
                ret = buildA187Response(reqCommonElement); // 기본 응답
            }

            // 응답 저장
            saveXmlLog(ts, ret, transNO, "RESP");
            logger.debug("[KiboResponseTransaction] 응답: " + ret);
            out.print(ret);

        } catch (Exception e) {
            logger.error("[KiboResponseTransaction] Exception: " + e.toString(), e);
            saveXmlLog(ts, e.toString(), "ERR", "ERR");
            out.print("<error>" + e.getMessage() + "</error>");
        }
    }

    /**
     * 담보보증 전문 처리
     * DB 저장 실패해도 응답은 정상 반환 (파일 로그로 복구 가능)
     */
    private String processGuarantee(String transNO, Map<String, String> ht,
            CommonElement commonElement) {
        try {
            switch (transNO) {
                case "C221": case "C223": case "C225": case "C227":
                    guaranteeBean.processC221(transNO, ht);
                    break;
                case "D211": case "D215":
                    guaranteeBean.processD211(transNO, ht);
                    break;
                case "E211":
                    guaranteeBean.processE211(transNO, ht);
                    break;
                case "F211": case "F215":
                    guaranteeBean.processF211(transNO, ht);
                    break;
                case "H211": case "H215":
                    guaranteeBean.processH211(transNO, ht);
                    break;
                default:
                    logger.warn("[KiboResponseTransaction] 알 수 없는 담보전문: " + transNO);
            }
        } catch (Exception e) {
            logger.error("[KiboResponseTransaction] DB저장 실패: " + e.getMessage());
        }

        return buildGuaranteeResponse(transNO, commonElement);
    }

    /**
     * 기보 담보보증 정상 응답 생성
     * C221 → C222, D211 → D212, F211 → F212, H211 → H212
     */
    private String buildGuaranteeResponse(String transNO, CommonElement ce) {
        String resTransNO;
        try {
            int lastNum = Integer.parseInt(transNO.substring(3));
            resTransNO = transNO.substring(0, 3) + (lastNum + 1);
        } catch (Exception e) {
            resTransNO = transNO;
        }

        logger.info("[KiboResponseTransaction] 응답전문: " + transNO + " -> " + resTransNO);

        return "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\n" +
               "<" + resTransNO + ">\n" +
               "  <Header></Header>\n" +
               "  <Body>\n" +
               "    <CommPart>\n" +
               "      <TransactionID></TransactionID>\n" +
               "      <CodeType></CodeType>\n" +
               "      <TransactionLength></TransactionLength>\n" +
               "      <Sender>"           + nvl(ce.getSender())           + "</Sender>\n" +
               "      <TransactionSEQNO>" + nvl(ce.getTransactionSEQNO()) + "</TransactionSEQNO>\n" +
               "      <Receiver>"         + nvl(ce.getReceiver())         + "</Receiver>\n" +
               "      <TransactionNO>"    + resTransNO                    + "</TransactionNO>\n" +
               "      <TransactionDate>"  + nvl(ce.getTransactionDate())  + "</TransactionDate>\n" +
               "      <TransactionTime>"  + nvl(ce.getTransactionTime())  + "</TransactionTime>\n" +
               "      <ResponseCode>0000</ResponseCode>\n" +
               "      <ResponseMessage>정상처리되었습니다.</ResponseMessage>\n" +
               "      <UserField></UserField>\n" +
               "    </CommPart>\n" +
               "  </Body>\n" +
               "</" + resTransNO + ">";
    }

    /**
     * A187 수신확인 응답 (기존과 동일)
     */
    private String buildA187Response(CommonElement ce) {
        String resTransNO = ce.incrementTransactionNO(ce.getTransactionNO());
        return "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\n" +
               "<" + resTransNO + ">\n" +
               "  <Header></Header>\n" +
               "  <Body>\n" +
               "    <CommPart>\n" +
               "      <TransactionID></TransactionID>\n" +
               "      <CodeType></CodeType>\n" +
               "      <TransactionLength></TransactionLength>\n" +
               "      <Sender>"           + nvl(ce.getSender())           + "</Sender>\n" +
               "      <TransactionSEQNO>" + nvl(ce.getTransactionSEQNO()) + "</TransactionSEQNO>\n" +
               "      <Receiver>"         + nvl(ce.getReceiver())         + "</Receiver>\n" +
               "      <TransactionNO>"    + resTransNO                    + "</TransactionNO>\n" +
               "      <TransactionDate>"  + nvl(ce.getTransactionDate())  + "</TransactionDate>\n" +
               "      <TransactionTime>"  + nvl(ce.getTransactionTime())  + "</TransactionTime>\n" +
               "      <ResponseCode>0000</ResponseCode>\n" +
               "      <ResponseMessage></ResponseMessage>\n" +
               "      <UserField></UserField>\n" +
               "    </CommPart>\n" +
               "  </Body>\n" +
               "</" + resTransNO + ">";
    }

    /**
     * 담보보증 전문 여부
     */
    private boolean isGuaranteeTransaction(String transNO) {
        switch (transNO) {
            case "C221": case "C223": case "C225": case "C227":
            case "D211": case "D215":
            case "E211":
            case "F211": case "F215":
            case "H211": case "H215":
                return true;
            default:
                return false;
        }
    }

    /**
     * 대출보증 전문 여부 (기존 EmtNetRcvBM 처리 유지)
     */
    private boolean isLoanTransaction(String transNO) {
        switch (transNO) {
            case "K311": case "K315": case "K325": case "K321":
            case "B331": case "B341": case "B413":
                return true;
            default:
                return false;
        }
    }

    /** 
     * XML Document → HashMap 변환
     * 기보 전문은 신보와 달리 "sb:" prefix 없이 순수 태그명 사용
     * 반복 태그(CArticle, Before, After, ChgYN, Condition)는 "&" 로 연결
     */
    private Map<String, String> parseXmlToMap(Document doc) {
        Map<String, String> map = new HashMap<>();
        if (doc == null) return map;

        // 반복 가능한 태그 (CcountInfo 하위)
        java.util.Set<String> repeatTags = new java.util.HashSet<>(
            java.util.Arrays.asList("CArticle", "Before", "After", "ChgYN", "Condition")
        );

        // 일반 태그 파싱 (텍스트 노드만)
        NodeList allNodes = doc.getElementsByTagName("*");
        for (int i = 0; i < allNodes.getLength(); i++) {
            Node node = allNodes.item(i);
            if (node.getNodeType() != Node.ELEMENT_NODE) continue;

            String tagName = node.getLocalName() != null ?
                             node.getLocalName() : node.getNodeName();

            // CcountInfoList 의 Ccount 속성값 추출
            if ("CcountInfoList".equals(tagName)) {
                org.w3c.dom.NamedNodeMap attrs = node.getAttributes();
                if (attrs != null) {
                    Node ccountAttr = attrs.getNamedItem("Ccount");
                    if (ccountAttr != null) {
                        map.put("Ccount", ccountAttr.getNodeValue().trim());
                    }
                }
                continue;
            }

            // 텍스트 노드가 하나인 요소만 처리
            NodeList children = node.getChildNodes();
            if (children.getLength() == 1 &&
                children.item(0).getNodeType() == Node.TEXT_NODE) {

                String value = node.getTextContent().trim();

                if (repeatTags.contains(tagName)) {
                    // 반복 태그: "&" 로 연결
                    String existing = map.get(tagName);
                    if (existing == null || existing.isEmpty()) {
                        map.put(tagName, value);
                    } else {
                        map.put(tagName, existing + "&" + value);
                    }
                } else {
                    // 일반 태그: 첫 번째 값만
                    if (!map.containsKey(tagName)) {
                        map.put(tagName, value);
                    }
                }
            }
        }

        // Before/After 날짜 정리 (공백 제거, "-" 포함 형식 그대로 전달)
        // KiboGuaranteeBean에서 날짜 변환 처리
        return map;
    }


    /**
     * XML 파일 로그 저장
     * 파일명: {HHmmssSSS}_{전문번호}_{RECV|RESP|ERR}.xml
     */
    private void saveXmlLog(String ts, String content, String transNO, String suffix) {
        try {
            String today   = new SimpleDateFormat("yyyyMMdd").format(new Date());
            String dirPath = GlobalEnv.getWebRootDir()
                           + "logfiles/kibo/guarantee/" + today + "/";
            File dir = new File(dirPath);
            if (!dir.exists()) dir.mkdirs();

            String fileName = ts + "_" + (transNO != null ? transNO : "UNK") +
                              "_" + suffix + ".xml";
            File logFile = new File(dirPath + fileName);

            try (BufferedWriter writer = new BufferedWriter(
                    new OutputStreamWriter(new FileOutputStream(logFile), "EUC-KR"))) {
                writer.write(content != null ? content : "");
            }
            logger.info("[KiboResponseTransaction] 파일저장: " + logFile.getAbsolutePath());
        } catch (Exception e) {
            logger.error("[KiboResponseTransaction] 파일저장 실패: " + e.getMessage());
        }
    }

    private String nvl(String val) {
        return val != null ? val : "";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
