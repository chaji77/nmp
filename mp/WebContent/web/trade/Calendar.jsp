<%@ page contentType="text/html;charset=utf-8"%>
<script>
/* GLOBAL VARIABLES */
var currentDate = new Date(); // CURRENT DATE
var strDefaultMaturityDate = "0000-00-00"; // DEFAULT MATURITY DATE
var strMaturityDateColor   = "#d53600"; // MATURITY DATE'S COLOR
var intDirection = -1; // DIRECTION TO TURN CALENDAR

/*******************************************************************************
 *
 * CALCUATOR
 *
 ******************************************************************************/

/**
 * GET TODAY
 *
 */
function getToday() {
  var m = ((currentDate.getMonth()+1)<10)? "0"+(currentDate.getMonth()+1) : (currentDate.getMonth()+1);
  var d = (currentDate.getDate()<10)? "0"+currentDate.getDate() : currentDate.getDate();
  return currentDate.getFullYear() + "-" + m + "-" + d;
}

/**
 * MATURITY DATE
 *
 * @param intDiff
 */
function setMaturityDate(intDiff) {

  if (intDiff == "") {
    return;
  } else if (parseInt(intDiff) > 180) {
    toast("대출일수 : "+intDiff+"일\n대출일수는 오늘부터 180 이전 날짜이여야 합니다.");
    return;
  } else if (parseInt(intDiff) < 5) {
    toast("대출일수 : "+intDiff+"일\n대출일수는 오늘부터 3일 이후 날짜이여야 합니다.");
    return;
  }
  var d 	= new Date();
  var td 	= new Date(d.getFullYear(), d.getMonth(), (parseInt(d.getDate())+parseInt(intDiff)-1));
  var m 	= ((td.getMonth()+1)<10)? "0"+(td.getMonth()+1) : (td.getMonth()+1);
  var d 	= (td.getDate()<10)? "0"+td.getDate() : td.getDate();
  strDefaultMaturityDate = td.getFullYear() + "-" + m + "-" + d;

  intDirection = 0;
  var intMove  = ((td.getFullYear()-currentDate.getFullYear())>0) ? 12-currentDate.getMonth()+td.getMonth() : td.getMonth()-currentDate.getMonth();
  moveCalendar(intMove);
}

/**
 * DATEDIFF (MATURITY DATE - TODAY)
 *
 * @param strDateTo
 * @param strDateFrom
 * @return int
 */
function getDateDiff(strDateTo, strDateFrom) {
    var arrDateTo = strDateTo.split("-");
    var dateTo = new Date(arrDateTo[0], arrDateTo[1]-1, arrDateTo[2]-0);
    var arrDateFrom = strDateFrom.split("-");
    var dateFrom = new Date(arrDateFrom[0], arrDateFrom[1]-1, arrDateFrom[2]-0);
    return Math.floor((dateTo.getTime() - dateFrom.getTime()) / (1000 * 60 * 60 * 24));
}

/*******************************************************************************
 *
 * CALENDAR-MAKER
 *
 ******************************************************************************/

/**
 * SET CALENDAR
 *
 * @param strDivId
 * @param intYear
 * @param intMonth
 */
function setCalendar(strDivId, intYear, intMonth) {

  var arrCalendar = new Array(6);
  for (var i=0; i<6; i++) {
    arrCalendar[i] = new Array(7);
    for (var j=0; j<7; j++) {
      arrCalendar[i][j] = "";
    }
  }

  var objDate     = new Date(intYear, intMonth, 1);

  var m = ((objDate.getMonth()+1)<10)? "0"+(objDate.getMonth()+1) : (objDate.getMonth()+1);
  var strYearMonth = objDate.getFullYear() + "-" + m;
  var intFirstDay = objDate.getDay();

  var objNextDate = new Date(intYear, intMonth+1, 0);
  var intLastDate = objNextDate.getDate();
  var intLastDay  = objNextDate.getDay();

  var j = 0;
  for (var i=0; i<intLastDate; i++) {
    intWeek = (intFirstDay+i)%7;
    if (i>0 && intWeek==0) j++;
    var d = ((i+1)<10)? "0"+(i+1) : (i+1);
    var strDate = strYearMonth + "-" + d;
    arrCalendar[j][intWeek] = (i+1) + "_" + strDate;
  }

  var str = "";
  str  = getCalendarHeader(strYearMonth);
  str += getCalendarBody(arrCalendar, intLastDate);
  str += getCalendarFooter();
  document.getElementById(strDivId).innerHTML = str;

}

