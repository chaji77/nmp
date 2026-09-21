package kr.co.soap.kodit.loan;

import java.io.FileReader;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.K231VO;
import kr.co.soap.controll.K232VO;
import kr.co.soap.controll.XmlEnum;

/**
 * 결제전문(K231) 송신 공통 베이스. (Kodit_B211 패턴)
 *   executeK231() : makeK231VO() -> (0000) -> makeK231XML() -> sendK231() -> persistResult()
 * - K232 응답은 Common + Response(ClearSEQNO) 로 내려오므로 ClearSEQNO 를 파싱한다.
 */
public abstract class Kodit_K231 {

    private Document doc    = null;
    private Document resDoc = null;
    protected K231VO k231VO = new K231VO();
    private   K232VO k232VO = new K232VO();

    protected Kodit_K231() {}

    public K232VO executeK231() {
        boolean attempted = false;
        try {
            CommonElement ce = this.makeK231VO();
            if (!ce.getResponseCode().equals("0000")) {
                k232VO.getCommonElement().setResponseCode(ce.getResponseCode());
                k232VO.getCommonElement().setResponseMessage(ce.getResponseMessage());
                return k232VO;
            }
            this.makeK231XML();
            attempted = true;
            this.k232VO = this.sendK231();
        } catch (Exception ex) {
            executeException(ex);
        } finally {
            if (attempted) {
                try { persistResult(this.k231VO, this.k232VO); }
                catch (Exception pe) { pe.printStackTrace(); }
            }
        }
        return this.k232VO;
    }

    private void executeException(Exception ex) {
        ex.printStackTrace();
        k232VO.getCommonElement().setResponseCode("0099");
        String exMsg = ex.getMessage();
        k232VO.getCommonElement().setResponseMessage(
            (exMsg == null || exMsg.length() < 50) ? exMsg : exMsg.substring(0, 50));
    }

    protected CommonElement makeK231VO() throws Exception {
        CommonElement ce = new CommonElement();
        ce.setResponseCode("0000");
        return ce;
    }

    protected void persistResult(K231VO req, K232VO res) throws Exception { }

    private void makeK231XML() throws Exception {
        String fileName = XmlEnum.getTemplatePath("K231.xml");
        System.out.println("K231 file_name:::::::::::" + fileName);
        FileReader fr = new FileReader(fileName);
        this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fr));
        setXML();
    }

    private void setXML() {
        CommonElement ce = k231VO.getCommonElement();
        setNode("sb:Sender",           ce.getSender());
        setNode("sb:TransactionSEQNO", ce.getTransactionSEQNO());
        setNode("sb:Receiver",         ce.getReceiver());
        setNode("sb:TransactionDate",  ce.getTransactionDate());
        setNode("sb:TransactionTime",  ce.getTransactionTime());

        setBuyerSeller("sb:BuyerID",   k231VO.getBuyerID());
        setNode("sb:BuyerBusinessNO",  k231VO.getBuyerBusinessNO());
        setBuyerSeller("sb:SellerID",  k231VO.getSellerID());
        setNode("sb:SellerBusinessNO", k231VO.getSellerBusinessNO());
        setNode("sb:OrderNO",          k231VO.getOrderNO());
        setNode("sb:ScheduleSEQNO",    k231VO.getScheduleSEQNO());
        setNode("sb:PaymentDueAMT",    k231VO.getPaymentDueAMT());
        setNode("sb:PaymentAMT",       k231VO.getPaymentAMT());
        setNode("sb:UnclearAMT",       k231VO.getUnclearAMT());
        setNode("sb:PaymentDueDate",   k231VO.getPaymentDueDate());
        setNode("sb:PaymentDate",      k231VO.getPaymentDate());
    }

    private void setBuyerSeller(String node, String id) {
        String v = StrUtil.isEmpty(StrUtil.nvl(id)) ? "0000000000000" : id;
        setNode(node, v);
    }
    private void setNode(String node, String value) {
        if (!StrUtil.isEmpty(value)) XMLUtil.setNodeValue(doc, node, value);
    }

    private K232VO sendK231() throws Exception {
        this.resDoc = HttpClientUtil.shinboCall(this.doc);
        CommonElementResInfo resinfo = HttpClientUtil.getCommonElementResInfo();

        CommonElement ce = new CommonElement();
        ce.setSender(resinfo.getSender());
        ce.setTransactionSEQNO(resinfo.getTransactionSEQNO());
        ce.setReceiver(resinfo.getReceiver());
        ce.setTransactionNO(resinfo.getTransactionNO());
        ce.setTransactionDate(resinfo.getTransactionDate());
        ce.setTransactionTime(resinfo.getTransactionTime());
        ce.setResponseCode(resinfo.getResponseCode());
        ce.setResponseMessage(resinfo.getResponseMessage());

        K232VO vo = new K232VO();
        vo.setCommonElement(ce);
        // K232 Response 바디: 성공 시 ClearSEQNO 파싱
        if ("0000".equals(StrUtil.nvl(resinfo.getResponseCode()))) {
            String clr = null;
            try { clr = XMLUtil.getNodeValue(this.resDoc, "sb:ClearSEQNO"); } catch (Exception e) {}
            vo.setClearSEQNO(StrUtil.nvl(clr));
        }
        return vo;
    }
}
