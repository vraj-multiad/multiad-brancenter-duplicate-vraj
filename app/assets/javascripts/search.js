// Handles clearing the 'Global' search filter
function clearGlobalFilter(filterText)  {
  $('#main-filter-button') // Fades out 'Global' site search filter and fades in chosen site option as new filter
      .removeClass('disabled')
        .fadeOut(function()  {
          $(this)
            .empty()
            .prepend('<span class="filter-text">' + filterText + '</span>&nbsp;<span class="caret"></span>');
        })
        .fadeIn();
}

// Manages all aspects of adding and removing search filters
function manageFilters()  {
  var $this = $(this),
		// $thisLabel = $this.closest('div'),
		// $mainFilter = $('#main-filter-button'), // Main Filter button
		// filterCount = $('input.filter').length,
    checkedCount = $('input.filter:checked').length; // Number of filters currently checked

  var no_submit = $this.data('no-submit');
  var update_search_filters = $this.data('update-search-filters');
  var search_type = $this.data('search-type');
	if ($this.prop('checked') === true)	{
    $('#search_form_' + search_type).val(search_type);
    if (update_search_filters) {
      $('#search_filters_form_' + search_type).val(search_type);
    }
  }
  else {
    if (checkedCount > 0 ) {
      $('#search_form_' + search_type).val('');
      if (update_search_filters) {
        $('#search_filters_form_' + search_type).val('');
      }
    }
  }
  if (!no_submit) {
    runSearchForm();
  }
  if (update_search_filters) {
    runSearchFiltersForm();
  }
}

function animateSiteOption($this) {
  $('#main-site-options').fadeOut(function()  { // Fades out then removes other site options and Twitter feed
    $('div#search-results-area').fadeIn();
  });
  $this.animate({  // Animates the selected option to condense and slide upward
    height: '44px',
    marginTop: '-165px',
  });
}

// Handles the animation and effects associated with choosing a search selection
function processSelection($this)  {
  // var $this = $(this),
  var text = $this.text();
  // var $mainButton = $('#main-filter-button');

  if (text.indexOf('search') >= 0)  { // Checks selection to see if it contains the word 'search'..
    text = text.substr(7);  // ..then removes it
  }

  var $checkbox = $('input.filter').filter(function() { // Finds the checkbox with the data field that matches the 'text' variable and stores it in a variable
    return $(this).data('filter') === text;
  });

  $('input.filter').prop('checked', false);
  $('.checkbox.search-filter').removeClass('active');

  $checkbox.prop('checked', true); // Sets the corresponding filter checkbox to 'checked'
  $checkbox.closest('div').addClass('active'); // Adds corresponding backgroung color to dropdown selection

  animateSiteOption($this);

  clearGlobalFilter(text);
  if ($this.hasClass('no-global-filter')) {
    $('#main-filter-button').addClass('disabled');
  }
  if ($this.hasClass('my-library-home')) {
    $('#group_results_by_user_category').val('1');
  }

}

// Launch AdCreator - fade out normal content and fade in AdCreator
 $(document).on('click', 'a.edit-template-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('div#site-contents').fadeOut(function() {
    $('div#adcreator-panel').addClass('active').fadeIn(); // Adds class 'active' to allow for lockAspect() to function
    setTemplateSize(); // Sets initial template size based on data attributes
    keepTemplateRatio(); // Locks the aspect ratio for vertical scaling
    setEditableSize();
  });
 });

// Executes the processSelection function when a site selection is clicked
// $(document).on('click', '.site-option', processSelection);

// Executes the manageFilters function when a selection is made in the filters dropdown
$(document).on('click', 'input.filter', manageFilters);
// $(document).on('click', '.checkbox.search-filter', manageFilters);

// Toggles selection of downloadable assets in search results
$(document).on('click', '.select-asset-button', function(e) {
  e.preventDefault();
  var $this = $(this);
  if ($this.hasClass('active')) {
    // $this.prop('checked', false);
    $this.removeClass('active');
  }
  else {
    // $this.prop('checked', true);
    $this.addClass('active');
  }
});

