package kr.co.mp.c;

import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.CryptoDESUtil;
import kr.co.funology.fw.util.StrUtil;

public class LoginBean {
  private static final String strCookieKey = "usertoken";
  
  public String setToken(LoginVO p, HttpServletRequest request, HttpServletResponse response) {
    String ip = LoginUtil.getClientIpAddr(request);
    String strToken = "{";
    strToken += "\"CPY_GUBUN\":\""  + StrUtil.nvl(p.CPY_GUBUN) + "\",";
    strToken += "\"CPY_ID\":\"" + StrUtil.nvl(p.CPY_ID, "0") + "\",";
    strToken += "\"CPY_BIZ_NO\":\"" + StrUtil.nvl(p.CPY_BIZ_NO) + "\",";
    strToken += "\"CPY_NM\":\"" + StrUtil.nvl(p.CPY_NM) + "\",";
    strToken += "\"PRS_ID\":\"" + StrUtil.nvl(p.PRS_ID) + "\",";
    strToken += "\"USER_LOGIN\":\""  + StrUtil.nvl(p.USER_LOGIN) + "\",";
    strToken += "\"REMOTE_IP\":\""  + StrUtil.nvl(ip) + "\",";
    strToken += "\"CU_USE_YN\":\""  + StrUtil.nvl(p.CU_USE_YN) + "\",";
    strToken += "\"CONFIRM_SETTLE_YN\":\""  + StrUtil.nvl(p.CONFIRM_SETTLE_YN) + "\",";
    strToken += "\"REVERSE_YN\":\""  + StrUtil.nvl(p.REVERSE_YN) + "\",";
    strToken += "\"MOBILE_YN\":\""  + StrUtil.nvl(p.MOBILE_YN) + "\",";
    strToken += "\"SIGN_EXCLUDE_YN\":\""  + StrUtil.nvl(p.SIGN_EXCLUDE_YN) + "\",";
    strToken += "\"CRG_ID\":\""  + StrUtil.nvl(p.CRG_ID) + "\",";
    strToken += "\"PAPER_BILL_YN\":\""  + StrUtil.nvl(p.PAPER_BILL_YN) + "\",";
    strToken += "\"FEE_MOD_YN\":\""     + StrUtil.nvl(p.FEE_MOD_YN) + "\",";
    strToken += "\"TAIL\":\"TAIL\"";
    strToken += "}";
    strToken = CryptoDESUtil.encrypt(strToken);
    // System.out.println(strToken);
    // System.out.println(strToken.length());
    addCookie(strToken.replaceAll("\n", "_____n_____").replaceAll("\r", "_____r_____"), request, response);
    return strToken;
  }
  private static LoginVO parseToken(String enToken, HttpServletRequest request) {
    enToken = StrUtil.nvl(enToken.replaceAll("_____n_____","\n").replaceAll("_____r_____","\r"));
    // System.out.println(enToken);
    LoginVO v = new LoginVO();
    try {
      String token = CryptoDESUtil.decrypt(enToken);
      // System.out.println(token);
      Gson gson = new Gson();
      Map<String, Object> map = gson.fromJson(token, Map.class);
      for (Map.Entry<String, Object> e : map.entrySet()) {
        if (e.getKey().equals("CPY_GUBUN")) v.CPY_GUBUN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CPY_ID")) v.CPY_ID = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CPY_BIZ_NO")) v.CPY_BIZ_NO = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CPY_NM")) v.CPY_NM = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("PRS_ID")) v.PRS_ID = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("USER_LOGIN")) v.USER_LOGIN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("REMOTE_IP")) v.REMOTE_IP = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CU_USE_YN")) v.CU_USE_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CONFIRM_SETTLE_YN")) v.CONFIRM_SETTLE_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("REVERSE_YN")) v.REVERSE_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("MOBILE_YN")) v.MOBILE_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("SIGN_EXCLUDE_YN")) v.SIGN_EXCLUDE_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("CRG_ID")) v.CRG_ID = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("PAPER_BILL_YN")) v.PAPER_BILL_YN = StrUtil.nvl(e.getValue().toString());
        if (e.getKey().equals("FEE_MOD_YN")) v.FEE_MOD_YN = StrUtil.nvl(e.getValue().toString());
      }
      v.VALID_IP_YN = (v.REMOTE_IP.equals(LoginUtil.getClientIpAddr(request))) ? "Y" : "N";
    } catch (Exception e) {
      System.out.println(e.toString());
    }
    return v;
  }
  private static void addCookie(String strToken, HttpServletRequest request, HttpServletResponse response) {
    Cookie cookie = new Cookie(LoginBean.strCookieKey, strToken);
    cookie.setPath(request.getContextPath()+"/");
    cookie.setHttpOnly(true);
    cookie.setSecure(true);
    cookie.setMaxAge(ConfigurationMgr.getInstance().getInt("COOKIE_MAX_AGE"));
    response.addCookie(cookie);
  }
  public static LoginVO getToken(HttpServletRequest request) {
    String enToken = "";
    try {
      Cookie[] cookies = request.getCookies();
      for (Cookie cookie : cookies) {
        if (cookie.getName().equals(LoginBean.strCookieKey)) {
          enToken = cookie.getValue();
        }
      }
      return (enToken!=null && enToken.length()>10) ? parseToken(enToken, request) : null;
    } catch (Exception e) {
      return null;
    }
  }
  public static void removeToken(HttpServletRequest request, HttpServletResponse response) {
    Cookie cookie = new Cookie(LoginBean.strCookieKey, "");
    cookie.setPath(request.getContextPath()+"/");
    cookie.setHttpOnly(true);
    cookie.setSecure(true);
    cookie.setMaxAge(0);
    response.addCookie(cookie);
  }
  public String C_LOGIN_PROC(String strLoginId, String strLoginPw, HttpServletRequest request, HttpServletResponse response) {
    LoginVO vo = new LoginDAO().C_LOGIN_PROC(strLoginId, CryptoDESUtil.encrypt(strLoginPw));
    if (!vo.CPY_ID.equals("0")) {
		if (vo.CST_ID != null && vo.CST_ID.equals("1")) {
	        return "-2";
	    }
      this.setToken(vo, request, response);
    }
    return vo.CPY_ID;
  }
  public String C_LOGIN_VIA_CERT_PROC(String strSSN, HttpServletRequest request, HttpServletResponse response) {
    LoginVO vo = new LoginDAO().C_LOGIN_VIA_CERT_PROC(strSSN);
    if (!vo.CPY_ID.equals("0")) {
    	if (vo.CST_ID != null && vo.CST_ID.equals("1")) {
	        return "-2";
	    }
      this.setToken(vo, request, response);
    }
    return vo.CPY_ID;
  }
  
  public String C_ACCOUNT_SEARCH_ID_PROC(String strBizNo, String strUserNm) {
    return new LoginDAO().C_ACCOUNT_SEARCH_ID_PROC(strBizNo, strUserNm);
  }
  public String[] C_ACCOUNT_EMAIL_PROC(String strBizNo, String strUserId) {
    return new LoginDAO().C_ACCOUNT_EMAIL_PROC(strBizNo, strUserId);
  }
  public String C_ACCOUNT_CHANGE_PASSWD_PROC(String strBizNo, String strUserId, String strEmail, String strNewPassword) {
    return new LoginDAO().C_ACCOUNT_CHANGE_PASSWD_PROC(strBizNo, strUserId, strEmail, strNewPassword);
  }
}
