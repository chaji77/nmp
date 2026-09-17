<%@ page contentType="text/html;charset=utf-8"%>	
<%@ page import="kr.co.funology.fw.util.DateTimeUtil"%>
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
<script src="<%=request.getContextPath() %>/static/js/jquery-3.7.1.min.js" type="text/javascript"></script>
</head>
<body>

<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-app.js";
  import { getMessaging, getToken, onMessage } from 'https://www.gstatic.com/firebasejs/11.3.1/firebase-messaging.js';
  const vapid = 'BFms4O9D7qoGMzIJcz83KYJbrQqvATV6PlK8CgIAtdVu4nkv0s91LGtvVXw8xIwo2GppVAS3gnga9YvNPaIw1t4';
  const firebaseConfig = {
    apiKey: "AIzaSyDFw2S0vS1cKPO9ds_ei9685HxTsq4OUfU",
    authDomain: "mpone-67d48.firebaseapp.com",
    projectId: "mpone-67d48",
    storageBucket: "mpone-67d48.firebasestorage.app",
    messagingSenderId: "253668877075",
    appId: "1:253668877075:web:fd348ec94923eb04ddb0e6"
  };
  const app = initializeApp(firebaseConfig);
  const messaging = getMessaging(app);
  if (Notification.permission === "granted") {
    getToken(messaging, { vapidKey: vapid })
    .then((token) => {
      console.log('FCM Token:', token);
      // STORE THIS TOKEN ON YOUR SERVER AND USE IT TO SEND NOTIFICATIONS.
    })
    .catch((error) => {
      console.error('Error getting token:', error);
    });
  } else if (Notification.permission === "default") {
    Notification.requestPermission()
    .then((permission) => {
      if (permission === "granted") {
        return getToken(messaging, { vapidKey: vapid });
      } else {
        console.log("Notification permission denied.");
      }
    })
    .then((token) => {
      if (token) {
        console.log('FCM Token:', token);
        // STORE THIS TOKEN ON YOUR SERVER AND USE IT TO SEND NOTIFICATIONS.
      }
    })
    .catch((error) => {
      console.error('Error getting permission or token:', error);
    });
  }
  onMessage(messaging, (payload) => {
    console.log('Message received:', payload);
    if (Notification.permission === "granted") {
      var noti = new Notification(payload.notification.title, {
        body: payload.notification.body,
        icon: payload.notification.icon
      });
      noti.onclick = () => { window.open(payload.data.url); }
    }
  });
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker
    .register('/firebase-messaging-sw.js')
    .then(function(registration) {
      console.log('Service Worker registered with scope: ', registration.scope);
    })
    .catch(function(error) {
      console.log('Service Worker registration failed: ', error);
    });
  }
</script>
</body>
</html>