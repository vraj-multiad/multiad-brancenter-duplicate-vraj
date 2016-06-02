class DlCartItemsController < ApplicationController
  before_action :set_dl_cart_item, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, except: [:new]

  
  # GET /dl_cart_items
  # GET /dl_cart_items.json
  def index
    @dl_cart_items = DlCartItem.all
  end

  # GET /dl_cart_items/1
  # GET /dl_cart_items/1.json
  def show
  end

  # GET /dl_cart_items/new
  def new
    # check to see if item in cart already
    @current_cart = current_cart
    asset = LoadAsset.load_asset(type: params[:downloadable_type], token: params[:token])

    cart_items = DlCartItem.where('dl_cart_id = ? and downloadable_type = ? and downloadable_id = ? ', current_cart.id, params[:downloadable_type], asset.id)

    if cart_items.length > 0
      cart_items[0].destroy
    else
      @dl_cart_item = DlCartItem.new
      @dl_cart_item.dl_cart_id = current_cart.id
      @dl_cart_item.downloadable_id = asset.id
      @dl_cart_item.downloadable_type = params[:downloadable_type]
      @dl_cart_item.save
    end
    @current_cart_items = current_cart_items
    logger.debug @current_cart_items.inspect
    render partial: 'cart_num_items', content_type: 'text/html'
  end

  # GET /dl_cart_items/1/edit
  def edit
  end

  # POST /dl_cart_items
  # POST /dl_cart_items.json
  def create
    @dl_cart_item = DlCartItem.new(dl_cart_item_params)

    respond_to do |format|
      if @dl_cart_item.save
        format.html { redirect_to @dl_cart_item, notice: 'Dl cart item was successfully updated.' }
      end
    end
  end

  # PATCH/PUT /dl_cart_items/1
  # PATCH/PUT /dl_cart_items/1.json
  def update
    respond_to do |format|
      if @dl_cart_item.update(dl_cart_item_params)
        format.html { redirect_to @dl_cart_item, notice: 'Dl cart item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dl_cart_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dl_cart_items/1
  # DELETE /dl_cart_items/1.json
  def destroy
    ### need to prevent unauthorized removal
    logger.debug 'current_cart' + current_cart.inspect
    logger.debug 'dl_cart_item: ' + @dl_cart_item.inspect
    @dl_cart_item.destroy if current_cart.id == @dl_cart_item.dl_cart_id
    respond_to do |format|
      # format.html { redirect_to dl_cart_items_url }
      format.html { redirect_to '/dl_cart' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dl_cart_item
      @dl_cart_item = DlCartItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dl_cart_item_params
      params.require(:dl_cart_item).permit(:dl_cart_id, :downloadable_id, :downloadable_type)
    end
end
