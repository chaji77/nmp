package kr.co.soap.controll;

/** B211 주문상세(OrderDetail) 1건 */
public class B211ItemVO {
    private String orderSEQNO;
    private String item;
    private String size;
    private String quantity;
    private String quantityUnit;
    private String unitPrice;
    private String supplyAMT;
    private String taxAMT;
    private String totalAMT;

    public String getOrderSEQNO() { return orderSEQNO; }
    public void setOrderSEQNO(String v) { this.orderSEQNO = v; }
    public String getItem() { return item; }
    public void setItem(String v) { this.item = v; }
    public String getSize() { return size; }
    public void setSize(String v) { this.size = v; }
    public String getQuantity() { return quantity; }
    public void setQuantity(String v) { this.quantity = v; }
    public String getQuantityUnit() { return quantityUnit; }
    public void setQuantityUnit(String v) { this.quantityUnit = v; }
    public String getUnitPrice() { return unitPrice; }
    public void setUnitPrice(String v) { this.unitPrice = v; }
    public String getSupplyAMT() { return supplyAMT; }
    public void setSupplyAMT(String v) { this.supplyAMT = v; }
    public String getTaxAMT() { return taxAMT; }
    public void setTaxAMT(String v) { this.taxAMT = v; }
    public String getTotalAMT() { return totalAMT; }
    public void setTotalAMT(String v) { this.totalAMT = v; }
}