// Toggles selection of items to be added to asset-group in search results
$(document).on('click', '.select-asset-group-button', function(e) {
  e.preventDefault();
  var token = $(this).data('token');
  var is_active = $(this).hasClass('active');

  $('.thumb-' + token).each(function(index) {
    var $this = $(this);
    if (is_active) {
      $this.find('.checked-asset').removeClass('active zoomIn').addClass('animated zoomOut', function(){ $(this).find('.checked-asset').hide(); });
      $this.removeClass('selected-asset-border active');
      $this.find('.un-check').hide();
      $this.find('.select-asset-group-button').removeClass('active');
    }
    else {
      $this.find('.checked-asset').stop().show().addClass('animated zoomIn active').removeClass('zoomOut');
      $this.addClass('selected-asset-border active');
      $this.find('.un-check').show();
      $this.find('.select-asset-group-button').addClass('active');
    }
  });
});

//$(document).on('click', '.checked-asset', function(e) {
//  e.preventDefault();
//  var $this = $(this);
//  $this.closest('.thumbnail').find('.show-buttons').find('form')[0].submit();
//});

//my-library-link => my-library-form
$(document).on('click', '.my-library-link', function(e)  {
  var $this = $(this);
  setTimeout( function() {  $('form#my-library-form').submit();
  }, 1);
  animateSiteOption($this);
});

//my-document-link => my-document-form
$(document).on('click', '.my-documents-link', function(e)  {
  var $this = $(this);
  setTimeout( function() {  $('form#my-documents-form').submit();
  }, 1);
  animateSiteOption($this);
});


// Executes the processSelection function when a site selection is clicked
// $(document).on('click', '.site-option', function () {
$(document).on('click', '.interactable', function () {
  var $this = $(this);
  var thisClass = $this.attr('id');
  // console.log(thisClass);


  $('#search_form_adcreator').val('');
  $('#search_form_asset-library').val('');
  $('#search_form_user-library').val('');
  $('#search_form_my-documents').val('');
  $('#search_form_user-content').val('');

  $('#search_form_' + thisClass).val(thisClass);

  if ($this.hasClass('my-library-home')) {
    $('#group_results_by_user_category').val('1');
  }

  // submit form
  $('form#search_form').submit();
  //animate

  processSelection($this);
  $('#filter-' + thisClass).prop('checked', true);
  $('#filter-' + thisClass).closest('div').addClass('active');
  // clearGlobalFilter(text);
});

function resetSearchFilters(no_submit,update_filters) {
  $('#search_form_topics').val('');
  $('#search_form_sub_topics').val('');
  $('#search_form_media_types').val('');
  $('#search_form_sub_media_types').val('');
  $('#search_form_user_categories').val('');
  $('#search_form_access_levels').val('');
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_topics').val('');
    $('#search_filters_form_sub_topics').val('');
    $('#search_filters_form_media_types').val('');
    $('#search_filters_form_sub_media_types').val('');
    $('#search_filters_form_user_categories').val('');  
    $('#search_filters_form_access_levels').val('');
    runSearchFiltersForm();
  }
}

function setAccessLevel(access_level,no_submit,update_filters) {
  resetSearchFilters(true,false);
  $('#search_form_access_levels').val(access_level);
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
  $('#search_filters_form_access_levels').val(access_level);
    runSearchFiltersForm();
  }
}

function setTopic(topic,no_submit,update_filters) {
  $('#search_form_topics').val(topic);
  $('#search_form_sub_topics').val('');
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_topics').val(topic);
    $('#search_filters_form_sub_topics').val('');
    runSearchFiltersForm();
  }
}

function setSubTopic(sub_topic,no_submit,update_filters) {
  $('#search_form_sub_topics').val(sub_topic);
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_sub_topics').val(sub_topic);
    runSearchFiltersForm();
  }
}

