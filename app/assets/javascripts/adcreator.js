var $window = $(window);

// resize limits
$(document).on('keyup', '.resize-input', function () {
  if (this.value !== this.value.replace(/[^0-9\.]/g, '')) {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  }
});

$(document).on('blur', '.resize-input', function () {
  var min = $(this).data('min');
  var max = $(this).data('max');
  if (this.value !== this.value.replace(/[^0-9\.]/g, '')) {
    this.value = this.value.replace(/[^0-9\.]/g, '');
  }
  if (parseFloat(min) > parseFloat(this.value)) {
    this.value = min;
  }
  if (parseFloat(max) < parseFloat(this.value)) {
    this.value = max;
  }
});

// change spread
$(document).on('click', '.change-spread', function(){
  var $new_spread = $(this).data('spread-number');
  var $current_spread = $('#current_spread').val();
  $('#adcreator_set_spread').val($new_spread);
  changeSpread($current_spread, $new_spread);
});

function changeSpread(current_spread, new_spread) {
  if (current_spread < new_spread) {
    $('#template_' + current_spread).fadeOut('slow').animate({
        'right': '-5540px'
      }, {duration: 'slow', queue: false}, function() {
    });
    $('#template_' + new_spread).fadeIn('slow').animate({
        'left': '0px'
      }, {duration: 'slow', queue: false}, function() {
    });
  }
  else if (current_spread > new_spread){
    $('#template_' + current_spread).fadeOut('slow').animate({
        'left': '-5540px'
      }, {duration: 'slow', queue: false}, function() {
    });
    $('#template_' + new_spread).fadeIn('slow').animate({
        'right': '0px'
      }, {duration: 'slow', queue: false}, function() {
    });
  }
  $('#current_spread').val(new_spread);
}

function processingOn() {
  $('.ac-image-uploader').hide();
  $('#adcreator-processing').fadeIn('slow', function()  {
    $('#adcreator-contents').fadeOut();
  });
}

function processingOff() {
  $('#adcreator-processing').fadeOut('slow', function()  {
    $('#adcreator-contents').fadeIn(function() {
      setTemplateSize(); // Sets initial template size based on data attributes
      setTextScale(); // Sets any font scaling
      keepTemplateRatio(); // Locks the aspect ratio for vertical scaling
      changeSpread($('#current_spread').val(), $('#adcreator_set_spread').val() );
      lock_steps();
    });
  });
}

//direct image upload not carrierwave --deprecated
$(document).on('change', '.ac-image-upload', function() {
  var $this = $(this);
  if ( isValidAcImageUploadExtension( $this )) {
    $(this).closest("form").submit();
  }
  else {
    $this.replaceWith( $this = $this.clone( true ) );
    // alert('Allowed file types: eps, jpg, jpeg, png, tif, tiff');
    alert('Allowed file types: eps, jpg, jpeg, tif, tiff');
  }
});

// Undo
$(document).on('click', 'a#undo-template', function(e)  {
  e.preventDefault();
  $('form#undo').submit();
});

function pointsToPixels(points)  {
  var previewRes = 96,
    coordinateRes = 72,
    pixels = points * (previewRes/coordinateRes);
  return pixels;
}

function pixelsToPoints(pixels)  {
  var previewRes = 96,
    coordinateRes = 72,
    points = pixels * (coordinateRes/previewRes);
  return points;
}

function pointsToInches(points)  {
  var inches = points/72;

  return inches;
}

function setEditableLabel(index, w, h)  {
  var labelSize = 30,
    pos = 10;

  $('.highlight-label').eq(index)
    .width((labelSize / w)*100 + '%')  // set width in %
    .height((labelSize / h)*100 + '%') // set height in %
    .css({top: -((pos/h)*100) + '%', left: -((pos/w)*100) + '%'}) // set absolute position in %
    .find('.label-id').text(index+1);
}

// Sets the size of each editable area in the template and positions it
function setEditableSize()  {
  $('.template-highlight').each(function(index)  {
    var $this = $(this),
      $template = $('div.template'),
      templateWidth = pointsToPixels($template.data("dimensions").width),
      templateHeight = pointsToPixels($template.data("dimensions").height),
      top = pointsToPixels($this.data("coordinates").top),
      left = pointsToPixels($this.data("coordinates").left),
      bottom = pointsToPixels($this.data("coordinates").bottom),
      right = pointsToPixels($this.data("coordinates").right),
      width = templateWidth - (left + right),
      height = templateHeight - (top + bottom);

    setEditableLabel(index, width, height); // Passes this highlight's index, width, and height to the setEditableLabel function

    $this.css({
      "width": ((width/templateWidth)*100).toFixed(3) + '%', // Converts values to % and trims decimal value
      "height": ((height/templateHeight)*100).toFixed(3) + '%',
      "top": (((top-1)/templateHeight)*100).toFixed(3) + '%',
      "left": (((left-1)/templateWidth)*100).toFixed(3) + '%'
    });
  });
}

// Scales all text in the AdCreator with class 'scale-text' based on font size specified in its data attribute (in px)
function setTextScale(scale) {
  $('.scale-text').each(function()  {
    var $this = $(this),
      fontSize = $this.data('fontsize');

      $this.css('font-size', fontSize*scale + 'px');
  });
}

// Maintain aspect ratio of AdCreator template
function lockAspect()  {
  if ($('div#adcreator-panel').hasClass('active'))  {
      $('#adcreator-canvas-area').find('div.template').each(function()  {
        var $this = $(this),
          width = pointsToPixels($this.data("dimensions").width),
          height = pointsToPixels($this.data("dimensions").height),
          aspectRatio = height / width;

        $this.height( $this.width() * aspectRatio );

        var scale = (($this.width() / width) * 100);
        if (!$this.hasClass('export-thumb'))  {  // if template has this class, it is part of the export step and should not be tracked
          $('span#template-scale-percentage').text(Math.round(scale) + "%");  // Sets the scale percentage in the toolbar area
          setTextScale(scale/100); // Passes scale % to setTextScale
        }
      });
    }
}

