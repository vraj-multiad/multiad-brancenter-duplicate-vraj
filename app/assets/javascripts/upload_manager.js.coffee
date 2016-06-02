class UploadManager
  constructor: ($fileupload) ->
    @ajaxTimeout = 5000
    @assets = []
    @consecutivePollFailures = 0
    @legacy = !(new XMLHttpRequest().upload)
    @maxDropSize = 75 # max total size of dropped files (in MB)
    @maxConsecutivePollFailures = 10
    @polling = false
    @pollInterval = 1000
    @successes = []
    @uploadCounter = 0
    @uploads = []

    @bindListeners $fileupload

    @initialize()

    $fileupload.fileupload
      autoUpload: false
      dataType: 'xml'
      dropZone: $(@dropZone)
      # forceIframeTransport: true
      sequentialUploads: true

  addAsset: (asset) =>
    @assets.push asset
    @addRemoveCallback() if @addRemoveCallback

  addUpload: (upload) =>
    upload.id = @uploadCounter++
    @uploads.push upload
    @addRemoveCallback() if @addRemoveCallback

  addProgressBar: (data, style='warning', active=true, striped=true) =>
    filename = if data.files? then data.files[0].name else data.filename
    $li = $($.parseHTML(HandlebarsTemplates['upload_progress']({id: data.id, filename: filename, token: data.token})))
    $(@statusList).append $li

    $progressBar = $li.find '.progress-bar'
    @setProgressBarActive  $progressBar, active
    @setProgressBarStriped $progressBar, striped
    @setProgressBarStyle   $progressBar, style

    $progressBar

  addProgressBars: (assets) => # expected to be called with assets from initialize()
    _.each assets, (asset) =>
      if asset.status == 'processing'
        active = striped = true
        style = 'warning'
        @addAsset asset
      else if asset.status == 'processed' || asset.status == 'staged'
        active = striped = false
        style = 'success'
        @addSuccess asset
      else if asset.status == 'failed'
        active = striped = false
        style = 'danger'
        @addAsset asset

      $progressBar = @addProgressBar asset, style, active, striped
      $progressBar.css 'width', '100%'
      return

  addSuccess: (asset) =>
    @successes.push asset
    @removeAsset asset
    @setProgressBarFinished @progressBar(asset.token)

  bindListeners: ($fileupload) =>
    $fileupload.bind 'fileuploadadd',      @fileuploadadd
    $fileupload.bind 'fileuploaddone',     @fileuploaddone
    $fileupload.bind 'fileuploaddrop',     @fileuploaddrop
    $fileupload.bind 'fileuploadfail',     @fileuploadfail
    $fileupload.bind 'fileuploadprogress', @fileuploadprogress

    # not sure how much i like dropZone in the selector...
    $("#{@dropZone} .add-to").bind('click', @categorize) if @dropZone?

    # is this ok?
    $(@statusList).on 'click', '.progress-cancel', @cancel

  cancel: (event) =>
    $that = $(event.target)
    $li = $that.closest 'li'

    # hide the li immediately for instant feedback
    # we'll remove it later if cancellation is successful
    # otherwise we'll unhide it if there's an error (awkward)
    $li.hide()

    id = $li.data 'id'
    token = $li.data 'token'

    _.each _.where(@uploads, {id: id}), (upload) =>
      upload.jqXHR.abort()
      $li.remove()
      @removeUpload upload
      return

    _.each _.where(@assets, {token: token}), (asset) =>
      $.ajax
        data:
          token: token
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error cancelling asset #{token}: #{textStatus} - #{errorThrown}"
          $li.show()
        success: =>
          @removeAsset asset
          $li.remove()
        timeout: @ajaxTimeout
        type: 'post'
        url: @cancelUrl
      return

    _.each _.where(@successes, {token: token}), (success) =>
      $.ajax
        data:
          token: token
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error cancelling success #{token}: #{textStatus} - #{errorThrown}"
          $li.show()
        success: =>
          @removeSuccess success
          $li.remove()
        timeout: @ajaxTimeout
        type: 'post'
        url: @cancelUrl
      return

  categorize: =>
    tokens = _.pluck @successes, 'token'

    $.ajax
      data:
        tokens: tokens
      dataType: 'html'
      error: (jqXH$, textStatus, errorThrown) ->
        # can we do anything else/better here?
        console.log "Error adding to library: #{textStatus} - #{errorThrown}"
      success: (data, textStatus, jqXHR) =>
        $('#categorize-contents').html data
        $("#{@dropZone}").hide()
        $('#categorize-contents').fadeIn 'slow'
        $("#{@statusList} li").remove()
        @successes = []
        @addRemoveCallback() if @addRemoveCallback
      type: 'post'
      url: @categorizeUrl

  file: (id) =>
    _.where(@files, id: id)[0]

  fileuploadadd: (event, data) =>
    # called once for each file before it starts uploading

    if @allowedExtensions? && !_.contains(@allowedExtensions, data.files[0].name.split('.').pop().toLowerCase())
      alert "Allowed file types: #{@allowedExtensions.join(', ')}"
      return

    @addUpload data

    @addProgressBar data

    requestData = {}
    requestData.legacy = true if @legacy

    $.ajax
      cache: false
      data: requestData
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown)=>
        console.log "Error getting form data: #{textStatus} - #{errorThrown}"
        @setProgressBarError @progressBar(data.id)
        @removeUpload data
      success: (result) ->
        # thanks http://suntouchersoftware.com/blog/2014/03/03/direct-uploads-aws-s3-rails-carrierwavedirect-jquery-file-upload-plugin/
        # see https://github.com/blueimp/jQuery-File-Upload/wiki/Submit-files-asynchronously

        data.formData = result.formData
        data.url      = result.url

        data.submit()
      timeout: @ajaxTimeout
      url: @uploadFormUrl

  fileuploaddone: (event, data) =>
    # called once for each upload when it is done

    key = $(data.result).find('Key').text()

    $.ajax
      complete: (jqXHR, textStatus) =>
        @removeUpload data
      data:
        key: key
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) =>
        console.log "Error creating asset: #{textStatus} - #{errorThrown}"
        @setProgressBarError @progressBar(data.id)
      success: (ajaxData, textStatus, jqXHR) =>
        @progressBar(data.id).closest('li').attr('data-token', ajaxData.token)

        @addAsset ajaxData
        @poll() unless @polling
        # callback for attachment
        @fileuploaddoneCallback(ajaxData) if @fileuploaddoneCallback
      timeout: @ajaxTimeout
      type: 'post'
      url: @createUrl

  fileuploaddrop: (event, data) =>
    totalFileSize = 0
    _.each data.files, (file) ->
      totalFileSize += file.size
      return

    if totalFileSize > @maxDropSize * 1000000000000
      alert "Maximum upload size of #{@maxDropSize} MB exceeded.  Cancelling upload."
      event.preventDefault()

  fileuploadfail: (event, data) =>
    console.log "File upload failed: #{data.jqXHR.status} - #{data.jqXHR.statusText}"
    @setProgressBarError @progressBar(data.id)
    @removeUpload data

  fileuploadprogress: (event, data) =>
    # called every interval (default 100ms) for every upload in progress

    id = data.id
    percent = parseInt data.loaded / data.total * 100, 10

    $progressBar = @progressBar id
    $progressBar.css('width', percent + '%')

    label = "#{data.files[0].name} - #{percent}%"
    label = Handlebars.helpers.nobreak # this is a little hacky
      fn: ->
        label

    $progressBar.find('.progress-label').html label

  initialize: =>
    $.ajax
      cache: false
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        # can we do anything else here?
        console.log "Error initializing upload manager: #{textStatus} - #{errorThrown}"
      success: (data, textStatus, jqXHR) =>
        @addProgressBars data
        $("#{@dropZone}").show() if data.length
        @poll() if _.where(data, {status: 'processing'}).length
      timeout: @ajaxTimeout
      url: @incompleteUrl

  poll: =>
    @polling = true
    tokens = _.pluck @assets, 'token'

    $.ajax
      cache: false
      data:
        tokens: tokens
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) =>
        @consecutivePollFailures++

        console.log "Error polling: #{textStatus} - #{errorThrown}"
        console.log "Consecutive polling failures: #{@consecutivePollFailures}"

        if @consecutivePollFailures >= @maxConsecutivePollFailures
          console.log "Polling failed #{@consecutivePollFailures} times, giving up"
          @polling = false

          # this isn't perfect...
          # there's a good chance the assets did NOT fail
          # but at least the user will have some feedback to stop waiting
          # we could try to cancel them, but that would likely fail, too
          _.each @assets, (asset) =>
            @removeAsset asset
            @setProgressBarError @progressBar(asset.id)
            return
        else
          @poll()
      success: (data, textStatus, jqXHR) =>
        @consecutivePollFailures = 0

        # it would be great if we could capture and log some real detail here
        failed    = _.where data, {status: 'failed'}
        _.each failed, (asset) =>
          _.each _.where(@assets, {token: asset.token}), (storedAsset) ->
            storedAsset.status = 'failed'
          @setProgressBarError @progressBar(asset.token)
          return

        # this is a super edge case and doesn't seem to be working quite right
        expired = _.where data, {expired: true}
        _.each expired, (asset) =>
          @removeAsset asset
          @progressBar(asset.id).remove()
          return

        processed = _.where data, {status: 'processed'}
        _.each processed, (asset) =>
          @addSuccess asset
          return

        complete = _.where data, {status: 'complete'}
        _.each complete, (asset) =>
          @addSuccess asset
          return

        staged = _.where data, {status: 'staged'}
        _.each staged, (asset) =>
          @addSuccess asset
          return

        if @assets.length - _.where(@assets, {status: 'failed'}) > 0
          setTimeout(@poll, @pollInterval)
        else
          @polling = false

      timeout: @ajaxTimeout
      type: 'get'
      url: @pollUrl

  progressBar: (idOrToken) ->
    bar = $("#{@statusList} li[data-id=#{idOrToken}] .progress-bar")
    bar = $("#{@statusList} li[data-token=#{idOrToken}] .progress-bar") unless bar.length
    bar

  removeAsset: (asset) =>
    _.remove @assets, {id: asset.id}
    @addRemoveCallback() if @addRemoveCallback

  removeAssets: (assets) =>
    _.each assets, (asset) =>
      @removeAsset asset
      return

  removeSuccess: (success) =>
    _.remove @successes, {id: success.id}
    @addRemoveCallback() if @addRemoveCallback

  removeSuccesses: (successes) =>
    _.each successes, (success) =>
      @removeSuccess success
      return

  removeUpload: (upload) =>
    _.remove @uploads, {id: upload.id}
    @addRemoveCallback() if @addRemoveCallback

  removeUploads: (uploads) =>
    _.each uploads, (upload) =>
      @removeUpload upload
      return

  setProgressBarActive: ($progressBar, active) ->
    if active
      $progressBar.addClass 'active'
    else
      $progressBar.removeClass 'active'

  setProgressBarError: ($progressBar) =>
    @setProgressBarActive  $progressBar, false
    @setProgressBarStriped $progressBar, false
    @setProgressBarStyle   $progressBar, 'danger'
    $progressBar.css 'width', '100%'

  setProgressBarFinished: ($progressBar) =>
    @setProgressBarActive  $progressBar, false
    @setProgressBarStriped $progressBar, false
    @setProgressBarStyle   $progressBar, 'success'
    $progressBar.css 'width', '100%' # presumably this is already the case, but whatever

  setProgressBarStriped: ($progressBar, striped) ->
    if striped
      $progressBar.addClass 'progress-bar-striped'
    else
      $progressBar.removeClass 'progress-bar-striped'

  setProgressBarStyle: ($progressBar, style) ->
    _.each ['success', 'info', 'warning', 'danger'], (aStyle) ->
      $progressBar.removeClass "progress-bar-#{aStyle}"
      return

    $progressBar.addClass "progress-bar-#{style}"

