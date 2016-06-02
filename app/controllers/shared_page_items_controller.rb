class SharedPageItemsController < ApplicationController
  before_action :set_shared_page_item, only: [:show, :edit, :update, :destroy]
  before_action :superuser?


  # GET /shared_page_items
  # GET /shared_page_items.json
  def index
    @shared_page_items = SharedPageItem.all
  end

  # GET /shared_page_items/1
  # GET /shared_page_items/1.json
  def show
  end

  # GET /shared_page_items/new
  def new
    @shared_page_item = SharedPageItem.new
  end

  # GET /shared_page_items/1/edit
  def edit
  end

  # POST /shared_page_items
  # POST /shared_page_items.json
  def create
    @shared_page_item = SharedPageItem.new(shared_page_item_params)

    respond_to do |format|
      if @shared_page_item.save
        format.html { redirect_to @shared_page_item, notice: 'Shared page item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shared_page_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @shared_page_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shared_page_items/1
  # PATCH/PUT /shared_page_items/1.json
  def update
    respond_to do |format|
      if @shared_page_item.update(shared_page_item_params)
        format.html { redirect_to @shared_page_item, notice: 'Shared page item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shared_page_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shared_page_items/1
  # DELETE /shared_page_items/1.json
  def destroy
    @shared_page_item.destroy
    respond_to do |format|
      format.html { redirect_to shared_page_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shared_page_item
      @shared_page_item = SharedPageItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shared_page_item_params
      params.require(:shared_page_item).permit(:shared_page_id, :shareable_id, :shareable_type)
    end
end
