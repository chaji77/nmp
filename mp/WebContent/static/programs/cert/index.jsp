<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%
String strssn = request.getParameter("ssn");
if (strssn==null || strssn.equals("")) strssn = "6078621116";
String ref = StrUtil.nvl(request.getHeader("REFERER"));
if (ref.indexOf("localhost")>-1 || ref.indexOf("mp1.co.kr")>-1) {
} else {
%>
<script>
  parent.toast("<font color='red'>전자서명을 실행할 수 없습니다.</font><br/>허용하지 않는 도메인에서 호출되었습니다.", 2000, function() {
    parent.closePopup();
  });
</script>
<%
  return;
}
%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv='X-UA-Compatible' content='IE=edge' />
    <meta http-equiv="Cache-control" content="no-cache">
    <meta http-equiv="Pragma" content="no-cache">
    <title></title>
    <!-- KICA SecuKit NXS -->
    <link rel="stylesheet" type="text/css" href="../SecuKitNXS/WebUI/css/base.css?2024" />
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Reddit+Sans+Condensed:wght@200..900&display=swap');
    @import url(https://cdn.jsdelivr.net/gh/eunchurn/NanumSquareNeo@0.0.6/nanumsquareneo.css);
    html, body {margin:0;padding:0;background-color:transparent;}
    body, .nx-pki-ui-wrapper {font-family:'Reddit Sans Condensed', 'NanumSquareNeo', 'AppleSDGothicNeo-Regular', sans-serif;}
    a.btnDownLoad {text-decoration:none;padding:4px 12px 4px 10px;color:#fff;background-color:#555;border-radius:2px;font-size:0.9em;transition:background-color .2s ease-in-out;}
    a.btnDownLoad:hover {background-color:#000;}
    </style>
    <script type="text/javascript" src="../SecuKitNXS/WebUI/js/jquery-1.8.2.min.js"></script>
    <script type="text/javascript" src="../SecuKitNXS/KICA/config/nx_config.js?<%=DateTimeUtil.getCurrentResourceVersion() %>"></script>
    <script type="text/javascript" src="../SecuKitNXS/KICA/config/LoadSecukitnx.js"></script>
    <script type="text/javascript">
        window.onload = function () {
            // KICA WebUI append
            $('#KICA_SECUKITNXDIV_ID').append(KICA_SECUKITNXDIV);
            secunx_Loading();
        };
        function SecuKitNX_Ready(res) {
            if (res) {
              get_certInfo();
            } else {
              $("div.divDownLoad").show();
              alert("다운로드가 완료되면 설치 후 재실행하십시오.");
              window.parent.postMessage("CLOSE", '*');
              infoTxtInit();
            }
        }

        // 함수 호출 결과값 리턴
        function SecuKitNXS_RESULT(cmd, res) {
            // Error Check
            var Err = 999;
            try {
                Err = res.ERROR_CODE;
            } catch (e) {
                console.log(e);
            }
            if (Err === undefined) {

                // cmd : 호출 함수명, res : 결과값(obj)
                var val = null;
                switch (cmd) {
                    // 인증서 정보 추출
                    case 'Get_CertInfo':
                        var certType = 'SignCert';                                               // 서명용 : SignCert, 암호화용 : EncryptCert
                        var certID = certListInfo.getCertID();                                   // 선택된 인증서 ID

                        var isViewVID = '1';													 // 0 : VID 추출 안함,  1 : VID 추출
                        var cmd = 'Get_CertInfo_Result.viewCertInfomationWithVID';
                        var Data = {
                            'certType': certType,
                            'certID': certID,
                            'isViewVID': isViewVID
                        };
                        var param = JSON.stringify(Data);
                        secukitnxInterface.SecuKitNXS(cmd, param);
                        break;

                        // 인증서 정보 추출 결과
                    case 'Get_CertInfo_Result':

                        var userDN                      = res.userDN;
                        var encryptCertPEM              = res.encryptCertPEM;
                        var certPEM                     = res.certPEM;
                        if (certPEM=="") certPEM = encryptCertPEM;
                        document.getElementById('SIGN').value = "$dn=" + userDN + "$data="+$.trim(certPEM.replace(/\n/gi, "").replace("-----BEGIN CERTIFICATE-----", "").replace("-----END CERTIFICATE-----", ""));

                        var ssn = document.getElementById('SSN').value;     // 신원확인 정보 ( 개인 : 주민등록번호, 사업자 : 사업자번호)
                        var certID = certListInfo.getCertID();              // 선택된 인증서 ID

                        var cmd = 'Check_SSN_Result.verifyVID';
                        var Data = {
                            'ssn': ssn,
                            'certID': certID
                        };
                        var param = JSON.stringify(Data);
                        secukitnxInterface.SecuKitNXS(cmd, param);
                        break;

                    case 'Check_SSN_Result':
                        callbackSignValue();
                        break;

                    default: break;
                }

            } else {
                // Error Message 출력
                infoTxtInit();
                $('.nx-cert-select').hide(); $('#nx-pki-ui-wrapper').hide(); KICA_Error.init();
                KICA_Error.setError(res.ERROR_CODE, res.ERROR_MESSAGE);
                var errorMsg = KICA_Error.getError();
                window.parent.postMessage("CLOSE_FAIL_SSN", '*');

            }
        }

        function clearCertInfo(certID) {
            infoTxtInit();
            //메모리에 저장된 인증서 clear
            try {
                var certID = certListInfo.getCertID();
                NXinitCert(certID);
            } catch (e) { console.log(e); }
        }

        function get_certInfo() {
            infoTxtInit();

            //로직 구분
            processLogic.init();
            processLogic.setProcessLogic('Get_CertInfo');

            // 인증서 선택창 호출
            NX_ShowDialog();

            /* 취소버튼에 이벤트추가 */
            $("button.btn-cancel").on("click", function() {
                window.parent.postMessage("CLOSE", '*');
                infoTxtInit();
            });


        }

        function check_cert_owner() {
            //로직 구분
            processLogic.init();
            processLogic.setProcessLogic('Check_SSN');

            // 인증서 선택창 호출
            NX_ShowDialog();
        }

        function infoTxtInit() {
          document.getElementById('SIGN').value = "";
        }

        /* 부모창과 통신 */
        function callbackSignValue() {
          window.parent.postMessage(document.getElementById('SIGN').value, '*');
          infoTxtInit();
        }
        window.addEventListener("message", function(e) {
          console.log(e.origin);
        });

        function download() {
            $.fileDownload("../SecuKitNXS/Install/SecuKitNXS.exe").done(function() {
              window.parent.postMessage("CLOSE", '*');
                infoTxtInit();
            });

        }


    </script>
    <!-- //KICA SecuKit NXS -->
  </head>
  <body>

    <div id="KICA_SECUKITNXDIV_ID"></div>
    <input type="hidden" value="<%=strssn %>" id="SSN" name="SSN" />
    <input type="hidden" value="" id="SIGN" name="SIGN" style='width:100%;'>
    <div class='divDownLoad' style='padding:60px;text-align:center;display:none;'>
      <a href="javascript:download();" class='btnDownLoad'>전자서명도구 수동 다운로드</a>
    </div>
  </body>
</html>
