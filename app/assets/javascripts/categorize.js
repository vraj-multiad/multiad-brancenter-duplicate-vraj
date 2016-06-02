$(document).on('click', '.dropdown-menu li.category-selections', function(e) {
  e.stopPropagation();
});

// target multiple functions using common selection method
$(document).on('click', '.admin-advanced-submit', function(e) {
  e.stopPropagation();
  var action = $(this).data('action');
  if ($(this).parents('form')[0].action.length > 0) {
    $(this).parents('form')[0].action = action;
  }
  $(this).parents('form').submit();
});


// show hide tabs on categorize panel add/edit/advanced
$(document).on('click', '#categorize-add-tab', function(e) {
  e.stopPropagation();
  var $this = $(this);
  $('#categorize-add-tab').addClass('active');
  $('#categorize-edit-tab').removeClass('active');
  $('#categorize-advanced-tab').removeClass('active');
  $('#categorize-add').css({'display':'block'});
  $('#categorize-edit').css({'display':'none'});
  $('#categorize-advanced').css({'display':'none'});
});
$(document).on('click', '#categorize-edit-tab', function(e) {
  e.stopPropagation();
  var $this = $(this);
  $('#categorize-edit-tab').addClass('active');
  $('#categorize-add-tab').removeClass('active');
  $('#categorize-advanced-tab').removeClass('active');
  $('#categorize-edit').css({'display':'block'});
  $('#categorize-add').css({'display':'none'});
  $('#categorize-advanced').css({'display':'none'});
});
$(document).on('click', '#categorize-advanced-tab', function(e) {
  e.stopPropagation();
  var $this = $(this);
  $('#categorize-advanced-tab').addClass('active');
  $('#categorize-add-tab').removeClass('active');
  $('#categorize-edit-tab').removeClass('active');
  $('#categorize-advanced').css({'display':'block'});
  $('#categorize-add').css({'display':'none'});
  $('#categorize-edit').css({'display':'none'});
});

// show hide tabs on categorize panel (my library) add/edit/advanced
$(document).on('click', '#categorize-add-tab-library', function(e) {
  e.stopPropagation();
  var $this = $(this);
  $('#categorize-add-tab-library').addClass('active');
  $('#categorize-edit-tab-library').removeClass('active');
  $('#categorize-add-library').css({'display':'block'});
  $('#categorize-edit-library').css({'display':'none'});
});
$(document).on('click', '#categorize-edit-tab-library', function(e) {
  e.stopPropagation();
  var $this = $(this);
  $('#categorize-edit-tab-library').addClass('active');
  $('#categorize-add-tab-library').removeClass('active');
  $('#categorize-edit-library').css({'display':'block'});
  $('#categorize-add-library').css({'display':'none'});
});

// form action: /admin/fulfillment_items -> replace panel-admin-advanced  
$(document).on('click', '.asset-admin-advanced-submit', function(e)  {
  e.stopPropagation();
  $(this).parents('form').submit();
});

// panel-admin-advanced
// open panel-admin-advanced
function asset_admin_advanced_open() {
  $('#categorize-advanced').hide();
  $('#panel-admin-advanced').show();
  initDatepicker();
  $('.admin-tab').hide();
}
// close panel-admin-advanced
function asset_admin_advanced_close() {
  $('#panel-admin-advanced').fadeOut().html('');
  $('#categorize-advanced').fadeIn();
  $('.admin-tab').fadeIn();
}
$(document).on('click', '.asset-admin-advanced-close', function(e)  {
  e.stopPropagation();
  $('form#admin-admin-advanced-refresh').submit();
  asset_admin_advanced_close();
  // $('#panel-admin-advanced').fadeOut().html('');
  // $('#categorize-advanced').fadeIn();
  // $('.admin-tab').fadeIn();
});

// panel-admin-advanced  display-edit-asset-asset
$(document).on('click', '.edit-asset-display-asset', function(e)  {
  e.stopPropagation();
  $('.edit-asset').hide();
  $('#' + $(this).data('asset-token') ).show();
});
// panel-admin-advanced  display-fulfillment-asset
$(document).on('click', '.fulfillment-item-display-asset', function(e)  {
  e.stopPropagation();
  $('.fulfillment-asset').hide();
  $('#' + $(this).data('asset-token') ).show();
});
// panel-admin-advanced  add-priceline
$(document).on('click', '.add-priceline', function(e)  {
  e.stopPropagation();
  $(this).parent().append('<div class="priceline"><div class="form-group" style="width:44%;float:left"><span>Number of Units</span><input type="text" name="quantity[]" class="form-control"></div><div class="form-group" style="width:44%;float:left;margin-left:2%;"><span>Price Per Unit</span><input type="text" name="price[]" class="form-control"></div><div class="form-group" style="float:left;text-align:center;width:8%;margin-left:2%;"><span style="display:block">&nbsp;</span><div class="delete-priceline btn btn-default add-new-filter-submit" style="width:100%;padding:8px 8px;"><div class="glyphicon glyphicon-remove"></div></div></div>');
});
// panel-admin-advanced  delete-priceline
$(document).on('click', '.delete-priceline', function(e)  {
  e.stopPropagation();
  $(this).parent().parent().remove();
});

