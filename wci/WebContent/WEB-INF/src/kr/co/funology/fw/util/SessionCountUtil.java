package kr.co.funology.fw.util;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

public class SessionCountUtil implements HttpSessionListener {
  private static int activeSessions = 0;

  public static int getActiveSessions() {
    if (activeSessions<0) activeSessions = 0;
    return activeSessions;
  }

  @Override
  public void sessionCreated(HttpSessionEvent se) {
    activeSessions++;
  }

  @Override
  public void sessionDestroyed(HttpSessionEvent se) {
    activeSessions--;
  }
}

