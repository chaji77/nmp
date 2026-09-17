package kr.co.funology.fw.util.tax;

import java.util.List;

public class TaxInvoiceVO {
    public String id;
    public String issueDateTime;
    public String issueId;
    public String typeCode;
    public String purposeCode;
    public String invoicerName;
    public String invoicerRegistrationId;
    public String invoicerSpecifiedPerson;
    public String invoicerTypeCode;
    public String invoicerClassificationCode;
    public String invoicerSpecifiedAddress;
    public String invoiceeName;
    public String invoiceeRegistrationId;
    public String invoiceeSpecifiedPerson;
    public String invoiceeTypeCode;
    public String invoiceeClassificationCode;
    public String invoiceeSpecifiedAddress;
    public String totalAmount;
    public String taxAmount;
    public String grandTotalAmount;
    public List<TaxLineItemVO> lineItems;
    

    
    @Override
	public String toString() {
		String str = "TaxInvoiceVO [id=" + id + ", issueDateTime=" + issueDateTime + ", issueId=" + issueId + ", typeCode="
				+ typeCode + ", purposeCode=" + purposeCode + ", invoicerName=" + invoicerName
				+ ", invoicerRegistrationId=" + invoicerRegistrationId + ", invoicerSpecifiedPerson="
				+ invoicerSpecifiedPerson + ", invoicerTypeCode=" + invoicerTypeCode + ", invoicerClassificationCode="
				+ invoicerClassificationCode + ", invoicerSpecifiedAddress=" + invoicerSpecifiedAddress
				+ ", invoiceeName=" + invoiceeName + ", invoiceeRegistrationId=" + invoiceeRegistrationId
				+ ", invoiceeSpecifiedPerson=" + invoiceeSpecifiedPerson + ", invoiceeTypeCode=" + invoiceeTypeCode
				+ ", invoiceeClassificationCode=" + invoiceeClassificationCode + ", invoiceeSpecifiedAddress="
				+ invoiceeSpecifiedAddress + ", totalAmount=" + totalAmount + ", taxAmount=" + taxAmount
				+ ", grandTotalAmount=" + grandTotalAmount + "]";
        if (lineItems!=null && lineItems.size()>0) {
            for (TaxLineItemVO lineItem : lineItems) {
              str += "\nItem : " + lineItem.toString();
            }
          }
        return str;
	}
    
    
}
