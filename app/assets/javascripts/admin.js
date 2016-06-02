$(document).on('click', '.admin-keyword-term-delete-submit', function(evt)  {
  evt.preventDefault();
  var $this = $(this);
  // prevent double confirm and support translations
  if ($this.attr('type') === 'submit' || confirm($this.data('confirm'))) {
    if ($this.parent().hasClass('parent-keyword-type')) {
      $this.parent().parent().fadeOut();
    }
    else {
      $this.parent().fadeOut();
    }
    $('#admin_keyword_term_delete_id').val($this.data('id'));
    $('form#admin-keyword-term-delete-form').submit();
  }
});

// Submit admin-user-search-form after setting: keyword_criteria  user_results_page
$(document).on('click', '.admin-user-change-page', function(evt)  {
  evt.preventDefault();
  var $this = $(this);
  $('#user_results_page').val($this.data('user-results-page'));
  $('#user_search').val($this.data('user-search'));
  $('#admin-user-search-form').submit();
});

// Submit form on admin-reset-password-submit
$(document).on('click', '.admin-user-reset-password-submit', function(evt)  {
  evt.preventDefault();
  var $this = $(this);
  // prevent double confirm and support translations
  if ($this.attr('type') === 'submit' || confirm($this.data('confirm'))) {
    $('#admin-panel').fadeOut();
    $('#admin_user_reset_password_id').val($this.data('id'));
    $('form#admin-user-reset-password-form').submit();
  }
});
// Submit form on admin-user-edit-submit
$(document).on('click', '.admin-user-edit-submit', function(evt)  {
  evt.preventDefault();
  var $this = $(this);
  $('#admin-user-edit-contents').fadeOut();
  $('#admin_user_edit_id').val($this.data('id'));
  $('form#admin-user-edit-form').submit();
});
// Submit form on admin-user-expire-submit
$(document).on('click', '.admin-user-expire-submit', function(evt)  {
  evt.preventDefault();
  var $this = $(this);
  // prevent double confirm and support translations
  if ($this.attr('type') === 'submit' || confirm($this.data('confirm'))) {
    $('#admin-user-expire-contents').fadeOut();
    $('#admin_user_expire_id').val($this.data('id'));
    $('form#admin-user-expire-form').submit();
  }
});
$(document).on('click', '.admin-user-edit-cancel', function(evt)  {
  evt.preventDefault();
  $('#admin-user-edit-contents').fadeOut();
});
$(document).on('click', '.admin-user-expire-cancel', function(evt)  {
  evt.preventDefault();
  $('#admin-user-expire-contents').fadeOut();
});
$(document).on('click', '.admin-buttons', function()  {
  // evt.preventDefault();
  $('.admin-buttons').removeClass('active');
  $('.admin-tab').removeClass('active');
  $(this).closest('li').addClass('active');
});

$(document).on('ajax:success', 'form[data-location-reload]', function(evt, data) {
  location.reload();
});

//admin user access-level selections
$(document).on('click', '.access-level-selections', function(e) {
  e.stopPropagation();
  var $this = $(this),
    $thisRadio = $this.find('input:radio');

  if ($this.hasClass('active')) {
    $thisRadio.prop('checked', false);
    $this.removeClass('active');
  }
  else {
    $thisRadio.prop('checked', true);
    $this.removeClass('active');
  }


});

