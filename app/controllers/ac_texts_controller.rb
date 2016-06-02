class AcTextsController < ApplicationController
  before_action :set_ac_text, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  def search_name_title
    @name = "#{params[:name]}"
    @title = "#{params[:title]}"
    @ac_texts = []
    @ac_texts = AcText.where('name like ? and title like ?', @name, @title) if params[:name].present? && params[:title].present?
    @ac_texts = AcText.where('name like ?', @name) if params[:name].present? && !params[:title].present?
    @ac_texts = AcText.where('title like ?', @title) if !params[:name].present? && params[:title].present?
    return render partial: 'index_results' if request.post?
    render 'index'
  end

  def search_text
    @text = "%#{params[:text]}%"
    @ac_texts = []
    @ac_texts = AcText.where('creator like ? or html like ?', @text, @text) if params[:text].present?
    @text = "#{params[:text]}"
    return render partial: 'index_results' if request.post?
    render 'index'
  end

  def search_keywords
    @keyword = params[:keyword].downcase
    @ac_texts = []
    @ac_texts = AcText.joins(:keywords).where(keywords: { term: @keyword, keyword_type: 'search' }) if params[:keyword].present?
    return render partial: 'index_results' if request.post?
    render 'index'
  end

  def search_set_attributes
    @ac_texts = []
    @set_name = params[:name]
    @set_value = params[:value]
    @ac_texts = AcText.joins(:set_attributes).where(set_attributes: { name: @set_name, value: @set_value }) if @set_name.present? && @set_value.present?
    @ac_texts = AcText.joins(:set_attributes).where(set_attributes: { name: @set_name }) if @set_name.present? && !@set_value.present?
    @ac_texts = AcText.joins(:set_attributes).where(set_attributes: { value: @set_value }) if !@set_name.present? && @set_value.present?
    return render partial: 'index_results' if request.post?
    render 'index'
  end

  def search_responds_to_attributes
    @ac_texts = []
    @responds_name = params[:name]
    @responds_value = params[:value]
    @ac_texts = AcText.joins(:responds_to_attributes).where(responds_to_attributes: { name: @responds_name, value: @responds_value }) if @responds_name.present? && @responds_value.present?
    @ac_texts = AcText.joins(:responds_to_attributes).where(responds_to_attributes: { name: @responds_name }) if @responds_name.present? && !@responds_value.present?
    @ac_texts = AcText.joins(:responds_to_attributes).where(responds_to_attributes: { value: @responds_value }) if !@responds_name.present? && @responds_value.present?
    return render partial: 'index_results' if request.post?
    render 'index'
  end

  # GET /ac_texts
  # GET /ac_texts.json
  def index
    if params[:all].present?
      @ac_texts = AcText.all
    else
      @ac_texts = AcText.all.limit(100)
    end
    @ac_texts
  end

  # GET /ac_texts/1
  # GET /ac_texts/1.json
  def show
  end

  # GET /ac_texts/new
  def new
    @ac_text = AcText.new
    @contact_types = ContactType.all
  end

  # GET /ac_texts/1/edit
  def edit
    @contact_types = ContactType.all
  end

  # POST /ac_texts
  # POST /ac_texts.json
  def create
    @ac_text = AcText.new(ac_text_params)

    respond_to do |format|
      if @ac_text.save
        @ac_text.update_keywords params['keywords'] unless params['keywords'].nil?
        @ac_text.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_text.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_text, notice: 'Ac text was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_text }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_texts/1
  # PATCH/PUT /ac_texts/1.json
  def update
    respond_to do |format|
      if @ac_text.update(ac_text_params)
        @ac_text.update_keywords params['keywords'] unless params['keywords'].nil?
        @ac_text.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_text.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_text, notice: 'Ac text was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_texts/1
  # DELETE /ac_texts/1.json
  def destroy
    @ac_text.destroy
    respond_to do |format|
      format.html { redirect_to ac_texts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_text
      @ac_text = AcText.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_text_params
      params.require(:ac_text).permit(:name, :title, :creator, :html, :expired, :status, :token, :inputs, :contact_flag, :contact_type, :contact_filter, :publish_at, :unpublish_at)
    end
end
