package kr.co.soap.kodit.loan;

import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.B211ItemVO;
import kr.co.soap.controll.B211VO;
import kr.co.soap.controll.B212VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.CommonElementResInfo;
import kr.co.soap.controll.HttpClientUtil;
import kr.co.soap.controll.XmlEnum;

/**
 * 매매계약서 발송(B211) 송신 공통 베이스. (Kodit_C211 패턴 + 주문상세 반복)
 *   executeB211() : makeB211VO() -> (0000) -> makeB211XML() -> sendB211() -> persistResult()
 * - OrderDetail(N건)은 템플릿의 프로토타입 노드를 cloneNode 복제하여 채운다.
 * - 응답 B212는 Common부만 존재 → 추가 body 파싱 없음.
 */
public abstract class Kodit_B211 {

    private Document doc    = null;
    private Document resDoc = null;

    protected B211VO            b211VO   = new B211VO();
    protected List<B211ItemVO>  itemList = new ArrayList<B211ItemVO>();
    private   B212VO            b212VO   = new B212VO();

    protected Kodit_B211() {}

    public B212VO executeB211() {
        boolean attempted = false;
        try {
            CommonElement ce = this.makeB211VO();
            if (!ce.getResponseCode().equals("0000")) {
                b212VO.getCommonElement().setResponseCode(ce.getResponseCode());
                b212VO.getCommonElement().setResponseMessage(ce.getResponseMessage());
                return b212VO;                       // 전송 전 검증 실패 → 적재 안 함
            }
            this.makeB211XML();
            attempted = true;
            this.b212VO = this.sendB211();
        } catch (Exception ex) {
            executeException(ex);
        } finally {
            if (attempted) {
                try { persistResult(this.b211VO, this.itemList, this.b212VO); }
                catch (Exception pe) { pe.printStackTrace(); }
            }
        }
        return this.b212VO;
    }

    private void executeException(Exception ex) {
        ex.printStackTrace();
        b212VO.getCommonElement().setResponseCode("0099");
        String exMsg = ex.getMessage();
        b212VO.getCommonElement().setResponseMessage(
            (exMsg == null || exMsg.length() < 50) ? exMsg : exMsg.substring(0, 50));
    }

    /** 하위 클래스에서 b211VO + itemList 적재(검증 포함). 정상이면 ResponseCode "0000". */
    protected CommonElement makeB211VO() throws Exception {
        CommonElement ce = new CommonElement();
        ce.setResponseCode("0000");
        return ce;
    }

    /** 송신 시도 후 결과 적재. 하위 클래스(EmtNetB211)에서 구현. */
    protected void persistResult(B211VO header, List<B211ItemVO> items, B212VO res) throws Exception { }

    private void makeB211XML() throws Exception {
        String fileName = XmlEnum.getTemplatePath("B211.xml");
        System.out.println("B211 file_name:::::::::::" + fileName);
        FileReader fr = new FileReader(fileName);
        this.doc = XMLEasyUtil.parseXMLDocument(new InputSource(fr));
        setHeaderXML();
        setItemXML();
    }

    private void setHeaderXML() {
        CommonElement ce = b211VO.getCommonElement();
        // Common
        setNode("sb:Sender",           ce.getSender());
        setNode("sb:TransactionSEQNO", ce.getTransactionSEQNO());
        setNode("sb:Receiver",         ce.getReceiver());
        setNode("sb:TransactionDate",  ce.getTransactionDate());
        setNode("sb:TransactionTime",  ce.getTransactionTime());
        // Transfer 헤더
        setNode("sb:ApplicationNO",          b211VO.getApplicationNO());
        setNode("sb:GuaranteeNO",            b211VO.getGuaranteeNO());
        setNode("sb:TradeDate",              b211VO.getTradeDate());
        setNode("sb:OrderNO",                b211VO.getOrderNO());
        setNode("sb:ContractDate",           b211VO.getContractDate());
        setBuyerSeller("sb:BuyerID",         b211VO.getBuyerID());
        setNode("sb:BuyerBusinessNO",        b211VO.getBuyerBusinessNO());
        setBuyerSeller("sb:SellerID",        b211VO.getSellerID());
        setNode("sb:SellerBusinessNO",       b211VO.getSellerBusinessNO());
        setNode("sb:TotalContractAMT",       b211VO.getTotalContractAMT());
        setNode("sb:SettlementScheduleCount",b211VO.getSettlementScheduleCount());
        // ScheduleDetail (1건)
        setNode("sb:ScheduleSEQNO",          b211VO.getScheduleSEQNO());
        setNode("sb:SettlementType",         b211VO.getSettlementType());
        setNode("sb:SettlementDueAMT",       b211VO.getSettlementDueAMT());
        setNode("sb:DeliveryDueDate",        b211VO.getDeliveryDueDate());
        setNode("sb:PaymentDueDate",         b211VO.getPaymentDueDate());
        setNode("sb:OrderCount",             b211VO.getOrderCount());
    }

    /** 주문상세: 템플릿 프로토타입 OrderDetail 을 아이템 수만큼 복제해 채운다. */
    private void setItemXML() {
        Element transfer = (Element) doc.getElementsByTagName("sb:Transfer").item(0);
        Element proto    = (Element) doc.getElementsByTagName("sb:OrderDetail").item(0);
        if (proto == null) return;

        for (int i = 0; i < itemList.size(); i++) {
            B211ItemVO it = itemList.get(i);
            Element od = (Element) proto.cloneNode(true);
            od.setAttribute("seq", String.valueOf(i + 1));
            setChild(od, "sb:OrderSEQNO",   it.getOrderSEQNO());
            setChild(od, "sb:Item",         it.getItem());
            setChild(od, "sb:Size",         it.getSize());
            setChild(od, "sb:Quantity",     it.getQuantity());
            setChild(od, "sb:QuantityUnit", it.getQuantityUnit());
            setChild(od, "sb:UnitPrice",    it.getUnitPrice());
            setChild(od, "sb:SupplyAMT",    it.getSupplyAMT());
            setChild(od, "sb:TaxAMT",       it.getTaxAMT());
            setChild(od, "sb:TotalAMT",     it.getTotalAMT());
            transfer.appendChild(od);
        }
        transfer.removeChild(proto);   // 빈 프로토타입 제거
    }

    private void setChild(Element parent, String tag, String value) {
        NodeList nl = parent.getElementsByTagName(tag);
        if (nl.getLength() > 0) {
            nl.item(0).setTextContent(value == null ? "" : value);
        }
    }

    private void setBuyerSeller(String node, String id) {
        String v = StrUtil.isEmpty(StrUtil.nvl(id)) ? "0000000000000" : id;
        setNode(node, v);
    }

    private void setNode(String node, String value) {
        if (!StrUtil.isEmpty(value)) {
            XMLUtil.setNodeValue(doc, node, value);
        }
    }

    private B212VO sendB211() throws Exception {
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

        B212VO vo = new B212VO();
        vo.setCommonElement(ce);
        return vo;   // 응답 Common부만 (추가 파싱 없음)
    }
}
