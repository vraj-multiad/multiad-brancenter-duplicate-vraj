// Generic form submit
$(document).on('click', '.submit-form-button', function() {
  var target = $(this).data('target-form');
  $('#' + target).submit();
});

$(document).on('click', '.cancel-attachment', function() {
  cancel_attachment_form($(this).data('dynamic-form-input-id'));
});

$(document).on('click', '.cancel-attachment-form-modal', function() {
  cancel_attachment_form_modal();
});

function update_attachment_form(dynamic_form_input_id, ajaxData) {
  $('#' + dynamic_form_input_id + '_form_active').hide();
  $('#' + dynamic_form_input_id + '_form_value').html(ajaxData.filename);
  $('#' + dynamic_form_input_id + '_form_submitted').show();
  $('#' + dynamic_form_input_id).val(ajaxData.token);
  cancel_attachment_form_modal();
}

function cancel_attachment_form(dynamic_form_input_id) {
  $('#' + dynamic_form_input_id).val('');
  $('#' + dynamic_form_input_id + '_form_submitted').hide();
  $('#' + dynamic_form_input_id + '_form_value').html('');
  $('#' + dynamic_form_input_id + '_form_active').show();
}

function cancel_attachment_form_modal() {
  $('#attachment-form').html('');
  $('#attachment-form-modal').hide();
}
