package kr.co.mp.c;

import javax.servlet.http.HttpServletRequest;

public class LoginUtil {
  public static String getClientIpAddr(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");
    if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("Proxy-Client-IP");
    }
    if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("WL-Proxy-Client-IP");
    }
    if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("HTTP_CLIENT_IP");
    }
    if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getHeader("HTTP_X_FORWARDED_FOR");
    }
    if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
      ip = request.getRemoteAddr();
    }
    return ip;
  }

  /**
   * get web browser
   * 
   * @param request
   * @return
   */
  public static String getBrowser(HttpServletRequest request) {
    String ua = request.getHeader("User-Agent");
    ua = ua.toUpperCase();
    System.out.println(ua);
    if (ua.indexOf("TRIDENT")>-1) return "IE";
    if (ua.indexOf("EDG")>-1) return "Edge";
    if (ua.indexOf("WHALE")>-1) return "Whale";
    if (ua.indexOf("OPERA")>-1) return "Opera";
    if (ua.indexOf("FIREFOX")>-1) return "Firefox";
    if (ua.indexOf("CHROME")>-1) return "Chrome";
    if (ua.indexOf("SAFARI")>-1) return "Safari";
    return "Others";
  }

  /**
   * get operation system name
   * 
   * @param request
   * @return
   */
  public static String getOS(HttpServletRequest request) {
    String os = "";
    String ua = request.getHeader("User-Agent");
    ua = ua.toUpperCase();

    if (ua.indexOf("WINDOWS")>-1) {
      os = "Windows";
      if (ua.indexOf("X64")>-1 || ua.indexOf("W64")>-1) os += " 64bit";
      else if (ua.indexOf("ARM") > -1) os += " RT";
    } else if ((ua.indexOf("IPAD") > -1) || (ua.indexOf("IPHONE") > -1) || (ua.indexOf("IPOD") > -1)) {
      os = "iOS";
    } else if (ua.indexOf("ANDROID") != -1) {
      os = "Android";
    } else if (ua.indexOf("MAC") > -1 || ua.indexOf("PPC") > -1) {
      os = "MacOS";
    } else if (ua.indexOf("Linux") > -1) {
      os = "Linux";
    } else os = "Other";

    return os;
  }
}
