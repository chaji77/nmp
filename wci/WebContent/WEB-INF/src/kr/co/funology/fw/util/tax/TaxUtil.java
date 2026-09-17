package kr.co.funology.fw.util.tax;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
/**
 * 국세청 세금계산서에서 필요한 정보를 추출하는 클래스
 * 
 */
public class TaxUtil {
    public static TaxInvoiceVO parseTaxInvoice(String xmlData) throws Exception {
        TaxInvoiceVO taxInvoiceVO = new TaxInvoiceVO();
        List<TaxLineItemVO> lineItems = new ArrayList<>();

        // XML Document 파싱
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document document = builder.parse(new java.io.ByteArrayInputStream(xmlData.getBytes()));

        // Root Element 가져오기
        Element root = document.getDocumentElement();

        // ExchangedDocument 데이터 추출
        Element exchangedDocument = (Element) root.getElementsByTagName("ExchangedDocument").item(0);
        taxInvoiceVO.id = getTagValue("ID", exchangedDocument);

        // TaxInvoiceDocument 데이터 추출
        Element taxInvoiceDocument = (Element) root.getElementsByTagName("TaxInvoiceDocument").item(0);
        taxInvoiceVO.issueId = getTagValue("IssueID", taxInvoiceDocument);
        taxInvoiceVO.issueDateTime = getTagValue("IssueDateTime", taxInvoiceDocument);
        taxInvoiceVO.typeCode = getTagValue("TypeCode", taxInvoiceDocument);
        taxInvoiceVO.purposeCode = getTagValue("PurposeCode", taxInvoiceDocument);

        // Invoicer 데이터 추출
        Element invoicer = (Element) root.getElementsByTagName("InvoicerParty").item(0);
        taxInvoiceVO.invoicerName = getTagValue("NameText", invoicer);
        taxInvoiceVO.invoicerRegistrationId = getTagValue("ID", invoicer);
        taxInvoiceVO.invoicerTypeCode = getTagValue("TypeCode", invoicer);
        taxInvoiceVO.invoicerClassificationCode = getTagValue("ClassificationCode", invoicer);

        // Invoicer's CEO
        Element invoicerSpecifiedPerson = (Element) invoicer.getElementsByTagName("SpecifiedPerson").item(0);
        taxInvoiceVO.invoicerSpecifiedPerson = getTagValue("NameText", invoicerSpecifiedPerson);
        
        // INvoicer's Address
        Element invoicerSpecifiedAddress = (Element) invoicer.getElementsByTagName("SpecifiedAddress").item(0);
        taxInvoiceVO.invoicerSpecifiedAddress = getTagValue("LineOneText", invoicerSpecifiedAddress);
        
        // Invoicee 데이터 추출
        Element invoicee = (Element) root.getElementsByTagName("InvoiceeParty").item(0);
        taxInvoiceVO.invoiceeName = getTagValue("NameText", invoicee);
        taxInvoiceVO.invoiceeRegistrationId = getTagValue("ID", invoicee);
        taxInvoiceVO.invoiceeTypeCode = getTagValue("TypeCode", invoicee);
        taxInvoiceVO.invoiceeClassificationCode = getTagValue("ClassificationCode", invoicee);

        // Invoicee's CEO
        Element invoiceeSpecifiedPerson = (Element) invoicee.getElementsByTagName("SpecifiedPerson").item(0);
        taxInvoiceVO.invoiceeSpecifiedPerson = getTagValue("NameText", invoiceeSpecifiedPerson);
        
        // INvoicee's Address
        Element invoiceeSpecifiedAddress = (Element) invoicee.getElementsByTagName("SpecifiedAddress").item(0);
        taxInvoiceVO.invoiceeSpecifiedAddress = getTagValue("LineOneText", invoiceeSpecifiedAddress);


        // SpecifiedMonetarySummation 데이터 추출
        Element monetarySummation = (Element) root.getElementsByTagName("SpecifiedMonetarySummation").item(0);
        taxInvoiceVO.totalAmount = getTagValue("ChargeTotalAmount", monetarySummation);
        taxInvoiceVO.taxAmount = getTagValue("TaxTotalAmount", monetarySummation);
        taxInvoiceVO.grandTotalAmount = getTagValue("GrandTotalAmount", monetarySummation);

        // TaxInvoiceTradeLineItem 데이터 추출
        NodeList lineItemNodes = root.getElementsByTagName("TaxInvoiceTradeLineItem");
        for (int i = 0; i < lineItemNodes.getLength(); i++) {
            Element lineItem = (Element) lineItemNodes.item(i);
            TaxLineItemVO lineItemVO = new TaxLineItemVO();
            lineItemVO.sequenceNumeric = getTagValue("SequenceNumeric", lineItem);
            lineItemVO.informationText = getTagValue("InformationText", lineItem);
            lineItemVO.invoiceAmount = getTagValue("InvoiceAmount", lineItem);
            lineItemVO.chargeableUnitQuantity = getTagValue("ChargeableUnitQuantity", lineItem);
            lineItemVO.nameText = getTagValue("NameText", lineItem);
            lineItemVO.purchaseExpiryDateTime = getTagValue("PurchaseExpiryDateTime", lineItem);
            lineItemVO.totalTax = getTagValue("CalculatedAmount", (Element) lineItem.getElementsByTagName("TotalTax").item(0));
            lineItems.add(lineItemVO);
        }
        taxInvoiceVO.lineItems = lineItems;

        return taxInvoiceVO;
    }

