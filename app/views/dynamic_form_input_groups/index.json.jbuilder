json.array!(@dynamic_form_input_groups) do |dynamic_form_input_group|
  json.extract! dynamic_form_input_group, :dynamic_form_id, :name, :title, :description, :input_group_type, :dynamic_form_id
  json.url dynamic_form_input_group_url(dynamic_form_input_group, format: :json)
end