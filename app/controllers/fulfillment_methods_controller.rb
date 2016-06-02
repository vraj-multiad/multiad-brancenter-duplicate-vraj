# class FulfillmentMethodsController < ApplicationController
class FulfillmentMethodsController < ApplicationController
  before_action :set_fulfillment_method, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /fulfillment_methods
  # GET /fulfillment_methods.json
  def index
    @fulfillment_methods = FulfillmentMethod.all
  end

  # GET /fulfillment_methods/1
  # GET /fulfillment_methods/1.json
  def show
  end

  # GET /fulfillment_methods/new
  def new
    @fulfillment_method = FulfillmentMethod.new
  end

  # GET /fulfillment_methods/1/edit
  def edit
  end

  # POST /fulfillment_methods
  # POST /fulfillment_methods.json
  def create
    @fulfillment_method = FulfillmentMethod.new(fulfillment_method_params)

    respond_to do |format|
      if @fulfillment_method.save
        format.html { redirect_to @fulfillment_method, notice: 'Fulfillment method was successfully created.' }
        format.json { render action: 'show', status: :created, location: @fulfillment_method }
      else
        format.html { render action: 'new' }
        format.json { render json: @fulfillment_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fulfillment_methods/1
  # PATCH/PUT /fulfillment_methods/1.json
  def update
    respond_to do |format|
      if @fulfillment_method.update(fulfillment_method_params)
        format.html { redirect_to @fulfillment_method, notice: 'Fulfillment method was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fulfillment_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fulfillment_methods/1
  # DELETE /fulfillment_methods/1.json
  def destroy
    @fulfillment_method.destroy
    respond_to do |format|
      format.html { redirect_to fulfillment_methods_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fulfillment_method
      @fulfillment_method = FulfillmentMethod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fulfillment_method_params
      params.require(:fulfillment_method).permit(:name, :title, :email_address)
    end
end
