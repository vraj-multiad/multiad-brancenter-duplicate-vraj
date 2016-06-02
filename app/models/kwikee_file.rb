# == Schema Information
#
# Table name: kwikee_files
#
#  id                :integer          not null, primary key
#  kwikee_product_id :integer
#  kwikee_asset_id   :integer
#  extension         :text
#  url               :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class KwikeeFile < ActiveRecord::Base
  belongs_to :kwikee_product
  belongs_to :kwikee_asset

  default_scope { order(extension: :asc) }

  def safe_file_name
    case extension
    when 'EPS'
      return 'EPS_3'
    when 'LEPS'
      return 'EPS_5'
    when 'GS1'
      return 'GS1_JPEG'
    when 'tga'
      return 'TGA_3'
    when 'TIF'
      return 'TIF_3'
    when 'ZIP'
      return 'EPS_3'
    when 'LZIP'
      return 'EPS_5'
    else
      return extension
    end
  end

  def label
    case extension
    when '1', '2', '3', '4', '5', '6', '7', '8', '9'
      return 'Planogram View'
    when 'EPS'
      return 'EPS 3"'
    when 'GS1'
      return 'GS1 JPG'
    when 'LEPS'
      return 'EPS 5"'
    when 'LZIP'
      return 'EPS 5"'
    when 'WIP TIF'
      return 'WIP TIF'
    when 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9' 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 'y1', 'y2', 'y3', 'y4', 'y5', 'y6', 'y7', 'y8', 'y9'
      type, side = extension.split('')
      case type
      when 'a'
        type = 'Alternate View'
      when 'y'
        type = 'Main View'
      when 't'
        type = 'Tray'
      when 'c'
        type = 'Case'
      end
      case side
      when '1'
        side = 'Front'
      when '2'
        side = 'Left'
      when '3'
        side = 'Top'
      when '4'
      when '5'
      when '6'
      when '7'
        side = 'Back'
      when '8'
        side = 'Right'
      when '9'
        side = 'Bottom'
      end
      return 'Packaging ' + side.to_s + ' ' + type.to_s
    when 'bmp'
      return  'BMP'
    when 'CDR'
      return  'CDR'
    when 'cdr'
      return  'CDR'
    when 'ai'
      return  'AI'
    when 'eps'
      return  'EPS'
    when 'GIF'
      return  'GIF'
    when 'gif'
      return  'GIF'
    when 'jpg'
      return  'JPG'
    when 'PCX'
      return  'PCX'
    when 'PDF'
      return  'PDF'
    when 'pdf'
      return  'PDF'
    when 'PNG'
      return  'PNG 5”'
    when 'png'
      return  'PNG'
    when 'PSD'
      return  'PSD'
    when 'psd'
      return  'PSD'
    when 'SIT'
      return  'SIT'
    when 'sit'
      return  'SIT'
    when 'tga'
      return  'TGA 3”'
    when 'TIF'
      return  'TIF 3”'
    when 'tif'
      return  'TIF'
    when 'zip'
      return  'ZIP'
    when 'ZIP'
      return 'EPS 3"'
    else
      logger.debug 'id: ' + id.to_s
      logger.debug 'extension: ' + extension.to_s
      return extension.upcase
    end
  end

  def cart_file
    url.sub('https://api.kwikeesystems.com', '')
  end

  def secure_url
    url.sub('https://api.kwikeesystems.com/ccs', SECURE_BASE_URL + '/secure_thumbnails')
  end

  def server_file
    url.sub('https://api.kwikeesystems.com', '')
  end

  def share_preview
    secure_url
  end
end
