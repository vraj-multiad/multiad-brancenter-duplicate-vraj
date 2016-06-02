# == Schema Information
#
# Table name: kwikee_assets
#
#  id                :integer          not null, primary key
#  kwikee_product_id :integer
#  asset_id          :integer
#  promotion         :text
#  asset_type        :text
#  version           :text
#  view              :text
#  created_at        :datetime
#  updated_at        :datetime
#  token             :string(255)
#

class KwikeeAsset < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Tokenable
  include Respondable
  include Setable
  include DefaultImageHelper

  default_scope { order(view: :asc, promotion: :asc, asset_type: :asc, version: :asc) }

  belongs_to :kwikee_product
  has_many :kwikee_files, dependent: :delete_all

  def view_code_description
    view_codes = {
      'CF' => 'Color Front',
      'CR' => 'Color Right',
      'CL' => 'Color Left',
      'BF' => 'B&W Front',
      'BR' => 'B&W Right',
      'BL' => 'B&W Left',
      'BC' => 'Barcode',
      'NF' => 'Nutrition Fact Panel',
      'IN' => 'Ingrdients Panel',
      'DF' => 'Drug Fact Panel',
      'PV' => 'Product Packaging Bundle',
      'shelfman' => 'Shelf Management Bundle',
      'CS' => 'Color Special',
      'CG' => 'Color Group',
      'CX' => 'Color Horizontal Logo',
      'CY' => 'Color Vertical Logo',
      'RF' => 'Color Reserved Front',
      'RR' => 'Color Reserved Right',
      'RL' => 'Color Reserved Left',
      'UF' => 'Color Unique Front',
      'UR' => 'Color Unique Right',
      'UL' => 'Color Unique Left',
      'F'  => 'Front View Color',
      'R'  => 'Right View Color',
      'L'  => 'Left View Color',
      'C_' => 'Color Not Applicable',
      'Y'  => 'Color Vertical',
      'XF' => 'Color Front Extra',
      'XL' => 'Color Left Extra',
      'XR' => 'Color Right Extra',
      'C0' => 'Color Group 0',
      'C1' => 'Color Group 1',
      'C2' => 'Color Group 2',
      'C3' => 'Color Group 3',
      'C4' => 'Color Group 4',
      'C5' => 'Color Group 5',
      'C6' => 'Color Group 6',
      'C8' => 'Color Group 8',
      'C9' => 'Color Group 9',
      'BS' => 'B&W Special',
      'BG' => 'B&W Group',
      'BX' => 'B&W Horizontal Logo',
      'BY' => 'B&W Vertical Logo',
      'RB' => 'B&W Reserved View',
      'UB' => 'B&W Unique View',
      'TF' => 'Tone Front',
      'TR' => 'Tone Right',
      'TL' => 'Tone Left',
      'TS' => 'Tone Special',
      'TG' => 'Tone Group',
      'TX' => 'Tone Horizontal Logo',
      'TY' => 'Tone Vertical Logo',
      'XB' => 'B&W Extra View',
      'B'  => 'Black & White Image',
      'X'  => 'Black & White Logo',
      'B_' => 'B&W Not Applicable',
      'T_' => 'Tone Not Applicable',
      'T'  => 'Read Me',
      'S'  => 'Special'
    }
    return view_codes[view] || view
  end

  def name
    name = kwikee_product.gtin + ' ' + view_code_description
    name
  end

  def title
    title = name
    title += ' Promotion: ' + promotion if promotion != 'Default'
    title
  end

  def description
    title
  end

  def shareable?
    true
  end

  def shareable_via_social_media?
    true
  end

  def shareable_via_email?
    true
  end

  def audio?
    false
  end

  def video?
    false
  end

  def image?
    true
  end

  def file?
    false
  end

  def extension
    'zip'
  end

  def preview_url
    secure_preview_url
  end

  def cart_files
    @cart_files = []
    kwikee_files.each do |kf|
      @cart_files << { 'location' => kf.cart_file }
    end
    @cart_files
  end

  def thumbnail
    if %w(shelfman PV).include?(view)
      return kwikee_files.where(extension: %w(jpg jpeg JPG JPEG)).take
    else
      return kwikee_files.where(extension: %w(GIF gif JPEG jpeg JPG jpg)).take
    end
  end

  def preview
    if %w(shelfman PV).include?(view)
      return kwikee_files.where(extension: %w(jpg jpeg JPG JPEG)).take
    else
      return kwikee_files.where(extension: %w(jpg jpeg JPG JPEG)).take
    end
  end

  def adcreator_creator_image
    return kwikee_files.where(extension: %w(eps EPS)).take if kwikee_files.where(extension: %w(eps EPS)).take
    return kwikee_files.where(extension: %w(tif TIF)).take if kwikee_files.where(extension: %w(tif TIF)).take
    return kwikee_files.where(extension: %w(jpg JPG)).take if kwikee_files.where(extension: %w(jpg JPG)).take
    return kwikee_files.where(extension: %w(gif GIF)).take if kwikee_files.where(extension: %w(gif GIF)).take
  end

  def adcreator_html_image
    return kwikee_files.where(extension: %w(png PNG)).take if kwikee_files.where(extension: %w(png PNG)).take
    return kwikee_files.where(extension: %w(jpg JPG)).take if kwikee_files.where(extension: %w(jpg JPG)).take
    return kwikee_files.where(extension: %w(gif GIF)).take if kwikee_files.where(extension: %w(gif GIF)).take
  end

  def secure_preview_url
    preview.secure_url
  end

  def secure_url
    thumbnail.secure_url
  end

  def share_preview
    thumbnail.share_preview
  end

  def default_thumbnail
    default_images('thumbnail.gif')
  end

  def default_thumbnail_url
    '/assets/' + default_thumbnail
  end
end
