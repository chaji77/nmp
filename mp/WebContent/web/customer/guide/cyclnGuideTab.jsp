<%@ page contentType="text/html;charset=utf-8"%>
<%
/* 싸이클론 이용안내 탭. 각 페이지에서 GUIDE_TAB 속성으로 현재 탭 번호(1~4)를 지정한다. */
String guideTab = String.valueOf(pageContext.getAttribute("GUIDE_TAB"));
String[] guideTabNames = {"싸이클론 소개", "업무 흐름도", "프로세스 단계별 상세설명", "준비서류"};
String[] guideTabPages = {"cyclnGuide.jsp", "cyclnGuide_02.jsp", "cyclnGuide_03.jsp", "cyclnGuide_04.jsp"};
%>
<style>
ul.guide-tab {display:flex;flex-flow:row wrap;margin:0 0 30px 0;padding:0;list-style:none;}
ul.guide-tab>li {flex:1 1 0;}
ul.guide-tab>li a {display:block;padding:12px 5px;text-align:center;border:1px solid #ddd;border-left:0;color:#555;background-color:#fafafa;}
ul.guide-tab>li:first-child a {border-left:1px solid #ddd;}
ul.guide-tab>li a.on {color:#fff;background-color:#246CEB;border-color:#246CEB;}
div.guide-section {margin-bottom:56px;font-size:15px;line-height:1.85;word-break:keep-all;overflow-wrap:break-word;color:#333;}
div.guide-section h2 {font-size:1.35em;line-height:1.4;color:#246CEB;margin:0 0 16px 0;padding-bottom:10px;border-bottom:2px solid #e8eefb;}
div.guide-section h3 {font-size:1.1em;line-height:1.5;color:#EB6C24;margin:28px 0 10px 0;}
div.guide-section p {line-height:1.85;margin:0 0 14px 0;max-width:860px;}
div.guide-section ul {margin:0 0 14px 0;padding-left:2px;max-width:860px;list-style:none;}
div.guide-section ul>li {padding-left:14px;text-indent:-14px;margin-bottom:4px;}
div.guide-section ul>li:before {content:"- ";color:#888;}
div.guide-section table.detail {margin-top:4px;}
div.guide-section table.detail th, div.guide-section table.detail td {line-height:1.7;vertical-align:top;}
div.guide-diagram {text-align:center;margin:28px 0;}
div.guide-diagram img {max-width:100%;}
span.guide-tag {display:inline-block;min-width:38px;padding:1px 6px;margin-right:6px;border-radius:3px;font-size:0.85em;color:#fff;text-align:center;}
span.guide-tag.buy {background-color:#246CEB;}
span.guide-tag.sell {background-color:#EB6C24;}
span.guide-tag.ibk {background-color:#555;}
div.guide-section table.detail tr:hover {background-color:transparent;}
div.guide-step {border:1px solid #e0e0e0;border-radius:6px;margin-bottom:20px;overflow:hidden;}
div.guide-step>div.guide-step-head {padding:14px 18px;background-color:#f5f8ff;border-bottom:1px solid #e8eefb;font-size:1.1em;font-weight:bold;color:#246CEB;}
div.guide-step span.guide-step-no {display:inline-block;margin-right:10px;padding:2px 9px;border-radius:3px;background-color:#246CEB;color:#fff;font-size:0.8em;letter-spacing:0.05em;vertical-align:middle;}
div.guide-step>div.guide-step-cont {display:flex;flex-flow:row nowrap;align-items:flex-start;padding:22px 18px;}
div.guide-step div.guide-step-img {flex:0 0 200px;text-align:center;}
div.guide-step div.guide-step-body {flex:1 1 auto;max-width:860px;}
div.guide-step div.guide-desc {padding:5px 0 5px 56px;line-height:1.85;}
div.guide-step div.guide-path {padding:0 0 8px 56px;color:#EB6C24;}
div.guide-step span.guide-tag {margin-left:-56px;}
@media only screen and (max-width:767px) {
  ul.guide-tab>li {flex:1 1 50%;}
  ul.guide-tab>li a, ul.guide-tab>li:first-child a {border:1px solid #ddd;}
  div.guide-step>div.guide-step-cont {flex-flow:column nowrap;padding:16px 12px;}
  div.guide-step div.guide-step-img {flex:0 0 auto;width:100%;margin-bottom:10px;}
  div.guide-step div.guide-step-img:empty {display:none;}
  div.guide-step div.guide-desc, div.guide-step div.guide-path {padding-left:0;}
  div.guide-step span.guide-tag {margin-left:0;}
}
</style>
<ul class='guide-tab'>
<%
for (int i = 0; i < guideTabPages.length; i++) {
  String guideTabClass = guideTab.equals(String.valueOf(i + 1)) ? "on" : "";
%>
  <li><a href='<%=guideTabPages[i] %>' class='<%=guideTabClass %>'><%=guideTabNames[i] %></a></li>
<%
}
%>
</ul>
