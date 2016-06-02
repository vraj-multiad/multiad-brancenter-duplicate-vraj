class AcBasesController < ApplicationController
  before_action :set_ac_basis, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /ac_bases
  # GET /ac_bases.json
  def index
    @ac_bases = AcBase.all
  end

  # GET /ac_bases/1
  # GET /ac_bases/1.json
  def show
  end

  # GET /ac_bases/new
  def new
    @ac_basis = AcBase.new
  end

  # GET /ac_bases/1/edit
  def edit
  end

  # POST /ac_bases
  # POST /ac_bases.json
  def create
    @ac_basis = AcBase.new(ac_basis_params)

    respond_to do |format|
      if @ac_basis.save
        format.html { redirect_to @ac_basis, notice: 'Ac base was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_basis }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_basis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_bases/1
  # PATCH/PUT /ac_bases/1.json
  def update
    respond_to do |format|
      if @ac_basis.update(ac_basis_params)
        format.html { redirect_to @ac_basis, notice: 'Ac base was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_basis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_bases/1
  # DELETE /ac_bases/1.json
  def destroy
    @ac_basis.destroy
    respond_to do |format|
      format.html { redirect_to ac_bases_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_basis
      @ac_basis = AcBase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_basis_params
      params.require(:ac_basis).permit(:name, :title, :expired, :status)
    end
end