// Sets the initial height and width of the canvas/template based on data attributes
function setTemplateSize()  {
  $('div.template').each(function()  {
      var $this = $(this),
      width = $this.data("dimensions").width,
      height = $this.data("dimensions").height;
    $('span#template-width').text(pointsToInches(width).toFixed(2) + '"');  // Converts points to inches then sets the display
    $('span#template-height').text(pointsToInches(height).toFixed(2) + '"'); // Additional code will be required to display pixels as needed
    $this.parent().width(pointsToPixels(width)); // Converts points to pixels and sets the initial size of the template element
    $this.height(pointsToPixels(height));
  });
  lockAspect();
}

// Maintains template ratio when template height exceeds viewport
function keepTemplateRatio()  {
  if ($('#export-wrapper').is(':visible'))  {
    return;
  }
  var $canvasArea = $('div#adcreator-canvas-area'),
    $template = $canvasArea.find('div#template_1'),
    $templates = $canvasArea.find('div.template');

  if (!($template && $canvasArea )) {
    return;
  }

  $templates.each (function(index)  {
    var $temp = $(this);
    if ($temp.css('display') === 'block') {
      $template = $temp;
    }
  });


  var templateOffset = $template.offset(),
    canvOffset = $canvasArea.offset();
  //above check has timing issues verify existence of templateOffset and cavOffset
  if (typeof(templateOffset) === 'undefined') {
    return;
  }

  var totalOffset = templateOffset.top + canvOffset.top,
  canvasAreaHeight = $canvasArea.height(),
  templateHeight = $template.height(),
  actualHeight = canvasAreaHeight - totalOffset,
  specWidth = pointsToPixels($template.data("dimensions").width),
  specHeight = pointsToPixels($template.data("dimensions").height),
  aspectRatio = specHeight / specWidth;

  if ($('span#template-scale-label').hasClass('auto'))  {
    $canvasArea.find('div.template-canvas').width(Math.min((actualHeight / aspectRatio), specWidth));
    lockAspect();
  }
  else {
    return;
  }
}

// Changes the size of the template based on user selection
function changePreviewPercent(perc)  {
  var $templateCanvas = $('div.template-canvas'),
    width = pointsToPixels($('div.template').data("dimensions").width),
    height = pointsToPixels($('div.template').data("dimensions").height),
    newWidth = width * (perc * 0.01),
    newHeight = height * (perc * 0.01);

  flag_template_highlights();
  $('.template-highlight').hide();

  if (perc === 'auto')  {  // If 'auto is selected' ...
    $templateCanvas
      .css({'max-width':'100%', 'height':'auto'})
      .animate({'width': width},
       'slow', function()  {
        keepTemplateRatio();
        lockAspect();
        show_flagged_template_highlights();
        adjustImageBoxes();
    });
    if (!$('span#template-scale-label').hasClass('auto'))  {
      $('span#template-scale-label').addClass('auto').text('auto');
    }
  }
  else  {
    $templateCanvas   // Otherwise scale to the selected percentage
        .css({'max-width':'none'})
        .animate({
          'width': newWidth,
          'height': newHeight
        }, 'slow', function()  {
          lockAspect();
          show_flagged_template_highlights();
        adjustImageBoxes();
      });
      $('span#template-scale-label').removeClass('auto').text('');
  }
  $templateCanvas.css("overflow","visible");
}

// Resets a few elements in the AdCreator (** likely unnecessary for production **)
function resetAdcreator()  {
  $('div#adcreator-panel').removeClass('active') // Removes 'active' to prevent lockAspect() from functioning
  $('.edit-tool').hide();
  changePreviewPercent('auto');  // Resets 'auto' sizing for next template
  resetForm($('.edit-tool > form'));
}

// Close AdCreator - fade out AdCreator and fade in normal content
$(document).on('click', 'a#close-template', function(e)  {
  e.preventDefault();
  $('div#adcreator-canvas-area').scrollTop(0); // Scrolls to top to prevent display bugs
  $('div#adcreator-panel').fadeOut(function()  {
    resetAdcreator();
    $('div#site-contents').fadeIn();
  });
});

// AdCreator template scaling control
$(document).on('click', '.scale-preview', function()  {
  var perc = $(this).text().replace(/[^a-zA-Z 0-9]+/g,'');

  $('div#adcreator-canvas-area').scrollTop(0); // Scrolls to top to prevent display bugs
  changePreviewPercent(perc);
});


// Shows the AdCreator edit tool specific to which editable area was clicked
$(document).on('click', '.template-highlight', function()  {
  var $this = $(this),
    stepId = $this.data('step-number');
  if ($this.hasClass('step-locked')) {
    return false;
  }

  $('.template-highlight').each(function()  {
    $(this).removeClass('active');
  });
  $('.template-highlight-resize').each(function()  {
    $(this).removeClass('active');
  });
  $('.template-highlight-resize-mask').each(function()  {
    $(this).removeClass('active').fadeOut();
  });
  $('.template-highlight-resize-containmentbox').each(function()  {
    $(this).removeClass('active').fadeOut();
  });
  $('.template-highlight-resize-containmentmask').each(function()  {
    $(this).removeClass('active').fadeOut();
  });

  $('.image-option').each(function()  {
    $(this).removeClass('active').fadeOut();
  });

  $('.image-choice-submit').each(function()  {
    $(this).removeClass('active').fadeOut();
  });

  $('.image-resize-instructions').fadeOut();

  $this.addClass('active');

  $('.edit-tool').fadeOut('fast').promise().done(function()  {
    $('#' + stepId).fadeIn('fast');
    // $('.edit-num').text(stepId + '.'); // Sets the corresponding step number in the edit tool header
  });
  if ($('#' + stepId).hasClass('ac-text-choice-step')) {
    $('form#ac_text_choice_step_' + stepId).submit();
  }
  if ($('#' + stepId).hasClass('ac-text-choice-multiple-step')) {
    $('form#ac_text_choice_multiple_step_' + stepId).submit();
  }
  if ($('#' + stepId).hasClass('ac-image-uploader-step')) {
    $('.ac-image-uploader').fadeIn();
  }
  else {
    $('.ac-image-uploader').fadeOut();
  }

});

