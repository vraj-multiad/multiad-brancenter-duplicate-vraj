json.array!(@ac_creator_templates) do |ac_creator_template|
  json.extract! ac_creator_template, :name, :title, :bundle, :preview, :thumbnail, :document_spec_xml
  json.url ac_creator_template_url(ac_creator_template, format: :json)
end