package kr.co.soap.kodit;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.kodit.guarantee.GuaranteeBean;
import kr.co.soap.kodit.loan.emtnet.EmtNetRcvBM;

/**
 * 신보 전문 수신 서블릿
 * - 담보보증: 직접 처리 (3번 서버 제거)
 * - 대출보증: 기존 EmtNetRcvBM 유지
 * - RECV 파일명에 전문번호 포함
 */
@WebServlet(name="ResponseTransaction", urlPatterns="/ResponseTransaction")
public class ResponseTransaction extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private LoanUtil loanUtil = new LoanUtil();
    private GuaranteeBean guaranteeBean = new GuaranteeBean();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("EUC-KR");
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("EUC-KR");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/xml; charset=EUC-KR");
        response.setCharacterEncoding("EUC-KR");
        OutputStream os = response.getOutputStream();

        String sendDoc = StrUtil.nvl(request.getParameter("xmldoc"));

        if (sendDoc == null || sendDoc.trim().isEmpty()) {
            os.write("<error>sendDoc is null or empty</error>".getBytes("EUC-KR"));
            os.flush(); os.close();
            return;
        }

        String responseXml = "";
        String transactionNO = "";
        String ts = new SimpleDateFormat("HHmmssSSS").format(new Date());

        try {
            Document resultXML = XMLEasyUtil.parseXMLDocument(
                    new InputSource(new StringReader(sendDoc)));
            HashMap<String, String> ht = loanUtil.getXmlData(resultXML);

            transactionNO = ht.get("sb:TransactionNO").substring(0, 4);
            System.out.println("[ResponseTransaction] 수신전문: " + transactionNO);

            // ① XML 파싱 후 전문번호 포함하여 RECV 저장
            saveXmlLog(ts, sendDoc, transactionNO, "RECV");

            // ② 전문번호별 처리
            responseXml = processTransaction(transactionNO, ht, sendDoc, resultXML);

            // ③ 응답전문 저장
            saveXmlLog(ts, responseXml, transactionNO, "RESP");

        } catch (Exception e) {
            System.err.println("[ResponseTransaction] 오류: " + e.getMessage());

            // 파싱 실패시 전문번호 없이 ERR 저장
            saveXmlLog(ts, sendDoc, "ERR", "RECV");
            responseXml = "<error>" + e.getMessage() + "</error>";
            saveXmlLog(ts, responseXml, "ERR", "ERR");
        } finally {
            os.write(responseXml.getBytes("EUC-KR"));
            os.flush();
            os.close();
        }
    }

    private String processTransaction(String transactionNO,
            HashMap<String, String> ht, String strXML, Document resultXML) {

        // A185: 수신확인
        if ("A185".equals(transactionNO)) {
            return createA185Response(ht);
        }

        // A181: 트랜잭션 조회
        if ("A181".equals(transactionNO)) {
            return createA181Response(ht);
        }

        // 담보보증 전문
        if (isGuaranteeTransaction(transactionNO)) {
            return processGuarantee(transactionNO, ht);
        }

        // 대출보증 기타 (기존 유지)
        return createOtherResponse(resultXML, ht);
    }

    /**
     * 담보보증 전문 처리
     * DB 저장 + 정상 응답 반환
     */
    private String processGuarantee(String transactionNO, HashMap<String, String> ht) {
        try {
            switch (transactionNO) {
                case "C221": case "C223": case "C225": case "C227":
                    guaranteeBean.processC221(transactionNO, ht);
                    break;
                case "D211": case "D215":
                    guaranteeBean.processD211(transactionNO, ht);
                    break;
                case "E211": case "E221": case "E225":
                    guaranteeBean.processE211(transactionNO, ht);
                    break;
                case "F221": case "F225":
                    guaranteeBean.processF221(transactionNO, ht);
                    break;
                case "H211": case "H215":
                    guaranteeBean.processH211(transactionNO, ht);
                    break;
            }
        } catch (Exception e) {
            // DB 저장 실패해도 응답은 정상 반환
            // 파일 로그로 나중에 수동 처리 가능
            System.err.println("[ResponseTransaction] DB저장 실패: " + e.getMessage());
        }

        // 정상 응답 반환 (DB 성공/실패 무관)
        return createGuaranteeResponse(transactionNO, ht);
    }

    /**
     * 담보보증 정상응답
     * C221->C222, D211->D212, F221->F222, H211->H212
     */
    private String createGuaranteeResponse(String transactionNO,
            HashMap<String, String> ht) {
        String resTransNO;
        try {
            int lastNum = Integer.parseInt(transactionNO.substring(3));
            resTransNO = transactionNO.substring(0, 3) + (lastNum + 1);
        } catch (Exception e) {
            resTransNO = transactionNO;
        }

        System.out.println("[ResponseTransaction] 응답: "
                + transactionNO + " -> " + resTransNO);

        return "<?xml version='1.0' encoding='EUC-KR'?>"
             + "<sb:ResCommon xmlns:sb='http://www.shinbo.co.kr'"
             + " xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>"
             + "<sb:Common>"
             + "<sb:Sender>"           + nvl(ht.get("sb:Sender"))           + "</sb:Sender>"
             + "<sb:TransactionSEQNO>" + nvl(ht.get("sb:TransactionSEQNO"))+ "</sb:TransactionSEQNO>"
             + "<sb:Receiver>"         + nvl(ht.get("sb:Receiver"))         + "</sb:Receiver>"
             + "<sb:TransactionNO>"    + resTransNO                         + "</sb:TransactionNO>"
             + "<sb:TransactionDate>"  + nvl(ht.get("sb:TransactionDate"))  + "</sb:TransactionDate>"
             + "<sb:TransactionTime>"  + nvl(ht.get("sb:TransactionTime"))  + "</sb:TransactionTime>"
             + "<sb:ResponseCode>0000</sb:ResponseCode>"
             + "<sb:ResponseMessage>정상처리되었습니다.</sb:ResponseMessage>"
             + "<sb:UserField />"
             + "</sb:Common>"
             + "</sb:ResCommon>";
    }

    /**
     * 담보보증 전문번호 여부 확인
     */
    private boolean isGuaranteeTransaction(String transactionNO) {
        switch (transactionNO) {
            case "C221": case "C223": case "C225": case "C227":
            case "D211": case "D215":
            case "E211": case "E221": case "E225":
            case "F221": case "F225":
            case "H211": case "H215":
                return true;
            default:
                return false;
        }
    }

    /**
     * XML 파일 저장
     * 파일명: {HHmmssSSS}_{전문번호}_{RECV|RESP|ERR}.xml
     * 예시:  144438123_F221_RECV.xml
     *        144438456_F222_RESP.xml
     *
     * @param ts        타임스탬프 (HHmmssSSS) - RECV/RESP 동일한 ts 사용
     * @param content   저장할 XML 내용
     * @param transNO   전문번호 (C221, F221 등)
     * @param suffix    파일 구분 (RECV, RESP, ERR)
     */
    private void saveXmlLog(String ts, String content, String transNO, String suffix) {
        try {
            String today   = new SimpleDateFormat("yyyyMMdd").format(new Date());
            String dirPath = GlobalEnv.getWebRootDir()
                           + "logfiles/kodit/guarantee/" + today + "/";
            File dir = new File(dirPath);
            if (!dir.exists()) dir.mkdirs();

            // 전문번호 없으면 파일명에서 생략
            String fileName;
            if (transNO != null && !transNO.isEmpty()) {
                fileName = ts + "_" + transNO + "_" + suffix + ".xml";
            } else {
                fileName = ts + "_" + suffix + ".xml";
            }

            File logFile = new File(dirPath + fileName);

            try (BufferedWriter writer = new BufferedWriter(
                    new OutputStreamWriter(new FileOutputStream(logFile), "EUC-KR"))) {
                writer.write(content);
            }
            System.out.println("[ResponseTransaction] 파일저장: "
                    + logFile.getAbsolutePath());
        } catch (Exception e) {
            System.err.println("[ResponseTransaction] 파일저장 실패: " + e.getMessage());
        }
    }

    private String createA185Response(HashMap<String, String> ht) {
        return "<?xml version='1.0' encoding='EUC-KR'?>"
             + "<sb:ResCommon xmlns:sb='http://www.shinbo.co.kr'"
             + " xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>"
             + "<sb:Common>"
             + "<sb:Sender>"           + nvl(ht.get("sb:Sender"))           + "</sb:Sender>"
             + "<sb:TransactionSEQNO>" + nvl(ht.get("sb:TransactionSEQNO"))+ "</sb:TransactionSEQNO>"
             + "<sb:Receiver>"         + nvl(ht.get("sb:Receiver"))         + "</sb:Receiver>"
             + "<sb:TransactionNO>A186</sb:TransactionNO>"
             + "<sb:TransactionDate>"  + nvl(ht.get("sb:TransactionDate"))  + "</sb:TransactionDate>"
             + "<sb:TransactionTime>"  + nvl(ht.get("sb:TransactionTime"))  + "</sb:TransactionTime>"
             + "<sb:ResponseCode>0000</sb:ResponseCode>"
             + "<sb:ResponseMessage>정상</sb:ResponseMessage>"
             + "</sb:Common></sb:ResCommon>";
    }

    private String createA181Response(HashMap<String, String> ht) {
        return "<?xml version='1.0' encoding='EUC-KR' ?>\n"
             + "<sb:ResTransactionInquiry xmlns:sb='http://www.shinbo.co.kr'>\n"
             + "<sb:Common xmlns:sb='http://www.shinbo.co.kr'>\n"
             + "<sb:Sender>"           + nvl(ht.get("sb:resSender"))            + "</sb:Sender>\n"
             + "<sb:TransactionSEQNO>" + nvl(ht.get("sb:resTransactionSEQNO")) + "</sb:TransactionSEQNO>\n"
             + "<sb:Receiver>"         + nvl(ht.get("sb:Receiver"))             + "</sb:Receiver>\n"
             + "<sb:TransactionNO>A182</sb:TransactionNO>\n"
             + "<sb:TransactionDate>"  + nvl(ht.get("sb:resTransactionDate"))   + "</sb:TransactionDate>\n"
             + "<sb:TransactionTime>"  + nvl(ht.get("sb:resTransactionTime"))   + "</sb:TransactionTime>\n"
             + "<sb:ResponseCode>0000</sb:ResponseCode>\n"
             + "<sb:ResponseMessage>트랜잭션조회 처리되었습니다.</sb:ResponseMessage>\n"
             + "<sb:UserField />\n"
             + "</sb:Common>\n"
             + "<sb:Response>\n"
             + "<sb:TransactionResultCode>"    + nvl(ht.get("sb:resCode")) + "</sb:TransactionResultCode>\n"
             + "<sb:TransactionResultMessage>" + nvl(ht.get("sb:resMsg"))  + "</sb:TransactionResultMessage>\n"
             + "</sb:Response>\n"
             + "</sb:ResTransactionInquiry>";
    }

    private String createOtherResponse(Document resultXML, HashMap<String, String> ht) {
        EmtNetRcvBM rcvBM = new EmtNetRcvBM();
        return rcvBM.receiveBM(resultXML, ht);
    }

    private String nvl(String val) {
        return val != null ? val : "";
    }
}
