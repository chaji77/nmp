package kr.co.soap.sender;

import kr.co.soap.controll.B212VO;
import kr.co.soap.controll.CommonElement;

public class EmtNetB211Adapter implements EmtNetSender {

    private final Object sender;

    public EmtNetB211Adapter(Object sender) {
        this.sender = sender;
    }

    @Override
    public Object execute() throws Exception {
        if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetB211) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetB211) sender).executeB211();
        } else {
            return errorMsg();
        }
    }

    private B212VO errorMsg() {
        B212VO vo = new B212VO();
        CommonElement ce = new CommonElement();
        ce.setResponseCode("4444");
        ce.setResponseMessage("지원하지 않는 B211 클래스입니다.");
        vo.setCommonElement(ce);
        return vo;
    }
}
