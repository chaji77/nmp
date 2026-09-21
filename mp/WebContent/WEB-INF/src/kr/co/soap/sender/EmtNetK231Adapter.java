package kr.co.soap.sender;

import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.K232VO;

public class EmtNetK231Adapter implements EmtNetSender {
    private final Object sender;
    public EmtNetK231Adapter(Object sender) { this.sender = sender; }

    @Override
    public Object execute() throws Exception {
        if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetK231) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetK231) sender).executeK231();
        } else {
            K232VO vo = new K232VO();
            CommonElement ce = new CommonElement();
            ce.setResponseCode("4444");
            ce.setResponseMessage("지원하지 않는 K231 클래스입니다.");
            vo.setCommonElement(ce);
            return vo;
        }
    }
}
