class SharedPagesController < ApplicationController
  before_action :set_shared_page, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /shared_pages
  # GET /shared_pages.json
  def index
    @shared_pages = SharedPage.all
  end

  # GET /shared_pages/1
  # GET /shared_pages/1.json
  def show
  end

  # GET /shared_pages/new
  def new
    @shared_page = SharedPage.new
  end

  # GET /shared_pages/1/edit
  def edit
  end

  # POST /shared_pages
  # POST /shared_pages.json
  def create
    @shared_page = SharedPage.new(shared_page_params)

    respond_to do |format|
      if @shared_page.save
        format.html { redirect_to @shared_page, notice: 'Shared page was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shared_page }
      else
        format.html { render action: 'new' }
        format.json { render json: @shared_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shared_pages/1
  # PATCH/PUT /shared_pages/1.json
  def update
    respond_to do |format|
      if @shared_page.update(shared_page_params)
        format.html { redirect_to @shared_page, notice: 'Shared page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shared_page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shared_pages/1
  # DELETE /shared_pages/1.json
  def destroy
    @shared_page.destroy
    respond_to do |format|
      format.html { redirect_to shared_pages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shared_page
      @shared_page = SharedPage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shared_page_params
      params.require(:shared_page).permit(:user_id, :token, :expiration_date)
    end
end
