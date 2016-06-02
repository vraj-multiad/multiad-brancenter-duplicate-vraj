/* -----------------------------------------------------
 * Profile Page
 * ----------------------------------------------------- */

// Show and hide Shipping Info
$(document).on('click', 'input#same_shipping_billing', function()  {
  if ($(this).is(":checked"))  {
    $('#shipping_info').fadeOut('fast');
  }
  else {
    $('#shipping_info').fadeIn('fast');
  }
});

// Click to edit Billing/Shipping Info
$(document).on('click', 'div.editable-area', function()  {
  if ($(this).hasClass('billing')) {
    $('#edit-billing-wrapper,#edit_billing_info').modal();
  }
  else {
    $('#edit_shipping_info').modal();
  }
});
$(document).on('click', 'div.editable-area', function()	{
	if ($(this).hasClass('shipping')) {
		$('#edit-shipping-wrapper,#edit_billing_info').modal();
	}
	else	{
		$('#edit_shipping_info').modal();
  }
});

// Removes a saved logo when the 'x' button is clicked
$(document).on('click', '.logos-wrapper .delete-thumb button', function() {
  $(this).parents('.saved-logo').fadeOut(function() {
    $(this).remove();
  });
});

$(document).on('click', '#logo-ul-submit', function(e)  {
  e.preventDefault();
  var l = Ladda.create(this);
  l.start();
  // Need server response code here
});

$(document).on('click', '.same-as-billing', function(e) {
  e.preventDefault();
  $('#same-as').toggle();
});

// Change Password modal
$(document).on('click', '.change-password', function(e)  {
  e.preventDefault();
  $('#change-password-panel').fadeIn();
});

$(document).on('click', '.change-password-cancel', function(e)  {
  e.preventDefault();
  $('#change-password-panel').fadeOut();
});

$(document).on('click', '.change-password-submit', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('#change-password-panel').hide();
});

function getFileName(file) {
  var filename = '';
  if (file.type === undefined) {
    filename = file.val();
  }
  else {
    filename = file.name;
  }
  return filename;
}

function isValidSpreadsheetExtension(file){
  var filename = getFileName(file);
  var ext = filename.split('.').pop().toLowerCase();
  if($.inArray(ext, ['csv', 'ods', 'xls', 'xlsx']) === -1) {
      return false;
  }
  return true;
}

function isValidMailingListExtension(file){
  var filename = getFileName(file);
  var ext = filename.split('.').pop().toLowerCase();
  if($.inArray(ext, ['xls', 'xlsx']) === -1) {
      return false;
  }
  return true;
}

$(document).on('change', '.fileupload-email-list', function() {
  var file_input = $(this);
  if ( isValidSpreadsheetExtension( file_input )) {
    file_input.closest("form").submit();
  }
  else {
    file_input.replaceWith( file_input.clone( true ) );
    alert('Allowed file types: csv, ods, xls, xlsx');
  }
});

$(document).on('change', '.fileupload-mailing-list', function() {
  var file_input = $(this);
  if ( isValidMailingListExtension( file_input )) {
    file_input.closest("form").submit();
  }
  else {
    file_input.replaceWith( file_input.clone( true ) );
    alert('Allowed file types: xls, xlsx');
  }
});

$(document).on('click', '.user-order-details-close', function()  {
  $('#user-order-details').empty();
  $('#user-order-details').hide();
  $('#main-content').show();
});

$(document).on('click', '.contact-search-form-submit', function()  {
  $('#contact-search-form').submit();
});
$(document).on('click', '.contact-edit-form-submit', function()  {
  var $this = $(this);
  $('#contact_form_edit_id').val($this.data('id'));
  $('form#contact-edit-form').submit();
});
$(document).on('click', '.contact-remove-form-submit', function()  {
  var $this = $(this);
  // prevent double confirm and support translations
  if ($this.attr('type') === 'submit' || confirm($this.data('confirm'))) {
    $('#contact_form_remove_id').val($this.data('id'));
    $('form#contact-remove-form').submit();
    $('#contact-search-form').submit();
  }
});
$(document).on('click', '.contact-form-cancel', function()  {
  $('#contact-search-form').submit();
  $('#contact-form-contents').fadeOut();
});
