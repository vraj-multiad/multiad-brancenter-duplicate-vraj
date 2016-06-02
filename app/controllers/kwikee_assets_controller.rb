class KwikeeAssetsController < ApplicationController
  before_action :set_kwikee_asset, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /kwikee_assets
  # GET /kwikee_assets.json
  def index
    @kwikee_assets = KwikeeAsset.all
  end

  # GET /kwikee_assets/1
  # GET /kwikee_assets/1.json
  def show
  end

  # GET /kwikee_assets/new
  def new
    @kwikee_asset = KwikeeAsset.new
  end

  # GET /kwikee_assets/1/edit
  def edit
  end

  # POST /kwikee_assets
  # POST /kwikee_assets.json
  def create
    @kwikee_asset = KwikeeAsset.new(kwikee_asset_params)

    respond_to do |format|
      if @kwikee_asset.save
        format.html { redirect_to @kwikee_asset, notice: 'Kwikee asset was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_asset }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_assets/1
  # PATCH/PUT /kwikee_assets/1.json
  def update
    respond_to do |format|
      if @kwikee_asset.update(kwikee_asset_params)
        format.html { redirect_to @kwikee_asset, notice: 'Kwikee asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_assets/1
  # DELETE /kwikee_assets/1.json
  def destroy
    @kwikee_asset.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_assets_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_asset
      @kwikee_asset = KwikeeAsset.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_asset_params
      params.require(:kwikee_asset).permit(:kwikee_product_id, :asset_id, :promotion, :asset_type, :version, :view)
    end
end
