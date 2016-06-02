# class DlImageGroupsController < ApplicationController
class DlImageGroupsController < ApplicationController
  before_action :set_dl_image_group_by_token, only: [:admin_update, :admin_add]
  before_action :set_dl_image_group, only: [:show, :edit, :update, :destroy]
  before_action :contributor?, only: [:admin_edit_form, :admin_update, :admin_create, :admin_add, :admin_refresh]
  before_action :superuser?, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  def render_nothing
    render nothing: true
  end

  def admin_add  # before_action :set_dl_image_group_by_token
    if params[:asset].present?
      tokens = []
      params[:asset].each do |asset|
        tokens << asset.split('|').last
      end
      dl_image_ids = @dl_image_group.dl_images.pluck(:id)
      new_dl_image_ids = DlImage.available.where(token: tokens).pluck(:id)
      @dl_image_group.update(dl_image_ids: dl_image_ids | new_dl_image_ids)
    end
    admin_edit_form
  end

  def admin_edit_form
    if params[:token].present?
      @dl_image_group ||= DlImageGroup.where(token: params[:token]).first
    else
      @dl_image_group ||= DlImageGroup.new
    end
    if params[:asset].present?
      tokens = []
      params[:asset].each do |asset|
        tokens << asset.split('|').last
      end
      @dl_images = DlImage.available.where(token: tokens)
    end

    if @dl_image_group.dl_images.present?
      if current_user.superuser?
        @dl_images = @dl_image_group.dl_images
      else
        @dl_images = @dl_image_group.dl_images.user_permitted(current_user.id)
      end
    end
    render partial: 'admin_edit_form'
  end

  def admin_create
    user = current_user
    assets = dl_image_group_admin_create_params
    tokens = []
    assets.each do |asset|
      tokens << asset.split('|').last
    end
    dl_images = DlImage.available.where(token: tokens)
    create_params = {}
    create_params[:user_id] = user.id
    create_params[:dl_image_ids] = dl_images.pluck(:id)
    create_params[:main_dl_image_id] = create_params[:dl_image_ids].first
    @dl_image_group = DlImageGroup.new(create_params)
    @dl_image_group.save!
    set_asset_group(@dl_image_group.class.name, @dl_image_group.token)
    redirect_to admin_dl_image_group_edit_url(@dl_image_group.token), notice: 'Image Group Created.'
  end

  def admin_update  # before_action :set_dl_image_group_by_token
    update_params = dl_image_group_admin_update_params
    main_dl_image_token = params['main_dl_image_token']

    # group_only_flag support
    form_dl_images = @dl_image_group.dl_images.where(token: params[:form_dl_image_ids])
    form_dl_images.reverse_each do |form_image|
      # force bundle_only flag to false group_only_flag assets that are being excluded
      force_false_group_only_flag = false
      force_false_group_only_flag = true if params[:group_only_dl_image_ids].present? && params[:group_only_dl_image_ids].include?(form_image.token) && params[:exclude_dl_image_ids].present? && params[:exclude_dl_image_ids].include?(form_image.token) && form_image.dl_image_groups.length == 1

      new_group_flag_value = (params[:group_only_dl_image_ids].present? && params[:group_only_dl_image_ids].include?(form_image.token)) || force_false_group_only_flag
      next unless form_image.group_only_flag != new_group_flag_value
      # next unless  force_false_group_only_flag
      if force_false_group_only_flag
        logger.debug 'force false group_only_flag for id: ' + form_image.id.to_s
        form_image.group_only_flag = false
      else
        form_image.group_only_flag = new_group_flag_value
      end
      form_image.save!
      logger.debug 'bundle flag change detected for id: ' + form_image.id.to_s
    end

    # remove excluded images from image_group
    if params[:exclude_dl_image_ids].present?
      dl_images = @dl_image_group.dl_images.where.not(token: params[:exclude_dl_image_ids])
      # if no images in bundle delete bundle
      unless dl_images.present?
        logger.debug 'no images left in bundle for id: ' + @dl_image_group.id.to_s
        set_asset_group(@dl_image_group.class.name, @dl_image_group.token)
        @dl_image_group.destroy
        return render_nothing
      end
      update_params[:dl_image_ids] = dl_images.pluck(:id)
      # make sure main_dl_image_id is still part of the image group
      main_dl_image_token = dl_images.pluck(:token).first unless dl_images.where(token: main_dl_image_token).present?
    end
    update_params[:main_dl_image_id] = DlImage.where(token: main_dl_image_token).pluck(:id).first

    if @dl_image_group.update(update_params)
      redirect_to admin_dl_image_group_edit_url(@dl_image_group.token), notice: 'Image Group Saved.'
    else
      redirect_to admin_dl_image_group_edit_url(@dl_image_group.token), notice: 'Failed to Update Image.'
    end
  end

  # defunct
  def admin_create_or_update
    create_params = dl_image_group_admin_create_params
    main_dl_image_token = params['main_dl_image_token']
    main_dl_image_token = params[:dl_image_ids][0] unless params[:dl_image_ids].include? main_dl_image_token
    dl_images = DlImage.where(token: params[:dl_image_ids])
    create_params[:user_id] = user.id
    create_params[:dl_image_ids] = dl_images.pluck(:id)
    create_params[:main_dl_image_id] = DlImage.where(token: main_dl_image_token).pluck(:id).first
    if params[:token].present?
      @dl_image_group = DlImageGroup.where(token: params[:token]).first
      # need to validate permissions first
      if @dl_image_group.user_id == current_user.id && current_user.contributor? || current_user.admin? || current_user.superuser?
        @dl_image_group.update(create_params)
      else
        redirect_to admin_dl_image_group_edit_url(@dl_image_group.token), notice: 'Permissions error.'
      end
    else
      @dl_image_group = DlImageGroup.new(create_params)
      @dl_image_group.save!
    end
    redirect_to admin_dl_image_group_edit_url(@dl_image_group.token), notice: 'Image Group Saved.'
  end

  def admin_remove
    return unless params[:token].present?
    dl_image_group = DlImageGroup.find_by(token: params[:token])
    dl_image_group.dl_images.each do |dl_image|
      next unless dl_image.group_only_flag  # unflag images that will no longer be a dl_image_group member
      if dl_image.dl_image_groups.length == 1
        dl_image.group_only_flag = false
        dl_image.save!
      end
    end
    set_asset_group(dl_image_group.class.name, dl_image_group.token) if current_asset_group['DlImageGroup'][dl_image_group.token].present?
    dl_image_group.destroy
    render_nothing
  end

  # GET /dl_image_groups
  # GET /dl_image_groups.json
  def index
    @dl_image_groups = DlImageGroup.all
  end

  # GET /dl_image_groups/1
  # GET /dl_image_groups/1.json
  def show
  end

  # GET /dl_image_groups/new
  def new
    @dl_image_group = DlImageGroup.new
  end

  # GET /dl_image_groups/1/edit
  def edit
  end

  # POST /dl_image_groups
  # POST /dl_image_groups.json
  def create
    @dl_image_group = DlImageGroup.new(dl_image_group_params)

    respond_to do |format|
      if @dl_image_group.save
        format.html { redirect_to @dl_image_group, notice: 'Dl image group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dl_image_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @dl_image_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dl_image_groups/1
  # PATCH/PUT /dl_image_groups/1.json
  def update
    respond_to do |format|
      if @dl_image_group.update(dl_image_group_params)
        format.html { redirect_to @dl_image_group, notice: 'Dl image group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dl_image_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dl_image_groups/1
  # DELETE /dl_image_groups/1.json
  def destroy
    @dl_image_group.destroy
    respond_to do |format|
      format.html { redirect_to dl_image_groups_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dl_image_group
    @dl_image_group = DlImageGroup.find(params[:id])
  end

  def set_dl_image_group_by_token
    @dl_image_group = DlImageGroup.where(token: params[:token]).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dl_image_group_params
    params.require(:dl_image_group).permit(:main_dl_image_id, :name, :title, :description, :user_id, :token)
  end

  def dl_image_group_admin_create_params
    params.require(:asset)
  end

  def dl_image_group_admin_add_params
    params.require(:dl_image_group).permit(:name, :title, :description)
  end

  def dl_image_group_admin_update_params
    params.require(:dl_image_group).permit(:name, :title, :description)
  end
end