function setMediaType(media_type,no_submit,update_filters) {
  $('#search_form_media_types').val(media_type);
  $('#search_form_sub_media_types').val('');
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_media_types').val(media_type);
    $('#search_filters_form_sub_media_types').val('');
    runSearchFiltersForm();
  }
}

function setSubMediaType(sub_media_type,no_submit,update_filters) {
  $('#search_form_sub_media_types').val(sub_media_type);
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_sub_media_types').val(sub_media_type);
    runSearchFiltersForm();
  }
}

function setUserCategory(user_category,no_submit,update_filters) {
  $('#search_form_user_categories').val(user_category);
  if (!no_submit) {
    runSearchForm();
  }
  if (update_filters) {
    $('#search_filters_form_user_categories').val(user_category);
    runSearchFiltersForm();
  }
}

function setSort(sort,no_submit, sort_title) {
  $('#search_form_sort').val(sort);
  if (!no_submit) {
    runSearchForm();
  }

}

$(document).on('click', '#group_results_by_user_category_checkbox', function() {
  var $this = $(this),
  value = 1;
  if ( $this.prop('checked') === false ) {
    value = 0;
  }
  $('#group_results_by_user_category').val( value );
  runSearchForm();
});

function runSearchForm() {
    $('form#search_form').submit();
    $('#clear_categorize').val(0);
}

function runSearchFiltersForm() {
    $('form#search_filters_form').submit();
    $('#search_filter_clear_categorize').val(0);
}

// could be more data driven lots of instantiation replication
$(document).on('click', '.main-categories', showSubTerms);
$(document).on('click', '.topic', function() {
  var term = $(this).data('term');
  var term_type = $(this).data('term-type');
  clearTermType(term_type);
  setTopic(term,1);
  $(this).addClass('active');
});
$(document).on('click', '.sub-topic', function() {
  var term = $(this).data('term');
  var term_type = $(this).data('term-type');
  clearTermType(term_type);
  setSubTopic(term,1);
  $(this).addClass('active');
});
$(document).on('click', '.media-type', function() {
  var term = $(this).data('term');
  var term_type = $(this).data('term-type');
  clearTermType(term_type);
  setMediaType(term,1);
  $(this).addClass('active');
});
$(document).on('click', '.sub-media-type', function() {
  var term = $(this).data('term');
  var term_type = $(this).data('term-type');
  clearTermType(term_type);
  setSubMediaType(term,1);
  $(this).addClass('active');
});
$(document).on('click', '.search-form-submit', runSearchForm);

//remove active from all term-type
function clearTermType(term_type) {
  $('.' + term_type).each( function(i) {
    $(this).removeClass('active');
  });
}

function showSubTerms() {
  var term = $(this).data('term');
  var term_type = $(this).data('term-type');
  clearTermType('sub-' + term_type);
  // Determine your class

  // ONly set your sub type
  // Need to iterate over all sub-categories and active if data-parent = parent_term
  $('.sub-categories').each( function(i)  {
    var sub_term = $(this);
    // console.log ("term + ' - ' + term_type + ' - ' + sub_term.data('parent')");
    // console.log (term + ' - ' + term_type  + ' - ' + sub_term.hasClass('sub-' + term_type) + ' - ' + sub_term.data('parent') + ' - ' + sub_term.data('term'));
    // if (sub_term.data('parent') == term && sub_term.hasClass('sub-' + term_type)) {
      //Still need to remove active from sibling sub-class, active should only be $this
    if (sub_term.data('parent') === term) {
      sub_term.css('display', 'block');
      // sub_term.addClass('active');
    }
    else {
      if (sub_term.hasClass('sub-' + term_type)) {
        sub_term.css('display', 'none');
        // sub_term.removeClass('active');
      }
    }
  });
}

