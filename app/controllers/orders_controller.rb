# class OrdersController < ApplicationController
class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, only: [:index, :show, :edit, :create, :update, :destroy]

  def cart
    @order = current_user.active_cart
    @user = current_user
    render partial: 'cart'
  end

  def add_to_cart
    orderable_type = params[:orderable_type]
    token = params[:token]
    ac_export_id = params[:ac_export_id]

    asset = LoadAsset.load_asset(token: token, type: orderable_type)
    # reenable ac_session which was auto-expired
    if asset.class.name == 'AcCreatorTemplate'
      ac_session_history = AcExport.find(ac_export_id).ac_session_history
      ac_session_history.expired = false
      ac_session_history.save
    end
    user = current_user
    active_cart = user.active_cart
    cart_item = active_cart.order_items.where(orderable_type: orderable_type, orderable_id: asset.id, ac_export_id: ac_export_id).first
    if cart_item.present? && !ac_export_id.present?
      cart_item.destroy
    else
      cart_item ||= active_cart.order_items.where(orderable_type: orderable_type, orderable_id: asset.id, ac_export_id: ac_export_id).create
      f = asset.fulfillment_items.first
      if f.present?
        cart_item.fulfillment_item_id = f.id
        cart_item.description = f.description
        if f.mailing_list_item.present?
          cart_item.quantity = 0
        else
          quantity = f.price_schedule[0].present? && f.price_schedule[0][0].present? ? f.price_schedule[0][0] : 1
          cart_item.quantity = quantity
        end
        unit_price = f.price_schedule[0].present? && f.price_schedule[0][0].present? ? f.price_schedule[0][1] : f.price_per_unit
        cart_item.unit_price = unit_price
        cart_item.description = f.description
        cart_item.save
        active_cart.save
      end
    end
    # if ac_export_id.present?
    #   return cart
    # else
    # render partial: 'cart_button', locals: { active_cart_items: user.active_cart_items }
    cart_button
    # end
  end

  def cart_button
    user = current_user
    render partial: 'cart_button', locals: { active_cart_items: user.active_cart_items }
  end

  def update_cart
    return cart_same_billing_shipping if params[:order][:same_billing_shipping].present?
    return remove_cart_item if params[:remove_cart_item_id].present?
    @order = current_user.active_cart
    notice = t('orders_notices_failed_to_update')
    notice = t('orders_notices_successful_update') if @order.id == params[:order][:id].to_i && @order.update(order_update_params)
    @order.order_items.each do |oi|
      if oi.mailing_list_id.present? && oi.mailing_list.user_id != current_user.id
        oi.mailing_list_id = nil
        oi.quantity = 0
        oi.save
        notice = t('orders_notices_failed_to_update')
      end
      if oi.fulfillment_item.min_quantity.present? && oi.fulfillment_item.min_quantity > oi.quantity
        oi.mailing_list_id = nil
        oi.quantity = 0
        oi.save
        notice = t('orders_notices_failed_min_quantity')
      end
      if oi.fulfillment_item.max_quantity.present? && oi.fulfillment_item.max_quantity < oi.quantity
        oi.mailing_list_id = nil
        oi.quantity = 0
        oi.save
        notice = t('orders_notices_failed_max_quantity')
      end
    end

    redirect_to cart_path, notice: notice
  end

  def cart_same_billing_shipping
    @order = current_user.active_cart
    notice = 'Order failed to update'
    notice = 'Order successfully updated.' if @order.id == params[:order][:id].to_i && @order.set_same_billing_shipping && @order.update(order_update_params)
    redirect_to cart_path, notice: notice
  end

  def remove_cart_item
    @order = current_user.active_cart
    notice = 'Failed to remove item'
    notice = 'Item removed from cart.' if @order.id == params[:order][:id].to_i && @order.order_items.where(id: params[:remove_cart_item_id]).destroy_all
    @order.save
    @order.save
    redirect_to cart_path, notice: notice
  end

  def process_cart
    @order = current_user.active_cart
    return redirect_to cart_path, notice: t('__shipping_address_required__') unless @order.valid_order?
    render partial: 'process_cart', notice: 'Please verify your order'
  end

  def submit_cart
    @order = current_user.active_cart
    @order.status = 'processing'
    notice = 'Processing Failed'
    @order.order_date = Time.zone.now
    if @order.id == params[:order_id].to_i && @order.save
      UserMailer.cart_confirmation_email(@order, current_language).deliver
      FulfillmentMethod.all.each do |fulfillment_method|
        next unless @order.order_items.joins(:fulfillment_item).where(fulfillment_items: { fulfillment_method_id: fulfillment_method.id }).present?
        UserMailer.cart_fulfillment_email(@order, fulfillment_method, current_language).deliver
      end
      notice = 'Your order has been submitted'
      render partial: 'process_cart', notice: notice
    else
      redirect_to cart_path, notice: notice
    end
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_update_params)
        format.html { redirect_to cart_path, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:user_id, :fulfillment_method_id, :bill_first_name, :bill_last_name, :bill_address_1, :bill_address_2, :bill_city, :bill_state, :bill_zip_code, :bill_phone_number, :bill_fax_number, :bill_email_address, :bill_comments, :bill_method, :ship_first_name, :ship_last_name, :ship_address_1, :ship_address_2, :ship_city, :ship_state, :ship_zip_code, :ship_phone_number, :ship_fax_number, :ship_email_address, :ship_comments, :shipping_method, :vendor_po_number, :status, :tracking_number, :order_comments, :currency_type, :sub_total, :tax, :handling, :total, :submitted_at, :completed_at, :bill_cost_center, :bill_external_id)
  end

  def order_update_params
    params.require(:order).permit(:fulfillment_method_id, :bill_first_name, :bill_last_name, :bill_address_1, :bill_address_2, :bill_city, :bill_state, :bill_zip_code, :bill_phone_number, :bill_fax_number, :bill_email_address, :bill_comments, :bill_method, :ship_first_name, :ship_last_name, :ship_address_1, :ship_address_2, :ship_city, :ship_state, :ship_zip_code, :ship_phone_number, :ship_fax_number, :ship_email_address, :ship_comments, :shipping_method, :status, :tracking_number, :order_comments, :same_billing_shipping, :bill_cost_center, :bill_external_id, :order_items_attributes => [:id, :quantity, :mailing_list_id])
  end
end
