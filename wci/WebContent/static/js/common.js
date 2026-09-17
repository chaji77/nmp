let strContextPath = "/mp";

/////////////// UI TOOLS ///////////////

function showLoading() {
  $("body").append("<div class='cover-all-in-progress'></div>");
  $("body").append("<div class='loading'></div>");
}

function removePopupMessage() {
  $(".cover-all-in-progress").remove();
  $(".cover-all").remove();
  $(".result-message").remove();
}

function hideLoading(msg, callback) {
  $(".loading").remove();
  if (msg!=undefined) {
    $("body").append("<div class='result-message'>"+msg+"</div");
    $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
    $(".result-message").show().delay(500).slideUp("fast", function() {
      if (callback && typeof(callback) == "function") callback();
      removePopupMessage();
    });
  } else {
    removePopupMessage();
  }
}
function showSpinner(msg) {
  hideSpinner();
  $("body").append("<div class='cover-all-in-progress'></div>");
  $("body").append("<div class='spinner-box'><div class='spinner'></div><span>"+msg+"</span></div>");
}
function hideSpinner() {
	$(".cover-all-in-progress").remove();
	$(".spinner-box").remove();
}

function toast(msg, duration, callback) {
  if (duration == undefined) duration = 800;
  $("body").append("<div class='cover-all'></div>");
  $("body").append("<div class='result-message'>"+msg+"</div");
  $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
  $(".result-message").css("padding", "30px");
  $(".result-message").show().delay(duration).slideUp("fast", function() {
    if (callback && typeof(callback) == "function") callback();
    removePopupMessage();
  });
}
function showAlert(msg, callback_ok) {
  removePopupMessage();
  $("body").append("<div class='cover-all'></div>");
  var direction = (msg.length < 20) ? "center" : "left";
  $("body").append("<div class='result-message' style='text-align:"+direction+";'>"+msg+"</div");
  $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
  $(".result-message").css("padding", "20px");
  $(".result-message").css("padding-top", "40px");
  $(".result-message").css("padding-bottom", "70px");
  $(".result-message").append("<div><button id='custom-confirm-ok'>확인</button></div>");
  $(".result-message").show();
  
  $("#custom-confirm-ok").on("click", function() {
    removePopupMessage();
    if (callback_ok && typeof(callback_ok) == "function") callback_ok();
    return false;
  });
}
function showAlert(msg, callback_ok, addClass) {
  removePopupMessage();
  $("body").append("<div class='cover-all'></div>");
  var direction = (msg.length < 20) ? "center" : "left";
  $("body").append("<div class='result-message "+addClass+"' style='text-align:"+direction+";'>"+msg+"</div");
  $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
  $(".result-message").css("padding", "20px");
  $(".result-message").css("padding-top", "40px");
  $(".result-message").css("padding-bottom", "70px");
  $(".result-message").append("<div><button id='custom-confirm-ok'>확인</button></div>");
  $(".result-message").show();
  
  $("#custom-confirm-ok").on("click", function() {
    removePopupMessage();
    if (callback_ok && typeof(callback_ok) == "function") callback_ok();
    return false;
  });
}

function showCustomConfirm(msg, callback_ok, callback_cancel) {
  removePopupMessage();
  $("body").append("<div class='cover-all'></div>");
  var direction = (msg.length < 20) ? "center" : "left";
  $("body").append("<div class='result-message' style='text-align:"+direction+";'>"+msg+"</div");
  $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
  $(".result-message").css("padding", "20px");
  $(".result-message").css("padding-top", "40px");
  $(".result-message").css("padding-bottom", "70px");
  $(".result-message").append("<div>");
  $(".result-message").append("<button  id='custom-confirm-ok' style='right:114px;'>확인</button>");
  $(".result-message").append("<button id='custom-confirm-cancel' style='right:20px;'>취소</button>");
  $(".result-message").append("</div>");
  $(".result-message").show();

  $("#custom-confirm-ok").on("click", function() {
    removePopupMessage();
    if (callback_ok && typeof(callback_ok) == "function") callback_ok();
    return false;
  });
  $("#custom-confirm-cancel").on("click", function() {
    removePopupMessage();
    if (callback_cancel && typeof(callback_cancel) == "function") callback_cancel();
    return false;
  });
}

