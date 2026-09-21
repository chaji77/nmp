<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.TodayStatVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
String getCodeName(String cd) {
  if (cd.equals("CONTRACT")) return "거래";
  if (cd.equals("ABNORMAL")) return "이상거래";
  if (cd.equals("COMPANY")) return "회원사";
  if (cd.equals("GUARANTEE")) return "보증서";
  if (cd.equals("CALL")) return "고객상담";
  return "";
}
String getKeyName(String cd, String colnm) {
  if (cd.equals("CONTRACT")) {
    if (colnm.equals("A")) return "당일 거래건";
    if (colnm.equals("B")) return "당일 거래총액";
    if (colnm.equals("C")) return "당일 MP수수료총액";
    if (colnm.equals("D")) return "<font color='red'>미해결 전송실패</font>";
  }
  if (cd.equals("ABNORMAL")) {
    if (colnm.equals("A")) return "당일 계약건";
    if (colnm.equals("B")) return "당일 발생건";
    if (colnm.equals("C")) return "당일 해제건";
  }
  if (cd.equals("COMPANY")) {
    if (colnm.equals("A")) return "누적 회원수";
    if (colnm.equals("B")) return "당일 가입회원수";
    if (colnm.equals("C")) return "누적 구매사";
    if (colnm.equals("D")) return "당일 로그인";
  }
  if (cd.equals("GUARANTEE")) {
    if (colnm.equals("A")) return "유효보증서건";
    if (colnm.equals("B")) return "유효보증총액";
  }
  if (cd.equals("CALL")) {
    if (colnm.equals("A")) return "당일 메모(상담)건";
  }
  return "";
}
%>
<%
request.setCharacterEncoding("utf-8");
String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
String strStatisticsDate = StrUtil.nvl(request.getParameter("strDate"), DateTimeUtil.getCurrentDate("-"));
ArrayList<TodayStatVO> arr = new TradeBean().DAILY_STAT_PROC(strStatisticsDate.replaceAll("-", ""));

String   strSeparator = ".";
String[] arrDate      = DateTimeUtil.getCurrentDate("-").split("-");
boolean  isReloadable = true;
String strDate = StrUtil.nvl(request.getParameter("ymd"));

if (!strDate.equals("") && strDate.length()==8) {
  arrDate[0] = strDate.substring(0,4);
  arrDate[1] = strDate.substring(4,6);
  arrDate[2] = strDate.substring(6,8);
}
int intYear  = Integer.parseInt(arrDate[0]);
int intMonth = Integer.parseInt(arrDate[1]);

%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>DASHBOARD</title>

<link rel="stylesheet" href="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.css?<%=DateTimeUtil.getCurrentResourceVersion()%>1" type="text/css" media="all" />
<script type="text/javascript" src="<%=request.getContextPath() %>/static/ui/jquery-ui-1.12.1.min.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath() %>/mgr/pims/schedule.css?<%=DateTimeUtil.getCurrentDateTime()%>" />
<script type="text/javascript" src="<%=request.getContextPath() %>/mgr/pims/schedule.js?<%=DateTimeUtil.getCurrentDateTime() %>" ></script>
<script type="text/javascript" src="<%=request.getContextPath() %>/mgr/pims/json2.js?<%=DateTimeUtil.getCurrentResourceVersion()%>"></script>

