class VideoUploader < BaseUploader
  version :preview do
    def full_filename(path=model.video.file.path)
      URI.decode URI.decode File.join(File.dirname(path), File.basename(path, File.extname(path))) + '_preview.mp4'
    end
  end

  version :thumbnail do
    def full_filename(path=model.video.file.path)
      URI.decode URI.decode File.join(File.dirname(path), video_thumbnail_filename.gsub!('{{number}}', '0'))  + '.png'
    end
  end

  def full_filename(path=model.video.file.path)
    URI.decode URI.decode super
  end

  def video_thumbnail_filename
    File.basename(model.read_attribute(:video), File.extname(model.read_attribute(:video))) + '_thumbnail_{{number}}'
  end
end