class @LibraryUploadManager extends UploadManager
  constructor: ($fileupload) ->
    @cancelUrl = '/user_uploaded_images/cancel'
    @categorizeUrl = '/categorize_multiple'
    @createUrl = '/user_uploaded_images/upload_direct_library'
    @dropZone = '#drag-n-drop-box'
    @incompleteUrl = '/user_uploaded_images/incomplete/library'
    @pollUrl = '/user_uploaded_images/poll'
    @statusList = '.fileupload-status-library'
    @uploadFormUrl = '/user_uploaded_images/upload_form'
    super $fileupload

  addRemoveCallback: =>
    if @assets.length || @uploads.length || !@successes.length
      $("#{@dropZone} .add-to").hide()
    else if $(@statusList).children().length
      $("#{@dropZone} .add-to").show()

class @LogoUploadManager extends UploadManager
  constructor: ($fileupload) ->
    @allowedExtensions = ['eps','jpg','jpeg','tif','tiff']
    @cancelUrl = '/user_uploaded_images/cancel'
    @createUrl = '/user_uploaded_images/upload_direct_logo'
    @incompleteUrl = '/user_uploaded_images/incomplete/logo'
    @pollUrl = '/user_uploaded_images/poll'
    @statusList = '.fileupload-status-logo'
    @uploadFormUrl = '/user_uploaded_images/upload_form'
    super $fileupload

  addRemoveCallback: =>
    if !@assets.length && !@uploads.length && @successes.length
      $.ajax
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          # TODO can we do something better here?
          console.log "Error updating logos: #{textStatus} - #{errorThrown}"
        success: (data, textStatus, jqXHR) =>
          $("#{@statusList} li").remove()
          $('#logos').html data
          @success = []
        url: '/profile/logos'