<style>
ul.work-block {display:flex;flex-flow:row wrap;justify-content:left;}
ul.work-block>li {margin-right: 10px;margin-bottom:50px;}
ul.work-block>li.extend {width:calc(100% - 680px);}
ul.work-block>li:last-child {width:auto;margin-left: 10px;margin-right: 0;}
ul.stat li {padding: 5px 0;}
ul.stat li.has-border {border-top:1px solid #ddd;margin-top: 15px;padding-top: 15px;}
ul.stat li.has-border:first-child {margin-top:0;}
ul.stat label {min-widht:60px;max-width:60px;font-weight:bold;}
ul.stat>li>span {display:inline-block;min-width: 125px;}
ul.stat>li>span:last-child {text-align:right;}
div.block-title {font-size:1.6em;height:30px;padding:5px 0 10px 0;}
li.system-status {width: 300px;}
li.system-status .systemtitle {font-weight:bold;padding: 10px 0;text-transform:uppercase;}
li.system-status .systemtitle:first-child {padding-top:0;}
li.system-status .systemtitle i:hover {color:darkorange;cursor:pointer;animation: rotate_loading .8s linear infinite;}
li.system-status label {width: 80px;}
@media only screen and (max-width:1023px) {
  ul.work-block li, ul.work-block>li.extend {width:100%;margin-right:0;}
  /* ul.work-block>li:last-child {display:none;} */
  #Calendar p.titlebar span:first-child {display:none;}
}
</style>


<script type="text/javascript">
<!--
strSeparator = "<%=strSeparator%>"; // separator for year, month, date
strToday     = "<%=DateTimeUtil.getCurrentDate(strSeparator)%>"; // this day
intYear      = <%=intYear%>;        // year
intMonth     = <%=intMonth%>;       // month
intMaxFloor  = 0;                   // calendar's floor
strStartCellCode = "";
isReloadable = <%=isReloadable%>;

function loadSystemInfo(server, obj) {
  var blocknm = server.replace(/\./g, "-");
  $("."+blocknm).html("");
  $("."+blocknm).load("https://"+server+"/wci/dev/SystemCheck.jsp");
}

$(document).ready(function() {
  getNotificationPermission();
  init();
  var server_to_check = ["w1.mp1.co.kr","w2.mp1.co.kr","w3.mp1.co.kr","n.mp1.co.kr"];
  for (var i=0; i<server_to_check.length; i++) {
    var blocknm = server_to_check[i].replace(/\./g, "-");
    $("li.system-status>ul").append("<li class='systemtitle'>"+server_to_check[i]+" <i class='fa-solid fa-rotate-right' onclick='loadSystemInfo(\""+server_to_check[i]+"\", this);'></i></li>");
    $("li.system-status>ul").append("<li><ul class='"+blocknm+"'></ul>");
    loadSystemInfo(server_to_check[i]);
    // $("."+blocknm).load("https://"+server_to_check[i]+"/mp/dev/SystemCheck.jsp");
  }
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(registrations => {
      if (registrations.length === 0) {
        navigator.serviceWorker.register(strContextPath +'/mgr/ServiceWorker.jsp')
          .then(reg => console.log('Service Worker registered with scope:', reg.scope))
          .catch(err => console.error('Service Worker registration failed:', err));
      } else {
        console.log('Service Worker is already registered.');
      }
    });
    /* This is an experimental feature of Chrome. It has not been adopted.
    navigator.serviceWorker.ready.then(registration => {
        registration.periodicSync.register("sync-data", {
          minInterval: 60 * 1000
        }).then(() => {
          console.log("Sync Success");
        }).catch(error => {
          console.error("Sync Fail : ", error);
        });
    });
    */
  }
});

//-->
</script>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>DASHBOARD</span>
  <span class='more'>
    
  </span>
</div>



<div>
  <ul class='work-block'>
    <li>
      <div class='block-title'><i class="fa-solid fa-chart-simple"></i> 통계</div>
      <ul class='stat'>
      <%
      if (arr!=null && arr.size()>0) {
        for (TodayStatVO v : arr) {
          if (!getKeyName(v.GUBUN, "A").equals("")) out.print("<li class='has-border'><label>"+getCodeName(v.GUBUN)+"</label><span>"+getKeyName(v.GUBUN, "A")+"</span><span>"+StrUtil.addComma(StrUtil.extractInteger(v.A))+"</span></li>");
          if (!getKeyName(v.GUBUN, "B").equals("")) out.print("<li><label></label><span>"+getKeyName(v.GUBUN, "B")+"</span><span>"+StrUtil.addComma(StrUtil.extractInteger(v.B))+"</span></li>");
          if (!getKeyName(v.GUBUN, "C").equals("")) out.print("<li><label></label><span>"+getKeyName(v.GUBUN, "C")+"</span><span>"+StrUtil.addComma(StrUtil.extractInteger(v.C))+"</span></li>");
          if (!getKeyName(v.GUBUN, "D").equals("")) out.print("<li><label></label><span>"+getKeyName(v.GUBUN, "D")+"</span><span>"+StrUtil.addComma(StrUtil.extractInteger(v.D))+"</span></li>");
        }
      }
      %>
      </ul>
    </li>
    <li class='extend'><div id="Calendar"></div></li>
    <li class='system-status'>
      <div class='block-title'><i class="fa-solid fa-server"></i> 서버현황</div>
      <ul>
      </ul>
    </li>
  </ul>
</div>

<div id="DailyScheduleCanvas"></div>
<div id="element_to_pop_up"></div>

</main>
</html>

