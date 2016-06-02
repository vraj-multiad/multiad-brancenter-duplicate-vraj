// sets share_via labels to active if selected
$(document).on('change', '.share-via', function() {
  var $this = $(this);
  var $active = true;

  $('.share-via').parent().removeClass('active');
  if ($this.val() == 'email') {
    $('#default-preview-text,#share-preview-social-media').fadeOut();
    $('#share-asset-link,#share-asset-link-span,#share-emails,#share-emails-note,#share-preview-email').fadeIn();
    // not-all-items-shareable-via-email
    $('#not-all-items-shareable-via-social-media-div').fadeOut();
    if ($this.hasClass('not-all-items-shareable-via-email')) {
      $('#not-all-items-shareable-via-email-div').fadeIn();
    }
    $('#share-email-subject').fadeIn();
  }
  else {
    $('#share-email-subject').fadeOut();
    $('#default-preview-text,#share-asset-link,#share-asset-link-span,#share-emails,#share-emails-note,#not-all-items-shareable-via-email-div,#share-preview-email').fadeOut();
    $('#share-preview-social-media').fadeIn();
    // not-all-items-shareable-via-social-media
    if ($this.hasClass('not-all-items-shareable-via-social-media')) {
       $('#not-all-items-shareable-via-social-media-div').fadeIn();
    }
  }
  $('#share-message').fadeIn();

  if ($this.val() == 'facebook') {
    $('#facebook_post_as_div').fadeIn();
  }
  else {
    $('#facebook_post_as_div').fadeOut();
  }


  // not-all-items-shareable-via-social-media

  


  // youtube-not-logged-in
  // youtube-not-logged-in-div
  // youtube-invalid-format
  // youtube-invalid-format-div
  var social_media_types = ['facebook','twitter','youtube'];
  for (var i = 0; i < social_media_types.length; i++) {
    var social_media_type = social_media_types[i];
    var error_types = ['-not-logged-in','-invalid-format'];
    for (var j = 0; j < error_types.length; j++) {
      var error_type = error_types[j];
      var social_media_div_selector = '#' + social_media_type + error_type +'-div';
      if ($this.val() == (social_media_type + error_type)) {
        $(social_media_div_selector).show();
        $this.removeProp('checked');
        $active = false;
      }
      else {
        $(social_media_div_selector).fadeOut();
      }
    }
  };


  if ($active) {
    $this.parent().addClass('active');
    if ($this.prop('checked') == true);
    $('#share_form_submit').fadeIn();
  }
  else {
    $('#share_form_submit').fadeOut();
  }

  $('#facebook_post_as_select').change(change_facebook_profile_image);
  change_facebook_profile_image();
});

function change_facebook_profile_image () {
  $('#facebook_profile_image').attr('src', $('#facebook_post_as_select').find(':selected').attr('data-image'));
}
