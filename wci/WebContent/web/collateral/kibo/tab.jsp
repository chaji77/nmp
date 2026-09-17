<%@ page contentType="text/html;charset=utf-8"%>
<style>
ul.guarantor-tab {display:flex;flex-flow:row wrap;justify-content:left;margin-top:20px;}
ul.guarantor-tab li {padding:10px 20px;border:1px solid #bbb;border-left:0;background-color:#eee;}
ul.guarantor-tab li:first-child {border-left:1px solid #bbb;}
ul.guarantor-tab li.on {background-color:#fff;border-bottom:1px solid transparent;}
ul.guarantor-tab li.blank {border:1px solid transparent;border-bottom:1px solid #bbb;background-color:transparent;flex-grow:1;}
ul.guarantor-tab li.clickable {cursor:pointer;}

ul.collateral-menus {display:flex;flex-flow:row wrap;justify-content:center;margin-top:10px;}
ul.collateral-menus li {margin:10px;}
</style>
<script>
function guarantor(t) {
  location.href = "<%=request.getContextPath()%>/web/collateral/"+t+"/";
}
</script>
<ul class='guarantor-tab'>
  <li class='clickable' onclick="guarantor('kodit');">신용보증기금</li>
  <li class='on clickable' onclick="guarantor('kibo');">기술보증기금</li>
  <li class='blank'></li>
</ul>

<ul class='collateral-menus'>
  <li><a href='index.jsp'>보증신청현황</a></li>
  <li><a href='Limit.jsp'>보증서/한도관리</a></li>
  <li><a href='Condition.jsp'>조건변경서</a></li>
</ul>