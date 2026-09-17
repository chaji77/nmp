/****************************************************************
 * valiables
 */
var strSeparator  = ".";    // separator for year, month, date
var strToday      = "";     // today, ex) 2013.07.01
var intYear       = 2013;   // year
var intMonth      = 1;      // month
var intMaxFloor   = 0;      // default is 0
var isReloadable  = true;   // reloadable or not. default is true
var intMinHeight  = 50;
var intNodeHeight = 25;
var intScheduleTopPaddingSize = 6; // = border size + padding-top size

// for touch event
var intSensingWidth = 40;
var intChangingWidth = 60;
var intStartX = 0;
var intCalendarLeft = 0;
var intStartY = 0;

// storage for calendar & schedule data
var objCalendar;
var objSchedule;

/****************************************************************
 * window.loaded event
 *
 *
 */
// $(document).ready(function() {

function init() {
  if (isReloadable==true) {
    sessionStorage.clear();
  };
  getCalendar();
  /* when display change */
  $(window).bind('resize', function(e) {
    e.preventDefault();
    $("#Calendar table").css("width", ($("#Calendar").width()-($("#Calendar").width()-8)%7)+"px");
    getSchedule();
  });
}

/****************************************************************
 * Get the key for each monthly calendar matrix data in localStorage
 *
 *
 */
function getCalendarJsonKey() {
  var strMonth = (intMonth<10) ? "0" + intMonth : intMonth;
  return "jc_" + intYear + strMonth;
}

/****************************************************************
 * Get the key for each monthly schedule data in sessionStorage
 *
 *
 */
function getScheduleJsonKey() {
  var strMonth = (intMonth<10) ? "0" + intMonth : intMonth;
  return "js_" + intYear + strMonth;
}

/****************************************************************
 * Get a monthly calendar matrix
 *
 *
 */
function getCalendar() {

  /* remove 'Calendar' elements */
  $('#Calendar p').remove();
  $('#Calendar table').remove();
  $('#Calendar div').remove();

  var tm    = new Date().getTime();
  var url   = strContextPath + "/mgr/pims/LoadCalendar.jsp?year="+intYear+"&mon="+intMonth+"&s="+strSeparator+"&tm="+tm;
  var s     = document.createElement("script");
  s.type    = "text/javascript";
  s.charset = "utf-8";
  s.src     = url;
  document.getElementsByTagName("head")[0].appendChild(s);
}

/****************************************************************
 * Save a monthly calendar data.
 *
 *
 * @param str     value(json)
 */
function saveCalendar(str) {
  objCalendar = JSON.stringify(str);
  drawCalendar();
}

/****************************************************************
 * Draw calendar
 *
 *
 */
function drawCalendar() {
  var calendar = JSON.parse(objCalendar);
  var j        = 0;
  var k        = 0;
  var strMonth = (intMonth<10) ? "0" + intMonth : intMonth;
  var str      = "";
  var strLink  = "";

  /* set calendar part */
  str     += getCalendarHeader(calendar.title);
  str     += "<tr id='floor_0'>";
  for (var i=0; i<calendar.content.length; i++) {
    if (j%7==0 && i>0) {
      k++;
      j=0;
      intMaxFloor = k;
      str     += "</tr><tr id='floor_"+k+"'>";
    }

    /* set td's background and text color style : today? sunday? saterday? holiday? */
    str     += "<td id='cell_" + calendar.content[i].solar.replace(strSeparator,'') + "' week='" + j + "'";
    str     += (calendar.title.substring(0,5) + calendar.content[i].solar == strToday) ? " class='today'>" : ">";
    if (i==0) str+= "<div id='topcell'></div>";
    str     += "<p class='date'><span class='solar ";
    if (calendar.content[i].solar.substring(0, 2) != strMonth) str += "cgray";
    else {
      if (calendar.content[i].week==6) str += "cred";
      else if (calendar.content[i].holiday==true || calendar.content[i].week==0) str += "cred";
      else str += "cblack";
    }
    str += "'>";
    str += calendar.content[i].solar.substring(3);
    str += "</span>";
    /* set lunar date or holiday name */
    if (calendar.content[i].name.length>1) {
      str += "<span class='lunar'>"  + calendar.content[i].name + "</span>";
    } else {
      if (calendar.content[i].lunar.substring(3) != '30' && (calendar.content[i].lunar.substring(3) == '01' || calendar.content[i].lunar.substring(4)%5 == 0)) {
        str += "<span class='lunar'>" + calendar.content[i].lunar.substring(0,5) + "</span>";
      }
    }
    str     += "</p></td>";
    j++;
  }
  str     += "</tr>";
  str     += "</table>";

  /* appending calendar-data to 'Calendar' */
  $('#Calendar p').remove();
  $('#Calendar').append(str);

  /* regist click event */
  $('a.prev').click(function(e){ // call previous month
    //e.preventDefault();
    goPrev();
  });

  $('a.next').click(function(e){ // call next month
    //e.preventDefault();
    goNext();
  });

  $('a.today').click(function(e){ // call this month
    //e.preventDefault();
    var arr = strToday.split(strSeparator);
    intYear = arr[0];
    intMonth = parseInt("1" + arr[1])-100;
    getCalendar();
  });

  $('#Calendar td').click(function(e){ // call any date's schedule
    e.preventDefault();
    getDailySchedule($(this).attr('id'));
  });

  getSchedule();
}


