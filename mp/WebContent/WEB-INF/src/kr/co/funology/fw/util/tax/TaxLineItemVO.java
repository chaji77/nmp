package kr.co.funology.fw.util.tax;

public class TaxLineItemVO {
	public String sequenceNumeric;
    public String informationText;
    public String invoiceAmount;
    public String chargeableUnitQuantity;
    public String nameText;
    public String purchaseExpiryDateTime;
    public String totalTax;

    @Override
    public String toString() {
        return "TaxLineItemVO [sequenceNumeric="+sequenceNumeric+", informationText=" + informationText + ", invoiceAmount=" + invoiceAmount
               + ", chargeableUnitQuantity=" + chargeableUnitQuantity + ", nameText=" + nameText
               + ", purchaseExpiryDateTime=" + purchaseExpiryDateTime + ", totalTax=" + totalTax + "]";
    }

}
