# module DefaultImageHelper
module DefaultImageHelper
  extend ActiveSupport::Concern

  def default_images(file = nil)
    image = 'default_file.png'
    return image unless file.present?
    extension = File.extname(file).downcase
    case extension
    when '.zip', '.tar', '.rar'
      image = 'default_archive.png'
    when '.ppt', '.pptx', '.pps', '.keynote'
      image = 'default_presentation.png'
    when '.doc', '.docx', '.txt', '.odt', '.pages', '.wpd', '.wps', '.rtf'
      image = 'default_document.png'
    when '.xls', '.xlsx', '.csv', '.numbers', '.tab'
      image = 'default_spreadsheet.png'
    when '.image'
      image = 'default_image.png'
    when '.video'
      image = 'default_video.png'
    when '.aif', '.iff', '.m3u', '.m4a', '.mid', '.mp3', '.mpa', '.ra', '.wav', '.wma'
      image = 'default_audio.png'
    end
    image
  end
end
