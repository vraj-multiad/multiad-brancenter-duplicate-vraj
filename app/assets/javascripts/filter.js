
// Adds/removes 'active' class for image choices on click
$(document).on('click', '.parent-keyword-type', function()  {
  var $this = $(this);
  if ($this.hasClass('active')){
    $this.removeClass('active');
    $('.child-keyword-type-' + $this.data('term-id')).hide();
  }
  else {
    $this.addClass('active');
    $('.child-keyword-type-' + $this.data('term-id')).show();
  }
});
// Submit form on add-new-filter-submit
$(document).on('click', '.add-new-filter-submit', function()  {
  var $this = $(this);
  
  $('#keyword_term_keyword_type').val($this.data('new-filter-type'));

  var parent_id = $this.data('new-filter-parent-id');
  if (parent_id != undefined) {
    $('#keyword_term_parent_term_id').val(parent_id);
  }
  else {
    $('#keyword_term_parent_term_id').val('');
  }

  var term = $('#' + $this.data('new-filter-text-id')).val();
  $('#keyword_term_term').val(term);
  $('form#add-new-filter-form').submit();
});
// Submit form on add-new-filter-submit
$(document).on('click', '.admin-filter-submit', function()  {
  $(this).closest('form').submit();
});
// Submit form on add-new-filter-submit
$(document).on('click', '.admin-filter-kt', function()  {
  $(this);
});
