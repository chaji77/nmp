CKEDITOR.config.toolbar = [
  ['Bold','Italic','Underline','StrikeThrough','-','Undo','Redo','-','NumberedList','BulletedList','-','TextColor','BGColor']
];
CKEDITOR.replace("contents",{});
CKEDITOR.config.contentsCss = strContextPath + '/static/css/style.css?'+(new Date()).getTime();
CKEDITOR.config.removePlugins = 'exportpdf';