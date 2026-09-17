/*************************** NAVIGATION **************************/
function toggleSearchCompanyForm() {
  if ($("#SearchCompanyForm").is(":visible")) $("#SearchCompanyForm").hide();
  else $("#SearchCompanyForm").show();
  $("#SearchCompanyForm input[name='bizno']").focus();
}
$(document).ready(function() {
  $("#navigation>li").on("mouseover", function() {
    $("#navigation-items-block").show();
  });
  $("#navigation-items-block").on("mouseleave", function() {
    $("#navigation-items-block").hide();
  });
  $("img.burger").on("click", function() {
    var isVisible = $("div.navigation-mobile-header").is(':visible'); 
    $("div.navigation-mobile-header").remove();
    $("div.navigation-mobile-body").remove();
    if (!isVisible) {
      $("body").append("<div class='navigation-mobile-header'><ul></ul></div>");
      $("div.navigation-mobile-header>ul").html($("#navigation").html());
      $("div.navigation-mobile-header>ul>li>a").attr("href", "#");
      $("div.navigation-mobile-header>ul>li").on("click", function() {
        var nav_id = $(this).attr("class").replace("navigation-li-col ", "");
        $("body").append("<div class='navigation-mobile-body'><ul></ul></div>");
        $("div.navigation-mobile-body>ul").html($("#navigation-items>li>ul."+nav_id).html());
        $("div.navigation-mobile-body").show();
      });
      $("div.navigation-mobile-header").show();
    }
  });
  $("header>aside>span.user-nm").on("click", function(){
    showCustomConfirm("로그아웃하시겠습니까?", function() {
      location.href=strContextPath+"/mgr/LogOut.jsp"; 
    }, function() {
      //
    });
  });
  $("#SearchCompanyForm input[name='bizno'], #SearchCompanyForm input[name='nm']").keydown(function(key) {
    if (key.keyCode == 13) document.frmSearchCompany.submit();
  });
});
$(window).on('resize', function(){
  $("div.navigation-mobile-header").remove();
  $("div.navigation-mobile-body").remove();
});

/*************************** POPUP CONTROL **************************/
function closePopup() {
  $("#element_to_pop_up").bPopup().close();
  $("#element_to_pop_up").empty();
}

/*************************** HOT BUTTONS **************************/
function getMemoWindow(cid, txt) {
  closePopup();
  var strUrl = strContextPath+'/mgr/memo/MemoReg.jsp?cid='+cid+'&txt='+encodeURI(txt);
  // $("#element_to_pop_up").bPopup({loadUrl:strUrl});
  window.open(strUrl, "_memo_", 'width=500,height=900,scrollbars=yes,resizable=no');
}
function getMailWindow(cid) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/mgr/customer/MailSend.jsp?cid='+cid});
}
function getSMSWindow(cid) {
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:strContextPath+'/mgr/customer/SMSSend.jsp?cid='+cid});
}
function getFaxWindow(cid) {
  closePopup();
  //
}

/*************************** NOTIFICATION **************************/
function showMyMemoForNaviator() {
  location.href = strContextPath + '/mgr/memo/Memos.jsp?my=Y';
}
function showNotificationForNaviator() {
  hideNotificationForNavigation();
  $("#notification-block").load(strContextPath + '/mgr/Notification.jsp', function() {
    var cnt = $("input[name='notification_cnt']").val();
    if (cnt>0) afterNotification();
    else toast("알릴 내용이 없습니다.");
  });
}
function checkoutForNavigation() {
  hideNotificationForNavigation()
  $("#notification-block").load(strContextPath + '/mgr/Notification.jsp?checkout=Y'  , function() {
    var cnt = $("input[name='notification_cnt']").val();
    if (cnt>0) afterNotification();
    else toast("알릴 내용이 없습니다.");
  });
}
function hideNotificationForNavigation() {
  $("#notification-block>div").remove();
  $("#notification-block").hide();
  $("span.notification_cnt").text("");
  $("span.notification_cnt").hide();
}
function afterNotification() {
  var cnt = $("input[name='notification_cnt']").val();
  if (cnt>0) {
    $("span.notification_cnt").text(cnt);
    $("span.notification_cnt").show();
    $("#notification-block").show();
  } else {
    hideNotificationForNavigation();
  }
}
function getNotificationPermission() {
  if (!("Notification" in window)) {
    toast("알림을 사용할 수 없습니다.");
    return false;
  }
  Notification.requestPermission(function (result) {
    if(result == 'denied') {
      toast("알림 차단 중입니다. 알림을 받으시려면, 브라우저 설정에서 알림을 허용하십시오.", 3000);
      return false;
    }
  });
  return true;
}

if (notificationtimer) clearInterval(notificationtimer);
var notificationtimer = setInterval(function() {
  $.post(strContextPath +"/mgr/Notification.jsp?notification=Y", function(data) {
   if ($.trim(data)!="") {
     hideNotificationForNavigation();
     $("#notification-block").html(data);
     var cnt = $("input[name='notification_cnt']").val();
     afterNotification();
     if (Notification.permission=="granted" && cnt>0) {
       const noti = new Notification("관리자 알림", {
        body : cnt + "건의 알림이 있습니다.",
        icon:  strContextPath + "/static/images/bi_square.png"
       });
       noti.onclick = () => {
         window.open(strContextPath + "/mgr/Notifications.jsp");;
       }
     }
   }
  });
}, 5*60*1000);
