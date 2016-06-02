# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', 'form .remove_dynamic_form_inputs', (event) ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('.container').hide()
  event.preventDefault()

$(document).on 'click', 'form .add_dynamic_form_inputs', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('dynamic-form-inputs').replace(regexp, time))
  event.preventDefault()