# class KeywordTermsController < ApplicationController
class KeywordTermsController < ApplicationController
  include KeywordTermsAdmin
  before_action :set_keyword_term, only: [:show, :edit, :update, :destroy]
  before_action :admin?, only: [:admin, :admin_new, :admin_delete, :destroy]
  before_action :superuser?, except: [:admin, :admin_new, :admin_delete, :destroy]

  def admin
    render_admin_keyword_terms('keyword_terms', 0, nil, nil)
  end

  def admin_new
    params = keyword_term_params
    params[:term_count] = 1
    ### brute force prevention of duplicates
    parent_term_id = params[:parent_term_id].to_i
    parent_term_id = nil if parent_term_id < 1

    keyword_term_validation = KeywordTerm.where(keyword_type: params[:keyword_type], term: params[:term], parent_term_id: parent_term_id, access_level_id: params[:access_level_id], language_id: params[:language_id])
    if keyword_term_validation.count == 0
      @keyword_term = KeywordTerm.new(params)
      @keyword_term.save
    end
    render_admin_keyword_terms('keyword_terms', parent_term_id, params[:language_id], params[:access_level_id])
  end

  def admin_delete
    id = params[:admin_keyword_term_delete_id]
    @keyword_term = KeywordTerm.find(id)
    @keyword_term.sub_terms.destroy_all
    @keyword_term.destroy
    render nothing: true
  end

  # GET /keyword_terms
  # GET /keyword_terms.json
  def index
    @keyword_terms = KeywordTerm.all
  end

  # GET /keyword_terms/1
  # GET /keyword_terms/1.json
  def show
  end

  # GET /keyword_terms/new
  def new
    @keyword_term = KeywordTerm.new
  end

  # GET /keyword_terms/1/edit
  def edit
  end

  # POST /keyword_terms
  # POST /keyword_terms.json
  def create
    @keyword_term = KeywordTerm.new(keyword_term_params)

    respond_to do |format|
      if @keyword_term.save
        format.html { redirect_to @keyword_term, notice: 'Keyword term was successfully created.' }
        format.json { render action: 'show', status: :created, location: @keyword_term }
      else
        format.html { render action: 'new' }
        format.json { render json: @keyword_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keyword_terms/1
  # PATCH/PUT /keyword_terms/1.json
  def update
    respond_to do |format|
      if @keyword_term.update(keyword_term_params)
        format.html { redirect_to @keyword_term, notice: 'Keyword term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @keyword_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keyword_terms/1
  # DELETE /keyword_terms/1.json
  def destroy
    @keyword_term.destroy

    respond_to do |format|
      # format.html { return admin }
      format.html { redirect_to admin_url }
    end
  end

  def refresh_term_count
    keyword_terms = KeywordTerm.all
    keyword_terms.each do |kt|
      kt.term_count = Keyword.where(term: kt.term.downcase).count
      kt.save
    end

    # fixup_list = []

    # fixup_list.each do |t|
    #   kt = KeywordTerm.where(term: t).first
    #   kt.term_count = 1
    #   kt.save
    # end
    redirect_to '/'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_keyword_term
    @keyword_term = KeywordTerm.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def keyword_term_params
    params.require(:keyword_term).permit(:language_id, :term, :parent_term_id, :keyword_type, :term_count, :access_level_id)
  end
end
