<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%
String strEndDate   = DateTimeUtil.getCurrentDate("-");
String strStartDate = DateTimeUtil.diff(strEndDate, 31, "-");
%>
<script>

  var NEWVER = "1.0.8.0";

  function getXMLHttpRequest() {
    if(window.AciveXObject) return new ActiveXObject("Microsoft.XMLHTTP");
    else if (window.XMLHttpRequest) return new XMLHttpRequest();
    else return new ActiveXObject("Msxml2.XMLHTTP");
    return null;
  }

  function StartServer() {
    var arg = "aldsvr://start?projcode=aldis&cmpid=aldisfs&cid=aldisuser";
    var iframe = "<iframe style='width:0;height:0;border:0;' src='" + arg + "'></iframe>";
    $("#tax-scrap-module").append(iframe);
  }

  function Startscraping() {
    $("#tax-wait-load span").text("국세청 세금계산서 가져오기 도구를 불러오고 있습니다. 잠시만 기다려주세요.");
    $("#tax-wait-load").show();
    document.getElementById("result_string").value = "";
    var start  = $("#TaxStartYmd").val().replace("-", "").replace("-", "");
    var end    = $("#TaxEndYmd").val().replace("-", "").replace("-", "");
    if (start > end) {
      toast("조회 종료일자가 시작일자보다 이전일 수 없습니다.");
      return;
    }
    var aOwner = $("input[name='aOwner']:checked").val();
    console.log(aOwner);

    var junmun = "<sCode>102</sCode><sName>전자세금계산서목록조회</sName><bCode>902</bCode><bType>B</bType><bName>e세로</bName><Idx>1</Idx>";
    junmun    += "<aNumber>"+$("#aNumber").val()+"</aNumber><aType>0</aType><aName></aName>";
    junmun    += "<aOwner>"+aOwner+"</aOwner>"; // 전자세금계산서(0), 전자계산서(1)
    junmun    += "<saName></saName><saNumber></saNumber><sToMemo>1</sToMemo>";
    junmun    += "<loginType>1</loginType>"; // 인증서로그인
    junmun    += "<abCert></abCert><abCertPass></abCertPass>";
    junmun    += "<abID></abID><abPwd></abPwd><uIDNum></uIDNum>";
    junmun    += "<sStartDate>"+start+"</sStartDate><sEndDate>"+end+"</sEndDate>";
    junmun    += "<sFromMemo>1</sFromMemo><fSkipOutput>0</fSkipOutput><fSkipInput>0</fSkipInput>";
    junmun    += "<projName>gyc</projName><projCode>gyc</projCode>";
    junmun    += "<userID>7867</userID>";

    var dd = Date.now();
    var key = "key" + dd;
    var itemkey1 = "item1" + dd;

    var loading = document.getElementById("loading").value;
    var isenc = document.getElementById("isenc").value;

    var post = "<SINFO>\n<cmpid>aldisfs</cmpid>\n<cid>aldis</cid>\n<key>" + key + "</key>\n<count>1</count>\n<projcode>aldis</projcode>\n<exhead>여분필드(헤더)</exhead>\n<timeout>300</timeout>\n<isenc>" + isenc + "</isenc>\n<args>\n<rec_0>\n<itemkey>" + itemkey1 + "</itemkey>\n<svccode>bank</svccode>\n<extraret>여분필드</extraret>\n<extraret1>여분필드1</extraret1>\n<extraret2>여분필드2</extraret2>\n<extraret3>여분필드3</extraret3>\n<junmun>" + junmun + "</junmun>\n</rec_0>\n</args>\n</SINFO>";
    document.getElementById("request_string").value = post;

    var url = 'https://127.0.0.1:13464/serverrequest.html?cmd=startscraping&progress=' + loading + '&dt=' + Date.now();
    var req = getXMLHttpRequest();
    req.onreadystatechange = function() {
      $("#tax-wait-load span").text("국세청 세금계산서 가져오기 도구를 실행하고 있습니다.");
      if (req.readyState == 4 && req.status == 200) {
        if (req.responseText.indexOf('<XMLDATA>') > -1 && req.responseText.indexOf('<LIST>') > -1) {
          $("#tax-wait-load span").text("선택하신 세금계산서를 저장하고 있습니다. 잠시만 기다려주세요.");
          document.getElementById("result_string").value = req.responseText.split('<XMLDATA>')[1].split("</XMLDATA>")[0];
          progressView('on');
          saveXml();
        } else {
          if (req.responseText.indexOf('<result>') > -1) {
            $("#tax-wait-load span").text("");
            showAlert(req.responseText.split('<result>')[1].split("<aNumber>")[0].replace(/[0-9-]/g, '').split("file")[0], function() {
              progressView("off");
            });
          }
        }
      }
    }
    req.open("POST", url, true);
    req.send(post);
  }

  function saveXml() {
    document.frmEnt.action = "BillAddProc.jsp";
    document.frmEnt.method = "post";
    document.frmEnt.target = "work";
    document.frmEnt.submit();
  }
  // callback from BillAddProc.jsp
  function savedXml(intTotal, intDuplicatedCnt, strErrorMsg) {
    /*
    console.log("savedXml");
    console.log(intTotal);
    console.log(intDuplicatedCnt);
    */
    progressView('off');
    if ($.trim(strErrorMsg).length==0) {
      if (intTotal == intDuplicatedCnt) showAlert("이미 첨부한 전자세금계산서입니다.");
      else {
        if (intDuplicatedCnt==0) showAlert(intTotal + "건의 전자세금계산서를 첨부하였습니다.");
        else showAlert("이미 첨부한 " + intDuplicatedCnt +"건의 전자세금계산서를 제외한 " + (intTotal - intDuplicatedCnt)  + "건의 전자세금계산서를 첨부하였습니다.");
      }
    } else {
    	showAlert(strErrorMsg);
    }
    document.getElementById("result_string").value = "";
    closePopup();
    reloadBills();
  }

  function Stopscraping(kind){
    document.getElementById("result_string").value = "";
    var dd = Date.now();
    var key = "key" + dd;
    var itemkey = "item" + dd;

    var cmd = "stopscraping";
    if(kind == "all") cmd = "stopallscraping";
    var post = "<SINFO>\n<cmpid>aldisfs</cmpid>\n<cid>aldis</cid>\n<key>" + key + "</key>\n<count>1</count>\n<projcode>aldis</projcode>\n<exhead>여분필드(헤더)</exhead>\n<timeout>300</timeout>\n<args>\n</args>\n</SINFO>";
    var url =  'https://127.0.0.1:13464/serverrequest.html?cmd=' + cmd + '&dt=' + Date.now();
    var req = getXMLHttpRequest();
    req.onreadystatechange = function() {
      if (req.readyState == 4 && req.status == 200) {
        document.getElementById("result_string").value = req.responseText;
      }
    }
    req.open("POST", url, true);
    req.send(post);
  }

  var timer;

  function getver(){
    document.getElementById("result_string").value = "";
    var dd = Date.now();
    var key = "key" + dd;
    var itemkey = "item" + dd;

    var post = "<SINFO>\n<cmpid>aldisfs</cmpid>\n<cid>aldis</cid>\n<key>" + key + "</key>\n<count>1</count>\n<projcode>aldis</projcode>\n<exhead>여분필드(헤더)</exhead>\n<timeout>300</timeout>\n<args>\n</args>\n</SINFO>";

    var url =  'https://127.0.0.1:13464/serverrequest.html?cmd=getver&dt=' + Date.now();
    var req = getXMLHttpRequest();
    req.onreadystatechange = function() {
      if (req.readyState == 4) {
        if (req.status == 200) {
          if (req.responseText.indexOf('<result>') > -1) {
            var text = req.responseText.split('<result>')[1].split("</result>")[0];
            if (!window.DOMParser) {
              xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
              xmlDoc.async = "false";
              xmlDoc.loadXML(text);
            } else {
              parser   = new DOMParser();
              xmlDoc   = parser.parseFromString(text, "text/xml");
            }
            ver  = xmlDoc.getElementsByTagName("MSG")[0].childNodes[0].nodeValue;
            if (NEWVER != ver) getNewVersion();
            else {
              hideVersion();
            }
          }
        } else {
          getNewVersion();
        }
      }
    }
    req.open("POST", url, true);
    req.send(post);
  }

  function getNewVersion() {
    wait();
    $("#tax-wait-load").hide();
    $("#tax-search-box").hide();
    $("#program-download").show();
  }

  function hideVersion() {
    clearTimeout(timer);
    $("#tax-wait-load").hide();
    $("#tax-search-box").show();
    $("#program-download").hide();
  }

  function wait() {
    timer = setTimeout(getver, 3000);
  }

  function base64_encode(str) {
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function(match, p1) {
      return String.fromCharCode('0x' + p1);
    }));
  }

  function RunBase64(){
    var junmun1 = document.getElementById("junmun_string1").value;
    document.getElementById("isenc").value = "1";
    document.getElementById("junmun_string1").value = base64_encode(junmun1);
  }

  function progressView(type){
    if (type=="on") showLoading();
    else {
      $("#tax-wait-load").hide();
      hideLoading();
    }
  }

  $(document).ready(function() {
    getver();
  });
  
