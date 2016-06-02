# class DlCartsController < ApplicationController
class DlCartsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_dl_cart, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?, except: [:finish, :single_download, :wait]
  before_action :superuser?, only: [:index, :show, :new, :edit, :update, :destroy]

  require 'digest'

  # GET /dl_carts
  # GET /dl_carts.json
  def index
    @dl_carts = DlCart.all
  end

  # GET /dl_carts/1
  # GET /dl_carts/1.json
  def show
  end

  # GET /dl_carts/1
  # GET /dl_carts/1.json
  def view_cart
    @current_cart_items = current_cart_items
    # logger.debug @current_cart_items
  end

  def _cart_num_items
    @current_cart_items = current_cart_items
  end

  # GET /dl_carts/new
  def new
    @dl_cart = DlCart.new
  end

  # GET /dl_carts/1/edit
  def edit
  end

  # POST /dl_carts
  # POST /dl_carts.json
  def create
    @dl_cart = DlCart.new(dl_cart_params)

    respond_to do |format|
      if @dl_cart.save
        format.html { redirect_to @dl_cart, notice: 'Dl cart was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dl_cart }
      else
        format.html { render action: 'new' }
        format.json { render json: @dl_cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dl_carts/1
  # PATCH/PUT /dl_carts/1.json
  def update
    respond_to do |format|
      if @dl_cart.update(dl_cart_params)
        format.html { redirect_to @dl_cart, notice: 'Dl cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dl_cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dl_carts/1
  # DELETE /dl_carts/1.json
  def destroy
    @dl_cart.destroy
    respond_to do |format|
      format.html { redirect_to dl_carts_url }
      format.json { head :no_content }
    end
  end

  # POST
  def submit
    email_address = params[:email_address]
    @dl_cart = current_cart
    logger.debug 'current_cart: '
    logger.debug @dl_cart.inspect
    @pickup_url = PICKUP_URL

    @asset_group = current_asset_group
    logger.debug @asset_group
    ## are all asset_group items downloadable?
    @asset_group.each do |asset_type, asset_items|
      asset_items.each do |asset_token|
        loaded_asset = LoadAsset.load_asset(type: asset_type, token: asset_token)
        if loaded_asset.class.name == 'DlImageGroup'
          assets = loaded_asset.dl_images.user_permitted(current_user.id)
        else
          assets = [loaded_asset]
        end
        assets.each do |asset|
          next unless asset.respond_to?('downloadable?') && asset.downloadable?
          next if @dl_cart.dl_cart_items.where(downloadable_type: asset.class.name, downloadable_id: asset.id).present?
          @dl_cart_item = DlCartItem.new
          @dl_cart_item.dl_cart_id = @dl_cart.id
          @dl_cart_item.downloadable_id = asset.id
          @dl_cart_item.downloadable_type = asset.class.name
          @dl_cart_item.save
        end
      end
    end

    if @dl_cart.dl_cart_items.length > 0
      case @dl_cart.status
      when 'submitted', 'complete'
        if @dl_cart.location
          # close_cart(@dl_cart.id)
          @dl_cart.status = 'downloaded'
          @dl_cart.save!
        end
        return render partial: 'in_process', content_type: 'text/html'
      end
      email_address = current_user.email_address if email_address.nil?

      @dl_cart.email_address = email_address
      @dl_cart.status = 'submitted'
      @dl_cart.save

      xml = dl_cart_process_xml(@dl_cart, '')
      logger.debug 'dispatching request' + xml.inspect
      dispatch_cart_request(xml)

      logger.debug @dl_cart.inspect if @dl_cart.cart_errors
    else
      return render partial: 'no_downloadable_items', content_type: 'text/html'
    end
    render partial: 'in_process', content_type: 'text/html'
  end

  def finish
    dl_cart_id = params[:id]
    location = params[:location]
    errors = params[:errors]

    # #update downloads
    @dl_cart = DlCart.find(dl_cart_id)
    @dl_cart.location = location
    @dl_cart.errors = errors if @errors
    @dl_cart.status = 'complete'
    @dl_cart.save!
    user_id = @dl_cart.user_id
    shared_page = nil
    shared_page = SharedPage.find_by(token: @dl_cart.shared_page_token) if @dl_cart.shared_page_token
    @dl_cart.dl_cart_items.each do |dl_cart_item|
      downloadable_type = dl_cart_item.downloadable_type
      downloadable_id = dl_cart_item.downloadable_id
      case downloadable_type
      when 'DlImage', 'UserUploadedImage', 'DlImageGroup', 'KwikeeProduct', 'KwikeeAsset'
        if shared_page
          spd = SharedPageDownload.new(
            shared_page_id:  shared_page.id,
            shareable_id: downloadable_id,
            shareable_type: downloadable_type,
            shared_page_view_id: @dl_cart.shared_page_view_id
          )
          spd.save
        else
          ud = UserDownload.new(
            user_id:  user_id,
            downloadable_id: downloadable_id,
            downloadable_type: downloadable_type
          )
          ud.save
        end
      end
    end
    UserMailer.dl_cart_email(@dl_cart, location, current_language).deliver if @dl_cart.email_address
    # close_cart( params[:dl_cart_id] );
    render nothing: true

    # redirect_to '/'
  end

  def clear
    @dl_cart = current_cart
    @dl_cart.email_address = ''
    @dl_cart.status = ''
    @dl_cart.save
    @dl_cart.dl_cart_items.each(&:destroy)
    redirect_to '/dl_carts'
  end

  def close
    @dl_cart = current_cart
    close_cart(@dl_cart.id)

    redirect_to '/dl_carts'
  end

  def single_download
    shared_page_view_token = params[:shared_page_view_token]
    shared_page_token = params[:shared_page_token]
    downloadable_type = params[:downloadable_type]
    downloadable_token = params[:token]
    # optional
    filetype = params[:filetype]

    asset_token = ''
    loaded_asset = LoadAsset.load_asset(type: downloadable_type, token: downloadable_token)

    return render nothing: true unless loaded_asset.downloadable?

    if loaded_asset.class.name == 'DlImageGroup'
      assets = loaded_asset.dl_images.downloadable.user_permitted(current_user.id)
      if shared_page_token.present?
        assets = loaded_asset.dl_images.downloadable.user_permitted(SharedPage.find_by(token: shared_page_token).user_id)
        assets = assets.where(is_shareable_via_email: true)
        # stub for shareable_via_social_media # no clients have social_media yet
        # assets = assets.where(is_shareable_via_social_media: true) if shared_page_token.present?
      end
      asset_token = downloadable_token
    else
      assets = [loaded_asset]
    end

    @pickup_url = PICKUP_URL
    @dl_cart = DlCart.new
    if shared_page_token
      @dl_cart.shared_page_token = shared_page_token
      @dl_cart.shared_page_view_id = SharedPage.find_by(token: shared_page_token).shared_page_views.find_by(token: shared_page_view_token).id if shared_page_view_token.present?
    else
      user_id = current_user.id
      @dl_cart.user_id = user_id
    end
    @dl_cart.asset_token = asset_token if asset_token.present?
    @dl_cart.status = 'wait'
    @dl_cart.save!
    assets.each do |asset|
      dl_cart_item = DlCartItem.new dl_cart_id: @dl_cart.id, downloadable_type: asset.class.name, downloadable_id: asset.id
      dl_cart_item.save
    end
    @token = downloadable_token
    s3 = AWS::S3.new
    if !filetype.present? && %w(DlImage UserUploadedImage).include?(loaded_asset.class.name) && s3.buckets[ENV['AWS_BUCKET_NAME']].objects[loaded_asset.image_uploader.zip.full_filename].exists?
      @dl_cart.status = 'direct_download'
      @dl_cart.save
    else
      xml = dl_cart_process_xml(@dl_cart, filetype)
      dispatch_cart_request(xml)
    end
    render partial: 'in_process', content_type: 'text/html'
  end

  def wait
    @dl_cart = DlCart.find_by(token: params[:dl_cart_token])
    @pickup_url = PICKUP_URL
    case @dl_cart.status
    when 'wait', 'complete'
      if @dl_cart.location
        @dl_cart.status = 'downloaded'
        @dl_cart.save!
      end
    end
    @token = @dl_cart.asset_token || @dl_cart.dl_cart_items.first.downloadable.token
    render partial: 'in_process', content_type: 'text/html'
  end

  private

  def dispatch_cart_request(xml)
    url = URI.parse(CART_URL + '/cart.xml')
    request = Net::HTTP::Put.new(url.path)
    # request.content_type = 'text/xml'
    request.body = xml
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
    logger.debug 'dispatch_cart_request : ' + url.host.to_s
    logger.debug response.inspect
  end

  def dl_cart_process_xml(dl_cart, filetype)
    logger.debug 'dl_cart_xml id: ' + dl_cart.id.to_s
    # cs commands cannot be null for dispatch
    data = {}
    data['dl_cart_id'] = dl_cart.id.to_s
    data['cart_complete_url'] = APP_DOMAIN + '/dl_cart/finish?id=' + dl_cart.id.to_s + '&location='
    # data['ac_base_url'] = AC_BASE_URL
    data['files'] = []
    data['product_data'] = []
    data['pog_data'] = []
    digest_files = []
    dl_cart.dl_cart_items.each do |item|
      cart_item = LoadAsset.load_asset(type: item.downloadable_type, id: item.downloadable_id)
      next unless cart_item
      if %w(KwikeeProduct KwikeeAsset).include?(item.downloadable_type)
        include_pog_data = false
        kfs = cart_item.kwikee_files
        if filetype && filetype.length > 0
          logger.debug 'filetype ' + filetype.to_s
          if filetype == 'product_data'
            # Product data only for this file
            data['product_data'] << { 'product_base_id' => cart_item.product_id.to_s }
          elsif filetype == 'shelfman'  ### must be a KwikeeAsset
            data['pog_data'] << { 'pog_base_id' => cart_item.kwikee_product.product_id.to_s }
          else
            kfs = kfs.where(extension: filetype)
            next unless kfs.present?
          end
        end
        gtin = item.downloadable_type == 'KwikeeProduct' ? cart_item.gtin : cart_item.kwikee_product.gtin
        kfs.each do |kf|
          file = {}
          ext = File.extname(kf.cart_file)
          promotion = kf.kwikee_asset.promotion.to_s
          promotion.gsub!(/Default/, '')
          file['file_location'] = kf.cart_file
          if %w(shelfman).include?(kf.kwikee_asset.view)
            file['file_new_name'] = gtin.to_s.html_safe + ext
            data['pog_data'] << { 'pog_base_id' => kf.kwikee_product.product_id.to_s }
          elsif %w(PV).include?(kf.kwikee_asset.view)
            file['file_new_name'] = gtin.to_s.html_safe + '_' + promotion.to_s + '_' + kf.kwikee_asset.view.to_s + '_' + kf.kwikee_asset.version.to_s + '_' + kf.kwikee_asset.asset_type.to_s + '_' + kf.safe_file_name + ext
          else
            file['file_new_name'] = gtin.to_s.html_safe + '_' + promotion.to_s + '_' + kf.kwikee_asset.view.to_s + '_' + kf.kwikee_asset.version.to_s + '_' + kf.kwikee_asset.asset_type.to_s + '_' + kf.safe_file_name + ext
          end
          data['files'] << file
          digest_files << file['file_new_name']
        end
        # Give them product data if Kwikee Product download
        data['product_data'] << { 'product_base_id' => cart_item.product_id.to_s } if item.downloadable_type == 'KwikeeProduct'
        data['pog_data'] << { 'pog_base_id' => cart_item.product_id.to_s } if item.downloadable_type == 'KwikeeProduct' && include_pog_data
        data['product_data'] = data['product_data'].uniq
        data['pog_data'] = data['pog_data'].uniq
        digest_files << Time.now.to_s if data['pog_data'].present? || data['product_data'].present?  # force unique digest for data
      else
        cart_item.cart_files.each do |cf|
          file = {}
          if item.downloadable_type == 'UserUploadedImage' || cart_item.video?
            name = File.basename(cart_item.image_uploader.path, File.extname(cart_item.image_uploader.path))
            ext = File.extname(cf['path'])
            next unless ext == filetype if filetype && filetype.length > 0
            file['aws_location'] = cf['url']
            file['unique_name'] = cf['unique_name']
            file['file_new_name'] = name + '/' + name + ext
          else
            ext = File.extname(cf['location'].to_s)
            next unless ext == filetype if filetype && filetype.length > 0
            file['file_location'] = cf['location']
            file['file_new_name'] = cart_item.name.to_s.html_safe + '/' + cart_item.name.to_s.html_safe + ext
          end
          data['files'] << file
          digest_files << item.downloadable_id.to_s + '_' + file['file_new_name']
        end
      end
    end
    logger.debug 'DATA DIGEST'
    logger.debug digest_files.to_s
    digest = Digest::SHA256.hexdigest(digest_files.to_s)
    data['cart_digest'] = digest
    xml = data.to_xml(root: 'download_cart', dasherize: false)
    logger.debug "\n\n" + xml + "\n\n"
    xml
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_dl_cart
    @dl_cart = DlCart.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dl_cart_params
    params.require(:dl_cart).permit(:user_id, :email_address, :status, :location, :cart_errors, :token, :shared_page_token)
  end
end
