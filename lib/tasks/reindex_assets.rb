# reindex_assets.rb
# manual index creation
def reindex_assets
  indexable_models = %w(AcCreatorTemplate AcText DlImage DlImageGroup KwikeeProduct UserUploadedImage).sort

  # Wipe indexes
  puts 'Removing all KeywordIndex records'
  KeywordIndex.destroy_all
  puts 'KeywordIndex empty'

  # Index all models
  indexable_models.each do |model|
    puts "  Reindexing #{model}"
    model.singularize.classify.constantize.all.each(&:index_asset)
    puts "     finished indexing #{model}"
  end

  # Indexing Results
  puts "\nIndex counts by type:\n"
  indexable_models.each do |model|
    puts format('%20s', model) + " #{KeywordIndex.where(indexable_type: model).count}"
  end
  puts "\n"
end
