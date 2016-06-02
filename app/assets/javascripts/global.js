// generic routine to alert translated text for required form fields
function validateAndSubmitForm(form_id){
  var validation_passed = true;
  $('#' + form_id).find('.required-field').each(function(index)  {
    if ($(this)[0].type === 'checkbox') {
      if ($("[name='" + $(this)[0].name + "']:checked").length === 0) {
      // if (!$(this).is(':checked')) {
        alert($(this).data('alert'));
        $(this).focus();
        validation_passed = false;
        return false;
      }
    }
    else if ($(this)[0].type === 'radio') {
      if ($("input[type='radio'][name='" + $(this)[0].name + "']:checked").length === 0) {
        alert($(this).data('alert'));
        $(this).focus();
        validation_passed = false;
        return false;
      }
    }
    else if ($(this).val().length === 0) {
      alert($(this).data('alert'));
      $(this).focus();
      validation_passed = false;
      return false;
    }
  });
  $('#' + form_id).find('.validate-email').each(function(index)  {
    if ($(this).length > 0) {
      var email_array = $(this).val().split(/,/);
      var i;
      for (i = 0; i < email_array.length; i++) {
        if (!isValidEmailAddress(email_array[i].trim())) {
          alert($(this).data('alert-validate'));
          $(this).focus();
          validation_passed = false;
          return false;
        }
      }
    }
  });
  if (validation_passed) {
    return $('#' + form_id).submit();
  }
}

$(document).on('click', '.validate-and-submit-form', function(e) {
  e.stopPropagation();
  var form_id = $(this).data('form-id');
  if (form_id.length > 0) {
    validateAndSubmitForm(form_id);
  }
  return false;
});

// Datepicker
$(document).on('ready page:load', function(e) {
  initDatepicker();
});

function initDatepicker() {
  $('.datepicker').each(function() {
    var today = new Date();
    var minDate = new Date(today.setYear(new Date().getFullYear() - 1));
    var maxDate = new Date(today.setYear(new Date().getFullYear() + 1));
    if ($(this).data('min-date')) {
      minDate = $(this).data('min-date');
    }
    if ($(this).data('max-date')) {
      maxDate = $(this).data('max-date');
    }
    $(this).datepicker({
      minDate: minDate,
      maxDate: maxDate,
      dateFormat: 'yy-mm-dd',
      altFormat: 'dd/mm/yyyy',
      autoclose: true,
      todayHighlight: true
    });
  });
}

//show-hide
$(document).on('click', '.show-hide', function(e) {
  e.preventDefault();
  if ($(this).data('hide-id') !== undefined) {
    $('#' + $(this).data('hide-id')).hide();
  }
  if ($(this).data('hide-class') !== undefined) {
    $('.' + $(this).data('hide-class')).hide();
  }
  if ($(this).data('remove-active-class') !== undefined) {
    $('.' + $(this).data('remove-active-class')).removeClass('active');
  }

  if ($(this).data('show-id') !== undefined) {
    $('#' + $(this).data('show-id')).show();
  }
  if ($(this).data('show-class') !== undefined) {
    $('.' + $(this).data('show-class')).show();
  }
  if ($(this).data('add-active-id') !== undefined) {
    $('#' + $(this).data('add-active-id')).addClass('active');
  }
});

function isValidEmailAddress(emailAddress) {
    var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
    return pattern.test(emailAddress);
}

// data-close-dropdown="close_this_id"
$(document).on('ajax:success', 'form[data-close-dropdown]', function(evt, data) {
  closeDropdown($(this).data('close-dropdown'));
});
function closeDropdown(id){
  $('#' + id).removeClass('open');
}

// Resets form fields belonging to the form passed to it
function resetForm($form) {
    $form.find('input:text, input:password, input:file, select, textarea').val('');
    $form.find('input:radio, input:checkbox').removeAttr('checked').removeAttr('selected');
}

$(document).on('click', '.reset-this-form', function(evt) {
  resetForm($(this).closest("form"));
});