/**
 * GET CALENDAR HEADER
 *
 * @param strYearMonth
 * @return String
 */
function getCalendarHeader(strYearMonth) {
  var arrWeekDay  = new Array("일","월","화","수","목","금","토");

  var str = "<table class='detail'>";
  str += "<tr><td colspan='7' align='center' style='font-size:1.3em;'>" + strYearMonth + "</td></tr>";
  str += "<tr>"
  for (var i=0; i<7; i++) {
    str += "<th>";
    if(i==0) {
      str += "<font color='#d53600'>" + arrWeekDay[i] + "</font></td>";
    } else if(i==6) {
      str += "<font color='#0036d5'>" + arrWeekDay[i] + "</font></td>";
    } else {
      str += arrWeekDay[i] + "</th>";
    }
  }
  str += "</tr>";
  return str;
}

/**
 * GET CALENDAR FOOTER
 *
 * @return String
 */
function getCalendarFooter() {
  var str = "</table>";
  return str;
}

/**
 * GET CALENDAR BODY
 *
 * @param arrCalendar
 * @param intLastDate
 * @return String
 */

function getCalendarBody(arrCalendar, intLastDate) {
  var str = "";
  var intDate = 0;
  for (var i=0; i<arrCalendar.length; i++) {
    if (intDate < intLastDate) {
      str += "<tr>";
      for (var j=0; j<arrCalendar[i].length; j++) {
        var arr = arrCalendar[i][j].split('_');

        var strFontColor = "#000000";
        if (j==0) strFontColor = "#d53600";
        else if (j==6) strFontColor = "#0036d5";

        str += "<td align='right' bgcolor='";
        str += (strDefaultMaturityDate == arr[1]) ? strMaturityDateColor : "#ffffff";
        str += "'";
        if (arrCalendar[i][j]!="" && getDateDiff(arr[1], getToday())>0) str += " onclick=\"clickEvent('" + arr[1] + "');\" style=\"cursor:pointer;\"" <!-- onmouseover="overEvent('" + arr[1] + "');" -->
        str += "><font color='" + strFontColor + "'>" + arr[0] + "</font></td>";
        intDate = (intDate < parseInt(arrCalendar[i][j])) ? parseInt(arrCalendar[i][j]) : intDate;
      }
      str += "</tr>";
    }
  }
  return str;
}


/*******************************************************************************
 *
 * EVENT
 *
 ******************************************************************************/

function overEvent(strDate) {
  $("#maturity").html(strDate + " = " + getToday() + " + " + getDateDiff(strDate, getToday()));
}