////Shared page version
// Launch Asset Preview - fade in Asset Detail
$(document).on('click', '.shared-page-preview-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  // $('div#shared-page').fadeOut("fast");
  $('div#asset-preview-panel').fadeIn("slow");
});
// Launch Asset Detail - fade in Asset Detail
$(document).on('click', '.shared-page-asset-detail-button, .shared-page-video-preview-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  // $('div#shared-page').fadeOut("fast");
  // $('div#shared-page-asset-detail-contents').fadeIn("slow");
});
// Close Asset Detail - fade out Asset Detail
$(document).on('click', 'a#close-shared-page-asset-detail', function(e) {
  e.preventDefault();
  $('div#shared-page-asset-detail-contents').fadeOut("fast");
  // $('div#shared-page').fadeIn("slow");
  $('div#shared-page-asset-detail-display').html('');  
});

// Close Shared Page Asset Preview - fade out Asset Detail
$(document).on('click', 'a#close-shared-page-asset-preview', function(e) {
  e.preventDefault();
  $('div#shared-page-asset-preview-panel').fadeOut();
  $('div#shared-page-asset-preview-panel').html('');
});

// Launch Asset Preview - fade in Asset Preview
$(document).on('click', '.asset-preview-button, .video-preview-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  // $('div#asset-preview-panel').fadeIn("slow");
});
// Launch Asset Detail - fade in Asset Detail
$(document).on('click', '.asset-detail-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('div#asset-detail-contents').fadeIn("slow");
});
// Close Asset Detail - fade out Asset Detail
$(document).on('click', 'a#close-asset-detail', function(e) {
  e.preventDefault();
  $('div#asset-detail-contents').fadeOut();
  $('div#asset-detail-display').html('');
});

// Close Asset Preview - fade out Asset Detail
$(document).on('click', 'a#close-asset-preview', function(e) {
  e.preventDefault();
  $('div#asset-preview-panel').fadeOut();
  $('div#asset-preview-panel').html('');
});

// Close Categorize - fade out Categorize
$(document).on('click', 'a#close-categorize', function(e) {
  e.preventDefault();
  // assetGroupInitForm();
  $('#clear_categorize').val(1);
  setAssetGroupButton(0);
  runSearchForm();
  $('div#categorize-contents').fadeOut();
  setTimeout(function() {
    $('div#categorize-panel').fadeOut();
  }, 350);
});

// Launch Categorize - fade in Categorize
$(document).on('click', '.select-category-submit', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('div#categorize-contents').fadeIn("slow");
});
// Launch Share - fade in Share
$(document).on('click', '.share-asset-submit', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  $('div#share-contents').fadeIn("slow");
});
// Close Share - fade out Share
$(document).on('click', 'a#close-share', function(e) {
  e.preventDefault();
  assetGroupInitForm();
  $('div#share-contents').fadeOut();
  setTimeout( $('div#share-panel').fadeOut(), 50);
});

$(document).on('click','.download-single-file-button', function(e) {
  e.preventDefault();
  // console.log('download-asset-button clicked');
  $(this).closest('form').submit();
});

$(document).on('click','.download-asset-button', function(e) {
  e.preventDefault();
  // console.log('download-asset-button clicked');
  $(this).closest('form').submit();
});

