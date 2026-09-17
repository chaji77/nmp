package kr.co.soap.sender;

import kr.co.soap.controll.CommonElement;

public class EmtNetA311SAdapter implements EmtNetSender {

    private final Object sender;

    public EmtNetA311SAdapter(Object sender) {
        this.sender = sender;
    }

    @Override
    public Object execute() throws Exception {
        if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetA311S) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetA311S) sender).executeA311S();
        } else {
            return errorMsg();
        }
    }

    private CommonElement errorMsg() {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("4444");
        commonElement.setResponseMessage("지원하지 않는 A311S 클래스입니다.");
        return commonElement;
    }
}