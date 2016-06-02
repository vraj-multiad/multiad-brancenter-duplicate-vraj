# encoding: utf-8

class AcCreatorTemplateBundleUploader < BaseUploader
  def extension_white_list
    ['zip','ZIP']
  end

  def full_filename (path = model.bundle.file.path)
    URI.decode URI.decode super
  end
end