function goPrev() {
    --intMonth;
    if (intMonth<1) {
      --intYear;
      intMonth = 12;
    }
    getCalendar();
}


function goNext() {
    ++intMonth;
    if (intMonth>12) {
      ++intYear;
      intMonth = 1;
    }
    getCalendar();
}

/****************************************************************
 * Get calendar header
 *
 *
 * @param subject year.month to display
 */
function getCalendarHeader(subject) {

  var str = "";
  str += "<p class='titlebar'><span><i class='fa-regular fa-calendar'></i> 공유일정</span> <a class='btn prev'><i class='fa-solid fa-chevron-left'></i></a><a class='title'>"+ subject + "</a><a class='btn next'><i class='fa-solid fa-chevron-right'></i></a><a class='btn today'>오늘</a></p>";
  str += "<table style='width:"+($("#Calendar").width()-($("#Calendar").width()-8)%7)+"px;'>";
  str += "<thead>";
  str += "<tr>";
  str += "<th><font color='red'>일</font></th>";
  str += "<th>월</th>";
  str += "<th>화</th>";
  str += "<th>수</th>";
  str += "<th>목</th>";
  str += "<th>금</th>";
  str += "<th><font color='red'>토</font></th>";
  str += "</tr>";
  str += "</thead>";
  return str;
}

/****************************************************************
 * Get schedule data by LoadSchedule.jsp
 *
 *
 */
function getSchedule() {
  var tm    = new Date().getTime();
  var url   = strContextPath + "/mgr/pims/LoadSchedule.jsp?y="+intYear+"&m="+intMonth+"&s="+strSeparator+"&a="+$("#ScheduleOrNot").val()+"&tm="+tm;
  var s     = document.createElement("script");
  s.type    = "text/javascript";
  s.charset = "utf-8";
  s.src     = url;
  document.getElementsByTagName("head")[0].appendChild(s);
}

/****************************************************************
 * Save schedule data to sessionStorage. It's called by LoadSchedule.jsp
 *
 *
 * @param str     value(json)
 */
function saveSchedule(str) {
  objSchedule = JSON.stringify(str);
  // console.log(objSchedule);
  drawSchedule();
}

/****************************************************************
 * Draw schedule
 *
 */
function drawSchedule() {
  var s = JSON.parse(objSchedule);
  $('#Calendar div').remove();
  if (s != null) {
    /* set cell-height */
    var floor = new Array(intMaxFloor+1);
    for (var f=0; f<floor.length; f++) {
      floor[f] = 1;
      for (var i=0; i<s.length; i++) {
       floor[f] = (s[i].floor==f && s[i].depth!=null && s[i].depth>floor[f]) ? s[i].depth : floor[f];
      }
      var intHeight = (floor[f]+2)*intNodeHeight;
      intHeight = (intHeight<intMinHeight) ? intMinHeight : intHeight;
      $('#floor_'+f).css("height", intHeight + "px");
      $('#linkablefloor_'+f).css("height", intHeight + "px");
    }

    /* get each schedule */
    for (var i=0; i<s.length; i++) {
       getScheduleNode(s[i].sdt, s[i].edt, s[i].nm, s[i].idx, s[i].depth, s[i].grp, i);
    }
    
    $('div.schedule').click(function(e){ // call any date's schedule
      e.preventDefault();
      viewSchedule($(this).attr('seq'), $(this).attr('grp'));
    });
    
  }
}

/****************************************************************
 * Get Schedule Node (is called drawSchedule())
 *
 * @param strStartDate 시작일
 * @param strEndDate   마감일
 * @param strSubject   제목
 * @param intScheduleIdx 시퀀스번호
 * @param intDepth     top위치
 * @param intGrp       일정분류
 * @param i            일정의 가상 행번호
 */
function getScheduleNode(strStartDate, strEndDate, strSubject, intScheduleIdx, intDepth, intGrp, i) {
  strStartDate = strStartDate.replace(strSeparator,'');
  strEndDate   = strEndDate.replace(strSeparator,'');
  try {
    var f     = $('#cell_'+strStartDate);
    var t     = $('#cell_'+strEndDate);
    var foff  = f.offset();
    var toff  = t.offset();
    var w     = toff.left - foff.left + t.width() - 1;
    var group = 'cwhite';
    switch (intGrp) {
      case "1":
        group = 'cred';
        break;
      case "2":
        group = 'cgreen';
        break;
      case "3":
        group = 'cblue';
        break;
      case "4":
        group = 'cyellow';
        break;
    };
    $('#Calendar').append("<div id='sidx_"+i+"' seq='"+intScheduleIdx+"' class='schedule "+ group +"' grp='"+intGrp+"'>"+strSubject+"</div>");
    $('#sidx_'+i).offset({top:(foff.top+intNodeHeight*intDepth), left:foff.left});
    $('#sidx_'+i).width(w);
    $('#sidx_'+i).height(intNodeHeight - intScheduleTopPaddingSize);
    
  } catch (e) {}
}

