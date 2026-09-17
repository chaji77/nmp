CKEDITOR.on('dialogDefinition', function (ev) {
  var dialogName = ev.data.name;
  var dialog = ev.data.definition.dialog;
  var dialogDefinition = ev.data.definition;
  if (dialogName == 'image') {
    dialog.on('show', function (obj) {
      this.selectPage('Upload'); //업로드텝으로 바로 이동
    });
  }
  dialogDefinition.removeContents( 'advanced' ); // 자세히 탭 삭제
  dialogDefinition.removeContents( 'Link' ); // 링크 탭 삭제
});
CKEDITOR.replace("contents",{
    filebrowserUploadUrl : strContextPath + '/common/UploadForCKEditor.jsp?',
});
CKEDITOR.config.contentsCss = strContextPath + '/static/css/style.css?'+(new Date()).getTime();
CKEDITOR.config.removePlugins = 'exportpdf';
