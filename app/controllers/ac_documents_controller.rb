class AcDocumentsController < ApplicationController
  before_action :set_ac_document, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /ac_documents
  # GET /ac_documents.json
  def index
    @ac_documents = AcDocument.order(id: :desc)
  end

  # GET /ac_documents/1
  # GET /ac_documents/1.json
  def show
  end

  # GET /ac_documents/new
  def new
    @ac_document = AcDocument.new
  end

  # GET /ac_documents/1/edit
  def edit
  end

  # POST /ac_documents
  # POST /ac_documents.json
  def create
    @ac_document = AcDocument.new(ac_document_params)

    respond_to do |format|
      if @ac_document.save
        format.html { redirect_to @ac_document, notice: 'Ac document was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_document }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_documents/1
  # PATCH/PUT /ac_documents/1.json
  def update
    respond_to do |format|
      if @ac_document.update(ac_document_params)
        format.html { redirect_to @ac_document, notice: 'Ac document was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_documents/1
  # DELETE /ac_documents/1.json
  def destroy
    @ac_document.destroy
    respond_to do |format|
      format.html { redirect_to ac_documents_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_document
      @ac_document = AcDocument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_document_params
      params.require(:ac_document).permit(:bundle, :document_spec_xml, :pdf, :jpg, :png, :eps, :preview, :status, :thumbnail)
    end
end
