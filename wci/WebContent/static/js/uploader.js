const ENV_SEPARATOR = "____________________";
const DIV_DRAGDROP  = "#dragandrophandler";
const DIV_DRAGTEXT  = "#dragtext";
const DIV_FIELS     = "#div_attach_file";
const UL_FILES      = "#ul_attached_files";
const FORM_UPLOAD   = "#frmAddFile";
var   UPLOAD_URL    = "UploadFileProc.jsp";
var   DRAGDROP_UPLOAD_AT  = ".dragdropplace";
var   DRAGDROP_UPLOAD_URL = "DragUploadFileProc.jsp";
var   O_FILES;
var   isFileUploading = false;

function initUploadForm(urlUpload, urlDragDrop, oFiles) {
  UPLOAD_URL    = urlUpload;
  DRAGDROP_UPLOAD_URL = urlDragDrop;
  O_FILES = oFiles;

  uploadPopupLayer();
  dragdropLayer();

  $(".openUploadPopup").on("click", function(){
    openAddFileForm();
  });

  var obj = $(DIV_DRAGDROP);
  obj.on('dragenter', function(e) {
    e.stopPropagation();
    e.preventDefault();
    $(this).css('border', '2px solid #0B85A1');
  });
  obj.on('dragover', function(e) {
     e.stopPropagation();
     e.preventDefault();
  });
  obj.on('drop', function(e) {
     $(this).css('border', '1px dotted #0B85A1');
     e.preventDefault();
     var files = e.originalEvent.dataTransfer.files;
     handleFileUpload(files,obj);
  });
  $(document).on('dragenter', function(e) {
    e.stopPropagation();
    e.preventDefault();
  });
  $(document).on('dragover', function(e) {
    e.stopPropagation();
    e.preventDefault();
    obj.css('border', '2px dotted #0B85A1');
  });
  $(document).on('drop', function(e) {
    e.stopPropagation();
    e.preventDefault();
  });

  var file_cnt = 0;
  $("input[id='file']").each(function(){
    file_cnt++;
  });
  if (file_cnt==0 && $(window).width()>1024) {
    $(DIV_DRAGTEXT).show();
  } else {
    $(DIV_DRAGTEXT).hide();
  }
}

function dropFile() {
  $("input[id='file']:checked").each(function(){
    $(this).parent().remove();
  });
  var file_cnt = 0;
  $("input[id='file']").each(function(){
    file_cnt++;
  });
  if(file_cnt==0) $(DIV_DRAGTEXT).show();
}

function dropAllFile() {
var file_cnt = 0;
  $("input[id='file']").each(function(){
    file_cnt++;
  });
  if(file_cnt>0) {
    showCustomConfirm("모두 삭제하시겠습니까?", 
      function() {
        $("input[id='file']").each(function(){
          $(this).parent().remove();
        });
        $(DIV_DRAGTEXT).show();	
      }, function() {
	    //
      }
    );
  }
}

function openAddFileForm() {
  $(DIV_FIELS).show();
  $("#attachfile").click();
  return;
}

function uploadOneFile(e) {
  var dt = e.dataTransfer || (e.originalEvent && e.originalEvent.dataTransfer);
  var files = e.target.files || (dt && dt.files);
  handleFileUpload(files);
}

function closeAddFileForm() {
  $(".loading").remove();
  removePopupMessage();
  $(DIV_FIELS).hide();
}

function dropUploadedFile(o) {
  $(o).parent().remove();
}

function callbackAddedFile(strFilePath, strFileSize) {
  closeAddFileForm();
  if (strFilePath=="") {
    toast("업로드하지 못했습니다.", 3600);
  } else {
    var arrFileName = strFilePath.split("/");
    var strFileName = arrFileName[arrFileName.length-1];

    $(DIV_DRAGTEXT).hide();
    $(UL_FILES).append("<li><input type='checkbox' name='file' id='file' value='"+strFilePath+ENV_SEPARATOR+strFileSize+"'><a href='" + strFilePath + "' target='_new'>" + strFileName +"</a> <i class='fa-solid fa-trash' onclick='dropUploadedFile(this);' style='cursor:pointer;'></i></li>");
    $(FORM_UPLOAD)[0].reset();
  }

  $(".cover-all-in-progress").remove();
  $(".result-message").remove();
  isFileUploading = false;
}

function getCountCheckedNode() {
  var intCnt = 0;
  $("input[id='file']:checked").each(function(){
    intCnt++;
  });
  return intCnt;
}

function sendFileToServer(formData,status) {
  var uploadURL = DRAGDROP_UPLOAD_URL;
  var extraData ={};
  var jqXHR=$.ajax({
      xhr: function() {
      var xhrobj = $.ajaxSettings.xhr();
      if (xhrobj.upload) {
          xhrobj.upload.addEventListener('progress', function(event) {
            var percent = 0;
            var position = event.loaded || event.position;
            var total = event.total;
            if (event.lengthComputable) {
              percent = Math.ceil(position / total * 100);
              showProcess(percent);
            }
          }, false);
        }
      return xhrobj;
    },
    url: uploadURL,
    type: "POST",
    contentType:false,
    processData: false,
    cache: false,
    data: formData,
    success: function(data){
      data = JSON.parse(data);
      var FILE_PATH	  = data[0].FILE_PATH;
      var FILE_SIZE	  = data[0].FILE_SIZE;
      callbackAddedFile(FILE_PATH, FILE_SIZE);
    },
    error: function(err) {
      callbackAddedFile("", 0);
    }
  });
}

