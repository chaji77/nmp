package kr.co.mp.kakaotalk;

import java.util.ArrayList;

import kr.co.funology.fw.util.StrUtil;

public class BlockBean {
  public static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_LIST_PROC(BlockVO pvo) {
    return BlockDAO.COMPANY_SMS_MAIL_BLOCK_LIST_PROC(pvo);
  }
  public static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_ADD_PROC(BlockVO pvo) {
    return BlockDAO.COMPANY_SMS_MAIL_BLOCK_ADD_PROC(pvo);
  }
  public static ArrayList<BlockVO> COMPANY_SMS_MAIL_BLOCK_DROP_PROC(BlockVO pvo) {
    return BlockDAO.COMPANY_SMS_MAIL_BLOCK_DROP_PROC(pvo);
  }
  public static boolean isBlocked(String strPhoneNumber, String strEmailAddr) {
    BlockVO v  = new BlockVO();
    v.PAGE     = 1;
    v.ROW_CNT  = 20;
    v.CPY_ID   = "0";
    v.CPY_NAME = "";
    v.PHONE_NO = StrUtil.nvl(strPhoneNumber);
    v.EMAIL    = StrUtil.nvl(strEmailAddr);
    ArrayList<BlockVO> arr = COMPANY_SMS_MAIL_BLOCK_LIST_PROC(v);
    return (arr.size()>0) ? true : false;
  }
}