function showCustomChoice(msg, callback_ok, callback_cancel, ok_btn_nm, cancel_btn_nm) {
  removePopupMessage();
  if (ok_btn_nm == undefined) ok_btn_nm = "네";
  if (cancel_btn_nm == undefined) cancel_btn_nm = "아니오";
  $("body").append("<div class='cover-all-in-progress'></div>");
  var direction = (msg.length < 20) ? "center" : "left";
  $("body").append("<div class='result-message' style='text-align:"+direction+";'>"+msg+"</div");
  $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
  $(".result-message").css("padding", "20px");
  $(".result-message").css("padding-top", "40px");
  $(".result-message").css("padding-bottom", "70px");
  $(".result-message").append("<div>");
  $(".result-message").append("<button  id='custom-confirm-ok' style='right:114px;width:auto !important;'>"+ok_btn_nm+"</button>");
  $(".result-message").append("<button id='custom-confirm-cancel' style='right:20px;width:auto !important;'>"+cancel_btn_nm+"</button>");
  $(".result-message").append("</div>");
  $(".result-message").show();
  $("#custom-confirm-ok").focus();

  $("#custom-confirm-ok").on("click", function() {
    removePopupMessage();
    if (callback_ok && typeof(callback_ok) == "function") callback_ok();
    return false;
  });
  $("#custom-confirm-cancel").on("click", function() {
    removePopupMessage();
    if (callback_cancel && typeof(callback_cancel) == "function") callback_cancel();
    return false;
  });
}

function enter(callback) {
  if (window.event.keyCode == 13 && callback && typeof(callback) == "function") callback();
}

String.prototype.trim = function() {
  return this.replace(/^\s+|\s+$/g,"");
};

String.prototype.replaceAll = function(org, dest) {
  return this.split(org).join(dest);
}

function stripTags(str) {
  str = str.replace(/</gi, "&lt;");
  str = str.replace(/>/gi, "&gt;");
  return str.replace(/(<([^>]+)>)/ig,"").trim();
}


/////////////// DESKTOP ALARM /////////////////////
function getNotificationPermission() {
    if (!("Notification" in window)) {
      toast("알람을 허용하지 않았습니다.");
      return false;
    }
    Notification.requestPermission(function (result) {
        if(result == 'denied') {
            toast('알람을 차단하셨습니다.');
            return false;
        }
    });
    return true;
}
function notify(title, msg, link) {
  if (getNotificationPermission()) {
      var options = {body:msg};
      var notification = new Notification(title, options);
      notification.onclick = function() {
        window.location.href = link;
      };
  }
}

/////////////// ENVIRONMENT ///////////////
function isMobile() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
}


/////////////// CURRENCY /////////////////////
function addComma(num) {
  var regexp = /\B(?=(\d{3})+(?!\d))/g;
  return num.toString().replace(regexp, ',');
}

function downloadurl(url) {
  location.href = encodeURIComponent(url);
}

/////////////// FORM-CHECKER /////////////////////
function validate(n, rule, range, errMessage) {
  var c = true;
  if (rule=="length") {
    var v = $.trim($(n).val());
    $(n).val(v);
    if (range[1]=='undefined') {
      if (v.length<range[0]) c = false;
    } else {
      if (v.length<range[0] || v.length>range[1]) c = false;
    }
    if (!c) {
      $(n).addClass("invalid");
      toast(errMessage, 1000, function() {
      	$(n).focus();
      	hideLoading();	
      });
      return false;
    }
  }
  if (rule=="option") {
    var v = $.trim($(n+" option:selected").val());
    if (v=="") {
      $(n).addClass("invalid");
      toast(errMessage, 1000, function() {
      	$(n).focus();
      	hideLoading();
      });
      return false;
    }
  }
  return true;
}
