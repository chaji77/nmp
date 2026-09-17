package kr.co.soap.controll;

/**
 * C212(C211 응답) 수신 전문 VO
 * - 신보 응답은 &lt;sb:ResCommon&gt;&lt;sb:Common&gt;...&lt;/sb:Common&gt;&lt;/sb:ResCommon&gt; 형태로
 *   Common 부만 내려오며 Transfer/보증번호는 없음(접수 ack).
 */
public class C212VO {

    private CommonElement commonElement = new CommonElement();

    public CommonElement getCommonElement() { return commonElement; }
    public void setCommonElement(CommonElement commonElement) { this.commonElement = commonElement; }
}
