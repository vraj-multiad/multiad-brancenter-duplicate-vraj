$(document).on('click', '.upload', function() {
  $('#drag-n-drop-box').show();
});

$(document).on('click', '.close-item-button', function() {
  $('#drag-n-drop-box').hide();
});

function handleDrag(event) {
  var files, target;

  event.preventDefault();

  switch(event.type) {
    case "dragenter":
      document.body.className = "dragging";
      break;

    case "dragleave":
      document.body.className = "";
      break;

    case "drop":
      if (!window.FileReader) {
        alert('Operation is not supported by your browser.  Please click select to choose files to upload.');
      }
      break;
  }
}

$(document).on("dragenter", '.image-upload', handleDrag);
$(document).on("dragover", '.image-upload', handleDrag);
$(document).on("dragleave", '.image-upload', handleDrag);
$(document).on("drop", '.image-upload', handleDrag);

$(document).on('ready page:load', function() {
  var $fileupload;

  $(document).bind('dragover drop', function (event) {
    event.preventDefault();
  });

  $fileupload = $('.fileupload-library');
  if ($fileupload.length) {
    window.libraryUploadManager = new LibraryUploadManager($fileupload);
  }

  $fileupload = $('.fileupload-logo');
  if ($fileupload.length) {
    window.logoUploadManager = new LogoUploadManager($fileupload);
  }

  $fileupload = $('.fileupload-contribution');
  if ($fileupload.length) {
    window.contributionUploadManager = new ContributionUploadManager($fileupload);
  }

  $fileupload = $('.fileupload-adminacimage');
  if ($fileupload.length) {
    window.adminAcImageUploadManager = new AdminAcImageUploadManager($fileupload);
  }

  $fileupload = $('.fileupload-useracimage');
  if ($fileupload.length) {
    window.userAcImageUploadManager = new UserAcImageUploadManager($fileupload);
  }

  $fileupload = $('.fileupload-attachment');
  if ($fileupload.length) {
    window.attachmentUploadManager = new AttachmentUploadManager($fileupload);
  }
});