$(document).on('click','.select-asset-group-button', function(e) {
  e.preventDefault();
  var num_asset_group_items = numAssetGroupItems();
  var num_asset_group_admin_keywords_items = numAssetGroupAdminKeywordsItems();
  var num_asset_group_share_items = numAssetGroupShareItems();
  var num_asset_group_download_items = numAssetGroupDownloadItems();
  var num_asset_group_categorize_items = numAssetGroupCategorizeItems();

  var modifier = -1;
  if ($(this).hasClass('active')) {
    modifier = 1;
  }

  num_asset_group_items = num_asset_group_items + modifier;

  if ($(this).hasClass('asset-group-admin-keywords')) {
    num_asset_group_admin_keywords_items = num_asset_group_admin_keywords_items + modifier;
  }
  if ($(this).hasClass('asset-group-share')) {
    num_asset_group_share_items = num_asset_group_share_items + modifier;
  }
  // if ($(this).hasClass('asset-group-download')) {
    num_asset_group_download_items = num_asset_group_download_items + modifier;
  // }
  // if ($(this).hasClass('asset-group-categorize')) {
    num_asset_group_categorize_items = num_asset_group_categorize_items + modifier;
  // }

  setAssetGroupButton( num_asset_group_items );
  setAssetGroupAdminKeywordsButton( num_asset_group_admin_keywords_items );
  setAssetGroupShareButton( num_asset_group_share_items );
  setAssetGroupDownloadButton( num_asset_group_download_items );
  setAssetGroupCategorizeButton( num_asset_group_categorize_items );

  $(this).closest('form').submit();
});

$(document).on('click','.checked-asset', function(e) {
  e.preventDefault();
  var num_asset_group_items = numAssetGroupItems();
  var num_asset_group_admin_keywords_items = numAssetGroupAdminKeywordsItems();
  var num_asset_group_share_items = numAssetGroupShareItems();
  var num_asset_group_download_items = numAssetGroupDownloadItems();
  var num_asset_group_categorize_items = numAssetGroupCategorizeItems();

  var modifier = -1,
  token = $(this).data('token');
  num_asset_group_items = num_asset_group_items + modifier;

  if ($(this).hasClass('asset-group-admin-keywords')) {
    num_asset_group_admin_keywords_items = num_asset_group_admin_keywords_items + modifier;
  }
  if ($(this).hasClass('asset-group-share')) {
    num_asset_group_share_items = num_asset_group_share_items + modifier;
  }
  // if ($(this).hasClass('asset-group-download')) {
    num_asset_group_download_items = num_asset_group_download_items + modifier;
  // }
  // if ($(this).hasClass('asset-group-categorize')) {
    num_asset_group_categorize_items = num_asset_group_categorize_items + modifier;
  // }

  setAssetGroupButton( num_asset_group_items );
  setAssetGroupAdminKeywordsButton( num_asset_group_admin_keywords_items );
  setAssetGroupShareButton( num_asset_group_share_items );
  setAssetGroupDownloadButton( num_asset_group_download_items );
  setAssetGroupCategorizeButton( num_asset_group_categorize_items );

  $(this).find('form').submit();

  $('.thumb-' + token).each(function(index) {
    $(this).find('.select-asset-group-button').removeClass('selected-asset-border active');
    $(this).removeClass('selected-asset-border active');
    $(this).find('.un-check').hide();
    $(this).find('.checked-asset').hide();
  });


});

$(function() {

  $(document).on('submit', 'form#search_form', function() {
    // get all the inputs into an array.

    $('#main-site-options').fadeOut(function()  { // Fades out then removes other site options and Twitter feed
      $('div#search-results-area').fadeIn();
    });

    return false; // return false to cancel form action
  });
});


