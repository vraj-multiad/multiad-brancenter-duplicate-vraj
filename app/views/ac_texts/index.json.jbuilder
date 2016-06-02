json.array!(@ac_texts) do |ac_text|
  json.extract! ac_text, :name, :title, :creator, :html
  json.url ac_text_url(ac_text, format: :json)
end