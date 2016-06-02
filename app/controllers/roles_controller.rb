class RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /roles
  # GET /roles.json
  def index
    @roles = Role.all
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    @access_levels = AccessLevel.all
  end

  # GET /roles/new
  def new
    @role = Role.new
    @access_levels = AccessLevel.all
    @languages = Language.all
  end

  # GET /roles/1/edit
  def edit
    @access_levels = AccessLevel.all
    @languages = Language.all
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        update_params = role_access_level_params
        tokens_to_ids = AccessLevel.where(token: update_params[:access_level_ids])
        update_params[:access_level_ids] = tokens_to_ids.map(&:id)
        @role.update(update_params)
        format.html { redirect_to @role, notice: 'Role was successfully created.' }
        format.json { render action: 'show', status: :created, location: @role }
      else
        format.html { render action: 'new' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update
    respond_to do |format|
      if @role.update(role_params)
        update_params = role_access_level_params
        tokens_to_ids = AccessLevel.where(token: update_params[:access_level_ids])
        update_params[:access_level_ids] = tokens_to_ids.map(&:id)
        @role.update(update_params)
        format.html { redirect_to @role, notice: 'Role was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_access_level_params
      params.require(:role).permit(:name, :title, :default_flag, :role_type, :language_id, :enable_ac_creator_template_customize, :enable_dl_image_download, :enable_user_uploaded_image_download, :enable_order, :enable_share_dl_image_via_email, :enable_share_dl_image_via_social_media, :enable_share_user_uploaded_image_via_email, :enable_share_user_uploaded_via_social_media, :enable_upload_ac_image, :enable_upload_mailing_list, :enable_upload_my_library, access_level_ids: [])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :title, :default_flag, :role_type, :language_id, :enable_ac_creator_template_customize, :enable_dl_image_download, :enable_user_uploaded_image_download, :enable_order, :enable_share_dl_image_via_email, :enable_share_dl_image_via_social_media, :enable_share_user_uploaded_image_via_email, :enable_share_user_uploaded_via_social_media, :enable_upload_ac_image, :enable_upload_mailing_list, :enable_upload_my_library)
    end
end
