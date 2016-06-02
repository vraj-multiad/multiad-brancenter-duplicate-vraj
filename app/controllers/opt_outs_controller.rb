class OptOutsController < ApplicationController
  before_action :set_opt_out, only: [:show, :edit, :update, :destroy]
  before_action :superuser?, except: [:unsubscribe]
  skip_before_filter :verify_authenticity_token, only: [:unsubscribe]

  def unsubscribe
    if params[:email_address].present?
      @opt_out = OptOut.find_or_create_by(email_address: params[:email_address])
      return render 'unsubscribed', layout: 'skeleton'
    end
    render nothing: true
  end

  # GET /opt_outs
  # GET /opt_outs.json
  def index
    @opt_outs = OptOut.all
  end

  # GET /opt_outs/1
  # GET /opt_outs/1.json
  def show

  end

  # GET /opt_outs/new
  def new
    @opt_out = OptOut.new
  end

  # GET /opt_outs/1/edit
  def edit
  end

  # POST /opt_outs
  # POST /opt_outs.json
  def create
    @opt_out = OptOut.new(opt_out_params)

    respond_to do |format|
      if @opt_out.save
        format.html { redirect_to @opt_out, notice: 'Opt out was successfully created.' }
        format.json { render action: 'show', status: :created, location: @opt_out }
      else
        format.html { render action: 'new' }
        format.json { render json: @opt_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /opt_outs/1
  # PATCH/PUT /opt_outs/1.json
  def update
    respond_to do |format|
      if @opt_out.update(opt_out_params)
        format.html { redirect_to @opt_out, notice: 'Opt out was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @opt_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /opt_outs/1
  # DELETE /opt_outs/1.json
  def destroy
    @opt_out.destroy
    respond_to do |format|
      format.html { redirect_to opt_outs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_opt_out
      @opt_out = OptOut.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def opt_out_params
      params.require(:opt_out).permit(:email_address)
    end
end