// Adds/removes 'active' class for image choices on click
$(document).on('click', '.categorize-choice', function(e)  {
  e.stopPropagation();
  var $this = $(this),
    $thisCheckbox = $this.find('input:checkbox'),
    $submitButt = $this.parents('form').find('.submit-butt');
    
  if ($this.hasClass('active')){
    $this.removeClass('active');
    $thisCheckbox.prop('checked', false);
  }
  
  else {
    $this.addClass('active');
    $thisCheckbox.prop('checked', true);
  }

  if ($this.parents('form').find('.categorize-choice.active').length > 0) {
    if ($submitButt.hasClass('disabled')) {
      $submitButt.removeClass('disabled');
    }
  }
  else {
    if (!$submitButt.hasClass('disabled')) {
      $submitButt.addClass('disabled');
    }
  }
  //dynamic initially for contributor+ function may extend to user-keyword
  if ($this.hasClass('dynamic')) {
    refreshRemoveDataListDynamic();
  }
  else {
    refreshRemoveDataList();
  }
});


// Adds/removes 'active' class for image choices on select all click
$(document).on('click', '.categorize-choice-all', function(e)  {
  e.stopPropagation();
  $submitButt = $(this).parents('form').find('.submit-butt');
  if ( $(this).hasClass('active') ) {
    $(this).removeClass('active');
    $(this).parents('form').find('.categorize-choice').each( function () {
      var $this = $(this),
        $thisCheckbox = $this.find('input:checkbox');
      $this.removeClass('active');
      $thisCheckbox.prop('checked', false);
    });
    $submitButt.addClass('disabled');
    if ($(this).hasClass('dynamic')) {
      refreshRemoveDataListDynamic();
    }
    else {
      refreshRemoveDataList();
    }
  }
  else {
    $(this).addClass('active');
    $(this).parents('form').find('.categorize-choice').each( function () {
      var $this = $(this),
        $thisCheckbox = $this.find('input:checkbox');
      $this.addClass('active');
      $thisCheckbox.prop('checked', true);
    });
    $submitButt.removeClass('disabled');
    if ($(this).hasClass('dynamic')) {
      refreshRemoveDataListDynamic();
    }
    else {
      refreshRemoveDataList();
    }
  }
});


function distinct(value, index, self) { 
    return self.indexOf(value) === index;
}

function refreshRemoveDataListDynamic() {
  var choices = $('.remove-categorize-choice.active');
  var categories_remove = $('.categories-remove');
  var all_keywords_hash = {};
  var all_keywords_hash_values = {};
  $('.remove-type-dynamic').empty();
  $('.categories.remove').hide();

  choices.each(function(index) {
    var $this = $(this);
    var admin_keyword_strings = $this.find('.admin-keyword-string-field');
    admin_keyword_strings.each(function(index) {
      var $keyword_string = $(this);
      // console.log('admin_keyword_strings: ' + $keyword_string);
      // console.log('admin_keyword_strings: ' + $keyword_string.data('type') + ":" + $keyword_string.val());
      var keyword_string_value = $keyword_string.val();
      var data_type = $keyword_string.data('type');
      var keywords = keyword_string_value.split(',');
      if (!all_keywords_hash.hasOwnProperty(data_type)) {
        all_keywords_hash[data_type] = [];
        all_keywords_hash_values[data_type] = {};
      }
      $.each(keywords, function (index, value) {
        all_keywords_hash[data_type].push (value);
        all_keywords_hash_values[data_type][value] = 1;
      });
    });
  });
  // console.log ('all_keywords_hash_values: ' + JSON.stringify(all_keywords_hash_values));
  categories_remove.each(function(index, category){
    var thisCheckbox = $(category).find('input:checkbox');
    var data_type = thisCheckbox.data('type');
    // console.log('categories_remove data_type = value: ' + data_type + " = " + thisCheckbox.val().toLowerCase());
    if (all_keywords_hash_values[data_type] &&   all_keywords_hash_values[data_type][ thisCheckbox.val().toLowerCase() ] === 1) {
      thisCheckbox.prop('checked', true);
      $(category).show();
      $(category).addClass('active');
    }
    else {
      thisCheckbox.prop('checked', false);
      $(category).hide();
      $(category).removeClass('active'); 
    }

  });

  //static keywords append section
  for (var key in all_keywords_hash) {
    all_keywords_hash[key] = all_keywords_hash[key].filter(distinct);
    var selector = '#remove-' + key + '-list';
    $.each(all_keywords_hash[key], function (index, value) {
      if (value.length > 0) {
        
        
        // append_value = '<div class="remove-' + key + '-selection remove-system-keyword" data-type="' + key + '" data-value="' + value + '"><li><a class="remove-' + key + '"><span class="glyphicon glyphicon-remove"></span>' + value + '<input type="hidden" data-type="' + key + '" name="' + key + '" value="' + value + '" style="display:none;">' + '</a></li></div>';
        var append_value = '<div class="remove-' + key + '-selection remove-system-keyword" data-type="' + key + '" data-value="' + value + '"><li><a class="remove-' + key + '"><span class="glyphicon glyphicon-remove"></span>' + value + '</a></li></div>';
        $(selector).append(append_value);
      }
    });
  }
}