$(document).on('click', '.template-highlight-resize', function()  {
  var $this = $(this),
    stepNumber = $this.data('step-number');

  $('.template-highlight-resize').each(function()  {
    $(this).removeClass('active');
    if ( $(this).data('step-number') === stepNumber ) {
      $(this).addClass('active');
      $('#resizable-area-mask-' + stepNumber).fadeIn();
      $('#editable-area-' + stepNumber).removeClass('active');
    }
    else {
      $(this).removeClass('active');
    }
  });
});

function xxx(stepNumber) {
  var maskBox = $('#resizable-area-mask-' + stepNumber);
  var imageBox = $('#resizable-area-' + stepNumber);
  var scale_percent = $('span#template-scale-percentage').html().replace('%','') * 1 /100;
  var template = $('div.template');
  var templateWidth = pointsToPixels(template.data("dimensions").width);
  var templateHeight = pointsToPixels(template.data("dimensions").height);

  console.log('maskBox: ' + maskBox);
}

function drawImageBox (stepNumber, selectedImageUrl ) {
  var maskBox = $('#resizable-area-mask-' + stepNumber),
    imageBox = $('#resizable-area-' + stepNumber),
    containmentmask = $('#resizable-area-containmentmask-' + stepNumber),
    containmentbox = $('#resizable-area-containmentbox-' + stepNumber);

  var actualImage = new Image(),
  cssBackgroundImage = selectedImageUrl,
  thumbnail_url = cssBackgroundImage.replace(/url\(['"]*(.*?)['"]*\)/g,'$1'),
  preview_url = thumbnail_url;

  actualImage.src = preview_url;
  var maskProp = maskBox.width() / maskBox.height(),
  imageProp = actualImage.width / actualImage.height,
  imageBoxWidth = maskBox.width(),
  imageBoxHeight = maskBox.height(),
  template = $('div.template'),
  templateWidth = template.width(),
  templateHeight = template.height(),
  maskBoxLeft = 0;
	if (maskBox.css('left').match('%') !== null ) {
    maskBoxLeft = maskBox.css('left').replace('%','') * 1;
    maskBoxLeft = maskBoxLeft / 100 * templateWidth;
  }
  else {
    maskBoxLeft = maskBox.css('left').replace('px','') * 1;
  }

  var maskBoxTop = 0;
  if (maskBox.css('top').match('%') !== null ) {
    maskBoxTop = maskBox.css('top').replace('%','') * 1;
    maskBoxTop = maskBoxTop / 100 * templateHeight;
  }
  else {
    maskBoxTop = maskBox.css('top').replace('px','') * 1;
  }

  var imageBoxLeft = maskBoxLeft,
  imageBoxTop = maskBoxTop,
  im_width_percent = 100,
  im_height_percent = 100,
  im_left_percent = 0,
  im_top_percent = 0,
  draggable_axis = 'x';

  if (maskProp / imageProp > 1 ) {
    draggable_axis = 'y';
    //height limited, calc new height
    imageBoxHeight = imageBoxHeight  / imageProp * maskProp;
    imageBoxTop = maskBoxTop + (maskBox.height()/2) - (imageBoxHeight/2);
    im_height_percent =  100 * imageProp / maskProp;  //smaller
    im_top_percent = 50 - im_height_percent /2;  //smaller
  }
  else {
    draggable_axis = 'x';
    //width limited, calc new width
    imageBoxWidth = imageBoxWidth * imageProp / maskProp;
    imageBoxLeft = maskBoxLeft  + (maskBox.width()/2) - (imageBoxWidth/2);
    im_width_percent = 100 * maskProp / imageProp;  //smaller
    im_left_percent = 50 - im_width_percent /2;  //smaller
  }

  // $('#resizable-area-image-' + stepNumber).attr("src",preview_url);
  imageBox.css('background-image', 'url(' + preview_url + ')');
  containmentbox.css('background-size', '100%');
  // imageBox.css('background-image', cssBackgroundImage);
  // imageBox.css('background-size', '100%');

  var ib_offset = 0,
  ib_width = imageBoxWidth+(ib_offset * 2),
  ib_height = imageBoxHeight+(ib_offset * 2),
  ib_top = imageBoxTop-(ib_offset * 1),
  ib_left = imageBoxLeft-(ib_offset * 1);

  imageBox.css({
    "width": ib_width,
    "height": ib_height,
    "top": ib_top - maskBoxTop,
    "left": ib_left - maskBoxLeft
    // "width": (ib_width*100/templateWidth).toFixed(10) + '%', // Converts values to % and trims decimal value
    // "height": (ib_height*100/templateHeight).toFixed(10) + '%',
    // "top": (ib_top*100/templateHeight).toFixed(10) + '%',
    // "left": (ib_left*100/templateWidth).toFixed(10) + '%'
  });
  imageBox.data('raw-left', ib_left);
  imageBox.data('raw-top', ib_top);


  containmentbox.css({
    "width": ib_width,
    "height": ib_height,
    "top": ib_top,
    "left": ib_left
    // "width": (ib_width*100/templateWidth).toFixed(10) + '%', // Converts values to % and trims decimal value
    // "height": (ib_height*100/templateHeight).toFixed(10) + '%',
    // "top": (ib_top*100/templateHeight).toFixed(10) + '%',
    // "left": (ib_left*100/templateWidth).toFixed(10) + '%'
  });

  containmentmask.css({
    "width": im_width_percent + '%', // Converts values to % and trims decimal value
    "height": im_height_percent + '%',
    "top": im_top_percent + '%',
    "left": im_left_percent + '%'
  });

  if ( $('#audit_image').prop('checked') ) {
    console.log('maskBox   width: ' + maskBox.css('width') + ' height: ' + maskBox.css('height') + ' top: ' + maskBox.css('top') + ' left: ' + maskBox.css('left'));
    console.log("imageBox assignment width: " + imageBoxWidth +  " height: " + imageBoxHeight +  " top: " + imageBoxTop +  " left: " + imageBoxLeft);
    console.log('imageBox  width: ' + imageBox.css('width') + ' height: ' + imageBox.css('height') + ' top: ' + imageBox.css('top') + ' left: ' + imageBox.css('left'));
    console.log('templateWidth ' + templateWidth);
    console.log('templateHeight ' + templateHeight);
    console.log('actualImage.width ' + actualImage.width);
    console.log('actualImage.height ' + actualImage.height);
    console.log('imageProp ' + imageProp);
    console.log('calculated imageProp ' + ib_width + ' / ' + ib_height + ' = ' + (ib_width /ib_height));
    console.log('maskProp ' + maskProp);
    console.log('im_width_percent ' + im_width_percent );
    console.log('im_height_percent ' + im_height_percent );
    console.log('im_left_percent ' + im_left_percent );
    console.log('im_top_percent ' + im_top_percent );
  }

  containmentbox.fadeIn();

  maskBox.fadeIn();
  imageBox.fadeIn();
  // imageBox.draggable({
  containmentbox.draggable({
    // axis: draggable_axis,
    drag: function(e, ui) {
      imageBox.css({
        "top": ui.position.top - maskBoxTop,
        "left": ui.position.left - maskBoxLeft
        // "top": (ui.position.top*100/templateHeight).toFixed(10) + '%',
        // "left": (ui.position.left*100/templateWidth).toFixed(10) + '%'
      });
      imageBox.data('raw-left', ib_left);
      imageBox.data('raw-top', ib_top);

    },
    stop: function(e, ui) {
      setImageResizeValues(stepNumber);
    },
    scroll: false,
  }).resizable({
    resize: function(e, ui) {
      imageBox.css({
        "width": ui.size.width, // Converts values to % and trims decimal value
        "height": ui.size.height,
        "top": ui.position.top - maskBoxTop,
        "left": ui.position.left - maskBoxLeft
        // "width": (ui.size.width*100/templateWidth).toFixed(10) + '%', // Converts values to % and trims decimal value
        // "height": (ui.size.height*100/templateHeight).toFixed(10) + '%',
        // "top": (ui.position.top*100/templateHeight).toFixed(10) + '%',
        // "left": (ui.position.left*100/templateWidth).toFixed(10) + '%'
      });
      imageBox.data('raw-left', ib_left);
      imageBox.data('raw-top', ib_top);
    },
    start: function (e, ui) {
      $('#resizing_in_progress').val(1);
    },
    stop: function (e, ui) {
      $('#resizing_in_progress').val(0);
      setImageResizeValues(stepNumber);
    },
    handles: "nw, ne, sw, se",
    // minHeight: ib_height,
    // minWidth: ib_width,
    aspectRatio: imageProp
  });
  setImageResizeValues(stepNumber);
}

function adjustImageBoxes () {
  if ($('#resizing_in_progress').val() === 0) {
    $('.template-highlight-resize').each(function(){
      if ($(this).is(':visible')) {
        // get step Number
        var step_number = $(this).data('step-number'),
        selectedImageUrl = '';

        //get step image-choice + active image
        $('#' + step_number).find('.image-choice').each (function () {
          if ($(this).hasClass('active')) {
            selectedImageUrl = $(this).find('.img-thumbs').css('background-image');
          }
        });
        drawImageBox(step_number, selectedImageUrl);
      }
    });
  }
}

$(document).on('click', '.test-submit', function() {
  var step_number = $(this).parent('form').data('step-number'),
  bounds = setImageResizeValues(step_number);

  console.log ("%o",bounds);
});

function setImageResizeValues(step_number) {
  var template = $('div.template'),
  templateWidth = template.width(),
  templateHeight = template.height(),
  actualImage = new Image();

  actualImage.src = template.find('img')[0].src;

  var docWidthPixels = actualImage.width,
  docHeightPixels = actualImage.height,
  resizable_area = $('#resizable-area-' + step_number),
  imWidth = resizable_area.width(),
  imHeight = resizable_area.height(),
  imLeft = parseFloat(resizable_area.css('left').replace('px','')) + parseFloat(resizable_area.parent().css('left').replace('px','')),
  imTop = parseFloat(resizable_area.css('top').replace('px','')) + parseFloat(resizable_area.parent().css('top').replace('px','')),
  imBottom = imTop + imHeight,
  imRight = imLeft + imWidth,
  scale_percent = templateWidth / docWidthPixels,
  bounds = {};

  bounds.left = toPoints(imLeft, scale_percent);
  bounds.top = toPoints(imTop, scale_percent);
  bounds.bottom = toPoints(imBottom, scale_percent);
  bounds.right = toPoints(imRight, scale_percent);

  $('#' + step_number).find('.image-choice').each (function () {
    if ($(this).hasClass('active')) {
      $(this).closest('form').find('input[name="resize_left"]').val(bounds.left);
      $(this).closest('form').find('input[name="resize_top"]').val(bounds.top);
      $(this).closest('form').find('input[name="resize_bottom"]').val(bounds.bottom);
      $(this).closest('form').find('input[name="resize_right"]').val(bounds.right);
    }
  });

  return bounds;
}

function toPoints (pixels, scale_percent) {
  return pixelsToPoints(parseInt(pixels) / scale_percent);
}


// Adds/removes 'active' class for IMAGE STEP image choices on click
$(document).on('click', '.image-choice', function()  {
  var $this = $(this),
    $thisRadio = $this.find('input:radio'),
    // $submitButt = $this.parents('form').nextAll('form').find('.submit-butt'),
    $imageUploader = $this.parents('form').nextAll('form').find('.image-upload-input'),
    $uploadText = $this.parents('form').nextAll('form').find('.upload-text'),
    $stepNumber = $this.parents('form').data('step-number'),
    $submitButt = $this.parents('form').find('.submit-butt');

  if (!$this.hasClass('multiple-select')) {
    $('.image-resize-instructions').fadeOut();

    $('.image-choice').removeClass('active');
    $('.image-choice input:radio').prop('checked', false);
    $imageUploader.val('');
    $uploadText.val('');
    $this.addClass('active');
    $thisRadio.prop('checked', true);
    if ($this.hasClass('logo') || $this.hasClass('auto_submit')) {
      $(this).closest("form").submit();
    }
    else if ($this.hasClass('resize')) {
      $('.image-choice-submit').fadeOut();
      var selectedImageUrl = $this.find('.img-thumbs').css('background-image');
      drawImageBox($stepNumber, selectedImageUrl);
      $this.parents('frm').find('.image-resize-instructions').fadeIn();
      $submitButt.fadeIn();
    }
    else if ($this.hasClass('validate-and-submit-form')) {
      var form_id = $(this).closest("form").data('form-id');
      if (form_id.length > 0) {
        validateAndSubmitForm(form_id);
      }
    }
    else if ($this.hasClass('set-layer')) {
      // defer to set-layer
    }
    else {
      $(this).closest("form").submit();
    }
  }

});

// Hide image upload input until warning is shown
$(document).on('click', '.image-upload-open', function()  {
  $('.image-upload-open').fadeOut();
  $('.image-upload-warning').fadeIn();
});

// Monitors activity in IMAGE STEP and PROFILE file upload
$(document).on('change', '.image-upload-input', function() {
  var $this = $(this),
		// $submitButt = $this.parents('.image-upload').nextAll('.form-group').find('.submit-butt'),
    $uploadText = $this.parents('.image-upload').find('.upload-text');

  $('.image-choice').removeClass('active'); // if present, remove any active image choices..
  $('.image-choice input:radio').prop('checked', false); // and uncheck its radio button

  $uploadText.val($this.val()); // ppulate the accompanying text field with the value of the file upload

});


/* -----------------------------------------------------
 * AdCreator - Export
 * ----------------------------------------------------- */

var storedTemplate,
  storedHighlights;

// shows the export panel when user clicks 'export template'
$(document).on('click', 'a#export-template', function()  {
  if (!$(this).hasClass('export-locked')) {
    $('#update-text-choice-results').hide();
    $('#export-panel-refresh-form').submit();
  }
  // on success displayExport
});

function displayExport() {
  var $canvas = $('#adcreator-canvas-area'),
    $sideToolbar = $('#adcreator-side-toolbar'),
    $exportWrapper = $('#export-wrapper,#export-close-options'),
    $origTemplate = $canvas.find('div.template-canvas');

  changePreviewPercent('auto'); // sets template area to 'auto'
  $sideToolbar.animate({right: '-350px'}, 'slow'); // slide the right toolbar off the screen
  $origTemplate.addClass('export-thumb'); // Adds a class to the template so the toolbar knows to stop tracking scale
  $('#adcreator-top-toolbar').animate({top:'-600px'}, 'slow'); // obscures the top toolbar so user cannot interact with it during export
  storedTemplate = $('div.template-canvas').clone();
  storedPreviews = $('#previews_1').clone();
  $('#export-preview').html(storedPreviews);
  $canvas.find('div.template-canvas, h2.template-name').fadeOut('slow', function()  {
     $canvas.css({
       right: '0',
       paddingLeft: '0'
     });  // widens the canvas area to allow the export panel to be centered
     //storedTemplate.appendTo('div.export-preview');
     flag_template_highlights();
     storedHighlights = $exportWrapper.find('div.template-highlight').detach();
     $exportWrapper.fadeIn().find('div.template-canvas').show();
     lockAspect();
  });
  $origTemplate.remove();
}

function refreshWorkspace() {
  $('form#manual_refresh').submit();
}

$(document).on('click', 'a#close-export-and-return-to-results', function(event) {
  event.preventDefault();
  closeExportAndTemplate();
  // closeTemplate();

});


// hides export panel and removes export preview from DOM when user cancels export
$(document).on('click', 'a#close-export', function(event) {
  event.preventDefault();
  var $canvas = $('#adcreator-canvas-area'),
    $sideToolbar = $('#adcreator-side-toolbar'),
    $exportWrapper = $('#export-wrapper,#export-close-options');

  $sideToolbar.animate({right: ''}, 'slow'); // slides the right toolbar back in
  $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
  $exportWrapper.fadeOut('slow', function()  {
    $exportWrapper.find('div.template-canvas').remove();
     $canvas
       .css({
         right: '',
         paddingLeft: ''
       })
       .find('div.container_canvas')
         .append(storedTemplate)
       .end()
       .find('div.template')
         .append(storedHighlights)
       .end()
         .find('div.template-canvas, h2.template-name')
           .show(function() {
             lockAspect();
             keepTemplateRatio();
    });
    show_flagged_template_highlights();
  //refreshWorkspace();
  });
});

function closeExportAndTemplate () {
  var $canvas = $('#adcreator-canvas-area'),
    $sideToolbar = $('#adcreator-side-toolbar'),
    $exportWrapper = $('#export-wrapper,#export-close-options');

  $sideToolbar.animate({right: ''}, 'slow'); // slides the right toolbar back in
  $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
  $exportWrapper.fadeOut('slow', function()  {
    $exportWrapper.find('div.template-canvas').remove();
     $canvas
       .css({
         right: '',
         paddingLeft: ''
       })
       .find('div.container_canvas')
         .append(storedTemplate)
       .end()
       .find('div.template')
         .append(storedHighlights)
       .end()
         .find('div.template-canvas, h2.template-name')
            .show(function() {
              lockAspect();
              keepTemplateRatio();
              $('div#adcreator-canvas-area').scrollTop(0); // Scrolls to top to prevent display bugs
              $('div#adcreator-panel').fadeOut(function()  {
              resetAdcreator();
              $('div#site-contents').fadeIn();
            });
    });
  show_flagged_template_highlights();
  //refreshWorkspace();
  });
}

// sets export file type labels to active if selected
$(document).on('change', '#export-wrapper .file-type', function()  {
  var $this = $(this);

	if ($this.prop('checked') === true)	{
    $this.parent().addClass('active');
		if ($this.attr('name') === 'ALL')	{
      $('.file-type').prop('checked', 'checked').parent().addClass('active');
      $('.file-type').prop('checked', 'checked');
    }
  }
  else {
    $this.parent().removeClass('active');
		if ($this.attr('name') === 'ALL')	{
      $('.file-type').prop('checked', false).parent().removeClass('active');
    }
		if ($('input.file-type[name="ALL"]').prop('checked') === true)	{
      $('input.file-type[name="ALL"]').prop('checked', false).parent().removeClass('active');
    }

  }
});

// sets export file type labels to active if selected
$(document).on('change', '#export-wrapper .bleed-choice', function()  {
  var $this = $(this);
  $('.bleed-choice').prop('checked', false).parent().removeClass('active');
  $this.prop('checked', 'checked').parent().addClass('active');
});


// Shows / hides loading animation in 'download' button when clicked
function exportFormatChosen () {
  return $('input.file-type').is(':checked');
}
function exportEmailSet () {
  var email_array = $('#export-emails').val().split(/,/);
  var i;
  for (i = 0; i < email_array.length; i++) {
    if (!isValidEmailAddress(email_array[i].trim())) {
      return false;
    }
  }
  return true;
}

$(document).on('click', '#download-files', function(e)  {
  e.preventDefault();
  if ( exportFormatChosen() ) {
    $('#export_type').val('download');
    $('form#export_form').submit();
  }
});

$(document).on('click', '#send-export-emails', function(e)  {
  e.preventDefault();
  if ( exportFormatChosen() && exportEmailSet() ) {
    $('#export_type').val('email');
    $('form#export_form').submit();
  }
});

$(document).on('click', '#submit-order', function(e)  {
  e.preventDefault();
  $('form#export_form_order').submit();
});

$(document).on('click', '#send-export-email-when-ready', function(e)  {
  e.preventDefault();
  $('form#set_export_email_address').submit();
});


function more_results(button) {
	var more_count = button.data('more-count'),
	count = 0,
  hidden_count = 0;
  button.parent().parent().find('.image-choice-paginate').each(function() {
    if ( !$(this).is(":visible") ) {
      if (count < more_count) {
				var background = $(this).data('background-image-url');

        $(this).find('.paginate').css('background-image','url(' + background + ')');
            count = count + 1;
            $(this).fadeIn();
      }
      else {
        hidden_count = hidden_count + 1;
      }
    }
  });
	if (hidden_count === 0) {
    button.fadeOut();
  }
}

$(document).on('change', '.ac-step-filter', function()  {
  var ac_step_sub_filter = $('#ac_step_sub_filter_' + $(this).data('ac-step-id'));
  var sub_filters = $('option:selected', this).attr('sub_filters');
  ac_step_sub_filter.hide();
  ac_step_sub_filter.empty();
  if (sub_filters !== undefined && sub_filters.length > 0) {
    ac_step_sub_filter.append($("<option></option>").attr('value', '').text(''));

    var sub_filters = sub_filters.split(',');
    for (var i = 0; i < sub_filters.length; i++) {
      var value = sub_filters[i];
      ac_step_sub_filter.append($("<option></option>").attr('value', value.toLowerCase()).text(value));
    }
    ac_step_sub_filter.show();
  }
  $(this).parent().submit();
});

$(document).on('change', '.ac-step-sub-filter', function()  {
  $(this).parent().submit();
});

$(document).on('change', '.ac-step-image-filter', function()  {
  $(this).parent().submit();
});
$(document).on('click', '.show-more-results', function()  {
  more_results($(this));
});

/* -----------------------------------------------------
 * Window Resize
 * ----------------------------------------------------- */

$window.resize(function()  {
  lockAspect();
  keepTemplateRatio();
  adjustImageBoxes();
});

$(document).on('click', '.close-text-choice-butt', function(e)  {
  e.preventDefault();
  $('.text-choice-results').hide();
});

$(document).on('click', '.text-choice-multiple', function(e)  {
  e.preventDefault();
  var step_id = $(this).data('ac-step-id');
  var option_type = $(this).data('option-type');
  var option_token = $(this).data('option-token');
  var title = $(this).data('title');
  var ul = $('#text-choice-multiple-choices' + step_id);
  var min_selections = ul.data('min-selections');
  var max_selections = ul.data('max-selections');

  if (ul.find('li[id=text-choice-multiple-sortable-' + option_token + ']').length !== 1 && ul.find('li').length < max_selections) {
    // write image to kwikee_product_input
    ul.append('<div style="border:solid 1px #fff;cursor:pointer;background-color:#fff;margin-bottom:5px;padding:5px;float:left;width:100%;"><li class="sortable-item" id="text-choice-multiple-sortable-' + option_token + '" style="float:left;width:100%"><div class="text-choice-multiple-remove delete-thumb" style="text-align:center"></div><input type="hidden" name="text_choice_multiple[]" value="' + option_type + '|' + option_token + '">' + title + '</li></div>');
    ul.sortable({ axis: 'y' });
    ul.disableSelection();
  }

  if (ul.find('li').length > 0) {
    $('#text-choice-multiple-choices-' + step_id).show();
  }
  else {
    $('#text-choice-multiple-choices-' + step_id).hide();
  }
  var submit_button = ul.parent().closest('form').find('.submit-butt');
  if (ul.find('li').length >= min_selections && ul.find('li').length <= max_selections) {
    submit_button.show();
  }
  else {
    submit_button.hide();
  }
});

// Remove
$(document).on('click','.text-choice-multiple-remove', function(e){
  e.preventDefault();
  var submit_button = $(this).parent().closest('form').find('.submit-butt');
  var ul = $(this).parent().closest('form').find('ul');
  var min_selections = ul.data('min-selections');
  var max_selections = ul.data('max-selections');

  $(this).parent().parent().remove();

  if (ul.find('li').length > 0) {
    $('#text-choice-multiple-choices-').show();
  }
  else {
    $('#text-choice-multiple-choices-').hide();
  }
  if (ul.find('li').length >= min_selections && ul.find('li').length <= max_selections) {
    submit_button.show();
  }
  else {
    submit_button.hide();
  }

});

// Kwikee Product Select/Remove 
// Select
$(document).on('click','.kwikee-product-choice', function(e){
  e.preventDefault();
  var step_id = $(this).closest('form').data('step-id');
  var thumbnail_url = $(this).data('background-image-url');
  var asset_type = $(this).data('asset-type');
  var asset_token = $(this).data('asset-token');
  var ul = $('#kwikee-product-choices' + step_id);
  var min_selections = ul.data('min-selections');
  var max_selections = ul.data('max-selections');
  // make sure not duplicate
  if (ul.find('li[id=kwikee-product-sortable-' + asset_token + ']').length !== 1 && ul.find('li').length < max_selections) {
    // write image to kwikee_product_input
    ul.append('<div style="border:solid 1px #fff;cursor:pointer;width:72px;height:72px;background-color:#fff;margin:5px;padding:5px;float:left;"><li class="sortable-item" id="kwikee-product-sortable-' + asset_token + '" style="background-image: url(\'' + thumbnail_url + '\');height:60px;width:60px;background-size:100%;float:left;"><div class="kwikee-product-remove delete-thumb" style="text-align:center"></div><input type="hidden" name="kwikee_product[]" value="' + asset_type + '|' + asset_token + '"</li></div>');
    ul.sortable();
    ul.disableSelection();
  }

  if (ul.find('li').length > 0) {
    $('.kwikee-sort-wrapper').show();
  }
  else {
    $('.kwikee-sort-wrapper').hide();
  }
  if (ul.find('li').length >= min_selections && ul.find('li').length <= max_selections) {
    $('.image-choice-submit').show();
  }
  else {
    $('.image-choice-submit').hide();
  }
});
// Remove
$(document).on('click','.kwikee-product-remove', function(e){
  e.preventDefault();
  var submit_button = $(this).parent().closest('form').find('.submit-butt');
  var ul = $(this).parent().closest('form').find('ul');
  var min_selections = ul.data('min-selections');
  var max_selections = ul.data('max-selections');

  $(this).parent().parent().remove();

  if (ul.find('li').length > 0) {
    $('.kwikee-sort-wrapper').show();
  }
  else {
    $('.kwikee-sort-wrapper').hide();
  }
  if (ul.find('li').length >= min_selections && ul.find('li').length <= max_selections) {
    submit_button.show();
  }
  else {
    submit_button.hide();
  }

});

// Refresh user-email-lists-select
$(document).on('click', '.submit-user-email-list-select', function(e)  {
  e.preventDefault();
  $('#refresh_user_email_lists').submit();
});

// show_hide_layer
$(document).on('change', '.ac-step-layer-select', function(e)  {
  e.preventDefault();
  var show_layer = $(this).val();
  var hide_layers = hidden_layers[show_layer];
  var orig_layer_name = hidden_layers['orig_names'][show_layer];
  $('.on-layer-' + show_layer).show();
  hide_layers.map( function(hide_layer) {
    // hide all elements that have layer_id as class
    $('.on-layer-' + hide_layer).hide();
  });
  active_layer.value = show_layer;
  $('#show_layer').val(show_layer);
  $('#current_layer').val(orig_layer_name);
  $("form[action='/adcreator/process_step']").find('input[name="set_layer"]').val(orig_layer_name);
  $('#export_form').find('input[name=layer]').val(orig_layer_name);
  $('#export_form_order').find('input[name=layer]').val(orig_layer_name);
  $('.edit-tool').hide();
});

// refresh display to current_layer
function showLayer () {
  if ($('#show_layer').length > 0) {
    var show_layer = $('#show_layer')[0].value;
    var hide_layers = hidden_layers[show_layer];
    var orig_layer_name = hidden_layers['orig_names'][show_layer];
    $('.on-layer-' + show_layer).show();
    hide_layers.map( function(hide_layer) {
      // hide all elements that have layer_id as class
      $('.on-layer-' + hide_layer).hide();
    });
    active_layer.value = show_layer;
  }
}

// fill in set_layer on dynamic form steps on click of choice before submit
$(document).on('click', '.image-choice-submit', function(e) {
  e.preventDefault();
  if ($('#current_layer').val()) {
    $(this).closest("form").find('input[name="set_layer"]').val( $('#current_layer').val() );
  }
  validateAndSubmitForm($(this).closest("form").data('form-id'));
});

// fill in set_layer on dynamic form steps on click of choice before submit
$(document).on('click', '.text-choice', function(e) {
  e.preventDefault();
  var ac_step_id = $(this).data('ac-step-id');
  $('#text-choice-step-' + ac_step_id).empty();
  if ($('#current_layer').val()) {
    $(this).closest("form").find('input[name="set_layer"]').val( $('#current_layer').val() );
  }
  validateAndSubmitForm($(this).closest("form").data('form-id'));
});

// fill in layer on process_step submit based on layer_element
$(document).on('click', ".set-layer", function(e) {
  e.preventDefault();
  var element_name = $(this).closest("form").find('input[name="layer_element"]').val();
  var active_layer = elements_to_layer[element_name]['name'];
  $(this).closest("form").find('input[name="layer"]').val(active_layer);
  if ($(this).closest("form").data('form-id') === undefined) {
    $(this).closest("form").submit();
  }
  else {
    validateAndSubmitForm($(this).closest("form").data('form-id'));
  }
});

function flag_template_highlights() {
  $('.template-highlight').each(function (i) {
    $(this).removeClass('is_visible');
    $(this).removeClass('is_hidden');

    if ($(this).is(':visible')) {
      $(this).addClass('is_visible');
    }
    else {
      $(this).addClass('is_hidden');
    }
  });
}

function show_flagged_template_highlights() {
  $('.template-highlight').each(function (i) {
    if ($(this).hasClass('is_visible')) {
      $(this).show();
    }
    else {
      // keep hidden
    }
    $(this).removeClass('is_visible');
    $(this).removeClass('is_hidden');
  });
}

$(document).on('click', '.text-choice-with-input', function(e) {
  e.preventDefault();
  var text_choice_token = $(this).data('text-choice-token');
  var ac_step_id = $(this).data('ac-step-id');
  $('#text-choice-step-' + ac_step_id).empty();
  $('form#text-choice-form-' + text_choice_token).clone().appendTo('#text-choice-step-' + ac_step_id);
});

// Travelers specific
$(document).on('change', '.case-study-drill-down-type', function(e)  {
  e.preventDefault();
  var step_id = $(this).data('ac-step-id');
  $('.case-study-drill-down-group').hide();
  if ($(this).prop('selectedIndex') > 0) {
    $('#drill-down-group-' + step_id + '-' + ($(this).prop('selectedIndex')-1)).show();
  }
});
$(document).on('click', '.case-study-choice', function(e)  {
  e.preventDefault();
  $('.case-study-results').hide();
  $(this).parent().submit();
});
$(document).on('click', '.close-case-study-drill-down-butt', function(e)  {
  e.preventDefault();
  $('.case-study-results').hide();
});

// Contacts
$(document).on('change', '.ac-step-contact-selection', function(e)  {
  e.preventDefault();
  var contact = window.system_contacts[parseInt($(this).val())];

  for (var property in contact) {
    var form_inputs = [];
    if ($(this).parents('form:first').find('[data-contact-field="' + property + '"]').length > 0) {
      form_inputs.push($(this).parents('form:first').find('[data-contact-field="' + property + '"]'));
    }
    if ($(this).parents('form:first').find('[data-contact-field^="' + property + '_"]').length > 0) {
      form_inputs.push($(this).parents('form:first').find('[data-contact-field^="' + property + '_"]'));
    }
    if ($(this).parents('form:first').find('[data-contact-field="$' + property + '"]').length === 1 ) {
      form_inputs.push($(this).parents('form:first').find('[data-contact-field="$' + property + '"]'));
    }
    if ($(this).parents('form:first').find('[data-contact-field^="$' + property + '_"]').length === 1 ) {
      form_inputs.push($(this).parents('form:first').find('[data-contact-field^="$' + property + '_"]'));
    }
    for (var i = 0; i < form_inputs.length; i++ ) {
      form_inputs[i].val(contact[property]);
    }
  }
});

// Required Step
// if Required Step Key
// array of required steps finished?
// add class disabled
function lock_steps() {
  step_ids = Object.keys(step_requirements)
  for (i = 0;i < step_ids.length;i++) {
    var locked = false;
    var step_id = step_ids[i];
    var required_steps = step_requirements[step_id];
    var finished_steps_length = finished_steps.length || 0
    if (required_steps.length > 0 && finished_steps_length === 0) {
      // lock required steps if no steps finished
      locked = true;
    }
    for (j = 0;j < required_steps.length;j++) {
      if (finished_steps.length > 0 && finished_steps.indexOf(required_steps[j].toString()) === -1) {
        locked = true;
      }
    }
    // locked?
    var class_name = 'step-locked';
    if (step_id === 'export') {
      class_name = 'export-locked'
    }
    if (locked) {
      $('.ac-step-' + step_id).addClass(class_name);
    }
    else {
      $('.ac-step-' + step_id).removeClass(class_name);
    }
  }
}
