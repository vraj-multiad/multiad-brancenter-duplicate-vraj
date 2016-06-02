// dynamic_form.js
$(document).on('click', '.asset-preview-link', function(evt, data) {
  if ($(this).data('type').length > 0 && $(this).data('token').length > 0) {
    var preview = '';
    if ($(this).data('preview').length > 0) {
      preview = $(this).data('preview')
    }
    load_asset_preview($(this).data('type'), $(this).data('token'), preview);
  }
}); 

function load_asset_preview(type, token, preview) {
  // requires 'asset-preview-panel'  manual displaying of panel  due to bypassing form success hook
  var jqxhr = $.get('/asset_preview', { type: type, token: token, preview: preview }, function() {
  })
    .done(function( data ){
      $( "#asset-preview-panel" ).html( data );
      $( "#asset-preview-panel" ).show();
      $('.flowplayer').each(function(){
        $(this).flowplayer();
      });
      init_audio();
    });
}
