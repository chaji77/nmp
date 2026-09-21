package kr.co.soap.controll;

/** B212(B211 응답) - Common부만 존재 (접수 ack) */
public class B212VO {
    private CommonElement commonElement = new CommonElement();
    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement c) { this.commonElement = c; }
}
