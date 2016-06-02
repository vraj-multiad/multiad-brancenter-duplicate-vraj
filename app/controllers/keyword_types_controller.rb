class KeywordTypesController < ApplicationController
  before_action :set_keyword_type, only: [:show, :edit, :update, :destroy]
  before_action :superuser?


  # GET /keyword_types
  # GET /keyword_types.json
  def index
    @keyword_types = KeywordType.all
  end

  # GET /keyword_types/1
  # GET /keyword_types/1.json
  def show
  end

  # GET /keyword_types/new
  def new
    @keyword_type = KeywordType.new
  end

  # GET /keyword_types/1/edit
  def edit
  end

  # POST /keyword_types
  # POST /keyword_types.json
  def create
    @keyword_type = KeywordType.new(keyword_type_params)

    respond_to do |format|
      if @keyword_type.save
        format.html { redirect_to @keyword_type, notice: 'Keyword type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @keyword_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @keyword_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyword_types/1
  # PATCH/PUT /keyword_types/1.json
  def update
    respond_to do |format|
      if @keyword_type.update(keyword_type_params)
        format.html { redirect_to @keyword_type, notice: 'Keyword type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @keyword_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyword_types/1
  # DELETE /keyword_types/1.json
  def destroy
    @keyword_type.destroy
    respond_to do |format|
      format.html { redirect_to keyword_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyword_type
      @keyword_type = KeywordType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keyword_type_params
      params.require(:keyword_type).permit(:name, :title, :label)
    end
end
