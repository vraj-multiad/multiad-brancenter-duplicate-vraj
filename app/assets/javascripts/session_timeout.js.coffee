@brandcenter ||= {}

sessionTimeoutRemaining = null

$(document).on 'ready page:load', ->
  $(document).idleTimer 'destroy'
  $(document.body).idleTimer 'destroy'
  clearInterval sessionTimeoutRemaining

  $modal = $('#session-timeout-modal')
  if $modal.length
    timeout = parseInt $modal.data('timeout')
    warning = parseInt $modal.data('warning')

    # this timer initiates the 'your session is about to timeout' modal
    $(document).idleTimer
      timeout: timeout - warning

    $(document).on 'idle.idleTimer', (event, element, data) ->
      $(this).idleTimer 'pause'
      $('#session-timeout-modal').modal
        backdrop: 'static'
      $('#session-timeout-modal').modal 'show'

      $(document.body).idleTimer
        timeout: warning,
        events: ''

      sessionTimeoutRemaining = setInterval(updateRemainingTime, 1000)
      updateRemainingTime()

    $(document.body).on 'idle.idleTimer', (event, element, data) ->
      event.stopPropagation()
      clearInterval sessionTimeoutRemaining
      updateRemainingTime()
      window.location.href= '/logout?timeout=1'

$(document).on 'click', '#session-timeout-continue', (event) ->
  $(document).idleTimer 'reset'
  $(document.body).idleTimer 'destroy'
  clearInterval sessionTimeoutRemaining
  $('#session-timeout-modal').modal 'hide'

$(document).on 'click', '#session-timeout-logout', (event) ->
  window.location.href= '/logout'

updateRemainingTime = ->
  time = new Date($(document.body).idleTimer('getRemainingTime'))
  minutes = time.getMinutes().toString()
  seconds = time.getSeconds().toString()
  seconds = '0' + seconds if seconds.length == 1
  $('#session-timeout-remaining').html "#{minutes}:#{seconds}"