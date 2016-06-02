json.array!(@ac_bases) do |ac_basis|
  json.extract! ac_basis, :name, :title
  json.url ac_basis_url(ac_basis, format: :json)
end