$(function()  {

//// shared-page asset preview

  //Asset Detail panel
  $(document).on('ajax:success', 'form[data-shared-page-asset-preview-panel]', function(evt, data) {
    var target = $(this).data('shared-page-asset-preview-panel');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
    $('.flowplayer').each(function(){
      $(this).flowplayer();
    });
    $('.flowplayer').each(function(){
      $(this).flowplayer();
    });
    init_audio();
  });

  //Asset Detail panel
  $(document).on('ajax:success', 'form[data-shared-page-asset-detail-display]', function(evt, data) {
    var target = $(this).data('shared-page-asset-detail-display');
    $('#' + target).html(data);
    $('#shared-page-asset-detail-contents').fadeIn();
    $('.flowplayer').each(function(){
      $(this).flowplayer();
    });
    init_audio();
  });

//// admin-panel replacement
// admin filters
  $(document).on('ajax:success', 'form[data-admin-asset-keywords]', function(evt, data) {
    var target = $(this).data('admin-asset-keywords');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
// admin users
  $(document).on('ajax:success', 'form[data-admin-users]', function(evt, data) {
    var target = $(this).data('admin-users');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
  // admin users expire
  $(document).on('ajax:success', 'form[data-admin-user-expire]', function(evt, data) {
    var target = $(this).data('admin-user-expire');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
  // admin users reset password
  $(document).on('ajax:success', 'form[data-admin-user-reset-password]', function(evt, data) {
    var target = $(this).data('admin-user-reset-password');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
  // admin users edit
  $(document).on('ajax:success', 'form[data-admin-user-edit]', function(evt, data) {
    var target = $(this).data('admin-user-edit');
    $('#' + target).html(data);
    $('#admin-user-edit-contents').fadeIn();
  });

  // admin users save
  $(document).on('ajax:success', 'form[data-admin-user-save]', function(evt, data) {
    var target = $(this).data('admin-user-save');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });

  // admin approve_document
  $(document).on('ajax:success', 'form[data-admin-approve-document]', function(evt, data) {
    var target = $(this).data('admin-approve-document');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });

  // admin approve_order
  $(document).on('ajax:success', 'form[data-admin-approve-order]', function(evt, data) {
    var target = $(this).data('admin-approve-order');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });

  // admin approve_user
  $(document).on('ajax:success', 'form[data-admin-approve-user]', function(evt, data) {
    var target = $(this).data('admin-approve-user');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });

  $(document).on('ajax:success', 'form[data-dl-images-add-to-library]', function(evt, data) {
    $('form#asset_group_admin_keywords_form').submit();
    $('div#categorize-contents').fadeIn("slow");
  });

  //Search filters replace
  $(document).on('ajax:success', 'form[data-update-search-filters]', function(evt, data) {
    var target = $(this).data('update-search-filters');
    $('#' + target).html(data);
  });

  //Search replace results
  $(document).on('ajax:success', 'form[data-update-search]', function(evt, data) {
    var target = $(this).data('update-search');
    $('#' + target).html(data);
  });

  //Replace Share panel
  $(document).on('ajax:success', 'form[data-share]', function(evt, data) {
    var target = $(this).data('share');
    $('#' + target).html(data);
    if ($('#no_shareable_items').length) {
      alert($('#no_shareable_items').html());
      $('#' + target).html('');
    }
  });
  $(document).on('ajax:success', 'form[data-process-share]', function(evt, data) {
    var target = $(this).data('process-share');
    $('#' + target).html(data);
    if ($('#social_media_auto_refresh').length) {
      setTimeout( function() {$('form#social_media_auto_refresh').submit();
      }, 700);
    }
  });

  //Init Categorize panel
  $(document).on('ajax:success', 'form[data-categorize-init]', function(evt, data) {
    // var target = $(this).data('categorize');
    // var target = $(this).data('categorize');
    runSearchForm();
  });

  //Replace Categorize panel
  $(document).on('ajax:success', 'form[data-categorize]', function(evt, data) {
    var target = $(this).data('categorize');
    $('#' + target).html(data);
  });

  //Replace panel-admin-advanced
  $(document).on('ajax:success', 'form[data-panel-admin-advanced]', function(evt, data) {
    var target = $(this).data('panel-admin-advanced');
    if (data.length > 1) {
      $('#' + target).html(data);
      asset_admin_advanced_open();
    }
    else {
      $('form#admin-admin-advanced-refresh').submit();
      asset_admin_advanced_close();
    }
  });

  //Replace admin-advanced-asset
  $(document).on('ajax:success', 'form[data-admin-advanced-asset]', function(evt, data) {
    var target = $(this).data('admin-advanced-asset');
    $('#' + target).fadeOut();
    $('#' + target).html(data);
    $('#' + target).fadeIn();
    initDatepicker();
  });

  //Replace asset_group admin keyword_types section
  $(document).on('ajax:success', 'form[data-admin-keyword-types]', function(evt, data) {
    var target = $(this).data('admin-keyword-types');
    $('#' + target).html(data);
  });

  //Asset Detail panel
  $(document).on('ajax:success', 'form[data-asset-preview-panel]', function(evt, data) {
    var target = $(this).data('asset-preview-panel');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
    $('.flowplayer').each(function(){
      $(this).flowplayer();
    });
    init_audio();
  });


  //Asset Detail panel
  $(document).on('ajax:success', 'form[data-asset-detail-display]', function(evt, data) {
    var target = $(this).data('asset-detail-display');
    $('#' + target).html(data);
    $('.flowplayer').each(function(){
      $(this).flowplayer();
    });
    init_audio();
  });


  // Launch AdCreator - fade out normal content and fade in AdCreator
  $(document).on('ajax:success', 'form[data-update-adcreator]', function(evt, data) {
    var target = $(this).data('update-adcreator');
    $('#' + target).html(data);
    $('#main-contents').fadeOut();
    $('#adcreator_set_spread').val(1);
    $('#adcreator-panel').addClass('active').fadeIn(); // Adds class 'active' to allow for lockAspect() to function
    lock_steps();
    setTemplateSize(); // Sets initial template size based on data attributes
    setTextScale(); // Sets any font scaling
    keepTemplateRatio(); // Locks the aspect ratio for vertical scaling
    $('.chosen-select').each( function() {
      var placeholder_text_single = $(this).data('placeholder-text-single');
      var no_results_text = $(this).data('no-results-text');
      $(this).chosen({placeholder_text_single: placeholder_text_single, no_results_text: no_results_text, width: '100%'});
    });
  });

  // Load adcreator div need to mimic process setp refresh cycle
  $(document).on('ajax:success', 'form[data-load-saved-ad]', function(evt, data) {
    var target = $(this).data('load-saved-ad');
    $('#' + target).html(data);
    $('#main-contents').fadeOut();
    $('#adcreator-panel').addClass('active').fadeIn(); // Adds class 'active' to allow for lockAspect() to function

    if ($('#ac_auto_refresh').length && $('#adcreator-panel').hasClass('active')) {
      setTimeout( function() {$('form#ac_auto_refresh').submit();
      }, 700);
    }
    else {
      setTemplateSize(); // Sets initial template size based on data attributes
      setTextScale(); // Sets any font scaling
      keepTemplateRatio(); // Locks the aspect ratio for vertical scaling
    }
  });

  // Expire saved ad
  $(document).on('ajax:success', 'form[data-expire]', function(evt, data) {
    runSearchForm();
  });



  // Process Step update adcreator div

  $(document).on('submit', 'form[data-ac-process-step]', function(evt,data) {
    setTimeout( function() {processingOn(); }, 1);
  });
  $(document).on('ajax:success', 'form[data-ac-process-step]', function(evt, data) {
    var target = $(this).data('ac-process-step');
    $('#' + target).html(data);
      //look for auto-refresh id
    if ($('#ac_auto_refresh').length && $('#adcreator-panel').hasClass('active')) {
      setTimeout( function() {$('form#ac_auto_refresh').submit();
      }, 600);
    }
    else {
      // refresh cleared steps
      for (i = 0; i < cleared_steps.length; i++) {
        $('.search-form' + cleared_steps[i]).submit();
      }
      $('.text-choice-results').hide();
      showLayer();
      processingOff();
    }
  });

  // Process Step update adcreator div

  $(document).on('submit', 'form[data-ac-process-step-post]', function(evt, data) {
      setTimeout( function() { refreshWorkspace(); }, 2000);
  });

  // Export processing
  $(document).on('ajax:success', 'form[data-ac-process-export]', function(evt, data) {
    var target = $(this).data('ac-process-export');
    $('#' + target).html(data);
    //look for auto-refresh id
    if ($('#ac_auto_refresh').length && $('#adcreator-panel').hasClass('active')) {
      setTimeout( function() {$('form#ac_auto_refresh').submit();
      }, 700);
    }
    else {
      //Download document
      if ( $('#download_url').data('download-url') ) {
        downloadURL( $('#download_url').data('download-url'));
      }
    }
  });

  // Export panel refresh
  $(document).on('ajax:success', 'form[data-refresh-ac-export-panel]', function(evt, data) {
    var target = $(this).data('refresh-ac-export-panel');
    $('#' + target).html(data);
    if ($('#current_layer').val() !== "") {
      $('#export_form').find('input[name=layer]').val($('#current_layer').val());
      $('#export_form').find('input[name=set_layer]').val($('#current_layer').val());
      $('#export_form_order').find('input[name=layer]').val($('#current_layer').val());
      $('#export_form_order').find('input[name=set_layer]').val($('#current_layer').val());
    }
    displayExport();
  });

  // submit-cart using order-cart-panel
  $(document).on('ajax:success', 'form[data-order-cart-submit]', function(evt, data) {
    var target = $(this).data('order-cart-submit');
    $('#' + target).html(data);
    runSearchForm();
    hideOrderCartButton();
  });
  // // edit-cart using order-cart-panel
  // $(document).on('ajax:success', 'form[data-order-cart-edit]', function(evt, data) {
  //   var target = $(this).data('order-cart-edit');
  //   $('#' + target).html(data);
  // });
  // process-cart 
  $(document).on('ajax:success', 'form[data-order-cart-process]', function(evt, data) {
    var target = $(this).data('order-cart-process');
    $('#' + target).html(data);
  });
  // update-cart 
  $(document).on('ajax:success', 'form[data-order-cart-update]', function(evt, data) {
    var target = $(this).data('order-cart-update');
    $('#' + target).html(data);
  });
  // display order-cart-panel
  $(document).on('ajax:success', 'form[data-order-cart-panel]', function(evt, data) {
    var target = $(this).data('order-cart-panel');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
  // add-to-cart update active_cart_items
  $(document).on('ajax:success', 'form[data-add-to-cart]', function(evt, data) {
    var target = $(this).data('add-to-cart');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
  });
  // add-to-cart update active_cart_items
  $(document).on('ajax:success', 'form[data-ac-export-add-to-cart]', function(evt, data) {
    var target = $(this).data('ac-export-add-to-cart');
    $('#' + target).html(data);
    $('#' + target).fadeIn();
    closeExportAndTemplate();
    orderCartSubmit();
  });
  // update active_cart_items cart-button
  $(document).on('ajax:success', 'form[data-update-cart-button]', function(evt, data) {
    var target = $(this).data('update-cart-button');
    $('#' + target).html(data);
    if ($('#active-cart-items-found').length > 0) {
      showOrderCartButton();
    }
    else {
      hideOrderCartButton();
    }
  });
  // Order processing
  $(document).on('ajax:success', 'form[data-ac-process-order]', function(evt, data) {
    var target = $(this).data('ac-process-order');
    $('#' + target).html(data);
    //look for auto-refresh id
    if ($('#ac_auto_refresh').length && $('#adcreator-panel').hasClass('active')) {
      setTimeout( function() {$('form#ac_auto_refresh').submit();
      }, 700);
    }
    else {
    }
  });

  // Cart processing
  $(document).on('ajax:success', 'form[data-asset-group-download]', function(evt, data) {
    var target = $(this).data('asset-group-download');
    $('#' + target).html(data);
    //look for auto-refresh id
    if ($('#dl_cart_auto_refresh').length) {
      setTimeout( function() {$('form#dl_cart_auto_refresh').submit();
      }, 1000);
    }
    else if ($('#no_downloadable_items').length) {
      alert($('#no_downloadable_items').html());
      setAssetGroupButton(0);
      setCartHidden();
      $('#' + target).html('');
    }
    else {
      //Download document
      assetGroupInitForm();
      if ( $('#dl_cart_download_url').data('dl-cart-download-url') ) {
        setCartButton(0);
        $('.select-asset-button').removeClass('active');
        downloadURL( $('#dl_cart_download_url').data('dl-cart-download-url'));
        $('#' + target).html('');
      }
    }
  });

  // Single Download
  $(document).on('ajax:success', 'form[data-dl-single]', function(evt, data) {
    var target = $(this).data('dl-single');
    $('#' + target).html(data);
    //look for auto-refresh id
    if ($('#' + target).find('form').length) {
      setTimeout( function() {$('#' + target).find('form').submit();
      // setTimeout( function() {$('form#dl_cart_auto_refresh').submit();
      }, 700);
    }
    else {
      //Download document
      if ( $('#dl_cart_download_url').data('dl-cart-download-url') ) {
        downloadURL( $('#dl_cart_download_url').data('dl-cart-download-url'));
        $('#' + target).html('');
      }
    }
  });

//Downloader
var downloadURL = function downloadURL(url) {
    // console.log ('downloadURL: ' + url );

    var hiddenIFrameID = 'hiddenDownloader',
        iframe = document.getElementById(hiddenIFrameID);
    if (iframe === null) {
        iframe = document.createElement('iframe');
        iframe.id = hiddenIFrameID;
        iframe.style.display = 'none';
        document.body.appendChild(iframe);
    }
    iframe.src = url;
};

});

//Show-Hide Account Info

$(document).on('click', '.user-options', function() {
  var $this = $(this);
  $('#account-info').toggle();
  e.stopPropagation();
});

$(document).on('click', function() {
  $('#account-info').fadeOut();
});

//load-step-images
$(document).on('ajax:success', 'form[data-ac-load-step-images]', function(evt, data) {
  var target = $(this).data('ac-load-step-images');
  $('#' + target).html(data);
});

//Search replace text-choice results
$(document).on('ajax:success', 'form[data-update-text-choice-results]', function(evt, data) {
  var target = $(this).data('update-text-choice-results');
  $('#' + target).html(data);
  if ($(this).is(':visible')) {
    $('#' + target).show();
  }
});

//Search replace text-choice-multiple results
$(document).on('ajax:success', 'form[data-update-text-choice-multiple-results]', function(evt, data) {
  var target = $(this).data('update-text-choice-multiple-results');
  $('#' + target).html(data);
  if ($(this).is(':visible')) {
    $('#' + target).show();
  }
});

//Profile user-email-lists
$(document).on('ajax:success', 'form[data-update-user-email-lists]', function(evt, data) {
  var target = $(this).data('update-user-email-lists');
  $('#' + target).html(data);
});

//Profile user-mailing-lists
$(document).on('ajax:success', 'form[data-update-user-mailing-lists]', function(evt, data) {
  var target = $(this).data('update-user-mailing-lists');
  $('#' + target).html(data);
});

//Export panel user-email-lists
$(document).on('ajax:success', 'form[data-ac-user-email-lists-select]', function(evt, data) {
  var target = $(this).data('ac-user-email-lists-select');
  $('.' + target).html(data);
});

//Marketing Email list stats
$(document).on('ajax:success', 'form[data-marketing-email-stats]', function(evt, data) {
  var target = $(this).data('marketing-email-stats');
  $('#' + target).html(data);
  $('#' + target).show();
});

$(document).on('ajax:success', 'form[data-update-case-study-results]', function(evt, data) {
  var target = $(this).data('update-case-study-results');
  $('#' + target).html(data);
  $('#' + target).show();
});

$(document).on('ajax:success', 'form[data-user-order-details]', function(evt, data) {
  var target = $(this).data('user-order-details');
  $('#' + target).html(data);
  $('#' + target).show();
  $('#main-content').hide();
});

$(document).on('ajax:success', 'form[data-contact-results]', function(evt, data) {
  var target = $(this).data('contact-results');
  $('#' + target).html(data);
  $('#' + target).show();
});

$(document).on('ajax:success', 'form[data-contact-form]', function(evt, data) {
  var target = $(this).data('contact-form');
  $('#' + target).html(data);
  $('#contact-form-contents').fadeIn();
});

$(document).on('ajax:success', 'form[data-attachment-form-div]', function(evt, data) {
  var target = $(this).data('attachment-form-div');
  $('#' + target).html(data);
  $fileupload = $('.fileupload-attachment');
  if ($fileupload.length) {
    window.attachmentUploadManager = new AttachmentUploadManager($fileupload);
  }
  $('#' + target + '-modal').fadeIn();
  $(this).fadeOut();
});

$(document).on('ajax:success', 'form[data-user-marketing-emails]', function(evt, data) {
  var target = $(this).data('user-marketing-emails');
  $('#' + target).html(data);
});

$(document).on('ajax:success', 'form[data-user-orders]', function(evt, data) {
  var target = $(this).data('user-orders');
  $('#' + target).html(data);
});

$(document).on('ajax:success', 'form[data-index-ac-text-results]', function(evt, data) {
  var target = $(this).data('index-ac-text-results');
  $('#' + target).html(data);
});
