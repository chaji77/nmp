package kr.co.mp.c.notice;

import java.util.ArrayList;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import kr.co.funology.fw.util.IntegerCryptoUtil;

public class NoticeBean {
	private NoticeDAO dao;
	public NoticeBean() {
		this.dao = new NoticeDAO();
	}
	public int C_NOTICE_ADD_PROC(NoticeVO vo) {
		return this.dao.C_NOTICE_ADD_PROC(vo);
	}
	public int C_NOTICE_MOD_PROC(NoticeVO vo) {
		return this.dao.C_NOTICE_MOD_PROC(vo);
	}
	public NoticeVO C_NOTICE_DETAIL_PROC(int intSeq) {
		return this.dao.C_NOTICE_DETAIL_PROC(intSeq);
	}
	public ArrayList<NoticeAttachVO> C_NOTICE_ATTACH_LIST_PROC(int intSeq) {
		return this.dao.C_NOTICE_ATTACH_LIST_PROC(intSeq);
	}
	public ArrayList<NoticeVO> C_NOTICE_LIST_PROC(NoticeVO p, String strIncludeDroppedArticle) {
		return this.dao.C_NOTICE_LIST_PROC(p, strIncludeDroppedArticle);
	}
	public ArrayList<NoticeVO> C_NOTICE_POPUPLIST_PROC() {
		return this.dao.C_NOTICE_POPUPLIST_PROC();
	}
	
	public ArrayList<NoticeVO> removeNoticeExcluded(HttpServletRequest request) {
	    String nid = "";
	    ArrayList<NoticeVO> arr = this.C_NOTICE_POPUPLIST_PROC();
	    if (arr!=null && arr.size()>0) {
	      try {
	        Cookie[] cookies = request.getCookies();
	        for (Cookie cookie : cookies) {
	          if (cookie.getName().contains("exclude_nid")) {
	            nid = cookie.getValue();
	            for (int i=0; i<arr.size();) {
	               NoticeVO v = arr.get(i);
	               String vnid = IntegerCryptoUtil.crypt(v.SEQ);
	               if (vnid.equals(nid)) arr.remove(i);
	               else i++;
	            }
	          }
	        }
	      } catch (Exception e) {
	      }
	    }
	    return arr;
	  }
	
}
