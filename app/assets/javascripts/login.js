/* -----------------------------------------------------
 * Login Page
 * ----------------------------------------------------- */

// Login Page - New User and Forgot Password modals
$(document).on('click', 'a#forgot-password', function(e)	{
	e.preventDefault();
	$('#forgot_password_panel').modal();
});

$(document).on('click', '.forgot-password-submit', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('#forgot_password_panel').modal();
});

$(document).on('click', 'a#new-user', function(e)  {
  // console.log('new-user');
  e.preventDefault();
  $('#terms_and_conditions_panel').modal();
});

//legacy support for placeholder text
jQuery(function() {
   jQuery.support.placeholder = false;
   test = document.createElement('input');
   if('placeholder' in test) jQuery.support.placeholder = true;
});
// This adds placeholder support to browsers that wouldn't otherwise support it. 
// $(function() {
//    if(!$.support.placeholder) { 
//       var active = document.activeElement;
//       $(':text,:password').focus(function () {
//          if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
//             $(this).val('').removeClass('hasPlaceholder');
//          }
//       }).blur(function () {
//          if ($(this).attr('placeholder') != '' && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
//             $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
//          }
//       });
//       $(':text,:password').blur();
//       $(active).focus();
//       $('form:eq(0)').submit(function () {
//          $(':text.hasPlaceholder').val('');
//       });
//    }
// });
// // On DOM ready, hide the real password
// $(document).on('change', '#password').hide();

// // Show the fake pass (because JS is enabled)
// $(document).on('change', '#fake_password').show();