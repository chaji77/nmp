package kr.co.mp.common;

import javax.servlet.http.HttpServletRequest;

public class MobileUtil {

  public static boolean isMobile(HttpServletRequest request) {
    String userAgent = request.getHeader("User-Agent");
    boolean isMobile = userAgent != null && (
        userAgent.contains("Mobi") || userAgent.contains("Android") || 
        userAgent.contains("iPhone") || userAgent.contains("iPad") ||
        userAgent.contains("iPod") || userAgent.contains("BlackBerry") || 
        userAgent.contains("Windows Phone")
    );
    return isMobile;
  }
}