class @AdminAcImageUploadManager extends UploadManager
  constructor: ($fileupload) ->
    @allowedExtensions = ['zip']
    @cancelUrl = '/admin/ac_images/cancel'
    @categorizeUrl = '/asset_group/admin_ac_image_keywords'
    @createUrl = '/admin/ac_image/upload_direct_ac_image'
    @dropZone = '#drag-n-drop-box'
    @incompleteUrl = '/admin/ac_images/incomplete'
    @pollUrl = '/admin/ac_images/incomplete'
    @statusList = '.fileupload-status-adminacimage'
    @uploadFormUrl = '/admin/ac_images/upload_form'
    super $fileupload

  addRemoveCallback: =>
    if @assets.length || @uploads.length || !@successes.length
      $("#{@dropZone} .add-to").hide()
    else
      $("#{@dropZone} .add-to").show()

class @UserAcImageUploadManager extends UploadManager
  constructor: ($fileupload) ->
    @allowedExtensions = ['eps','jpg','jpeg','tif','tiff']
    @cancelUrl = '/user_uploaded_images/cancel'
    @createUrl = '/user_uploaded_images/upload_direct_ac_image'
    @incompleteUrl = '/user_uploaded_images/incomplete/ac_image'
    @pollUrl = '/user_uploaded_images/poll'
    @statusList = '.fileupload-status-useracimage'
    @uploadFormUrl = '/user_uploaded_images/upload_form'
    super $fileupload

  addRemoveCallback: =>
    if !@assets.length && !@uploads.length && @successes.length
      $.ajax
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error updating adcreator images: #{textStatus} - #{errorThrown}"
        success: (data, textStatus, jqXHR) =>
          $("#{@statusList} li").remove()
          $('#user-uploaded-image-ac-image-choices').html data
          @successes = []
        url: '/adcreator/user_uploaded_images_ac_image'