</script>

<div style='background-color:white;padding:40px 20px 20px 20px;min-width:370px;'>
  <!-- load engine -->
  <div id='tax-scrap-module'></div>
  <!-- title -->
  <p style='text-align:center;font-size:1.3em;'><strong>홈텍스 신고자료 가져오기</strong></p>
  <!-- search -->
  <ul id='tax-search-box' style='margin-top:40px;margin-left:20px;display:none;'>
    <li style='margin-bottom:10px;'>
      <label style='width:80px;'>거래구분</label>
      <input type="radio" name="aOwner" id="aOwner_1" value="0" checked> 전자세금계산서
      <input type="radio" name="aOwner" id="aOwner_2" value="1"> 전자계산서
    </li>
    <li style='margin-bottom:10px;'>
      <label style='width:80px;'>작성일자</label>
      <input type='date' name='TaxStartYmd' id='TaxStartYmd' style='width:100px;' value='<%=strStartDate%>'> ~ 
      <input type='date' name='TaxEndYmd' id='TaxEndYmd' style='width:100px;' value='<%=strEndDate%>'>
    </li>
    <li>
      <label style='width:80px;'></label>
      <a onclick='Startscraping()' class='btn'>조회</a>
    </li>
  </ul>
  <!-- download -->
  <div id='program-download' style='display:none;text-align:center;margin-top:80px;'>
    <a href='<%=request.getContextPath() %>/static/programs/AldServer_setup.exe' target='_new' class='btn lurian' style='padding:10px 15px;'>세금계산서 가져오기 도구 다운로드</a>
  </div>
  <!-- wait -->
  <div id='tax-wait-load' style='text-align:center;color:darkgreen;padding:10px;margin-top:40px;'><i class="fa fa-spinner" style='animation: rotate_loading .8s linear infinite;'></i> &nbsp; <span></span></div>
  <!-- close -->
  <div style='text-align:center;margin-top:50px;margin-bottom:10px;'><i class="fa-solid fa-xmark" onclick='hideVersion();closePopup();' style='cursor:pointer;font-size:2em;'></i></div>
</div>