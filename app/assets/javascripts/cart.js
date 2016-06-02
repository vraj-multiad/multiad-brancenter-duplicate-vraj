/* -----------------------------------------------------
 * Order Cart
 * ----------------------------------------------------- */
$(document).on('click', '.order-same-as-billing-submit', function(event) {
  event.preventDefault();
  $(this).closest('form').submit();
});
  // hide order-cart-panel
  // Close order-cart-panel
$(document).on('click', '.close-order-cart', function(event) {
  event.preventDefault();
  hideOrderCart();
});


$(document).on('click', '.order-cart-button', function(event) {
  event.preventDefault();
  orderCartSubmit();
});

$(document).on('click', '.remove-cart-item', function(event) {
  event.preventDefault();
  var item_id = $(this).data('item-id');
  removeCartItem(item_id);
});

$(document).on('change', '.quantity-input', function(event){
  event.preventDefault();
  orderCartUpdate();
});

function removeCartItem(item_id) {
  $('#remove_cart_item_id').val(item_id);
  orderCartUpdate();
}

function orderCartUpdate() {
  $('#order-cart-update-form').submit();
}

function orderCartSubmit() {
  $('#order-cart-panel-form').submit();
}

function showOrderCartButton() {
  $('#cart-button').fadeIn();
}

function hideOrderCartButton() {
  $('#cart-button').fadeOut();
}

function updateCartButton() {
  $('form#update-cart-button-form').submit();
}

function showOrderCart() {
  $('#order-cart-panel').fadeIn();
}

function hideOrderCart() {
  updateCartButton();
  runSearchForm();
  $('#order-cart-panel').fadeOut();
}


/* -----------------------------------------------------
 * Cart
 * ----------------------------------------------------- */

// Removes an item in the cart when its 'x' is clicked
$(document).on('click', '#cart-area .order-item .close, .download-item .close', function()  {
  var $this = $(this);

  $this.parent().fadeOut('slow', function() {
    $this.parent().remove();
  });
});

function submitCart() {
  setAssetGroupActionsHidden();
  setAssetGroupHidden();
  setCartProcessing();
  // console.log('submitting cart');
  $('#asset_group_download_form').submit();
}

function setCartButton (num_items) {
  if ( num_items > 0 ) {
    // console.log ('num_items:' + num_items);
    if ($('#dl_cart_auto_refresh').length) {
      // console.log ('dl_cart_auto_refresh:' + $('#dl_cart_auto_refresh').length);
      setCartProcessing();
    }
    else {
      // console.log ('dl_cart_auto_refresh:' + $('#dl_cart_auto_refresh').length);
      setCartVisible();
    }
  }
  else {
    // console.log ('num_items:' + num_items);
    setCartHidden();
  }
}

function setCartProcessing () {
  $('#download-all-button').css( 'display', 'none');
  $('#download-all-zipping').css( 'display', 'inline-block');
}

function setCartVisible () {
  $('#download-all-button').css( 'display', 'inline-block');
  $('#download-all-zipping').css( 'display', 'none');
}

function setCartHidden (){
  $('#download-all-button').css( 'display', 'none');
  $('#download-all-zipping').css( 'display', 'none');
}

// asset_group
function numAssetGroupItems () {
  num_items = parseInt($('#asset-group-length').html());
  // console.log("numAssetGroupItems: " + num_items);
  return num_items;
}
function numAssetGroupDownloadItems () {
  num_items = parseInt($('#asset-group-download-length').html());
  // console.log("numAssetGroupDownloadItems: " + num_items);
  return num_items;
}
function numAssetGroupAdminKeywordsItems () {
  num_items = parseInt($('#asset-group-admin-keywords-length').html());
  // console.log("numAssetGroupShareItems: " + num_items);
  return num_items;
}
function numAssetGroupShareItems () {
  num_items = parseInt($('#asset-group-share-length').html());
  // console.log("numAssetGroupShareItems: " + num_items);
  return num_items;
}
function numAssetGroupCategorizeItems () {
  num_items = parseInt($('#asset-group-categorize-length').html());
  // console.log("numAssetGroupCategorizeItems: " + num_items);
  return num_items;
}

function setAssetGroupButton (num_items) {
  $('#asset-group-length').html( num_items );
  if ( num_items > 0 ) {
    // console.log ('num_items:' + num_items);
    setAssetGroupVisible();
  }
  else {
    // console.log ('num_items:' + num_items);
    setAssetGroupHidden();
  }
}

function setAssetGroupDownloadButton (num_items) {
  $('#asset-group-download-length').html( num_items );
}

