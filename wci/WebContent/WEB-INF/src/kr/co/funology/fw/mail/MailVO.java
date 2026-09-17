package kr.co.funology.fw.mail;

import java.util.ArrayList;

public class MailVO {
    public int    intNumber     = 0;
    public String strSender     = "";
    public String strSubject    = "";
    public String strReceives   = "";
    public String strCarbonCopy = "";
    public String strHiddenCopy = "";
    public String strDate       = "";
    public String strSize       = "";
    public String content       = "";
    public boolean isSeenOrNot  = false;
    public boolean isAnswered   = false;
    public boolean isFlaged     = false;
    public boolean hasFile      = false;
    public ArrayList<String[]> files = new ArrayList<>();
    public String messageid     = ""; // Message-ID in Header
    public String messageuid    = "";
    public String strReceiverEmail = "";
}