function showProcess(percent) {
  if (percent>99) {
    $(".result-message").html("업로드되었습니다.");
    $(".btnUpload").show();
  } else {
    $(".btnUpload").hide();
    if (isFileUploading) {
      $(".result-message").html("<img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAUCAIAAADDbMD2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAQSURBVBhXY/hfr049XK8OADUbIOVS2YnbAAAAAElFTkSuQmCC' width='"+(percent*2)+"' height='20'> "+percent+"%");
    } else {
      $("body").append("<div class='cover-all-in-progress'></div>");
      $("body").append("<div class='result-message'><img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAUCAIAAADDbMD2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAQSURBVBhXY/hfr049XK8OADUbIOVS2YnbAAAAAElFTkSuQmCC' width='"+(percent*2)+"' height='20'> "+percent+"%</div");
      $(".result-message").css({"top":(($(window).height()-$('.result-message').outerHeight())/2+$(window).scrollTop())+"px"});
      $(".result-message").css("padding", "30px");
      $(".result-message").show();
      isFileUploading = true;
    }
  }
}

function handleFileUpload(files,obj) {
  for (var i = 0; i < files.length; i++) {
    if (files[i].name.indexOf(".exe")>-1 || files[i].name.indexOf(".bat")>-1 || files[i].name.indexOf(".dll")>-1 || files[i].name.indexOf(".app")>-1 ||
      files[i].name.indexOf(".ocx")>-1 || files[i].name.indexOf(".sys")>-1 || files[i].name.indexOf(".scr")>-1 ||
      files[i].name.indexOf(".com")>-1 || files[i].name.indexOf(".sh")>-1  || files[i].name.indexOf(".js")>-1) {
      toast(files[i].name + " 파일은 허용하지 않는 파일형식입니다.", 3000);
      break;
    } else {
      var fd = new FormData();
      fd.append('file', files[i]);
      sendFileToServer(fd,status);
    }
  }
}

function uploadPopupLayer() {
  var html = "<div id='div_attach_file' style='display:none;position:absolute;border:solid 5px #555;border-radius:10px;background-color:white;width:300px;left:calc(50% - 180px);top:460px;height:100px;z-index:401;padding:20px;'>";
  html += "<div class='attachinBox'>";
  html += "<form name='frmAddFile' id='frmAddFile' target='ifrm' method='post' enctype='multipart/form-data' action='"+UPLOAD_URL+"'>";
  html += "<input type='file' name='attachfile' id='attachfile' multiple='multiple' onChange='uploadOneFile(event);' style='width:280px;' accept='.txt,.doc,.docx,.pdf,.xls,.xlsx,.ppt,.pptx,.hwp,.zip,.gz,image/*,audio/*,video/*,text/*,'>";
  html += "</form>";
  html += "</div>";
  html += "<div class='attachMsg' style='margin-top:5px;margin-bottom:-15px;color:#f77;'></div>";
  html += "<div class='attachinBtn' style='margin-top:20px;text-align:center;padding-top:20px;border-top:1px solid #ddd;'><a onclick='uploadOneFile();' class='btn darkgreen btnUpload'>업로드</a> <a onclick='closeAddFileForm();' class='btn btnUpload'>닫기</a></div>";
  html += "<iframe name='ifrm'></iframe>";
  html += "</div>";
  $("body").append(html);
}

function dragdropLayer() {
  var html = "<div style='height:24px;'><a class='openUploadPopup btn'>파일첨부</a> &nbsp;<a onClick='dropFile();' class='btn'>파일삭제</a> &nbsp;<a onClick='dropAllFile();' class='btn'>모두삭제</a></div>";
  html += "<div id='dragandrophandler'>";
  html += "<div id='dragtext' class='mobile_hide'>마우스로 파일을 끌어오세요.</div>";
  html += "<ul id='ul_attached_files'>";
  if (O_FILES!=null && O_FILES.length>0) {
    for (var i=0; i<O_FILES.length; i++) {
      html += "<li><input type='checkbox' name='file' style='border:none;' id='file' value='"+ O_FILES[i][0] + ENV_SEPARATOR + O_FILES[i][2] + "'><a href='"+ getLinkUrl(O_FILES[i][0]) +"' target='_new'>"+O_FILES[i][1]+"</a> ("+O_FILES[i][3]+" KB)</li>";
    }
  }
  html += "</ul>";
  html += "</div>";
  html += "<div class='mobile_hide'><img src='data:image/gif;base64,R0lGODlhDQANANUAAAAAAP///+yhl/fa1vfc2NxKONxMO9xOPd9bS99dTeBfT+BhUuBkVOJuYOR5a+aDd+eFeeiJfuiMgOmSh+qUieqWjOuakOyfleyjmu2nnu6tpe+vqO+yqvbTz/je2/35+f37+/7+/v///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAACIALAAAAAANAA0AAAZfwJDQA0kUEhCPUPjJHApQ6CEDElaijsEjWgl1ooVNiAPuRMCXEAYcMUYlIQo48cSGIOCDG7oYNOZnUQkWDGxfURghGmUhE1EKF4VQE0wCBmAFBgIfSyEEEAgFCBAES0EAOw==' style='width:13;height:13;vertical-align:middle;'> 첨부파일을 삭제하시려면 해당 파일을 선택 후 '파일삭제'를 클릭하세요.</div>";
  $(DRAGDROP_UPLOAD_AT).html(html);
}


function getLinkUrl(str) {
	return replaceAllForUrl(replaceAllForUrl(replaceAllForUrl(encodeURIComponent(str), "%2F", "/"), "\\+", "%20"), "amp%3B", "");
}

function replaceAllForUrl(str, searchStr, replaceStr) {
	return str.split(searchStr).join(replaceStr);
}
