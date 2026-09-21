package kr.co.soap.controll;

/** K232(K231 응답) VO - Common + Response.ClearSEQNO */
public class K232VO {
    private CommonElement commonElement = new CommonElement();
    private String clearSEQNO;   // 상환 처리번호

    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement c) { this.commonElement = c; }
    public String getClearSEQNO() { return clearSEQNO; }
    public void setClearSEQNO(String v) { this.clearSEQNO = v; }
}
