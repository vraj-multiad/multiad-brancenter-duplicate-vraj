# class FulfillmentItemsController < ApplicationController
class FulfillmentItemsController < ApplicationController
  before_action :set_fulfillment_item, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :contributor?, only: [:admin]
  before_action :superuser?, only: [:index, :show, :edit, :create, :update, :destroy]

  def admin
    assets = params[:asset]
    @fulfillment_item = FulfillmentItem.new
    @fulfillment_methods = FulfillmentMethod.all
    @fulfillment_assets = []
    assets.each do |asset_type_and_token|
      asset_type, token = asset_type_and_token.split('|')
      @fulfillment_assets << LoadAsset.load_asset(type: asset_type, token: token)
    end
    # logger.debug @fulfillment_assets.inspect
    render partial: 'admin'
  end

  def add
    add_params = fulfillment_item_params
    @fulfillment_methods = FulfillmentMethod.all
    asset = LoadAsset.load_asset(type: params[:asset_type], token: params[:asset_token])
    fulfillment_item_messages = []
    if asset.present?
      add_params[:fulfillable_type] = asset.class.name
      add_params[:fulfillable_id] = asset.id
      # asset.fulfillment_items.where(fulfillment_method_id: add_params[:fulfillment_method_id]).destroy_all
      @fulfillment_item = asset.fulfillment_items.first
      price_schedule = {}
      if params[:quantity].present?
        params[:quantity].each_with_index do |q, i|
          price_schedule[q.to_i] = params[:price][i].to_f if params[:price].present? && params[:price][i].present?
        end
        fulfillment_item_messages << 'Price schedule detected'
        add_params[:price_schedule] = price_schedule.sort
      end
      if add_params[:price_schedule].present? || add_params[:price_per_unit].present?
        if @fulfillment_item.present?
          @fulfillment_item.update(add_params)
          OrderItem.joins(:order).where(orders: { status: 'open' }).where(order_items: { fulfillment_item_id: @fulfillment_item.id }).each do |uo|
            order_item = OrderItem.find(uo.id)
            if add_params[:price_per_unit].present?
              order_item.unit_price = @fulfillment_item.price_per_unit
              order_item.save
            else
              order_item.quantity = 0
              order_item.unit_price = 0
              order_item.item_total = 0
            end
          end
        else
          @fulfillment_item = FulfillmentItem.new(add_params)
        end
        fulfillment_item_messages << 'Fulfillment Asset saved'
        @fulfillment_item.save
      else
        if @fulfillment_item.present?
          @fulfillment_item.update(add_params)
        else
          @fulfillment_item = FulfillmentItem.new
        end
        fulfillment_item_messages << 'Pricing information incomplete Fulfillment information not saved'
      end
    else
      fulfillment_item_messages << 'Asset Save Failed'
    end
    render partial: 'admin_asset', locals: { fulfillment_asset: asset, fulfillment_item: @fulfillment_item, fulfillment_item_messages: fulfillment_item_messages, i: params[:asset_index], asset_count: params[:asset_count] }
  end

  # GET /fulfillment_items
  # GET /fulfillment_items.json
  def index
    @fulfillment_items = FulfillmentItem.all
  end

  # GET /fulfillment_items/1
  # GET /fulfillment_items/1.json
  def show
  end

  # GET /fulfillment_items/new
  def new
    @fulfillment_item = FulfillmentItem.new
  end

  # GET /fulfillment_items/1/edit
  def edit
  end

  # POST /fulfillment_items
  # POST /fulfillment_items.json
  def create
    @fulfillment_item = FulfillmentItem.new(fulfillment_item_params)

    respond_to do |format|
      if @fulfillment_item.save
        format.html { redirect_to @fulfillment_item, notice: 'Fulfillment item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @fulfillment_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @fulfillment_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fulfillment_items/1
  # PATCH/PUT /fulfillment_items/1.json
  def update
    respond_to do |format|
      if @fulfillment_item.update(fulfillment_item_params)
        format.html { redirect_to @fulfillment_item, notice: 'Fulfillment item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fulfillment_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fulfillment_items/1
  # DELETE /fulfillment_items/1.json
  def destroy
    @fulfillment_item.destroy
    respond_to do |format|
      format.html { redirect_to fulfillment_items_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fulfillment_item
    @fulfillment_item = FulfillmentItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fulfillment_item_params
    params.require(:fulfillment_item).permit(:fulfillable_type, :fulfillable_id, :fulfillment_method_id, :price_schedule, :price_per_unit, :weight_per_unit, :taxable, :description, :vendor_item_id, :mailing_list_item, :item_category, :item_type, :min_quantity, :max_quantity)
  end
end
