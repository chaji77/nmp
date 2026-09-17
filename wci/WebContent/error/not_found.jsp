<%@ page contentType="text/html;charset=utf-8"%>
<%@ page isErrorPage="true" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.mgr.LanguageMgr" %>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
<style>
@import url('https://fonts.googleapis.com/css2?family=Gloria+Hallelujah&family=Alegreya+Sans&family=Noto+Sans+KR&display=swap');
html, body {margin:0;}
body {padding:20px;font-family:'Alegreya Sans','Noto Sans KR',sans-serif;font-size:16px;line-height:20px;color:#555;letter-spacing:-0.5px;}
div.pane {position:absolute;width:50%;left:25%;top:20%;}
div.body {border-top:1px solid #ddd;border-bottom:1px solid #ddd;padding:20px 0;font-size:1em;line-height:1.6em;}
pre {font-family:'AppleSDGothicNeo-Regular','Courier New','Noto Sans KR',sans-serif;}
h1 {color:#000;font-size:2.3em;letter-spacing:-1px;}
h1 span {font-family: 'Gloria Hallelujah', cursive;font-size:2em;}
h3 {color:#000;font-size:1.3em;padding-top:20px;letter-spacing:-1px;}
  div.center {
	  width: 100%;
	  text-align:center;
  }
  div.header {
	  border-bottom: 1px solid #ccc;
	  margin-top: 20px;
	  padding-bottom: 20px;
	  margin-bottom: 20px;	  
  }
  img.logo {
	  height: 60px;
  }
@media only screen and (max-width:767px) {
        body {font-size:0.825em;}
        div.pane {width:90%;left:5%;}
        span {padding:10px;}
        span:first-child {width:100px;}
        span:last-child {width:calc(100% - 150px);}
        span img {width:100px;}
}
#ani {
	width: 50px;
	height: 50px;
	position: relative;
	animation: leftMove 5s infinite;	
}
@keyframes leftMove {
	10% {
		transform: rotate(15deg);
	}
	50% {
		margin-left: 80%;
		transform: rotate(0);
	}
	100% {
		transform: rotate(-360deg);
	}
}
</style>
</head>
<body>

	<div class="center header"><a href='<%=ConfigurationMgr.getInstance().getString("OWNER_URL_MAIN")%>'><img src='<%=ConfigurationMgr.getInstance().getString("OWNER_URL_BI_SQUARE") %>' id='center-logo' class="logo"></a></div>


    <div class='pane'>
      <h1>페이지를 찾을 수 없습니다.</h1>
      <div class='body'>존재하지 않는 페이지입니다. 뒤로 돌아가거나 <a href='<%=ConfigurationMgr.getInstance().getString("OWNER_URL_MAIN")%>'>홈</a>으로 이동하십시오.</div>
    </div>


</body>
</html>
