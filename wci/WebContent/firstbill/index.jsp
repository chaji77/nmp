<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ include file="../web/includes/Header.jsp" %>
  <title><%=ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM")%> 처음빌</title>
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
    var is = validate("#login_id", "length", [6,11], "아이디를 확인하세요.");
    if (is) is = validate("#login_pw", "length", [6,15], "비밀번호를 확인하세요.");
    return is;
  }
  function login() {
    if (check()) {
      showLoading();
      $.post("LoginProc.jsp", $("#frmEnt").serialize(), function(data){
        hideLoading();
        if (data=="0") {
          toast("등록된 정보가 없습니다. 아이디와 비밀번호를 확인하십시오.", 2000);
        } else if (data=="-1") {
          toast("잘못된 접근입니다. 페이지를 다시 불러옵니다.", 1000, function() {
            location.href = "index.jsp";
          });
        } else {
          location.href = "Standbys.jsp";
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
   background-image: url('https://image.mp1.co.kr/firstbill/blue.png?<%=ConfigurationMgr.getInstance().getString("RESOURCE_VERSION")%>');
   background-position: left;
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
  h1 {margin-bottom:30px;color:#000;letter-spacing:-2px;}
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
  #div.cover {z-index:5;position:fixed;width:100%;height:100%;background-color:rgba(203, 178, 148, 0.3);}
  span.txt {line-height:160%;font-size:1.2em;margin-top:-5px;}
  span.txt>h1 {color:#777;}
  </style>

</head>
<body>

  <form id='frmEnt' autocomplete="off">
  <input type="hidden" name="csrf-token" value="" />
  <div class='box'>
    <div style='text-align:center;'><h1><%=ConfigurationMgr.getInstance().getString("OWNER_SERVICE_NM")%> 처음빌</h1></div>
    <input type='text'     id="login_id" name='login_id' value='' maxlength='11' class='inp' placeholder="아이디">
    <input TYPE='password' id="login_pw" name='login_pw' value='' maxlength='15' class='inp' placeholder="비밀번호">
    <a onclick='login();' class='btn'>로그인</a>
    <p>&nbsp;</p>
    <!-- a href='Regist.jsp'>처음빌 회원가입</a -->
  </div>
  </form>

</body>
</html>
