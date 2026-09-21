package kr.co.mp.mgr.memo;

import java.util.ArrayList;

public class CommentBean {
  CommentDAO dao;
  public CommentBean() {
    this.dao = new CommentDAO();
  }
  public ArrayList<CommentVO> ACTIVE_COMMENT_LIST_PROC(int intActiveId) {
    return this.dao.ACTIVE_COMMENT_LIST_PROC(intActiveId);
  }
  public int ACTIVE_COMMENT_ADD_PROC(CommentVO pvo) {
    return this.dao.ACTIVE_COMMENT_ADD_PROC(pvo);
  }
  public int ACTIVE_COMMENT_MOD_PROC(CommentVO pvo) {
    return this.dao.ACTIVE_COMMENT_MOD_PROC(pvo);
  }
  public int ACTIVE_COMMENT_DROP_PROC(int intCommentId, String strWriteId) {
    return this.dao.ACTIVE_COMMENT_DROP_PROC(intCommentId, strWriteId);
  }
}