// Show & Animate Results Buttons

  $(document).on('mouseenter', '.thumbnail', function() {
    //$(this).find('.show-buttons').addClass('animated bounceInUp');
    $(this).find('.show-buttons').stop().show().animate({'bottom': '59px'}, 300);
    $(this).find('.cart-icon').stop().fadeIn('fast');
    $(this).find('.fav-star').stop().fadeIn('fast');
    $(this).find('.remove-button').stop().fadeIn('fast');
    $(this).find('.unbundle-button').stop().fadeIn('fast');
  });
  $(document).on('mouseleave', '.thumbnail', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).find('.show-buttons').stop().animate({'bottom': '23px'}, 300, function(){ $(this).hide();});
    if ($(this).find('.cart-icon').hasClass('active')) {
    }
    else {
  		$(this).find('.cart-icon').stop().fadeOut('fast');
    }
    if ($(this).find('.fav-star').hasClass('active')) {
    }
    else {
      $(this).find('.fav-star').stop().fadeOut('fast');
    }
    $(this).find('.remove-button').stop().fadeOut('fast');
    $(this).find('.unbundle-button').stop().fadeOut('fast');
  });

  $(document).on('mouseenter', '.remove-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).find('.remove-text').stop().animate({'right': '0px'}, 300);
  });
  $(document).on('mouseleave', '.remove-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).find('.remove-text').stop().animate({'right': '-80px'}, 300);
  });
  
   $(document).on('mouseenter', '.unbundle-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).find('.unbundle-text').stop().animate({'right': '0px'}, 300);
  });
  $(document).on('mouseleave', '.unbundle-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).find('.unbundle-text').stop().animate({'right': '-80px'}, 300);
  });

  $(document).on('click', '.remove-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).closest('.thumbnail').find('.are-you-sure').stop().animate({'right': '0px'}, 300);
    $(this).closest('.thumbnail').find('.clip-are-you-sure').show();
  });
  $(document).on('click', '.no-remove-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
		$(this).closest('.thumbnail').find('.are-you-sure').stop().animate({'right': '-200px'}, 300, function(){ $(this).closest('.thumbnail').find('.clip-are-you-sure').hide(); });
    //$('.clip-are-you-sure').hide();
  });
  
  
  $(document).on('click', '.unbundle-button', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
    $(this).closest('.thumbnail').find('.are-you-sure-unbundle').stop().animate({'right': '0px'}, 300);
    $(this).closest('.thumbnail').find('.clip-are-you-sure-unbundle').show();
  });
  $(document).on('click', '.no-remove-button-unbundle', function() {
    //$(this).find('.show-buttons').addClass('animated bounceOutDown')
		$(this).closest('.thumbnail').find('.are-you-sure-unbundle').stop().animate({'right': '-200px'}, 300, function(){ $(this).closest('.thumbnail').find('.clip-are-you-sure-unbundle').hide(); });
    //$('.clip-are-you-sure').hide();
  });

  $(document).on('mouseenter', '.checked-asset', function() {
    $(this).find('.un-checked').show();
    $(this).find('.ed-checked').hide();
  });
  $(document).on('mouseleave', '.checked-asset', function() {
    $(this).find('.un-checked').hide();
    $(this).find('.ed-checked').show();
  });

  $(document).on('mouseenter', '.share-asset-group-button', function() {
    $(this).find('.classic').show();
  });
  $(document).on('mouseleave', '.share-asset-group-button', function() {
    $(this).find('.classic').hide();
  });
  $(document).on('click', '.share-asset-group-button', function() {
    $(this).find('.classic').hide();
  });
  
  $(document).on('click', '.cart-icon', function() {
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');
    }
    else {
      $(this).addClass('active');
    }
  });	
  $(document).on('click', '.fav-star', function() {
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');
    }
    else {
      $(this).addClass('active');
    }
  });

function more_search_results(button) {
  var more_count = button.data('more-count'),
  count = 0,
  hidden_count = 0;
  button.parent().parent().find('.paginate-result').each(function() {
    if ( !$(this).is(":visible") ) {
      if (count < more_count) {
        $(this).find('.paginate').each(function() {
          var image = $(this).data('image-url');
          $(this).html('<img src="' + image + '">');
            count = count + 1;
        });
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

$(document).on('click', '.show-search-results', function()  {
  more_search_results($(this));
});

$(document).on('click', '.external-link', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  var url = $(this).data('external-link');
  window.open(url, '_blank');
});

function init_audio() {
  var audioSection = $('section#audio');
  $('a.html5').each(function() {

      var audio = $('<audio>', {
           controls : 'controls'
      });

      var url = $(this).attr('href');
      $('<source>').attr('src', url).appendTo(audio);
      audioSection.html(audio);
      return false;
  });
}

