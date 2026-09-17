package kr.co.soap.sender;

import kr.co.soap.controll.C212VO;
import kr.co.soap.controll.CommonElement;

public class EmtNetC211Adapter implements EmtNetSender {

    private final Object sender;

    public EmtNetC211Adapter(Object sender) {
        this.sender = sender;
    }

    @Override
    public Object execute() throws Exception {
        if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetC211) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetC211) sender).executeC211();
        } else {
            return errorMsg();
        }
    }

    private C212VO errorMsg() {
        C212VO vo = new C212VO();
        CommonElement ce = new CommonElement();
        ce.setResponseCode("4444");
        ce.setResponseMessage("지원하지 않는 C211 클래스입니다.");
        vo.setCommonElement(ce);
        return vo;
    }
}
