package kr.co.soap.kodit.loan;

import java.io.FileReader;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.C211VO;
import kr.co.soap.controll.C212VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.XmlEnum;

/**
 * 담보보증 신청(C211) 송신 공통 베이스. (Kodit_A311S 패턴)
 *   executeC211() : makeC211VO() -> (0000) -> makeC211XML() -> sendC211() -> persistResult()
 * - C212 응답은 Common 부만 존재하므로 body 추가 파싱 없음.
 * - 송신을 실제 시도(makeC211XML 통과)한 경우, 성공/실패 무관하게 persistResult() 호출.
 *   (전송 전 검증 실패는 적재하지 않음)
 */
public abstract class Kodit_C211 {

    protected String MPCode = null;
    private Document doc    = null;
    private Document resDoc = null;
    protected C211VO kodit_C211VO = new C211VO();
    private C212VO   kodit_C212VO = new C212VO();

    protected Kodit_C211() {}
    protected Kodit_C211(String p_MPCode) {
        this.MPCode = p_MPCode;
    }

    public C212VO executeC211() {
        boolean attempted = false;
        try {
            CommonElement commonElement = this.makeC211VO();
            if (!commonElement.getResponseCode().equals("0000")) {
                kodit_C212VO.getCommonElement().setResponseCode(commonElement.getResponseCode());
                kodit_C212VO.getCommonElement().setResponseMessage(commonElement.getResponseMessage());
                return kodit_C212VO;                 // 전송 전 검증 실패 → 적재 안 함
            }
            this.makeC211XML();
            attempted = true;                        // 이 시점부터는 전송 시도로 간주
            this.kodit_C212VO = this.sendC211();
        } catch (Exception ex) {
            executeException(ex);
        } finally {
            if (attempted) {
                try {
                    persistResult(this.kodit_C211VO, this.kodit_C212VO);
                } catch (Exception pe) {
                    pe.printStackTrace();            // 적재 실패는 응답에 영향 주지 않음(로깅)
                }
            }
        }
        return this.kodit_C212VO;
    }

    private void executeException(Exception ex) {
        ex.printStackTrace();
        kodit_C212VO.getCommonElement().setResponseCode("0099");
        String exMsg = ex.getMessage();
        kodit_C212VO.getCommonElement().setResponseMessage(
            (exMsg == null || exMsg.length() < 50) ? exMsg : exMsg.substring(0, 50));
    }

    /** 하위 클래스에서 VO 적재(검증 포함). 정상이면 ResponseCode "0000". */
    protected CommonElement makeC211VO() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        return commonElement;
    }

    /** 송신 시도 후 결과 적재. 하위 클래스(EmtNetC211)에서 구현. */
    protected void persistResult(C211VO req, C212VO res) throws Exception { }

    private void makeC211XML() throws Exception {
        String file_name = XmlEnum.getTemplatePath("C211.xml");
        System.out.println("C211 file_name:::::::::::" + file_name);
        FileReader fileReader = new FileReader(file_name);
        this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fileReader));
        setXML();
    }

    private void setXML() {
        // Common
        setXMLNodeValue("sb:Sender",           kodit_C211VO.getCommonElement().getSender());
        setXMLNodeValue("sb:TransactionSEQNO", kodit_C211VO.getCommonElement().getTransactionSEQNO());
        setXMLNodeValue("sb:Receiver",         kodit_C211VO.getCommonElement().getReceiver());
        setXMLNodeValue("sb:TransactionDate",  kodit_C211VO.getCommonElement().getTransactionDate());
        setXMLNodeValue("sb:TransactionTime",  kodit_C211VO.getCommonElement().getTransactionTime());

        // Transfer
        setBuyerSellerDetails("sb:BuyerID",    kodit_C211VO.getBuyerID());
        setXMLNodeValue("sb:BuyerBusinessNO",  kodit_C211VO.getBuyerBusinessNO());
        setBuyerSellerDetails("sb:SellerID",   kodit_C211VO.getSellerID());
        setXMLNodeValue("sb:SellerBusinessNO", kodit_C211VO.getSellerBusinessNO());
        setXMLNodeValue("sb:ApplicationNO",    kodit_C211VO.getApplicationNO());
        setXMLNodeValue("sb:ApplicationAMT",   kodit_C211VO.getApplicationAMT());
        setXMLNodeValue("sb:GuaranteeExpirationText", kodit_C211VO.getGuaranteeExpirationText());
        setXMLNodeValue("sb:GuaranteeType",    kodit_C211VO.getGuaranteeType());
        setXMLNodeValue("sb:Information",      kodit_C211VO.getInformation());
    }

    private void setBuyerSellerDetails(String node, String id) {
        String value = StrUtil.isEmpty(StrUtil.nvl(id)) ? "0000000000000" : id;
        setXMLNodeValue(node, value);
    }

    private void setXMLNodeValue(String node, String value) {
        if (!StrUtil.isEmpty(value)) {
            XMLUtil.setNodeValue(doc, node, value);
        }
    }

    private C212VO sendC211() throws Exception {
        this.resDoc = HttpClientUtil.shinboCall(this.doc);
        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();

        CommonElement commonElement = new CommonElement();
        commonElement.setSender(resinfo.getSender());
        commonElement.setTransactionSEQNO(resinfo.getTransactionSEQNO());
        commonElement.setReceiver(resinfo.getReceiver());
        commonElement.setTransactionNO(resinfo.getTransactionNO());
        commonElement.setTransactionDate(resinfo.getTransactionDate());
        commonElement.setTransactionTime(resinfo.getTransactionTime());
        commonElement.setResponseCode(resinfo.getResponseCode());
        commonElement.setResponseMessage(resinfo.getResponseMessage());

        C212VO kodit_C212 = new C212VO();
        kodit_C212.setCommonElement(commonElement);
        // C212 응답은 Common 부만 존재 → 추가 body 파싱 없음
        return kodit_C212;
    }
}