function setAssetGroupAdminKeywordsButton (num_items) {
  $('#asset-group-admin-keywords-length').html( num_items );

  if (num_items == 0 ) {
    setAssetGroupActionAdminKeywordsHidden();
  }
  else {
    setAssetGroupActionAdminKeywordsVisible();
  }
}

function setAssetGroupShareButton (num_items) {
  $('#asset-group-share-length').html( num_items );

  if (num_items == 0 ) {
    setAssetGroupActionShareHidden();
  }
  else {
    setAssetGroupActionShareVisible();
  }
}

function setAssetGroupCategorizeButton (num_items) {
  $('#asset-group-categorize-length').html( num_items );
}


function assetGroupInitForm () {
  setAssetGroupButton(0);
  $('#asset-group-button').removeClass( 'active');
  $('form#asset_group_init_form').submit();
}

function setAssetGroupVisible () {
  // $('#asset-group-button').css( 'display', 'inline-block');

  $('#asset-group-button').fadeIn('fast');

  // $('#asset-group-button').fadeOut('fast');
  // $('#asset-group-button').fadeIn('fast');
  // $('#asset-group-button').addClass('active');
}

function setAssetGroupHidden (){
  // $('#asset-group-button').css( 'display', 'none');
  $('#asset-group-button').fadeOut('fast');
  $('#asset-group-button').removeClass( 'active');
  $('.select-asset-group-button').removeClass( 'active');
  $('.selected-asset-border').removeClass( 'active');
  $('.un-check').hide();
  $('.checked-asset').fadeOut();
  setAssetGroupActionsHidden();
}


// Show and Hide AssetGroupActions on click
$(document).on('click', '#activate-action-panel', function()  {
  var $this = $(this);
  if ($this.hasClass('active')) {
    $this.removeClass('active');
    setAssetGroupActionsHidden();
  }
  else {
    $this.addClass('active');
    setAssetGroupActionsVisible();
  }
});

function setAssetGroupActionsVisible () {
  	$('#action-group').show();
    // // Animates the selected option to condense and slide upward
    // $this.animate({
    //  height: '44px',
    //  marginTop: '-165px'
    // });
  // $('.btn-group-action').css( 'display', 'inline-block');
  // $parent.fadeIn('fast', function() {
}

function setAssetGroupActionAdminKeywordsVisible (){
  $('#asset-group-share-button').fadeIn('fast');
  // $('.btn-group-action').css( 'display', 'none');
  // $parent.fadeOut('fast', function() {
  // $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
}

function setAssetGroupActionShareVisible (){
  $('.btn-group-action-share').fadeIn('fast');
  // $('.btn-group-action').css( 'display', 'none');
  // $parent.fadeOut('fast', function() {
  // $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
}


function setAssetGroupActionsHidden (){
  $('#action-group').hide();
  // $('.btn-group-action').css( 'display', 'none');
  // $parent.fadeOut('fast', function() {
  // $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
}

function setAssetGroupActionAdminKeywordsHidden (){
  $('#asset-group-share-button').fadeOut('fast');
  // $('.btn-group-action').css( 'display', 'none');
  // $parent.fadeOut('fast', function() {
  // $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
}

function setAssetGroupActionShareHidden (){
  $('.btn-group-action-share').fadeOut('fast');
  // $('.btn-group-action').css( 'display', 'none');
  // $parent.fadeOut('fast', function() {
  // $('#adcreator-top-toolbar').animate({top:'0px'}, 'slow');
}


// asset_group admin-keywords
$(document).on('click','#asset-group-admin-keywords-button', function(e) {
  e.preventDefault();
  $(this).closest("form").submit();
  setAssetGroupActionsHidden();
  setAssetGroupHidden();
  $('div#categorize-contents').fadeIn("slow");
});

// asset_group share
$(document).on('click','#asset-group-share-button', function(e) {
  e.preventDefault();
  $(this).closest("form").submit();
  $('div#share-contents').fadeIn("slow");
  setAssetGroupActionsHidden();
  setAssetGroupHidden();
  assetGroupInitForm();
});

// asset_group download
$(document).on('click','#asset-group-download-button', function(e) {
  e.preventDefault();
  // moved to submitCart to allow function
  // setAssetGroupActionsHidden();
  // setAssetGroupHidden();
  submitCart();
});

// asset_group categorize on click
$(document).on('click', '#asset-group-categorize-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  setAssetGroupActionsHidden();
  setAssetGroupHidden();
  $('div#categorize-contents').fadeIn("slow");
});

// asset_group init on click
$(document).on('click', '#asset-group-init-button', function(e)  {
  e.preventDefault();
  $(this).closest("form").submit();
  setAssetGroupButton(0);
  setAssetGroupActionsHidden();
  setAssetGroupHidden();
});
