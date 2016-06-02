json.array!(@ac_documents) do |ac_document|
  json.extract! ac_document, :bundle, :document_spec_xml, :pdf, :preview, :status, :thumbnail
  json.url ac_document_url(ac_document, format: :json)
end