function clickEvent(strDate) {
  if (document.frmEnt.bnk_pay_id && document.frmEnt.bnk_pay_id.value != "") {}
  else {
    toast("결제은행 및 결제수단을 먼저 선택하십시오.");
    return;
  }
  var bnk_pay_id = document.frmEnt.bnk_pay_id.value;
  var bnk_cd = bnk_pay_id.substring(0, 2);
  var pay_id = bnk_pay_id.substring(bnk_pay_id.length-1);
  
  console.log("clickEvent");
  $.post("ValidateDateCheck.jsp", {"strDate":strDate}, function(data){
    console.log(data);
    var json = JSON.parse($.trim(data));
    if (json.kind == "OVER") {
      toast("선택할 수 없는 날짜입니다.");
      return;
    }
    if (json.kind == "LAW" || json.kind == "FIN") {
    	console.log(json.kind);
      var nm = json.nm;
      if (nm.length>0) toast(nm+"입니다.");
      else toast("영업일이 아닙니다.");
    } else {
      if (json.cnt>180) {
        toast("대출일수는 오늘부터 180일 이내이어야 합니다.");
        return;
      }
      if (json.cnt<4) {
        toast("대출일수는 오늘부터 4일이 경과되어야 합니다.");
        return;
      }
      if (bnk_cd=="HN" && pay_id==4 && json.cnt<7) {
        toast("하나은행은 오늘부터 7일이 경과되어야 합니다.");
        return;
      }

      var msg = "대출일수는 " + json.cnt + "일입니다.";
      if((bnk_cd == "SB" || bnk_cd == "KB" || bnk_cd == "TB") && pay_id == 4) {
        msg += "<br/>지정한 만기일은 인터넷 뱅킹시 다시 지정해야 되오니 착오없으시기 바랍니다.";
      }
      toast(msg, 2000);
      
      $("input[name='maturity_ymd']").val(strDate);
      $("#maturity-cnt span").html("[ "+json.cnt+"일 ]");
      $("#maturity-cnt").show();
      hideCalendar();
    }
  });
}

/*******************************************************************************
 *
 * CONTROLLER
 *
 ******************************************************************************/

/**
 * VIEW CALENDAR
 *
 * @param strMaturityDate
 */
function viewCalendar(strMaturityDate) {
  strDefaultMaturityDate = strMaturityDate;
  setCalendar('calendarA', currentDate.getFullYear(), currentDate.getMonth());
  setCalendar('calendarB', currentDate.getFullYear(), currentDate.getMonth()+1);
  setCalendar('calendarC', currentDate.getFullYear(), currentDate.getMonth()+2);
}

/**
 * TURN CALENDAR
 *
 * @param intMove
 */
function moveCalendar(intMove) {
  intDirection = intDirection - intMove;
  setCalendar('calendarA', currentDate.getFullYear(), currentDate.getMonth()-intDirection-1);
  setCalendar('calendarB', currentDate.getFullYear(), currentDate.getMonth()-intDirection);
  setCalendar('calendarC', currentDate.getFullYear(), currentDate.getMonth()-intDirection+1);
}

//-->
</script>

<div style='text-align:center;'>
  <i class="fa-solid fa-chevron-left" style='padding:8px 10px;vertical-align:middle;' onClick="moveCalendar(-1);"></i>
  <i class="fa-solid fa-chevron-right" style='padding:8px 10px;vertical-align:middle;' onClick="moveCalendar(1);"></i>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <input type='number' name='days' size='3' min='1' max='365' placeholder='만기일수'
         onkeydown='javascript:if (event.keyCode == 13) setMaturityDate(this.value);'
         style='width:100px;vertical-align:middle;'>
  <i class="fa-solid fa-magnifying-glass" style='padding:8px 10px;vertical-align:middle;' onclick='setMaturityDate(document.frmEnt.days.value);'></i>
</div>

<ul>
  <li id="calendarA"></li>
  <li id="calendarB"></li>
  <li id="calendarC" class='mobile_hide'></li>
</ul>

<div style='text-align:center;margin-top:20px;margin-bottom:10px;'>달력에서 희망하는 만기(대출상환)일을 선택하십시오.</div>
<div id="maturity"></div>

<style>
#calendar ul {display:flex;justify-content:center;}
#calendar ul>li {padding:5px;}
#calendar i {font-size:15px;vertical-align:middle;padding:6px 10px;border-radius:5px;background-color:#547da3;color:#fff;cursor:pointer;}
#calendar i:hover {background-color:#555;}
#calendar th, #calendar td {padding:5px;}
</style>

<script defer="defer">
  viewCalendar(getToday());
</script>

