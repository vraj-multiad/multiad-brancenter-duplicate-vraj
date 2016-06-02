class AccessLevelsController < ApplicationController
  before_action :set_access_level, only: [:show, :edit, :update, :destroy]
  before_action :superuser?


  # GET /access_levels
  # GET /access_levels.json
  def index
    @access_levels = AccessLevel.all
  end

  # GET /access_levels/1
  # GET /access_levels/1.json
  def show
  end

  # GET /access_levels/new
  def new
    @access_level = AccessLevel.new
  end

  # GET /access_levels/1/edit
  def edit
  end

  # POST /access_levels
  # POST /access_levels.json
  def create
    @access_level = AccessLevel.new(access_level_params)

    respond_to do |format|
      if @access_level.save
        format.html { redirect_to @access_level, notice: 'Access level was successfully created.' }
        format.json { render action: 'show', status: :created, location: @access_level }
      else
        format.html { render action: 'new' }
        format.json { render json: @access_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /access_levels/1
  # PATCH/PUT /access_levels/1.json
  def update
    respond_to do |format|
      if @access_level.update(access_level_params)
        format.html { redirect_to @access_level, notice: 'Access level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @access_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /access_levels/1
  # DELETE /access_levels/1.json
  def destroy
    @access_level.destroy
    respond_to do |format|
      format.html { redirect_to access_levels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_access_level
      @access_level = AccessLevel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def access_level_params
      params.require(:access_level).permit(:name, :title, :parent_access_level_id)
    end
end
