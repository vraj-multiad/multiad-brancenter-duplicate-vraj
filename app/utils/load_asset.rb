module LoadAsset
  def self.load_asset(params)
    asset = nil
    type = params[:type]
    id = params[:id]
    token = params[:token]

    find_by_params = {}
    if id
      find_by_params[:id] = id
    elsif token
      find_by_params[:token] = token
    else
    end

    return unless id || token
    case type
    when 'AcCreatorTemplate'
      asset = AcCreatorTemplate.find_by(find_by_params)
    when 'AcImage'
      asset = AcImage.find_by(find_by_params)
    when 'AcText'
      asset = AcText.find_by(find_by_params)
    when 'DlImage'
      asset = DlImage.find_by(find_by_params)
    when 'UserUploadedImage'
      asset = UserUploadedImage.find_by(find_by_params)
    when 'SharedPage'
      asset = SharedPage.find_by(find_by_params)
    when 'DlImageGroup'
      asset = DlImageGroup.find_by(find_by_params)
    when 'KwikeeAsset'
      asset = KwikeeAsset.find_by(find_by_params)
    when 'KwikeeProduct'
      asset = KwikeeProduct.find_by(find_by_params)
    else
    end
    asset
  end
end