class @AttachmentUploadManager extends UploadManager
  constructor: ($fileupload) ->
    # @allowedExtensions = ['eps','jpg','jpeg','tif','tiff']
    @cancelUrl = '/user_uploaded_images/cancel'
    @createUrl = '/user_uploaded_images/upload_direct_attachment'
    @incompleteUrl = '/user_uploaded_images/incomplete/attachment'
    @pollUrl = '/user_uploaded_images/poll'
    @statusList = '.fileupload-status-attachment'
    @uploadFormUrl = '/user_uploaded_images/upload_form'
    super $fileupload

  fileuploaddoneCallback: (ajaxData) =>
    console.log 'ajaxData', ajaxData
    $("#{@statusList} li").remove()
    @success = []
    @dynamic_form_input_id = $("#{@statusList}").parent().data('dynamic-form-input-id')
    update_attachment_form @dynamic_form_input_id, ajaxData

class @ContributionUploadManager extends UploadManager
  constructor: ($fileupload) ->
    @cancelUrl = '/admin/dl_images/cancel'
    @categorizeUrl = '/asset_group/admin_dl_image_keywords'
    @createUrl = '/dl_images/upload_direct_contributor'
    @dropZone = '#drag-n-drop-box'
    @incompleteUrl = '/dl_images/incomplete'
    @pollUrl = '/dl_images/poll'
    @statusList = '.fileupload-status-contribution'
    @uploadFormUrl = '/dl_images/upload_form'
    super $fileupload

  addRemoveCallback: =>
    if @assets.length || @uploads.length || !@successes.length
      $("#{@dropZone} .add-to").hide()
    else
      $("#{@dropZone} .add-to").show()

  addSuccess: (asset) =>
    super unless asset.status == 'processed' && _.where(@assets, {id: asset.id}).length
