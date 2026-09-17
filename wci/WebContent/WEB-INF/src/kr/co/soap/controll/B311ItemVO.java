package kr.co.soap.controll;

public class B311ItemVO {
	private String orderno;
    private String seqno;
    private int orderseqno;
    private String item;
    private String size;
    private double quantity;
    private String quantityunit;
    private double unitprice;
    private double supplyamt;
    private double taxamt;
    private double totalamt;

    // 기본 생성자
    public B311ItemVO() {}

    // Getter와 Setter 메서드들
    public String getOrderno() {
        return orderno;
    }

    public void setOrderno(String orderno) {
        this.orderno = orderno;
    }

    public String getSeqno() {
        return seqno;
    }

    public void setSeqno(String seqno) {
        this.seqno = seqno;
    }

    public int getOrderseqno() {
        return orderseqno;
    }

    public void setOrderseqno(int orderseqno) {
        this.orderseqno = orderseqno;
    }

    public String getItem() {
        return item;
    }

    public void setItem(String item) {
        this.item = item;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public double getQuantity() {
        return quantity;
    }

    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    public String getQuantityunit() {
        return quantityunit;
    }

    public void setQuantityunit(String quantityunit) {
        this.quantityunit = quantityunit;
    }

    public double getUnitprice() {
        return unitprice;
    }

    public void setUnitprice(double unitprice) {
        this.unitprice = unitprice;
    }

    public double getSupplyamt() {
        return supplyamt;
    }

    public void setSupplyamt(double supplyamt) {
        this.supplyamt = supplyamt;
    }

    public double getTaxamt() {
        return taxamt;
    }

    public void setTaxamt(double taxamt) {
        this.taxamt = taxamt;
    }

    public double getTotalamt() {
        return totalamt;
    }

    public void setTotalamt(double totalamt) {
        this.totalamt = totalamt;
    }

    // 출력 메서드
    public void print() {
        System.out.println("Orderno: " + orderno);
        System.out.println("SeqNO: " + seqno);
        System.out.println("OrderSEQNO: " + orderseqno);
        System.out.println("Item: " + item);
        System.out.println("Size: " + size);
        System.out.println("Quantity: " + quantity);
        System.out.println("QuantityUnit: " + quantityunit);
        System.out.println("UnitPrice: " + unitprice);
        System.out.println("SupplyAMT: " + supplyamt);
        System.out.println("TaxAMT: " + taxamt);
        System.out.println("TotalAMT: " + totalamt);
    }
}
