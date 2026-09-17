<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>

    </div>
  </main>


  <div class='footer-nav'>
    <div class='wrapper'>
      <span><i class="fa-solid fa-phone"></i> <%=ConfigurationMgr.getInstance().getString("OWNER_TEL") %></span>&nbsp;&nbsp;&nbsp;
      <span><i class="fa-solid fa-fax"></i> <%=ConfigurationMgr.getInstance().getString("OWNER_FAX") %></span>
      <span class='more mobile_hide'>
        <a href='<%=request.getContextPath()%>/web/customer/download/Downloads.jsp'><i class="fa-solid fa-cloud-arrow-down"></i> 다운로드</a>&nbsp;&nbsp;&nbsp;
        <a href='<%=ConfigurationMgr.getInstance().getString("REMOTE_SUPPORT_URL") %>' target='_new'><i class="fa-solid fa-desktop"></i> 원격지원</a>
      </span>
    </div>
  </div>
  
  <footer>
    <div class='wrapper'>
      <span>
        <a href='<%=request.getContextPath()%>/web/customer/Privacy.jsp'>개인정보처리방침</a> | <a href='<%=request.getContextPath()%>/web/customer/Rule.jsp'>이용약관</a><br/><br/><br/>
        <span><%=ConfigurationMgr.getInstance().getString("OWNER_ADDR") %></span>
        <span><%=ConfigurationMgr.getInstance().getString("OWNER_NM") %></span>
        <span class='noseparator'>대표이사 <%=ConfigurationMgr.getInstance().getString("OWNER_CEO") %></span><br/>
        <span>사업자등록번호 : <%=ConfigurationMgr.getInstance().getString("OWNER_BIZ_NO") %></span>
        <span class='noseparator'>개인정보 관리책임자 : <%=ConfigurationMgr.getInstance().getString("OWNER_CPO") %></span><br/>
        Copyright <%=ConfigurationMgr.getInstance().getString("OWNER_COPYRIGHT") %> All rights reserved.
      </span>
      <span class='more'>
        <select name='partner' class='mobile_hide' style='width:160px;position:absolute;top:0;right:10px;' onChange="goPartnerWeb();">
          <option value="">:: 엠피원(MP1)그룹 ::</option>
          <option value="http://www.mp1.co.kr/">MP1</option> 	
          <option value="http://www.cycleloan.co.kr/">IBK 싸이클론</option>
        </select>
      </span>
    </div>
  </footer>
  <script>
  function goPartnerWeb() {
    var url=$("select[name='partner']").val();
    window.open(url, '_blank');
  }
  </script>

<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-YN2RKMR957"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-YN2RKMR957');
</script>

</body>
</html>

