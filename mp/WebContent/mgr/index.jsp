<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
  <title><%=ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM")%> 관리자</title>
  <link rel="apple-touch-icon" href="//image.mp1.co.kr/mp/favicon.png" />
  <link rel="shortcut icon" href="//image.mp1.co.kr/mp/favicon.png" />
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/css/style.css?<%=ConfigurationMgr.getInstance().getString("RESOURCE_VERSION")%>"/>
  <script src="<%=request.getContextPath()%>/static/js/jquery-3.7.1.min.js"></script>
  <script src="<%=request.getContextPath()%>/static/js/common.js?<%=ConfigurationMgr.getInstance().getString("RESOURCE_VERSION")%>" charset="utf-8"></script>
  <script>
  $(document).ready(function(){
    $.post("<%=request.getContextPath()%>/common/UUID.jsp", function(txt) { 
      $("input[name='csrf-token']").val($.trim(txt));
    });
    $("#login_id").focus();
    $("#login_id, #login_pw").keydown(function(key) {
      if (key.keyCode == 13) login();
    });
  });

  function check() {
    var is = validate("#login_id", "length", [4,11], "아이디를 확인하세요.");
    if (is) is = validate("#login_pw", "length", [4,15], "비밀번호를 확인하세요.");
    return is;
  }
  function login() {
    if (check()) {
      showLoading();
      $.post("LoginProc.jsp", $("#frmEnt").serialize(), function(data){
        var json = JSON.parse($.trim(data));
        if (json.isSuccess) {
          location.href = "trade/index.jsp";
        } else {
          hideLoading(json.msg);
        }
      });
	}
	return false;
  }
  $(document).on('visibilitychange', function() {
    if (document.visibilityState === 'visible') {
      console.log('visibilitychanged');
      $.post("<%=request.getContextPath()%>/common/UUID.jsp", $("#frmEnt").serialize(), function(data){
        $("input[name='csrf-token']").val(data);
      });
    } else if (document.visibilityState === 'hidden') {
      //
    }
  });
  </script>
  <style>
  html {
   overflow-x:hidden;overflow-y:hidden;
   background-image: url('//image.mp1.co.kr/mp/caption.webp?<%=ConfigurationMgr.getInstance().getString("RESOURCE_VERSION")%>');
   background-position: center;
   background-size: cover;
   background-repeat: no-repeat;
  }
  ::-webkit-input-placeholder {color: #999;}
  ::-moz-placeholder {color: #999;}
  ::-moz-placeholder {color: #999;}
  ::-ms-input-placeholder {color: #999;}
  div.box {
    z-index:10;position:absolute;width:280px;left:calc(50% - 280px);top:calc(50% - 200px);
    vertical-align:middle;
    padding:60px 120px 60px 120px;
  }
  h1 {margin-bottom:30px;color:olivedrab;letter-spacing:-2px;}
  input {margin-bottom:5px;border:0;border-radius:5px;height:50px;background-color:#555;color:#fff;}
  input:focus {outline:none;background-color:#333;}
  a.btn {
    display:block;margin-top:0px;margin-bottom:5px;padding-top:16px;background-color: olivedrab;
    text-align:center;font-size:1.3em;
    border-radius:5px;height:30px;
  }
  @media only screen and (max-width:767px) {
    div.box {left:10px;top:100px;width:calc(100% - 60px);padding:30px 20px;border-radius:5px;}
  }
  div.cover {z-index:5;position:fixed;width:100%;height:100%;background-color:rgba(47, 79, 79, 0.3);}
  span.txt {line-height:160%;font-size:1.2em;margin-top:-5px;}
  span.txt>h1 {color:#777;}
  </style>

</head>
<body>

  <form id='frmEnt' autocomplete="off">
  <input type="hidden" name="csrf-token" value="" />
  <div class='box'>
    <div style='text-align:center;'><h1><%=ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM")%> 관리자</h1></div>
    <input type='text'     id="login_id" name='login_id' value='' maxlength='11' class='inp' placeholder="아이디">
    <input TYPE='password' id="login_pw" name='login_pw' value='' maxlength='15' class='inp' placeholder="비밀번호">
    <a onclick='login();' class='btn'>로그인</a>
  </div>
  </form>
  <div class='cover'></div>

</body>
</html>
