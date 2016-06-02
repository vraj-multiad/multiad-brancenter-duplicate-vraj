# encoding: utf-8

class BundleUploader < BaseUploader
  version :jpg do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'image'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_full.jpg'
      end
    end
  end

  version :mov do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'video'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_full.mov'
      end
    end
  end

  version :original do
    def full_filename(path = model.image_uploader.file.path)
      if model.upload_type == 'video' && ENV['ZENCODER_TRANSCODE_ORIGINAL']
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_original.' + (ENV['ZENCODER_TRANSCODE_ORIGINAL_FORMAT'] || 'mp4')
      else
        URI.decode URI.decode path
      end
    end
  end

  version :zip do
    def full_filename (path = model.bundle.file.path)
      URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '.zip'
    end
  end

  version :png do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'image'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_full.png'
      end
    end
  end

  version :preview do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'image'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_preview.png'
      when 'video'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_preview.mp4'
      end
    end
  end

  version :thumbnail do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'image'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_thumbnail.png'
      when 'video'
        URI.decode URI.decode File.join(File.dirname(path), self.video_thumbnail_filename.gsub!('{{number}}', '0'))  + '.png'
      end
    end

    def url
      super
    end
  end

  version :wmv do
    def full_filename (path = model.bundle.file.path)
      case model.upload_type
      when 'video'
        URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_full.wmv'
      end
    end
  end

  def full_filename (path = model.bundle.file.path)
    URI.decode URI.decode super
  end

  def video_thumbnail_filename
    File.basename(self.model.read_attribute(:bundle), File.extname(self.model.read_attribute(:bundle))) + '_thumbnail_{{number}}'
  end
end
