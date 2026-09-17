<%@ page contentType="application/javascript;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%
String strDomainUrl   = ConfigurationMgr.getInstance().getString("DOMAIN_URL");
String strContextPath = ConfigurationMgr.getInstance().getString("CONTEXT_PATH");
%>
self.addEventListener("push", event => {
  const options = {
    body: "새로운 알림이 도착했습니다!",
    icon: "<%=strContextPath %>/static/images/bi_square.png"
  };
  event.waitUntil(self.registration.showNotification("관리자 알림 [백그라운드]", options));
});
/* This is an experimental feature of Chrome. It has not been adopted.
self.addEventListener("periodicsync", event => {
  if (event.tag === "sync-data") { 
    event.waitUntil(
      fetch("<%=strContextPath %>/mgr/Notification.jsp?notification=Y")
        .then(response => response.text()) 
        .then(data => {
          let parser = new DOMParser();
          let doc = parser.parseFromString(data, "text/html");
          let cntInput = doc.querySelector("input[name='notification_cnt']");
          let cnt = cntInput ? cntInput.value : "0";
          return self.registration.showNotification("관리자 알림", {
              body: `${cnt}건의 알림이 있습니다.`,
              icon: strContextPath + "/static/images/bi_square.png"
          });
        })
        .catch(error => console.error("Failure : ", error))
    );
  }
});
*/