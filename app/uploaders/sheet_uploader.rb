# encoding: utf-8

class SheetUploader < BaseUploader
  def full_filename (path = model.sheet.file.path)
    URI.decode URI.decode super
  end
end