function refreshRemoveDataList() {
  var choices = $('.remove-categorize-choice.active');
  var all_keywords = [];
  var all_categories = [];
  choices.each(function(index) {
    var $this = $(this);
    var keywords_string = $this.find('.keywords-string').val(),
    keywords = keywords_string.split(','),
    categories_string = $this.find('.categories-string').val(),
    categories = categories_string.split(',');

    $.each(keywords, function ( index, value) {
      all_keywords.push (value);
    });
    $.each(categories, function ( index, value) {
      all_categories.push (value);
    });

  });

  all_categories = all_categories.filter(distinct);
  all_keywords = all_keywords.filter(distinct);
  // all_keywords = $.unique(all_keywords).reverse();

  $('#remove-categories-list').empty();
  $('#remove-keywords-list').empty();

  $.each(all_categories, function (index, value) {
    if (value.length > 0) {
      $('#remove-categories-list').append('<div class="remove-category-selection" data-value="' + value + '"><li><a class="remove-category"><span class="glyphicon glyphicon-remove"></span>' + value + '</a></li></div>');
    }
  });
  $.each(all_keywords, function (index, value) {
    if (value.length > 0) {
      $('#remove-keywords-list').append('<div class="remove-keyword-selection" data-value="' + value + '"><li><a class="remove-keyword"><span class="glyphicon glyphicon-remove"></span>' + value + '</a></li></div>');
    }
  });  

}


// ADD category menu display and ops
$(document).on('click', '.category-dropdown', function(e) {
  e.stopPropagation();
  var $this = $(this);
  if ( $this.hasClass('active') ) {
    $this.removeClass('active');
    $this.parent().find('.category-menu').hide();
  }
  else {
    $this.addClass('active');
    $this.parent().find('.category-menu').show();
  }
});




//category selections
$(document).on('click', '.category-selections', function(e) {
  e.stopPropagation();
  var $this = $(this),
    $thisCheckbox = $this.find('input:checkbox'),
    $term_id = $this.data('term-id');

  if ($this.hasClass('active')){
    $this.removeClass('active');
    $thisCheckbox.prop('checked', false);
    $('.child-category-selections-' + $term_id ).each( function(){
      $child_checkbox = $(this).find('input:checkbox');
      $child_checkbox.prop('checked', false);
      $(this).removeClass('active');
      $(this).hide();
    });
  }
  
  else {
    $this.addClass('active');
    $thisCheckbox.prop('checked', true);
    $('.child-category-selections-' + $term_id ).show();
  }

});


//Add category to respective text field
$(document).on('click', '.add-category-dynamic', function(e) {
  e.stopPropagation();
  var $this = $(this);

  $type = $this.data('type');
  $new_category = $this.parents('form').find('#new_' + $type);
  $category_selections = $this.parents('form').find('.category-selections-' + $type);
  $category_input = $this.parents('form').find('#' + $type);
  $selected_values = new Object();

  $category_selections.each(function(index, category) {
    var $thisCheckbox = $(category).find('input:checkbox');
    if ($(category).hasClass('active')) {
      $category_input.val( ($category_input.val() + ',' + $thisCheckbox.val()) );
      $thisCheckbox.prop('checked', false);
      $(category).removeClass('active');
      // $('#add-category-list-' + $type).append('<li class="add-category-list-item" data-type="' + $type + '">' + $thisCheckbox.val() + '</li>');
      $selected_values[$thisCheckbox.val()] = 1;
    }
  });
  $categories_selected = $this.parents('form').find('.categories-selected-' + $type);
  $categories_selected.each(function(index, category) {
    var $thisCheckbox = $(category).find('input:checkbox');
    if ($selected_values[ $thisCheckbox.val() ] === 1) {
      $thisCheckbox.prop('checked', true);
      $(category).show();
      $(category).addClass('active');

    }
    else {

    }
  }   );

  if ( $new_category.val() ) {
      $category_input.val( ($category_input.val() + ',' + $new_category.val()) );
      $('#add-category-list-' + $type).append('<li class="add-category-list-item" data-type="' + $type + '">' + $new_category.val() + '</li>');
  }

  $new_category.val('');
  $('.category-dropdown').removeClass('active');
  $('.category-selections').removeClass('active');
  $('.child-category-selections').hide();
  $('.category-menu').hide();
});