/****************************************************************
 * Get daily schedule
 *
 * @param id cell_id of a choosen day
 */
function getDailySchedule(id) {
  var intChooseYmd = intYear + id.substring(5);
  var s = JSON.parse(objSchedule);
  /* blur background & hide linkable cells */
  $("body").append("<div class='cover-all-in-calendar'></div>");
  $('#DailyScheduleCanvas').append("<div class='body'></div>");
  $('#DailyScheduleCanvas div.body').append("<div class='subject'><span class='title'>" + id.substring(5,7) + strSeparator + id.substring(7,9) + "<span class='week'>(" + getWeekName($('#'+id).attr('week')) + ")</span><a class='btn add' md='"+intChooseYmd+"'>일정등록</a> <a class='btn close'>닫기</a></div>");
  $('#DailyScheduleCanvas div.body').append("<div class='list'></list>");
  for (var i=0; i<s.length; i++) {

    var intStartYmd = "" + intYear + s[i].sdt.replace(strSeparator, "");
    var intEndYmd   = "" + intYear + s[i].edt.replace(strSeparator, "");
    if (intChooseYmd >= intStartYmd  && intChooseYmd <= intEndYmd) {
      var hm = (s[i].shm==s[i].ehm && s[i].shm=="00:00") ? "" : "(" + s[i].shm+"~"+s[i].ehm + ")";

      hm = (s[i].grp=="1") ? "업무" : hm; // "업무<br>"+s[i].status : hm;
      hm = (s[i].grp=="2") ? "회의" : hm;
      hm = (s[i].grp=="3") ? "외근|출장" : hm;
      hm = (s[i].grp=="4") ? "휴가" : hm;
      var iconcolor = (s[i].grp == "0") ? "cred" : "cblue";
      var txt = "<li class='list "+iconcolor+"'><span class='hm'>"+hm+"</span><a class='nm' href='#top' seq='"+s[i].idx+"' grp='"+s[i].grp+"'>"+s[i].nm+"</a>";

      $('#DailyScheduleCanvas div.list').append(txt);
    }
  }
  $( 'html, body' ).animate( { scrollTop : 0 }, 400 );
  $('#DailyScheduleCanvas div.list').append("<li class='bottom'><a href='#top' class='add' md='"+intChooseYmd+"' style=\"font-size:1em;\">새로운 일정</a></li>");
  $('#DailyScheduleCanvas').slideDown();

  /* regist schedule click event */
  $('#DailyScheduleCanvas a.btn').click(function(){
    $(".cover-all-in-calendar").remove();
      $('#DailyScheduleCanvas div.body').remove();
  });
  $('#DailyScheduleCanvas a.nm').click(function(){
    viewSchedule($(this).attr('seq'), $(this).attr('grp'));
    return false;
  });
  $('#DailyScheduleCanvas a.del').click(function(){
    dropSchedule($(this).attr('seq'), $(this).attr('md'));
    return false;
  });
  $('#DailyScheduleCanvas a.add').click(function(){
    addSchedule($(this).attr('md'));
    return false;
  });
}


/****************************************************************
 * Add schedule
 *
 * @param md to-add-day
 */
function addSchedule(ymd) {
  var url = strContextPath + "/mgr/pims/ScheduleWrite.jsp?ymd=" + ymd;
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:url});
}

function dropSchedule(id, ymd) {
  // $("#DailyScheduleCanvas").css("z-index", "299");
  showCustomConfirm("삭제할까요?", function() {
    $.post(strContextPath + "/mgr/pims/ScheduleDropProc.jsp", {'plan_id':id, 'ym':ymd}, function(data) {
      window.location.reload();
    });
  }, function() {
  });
}

function editSchedule(pid) {
  var url = strContextPath + "/mgr/pims/ScheduleWrite.jsp?plan_id=" + pid;
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:url});
}

function reloadSchedule() {
setTimeout(
  function() {
    // $("#DailyScheduleCanvas").css("z-index", "");
    $("body").append("<div class='cover-all-in-calendar'></div>");
  }, 500);
}


function viewSchedule(id, grp) {
  var url = strContextPath + "/mgr/pims/ScheduleView.jsp?plan_id=" + id;
  closePopup();
  $("#element_to_pop_up").bPopup({loadUrl:url});
}

/****************************************************************
 * Get week name
 *
 * @param week
 */
function getWeekName(week) {
  var weeknm = "";
  switch(week) {
      case '0':
      weeknm = "일";
      break;
    case '1':
      weeknm = "월";
      break;
    case '2':
      weeknm = "화";
      break;
    case '3':
      weeknm = "수";
      break;
    case '4':
      weeknm = "목";
      break;
    case '5':
      weeknm = "금";
      break;
    default:
      weeknm = "토";
      break;
  }
  return weeknm;
}
