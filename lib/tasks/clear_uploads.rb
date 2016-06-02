def clear_uploads
  DlImage.incomplete.where('created_at < ?',  Time.now - 1.days).each(&:expire!)
  UserUploadedImage.incomplete.where('created_at < ?',  Time.now - 1.days).each(&:expire!)
  AcCreatorTemplate.incomplete.where('created_at < ?',  Time.now - 1.days).each(&:expire!)
end

# Custom routines for account sync go here.
#
#
#
#
#