    // Helper method to get tag value
    private static String getTagValue(String tag, Element element) {
        try {
          Node node = element.getElementsByTagName(tag).item(0);
          return node != null ? node.getTextContent() : "";
        } catch (Exception e) {
          e.toString();
        }
        return "";
    }

    public static void main(String[] args) throws Exception {
        String xmlData = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                + "\n"
                + "<TaxInvoice xmlns=\"urn:kr:or:kec:standard:Tax:ReusableAggregateBusinessInformationEntitySchemaModule:1:0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:kr:or:kec:standard:Tax:ReusableAggregateBusinessInformationEntitySchemaModule:1:0 http://www.kec.or.kr/standard/Tax/TaxInvoiceSchemaModule_1.0.xsd\">\n"
                + "  <ExchangedDocument>\n"
                + "    <IssueDateTime>20250410171947</IssueDateTime>\n"
                + "  </ExchangedDocument>\n"
                + "  <TaxInvoiceDocument>\n"
                + "    <IssueID>202503281025041012000458</IssueID>\n"
                + "    <TypeCode>0301</TypeCode>\n"
                + "    <IssueDateTime>20250328</IssueDateTime>\n"
                + "    <PurposeCode>02</PurposeCode>\n"
                + "  </TaxInvoiceDocument>\n"
                + "  <TaxInvoiceTradeSettlement>\n"
                + "    <InvoicerParty>\n"
                + "      <ID>1038702370</ID>\n"
                + "      <TypeCode>도소매업</TypeCode>\n"
                + "      <NameText>효성농산유통 주식회사</NameText>\n"
                + "      <ClassificationCode>농,수,축산물</ClassificationCode>\n"
                + "      <SpecifiedOrganization>\n"
                + "        <TaxRegistrationID>0</TaxRegistrationID>\n"
                + "      </SpecifiedOrganization>\n"
                + "      <SpecifiedPerson>\n"
                + "        <NameText>신호섭</NameText>\n"
                + "      </SpecifiedPerson>\n"
                + "      <DefinedContact>\n"
                + "        <URICommunication>-xxxx@naver.com</URICommunication>\n"
                + "      </DefinedContact>\n"
                + "      <SpecifiedAddress>\n"
                + "        <LineOneText>광주광역시 남구 서문대로 758, 108호(주월동)</LineOneText>\n"
                + "      </SpecifiedAddress>\n"
                + "    </InvoicerParty>\n"
                + "    <InvoiceeParty>\n"
                + "      <ID>2128601756</ID>\n"
                + "      <NameText>유한회사푸른판</NameText>\n"
                + "      <SpecifiedOrganization>\n"
                + "        <TaxRegistrationID>0</TaxRegistrationID>\n"
                + "        <BusinessTypeCode>01</BusinessTypeCode>\n"
                + "      </SpecifiedOrganization>\n"
                + "      <SpecifiedPerson>\n"
                + "        <NameText>허광무</NameText>\n"
                + "      </SpecifiedPerson>\n"
                + "      <PrimaryDefinedContact/>\n"
                + "      <SecondaryDefinedContact/>\n"
                + "    </InvoiceeParty>\n"
                + "    <SpecifiedMonetarySummation>\n"
                + "      <ChargeTotalAmount>43238450</ChargeTotalAmount>\n"
                + "      <TaxTotalAmount>0</TaxTotalAmount>\n"
                + "      <GrandTotalAmount>43238450</GrandTotalAmount>\n"
                + "    </SpecifiedMonetarySummation>\n"
                + "  </TaxInvoiceTradeSettlement>\n"
                + "  <TaxInvoiceTradeLineItem>\n"
                + "    <SequenceNumeric>1</SequenceNumeric>\n"
                + "    <InvoiceAmount>43238450</InvoiceAmount>\n"
                + "    <NameText>농산물 양곡</NameText>\n"
                + "    <PurchaseExpiryDateTime>20250328</PurchaseExpiryDateTime>\n"
                + "    <TotalTax>\n"
                + "      <CalculatedAmount>0</CalculatedAmount>\n"
                + "    </TotalTax>\n"
                + "  </TaxInvoiceTradeLineItem>\n"
                + "</TaxInvoice>\n"
                + "";
        TaxInvoiceVO taxInvoice = parseTaxInvoice(xmlData);
        System.out.println(taxInvoice.toString());
    }
}