//Add category to respective text field
$(document).on('click', '.add-category', function(e) {
  e.stopPropagation();
  var $this = $(this),
  $new_category = $this.parents('form').find('#new_category'),
  $category_selections = $this.parents('form').find('.category-selections');
  $category_input = $this.parents('form').find('#category');
  $category_selections.each(function(index, category) {
    var $thisCheckbox = $(category).find('input:checkbox');
    if ($(category).hasClass('active')) {
      $category_input.val( ($category_input.val() + ',' + $thisCheckbox.val()) );
      $thisCheckbox.prop('checked', false);
      $(category).removeClass('active');
      $('#add-category-list').append('<li class="add-category-list-item">' + $thisCheckbox.val() + '</li>');
    }
  });
  if ( $new_category.val() ) {
      $category_input.val( ($category_input.val() + ',' + $new_category.val()) );
      $('#add-category-list').append('<li class="add-category-list-item">' + $new_category.val() + '</li>');
  }

  $new_category.val('');
  $('.category-dropdown').removeClass('active');
  $('.category-menu').css({'display':'none'});
});

//Add keyword to respective text field
$(document).on('click', '.add-keyword', function(e) {
  e.stopPropagation();
  var $this = $(this),
  $keyword_list = $this.parents('form').find('#keyword_list'),
  $keyword_display = $this.parents('form').find('#keyword_display');
  $keyword_input = $this.parents('form').find('#keyword');
  // console.log($this);

  $keyword_input.val( ($keyword_input.val() + ',' + $keyword_list.val()) );
  $keyword_display.val( ($keyword_input.val()) );
  $keyword_list.val('');
});

//Remove add-category-list-item
$(document).on('click', '.add-category-list-item-remove', function(e) {
  e.stopPropagation();
  $this.parent().remove();
});


//Remove keyword selection
$(document).on('click', '.remove-category', function(e) {
  e.stopPropagation();
  var $this = $(this),
    $category_input = $this.parents('form').find('#category');

  $this.parent().parent().remove();
  var $remove_string = ' ';  
  $('.remove-category-selection').each(function(index,category) {
    if ($(category).data('value') != null) {
      $remove_string = $remove_string + ',' + $(category).data('value');
    }
  });
  $category_input.val( $remove_string );

});



//Remove keyword selection
$(document).on('click', '.remove-keyword', function(e) {
  e.stopPropagation();
  var $this = $(this),
    $keyword_input = $this.parents('form').find('#keyword');

  $this.parent().parent().remove();
  var $remove_string = ' ';  
  $('.remove-keyword-selection').each(function(index,keyword) {
    if ($(keyword).data('value') != null) {
      $remove_string = $remove_string + ',' + $(keyword).data('value');
    }
  });
  $keyword_input.val( $remove_string );

});

//Remove filter keyword selection
$(document).on('click', '.remove-system-keyword-dynamic', function(e) {
  e.stopPropagation();
  var $this = $(this);
  var $keyword_type = $this.data('type') + '';
  var $keyword_input = $this.parents('form').find('#' + $keyword_type);

  $this.removeClass('active');
  var $thisCheckbox = $this.find('input:checkbox');
  $thisCheckbox.prop('checked', false);
  //remove active from children
  var $data_term_id = $this.data('term-id');
  $('.child-categories-remove-' + $data_term_id).hide();
  $('.child-categories-remove-' + $data_term_id).removeClass('active');
  $('.child-categories-remove-' + $data_term_id).find('input:checkbox').prop('checked',false);


  var $remove_string = ' ';  
  $('.categories-remove-' + $keyword_type +'.active').each(function(index,keyword) {
    var $thisCheckbox = $(keyword).find('input:checkbox');
    if ($thisCheckbox.val() != null) {
      $remove_string = $remove_string + ',' + $thisCheckbox.val();
    }
  });
  $keyword_input.val( $remove_string );
  $this.hide();
});

//Remove keyword selection
$(document).on('click', '.remove-system-keyword', function(e) {
  e.stopPropagation();
  var $this = $(this);
  var $keyword_type = $this.data('type') + '';
  var $keyword_input = $this.parents('form').find('#' + $keyword_type);

  $this.addClass('ignore');
  var $remove_string = ' ';  
  $('.remove-' + $keyword_type + '-selection').each(function(index,keyword) {
    $(keyword);
    if ($(keyword).data('value') != null && !$(keyword).hasClass('ignore')) {
      $remove_string = $remove_string + ',' + $(keyword).data('value');
    }
  });
  $keyword_input.val( $remove_string );
  $this.remove();

});

