# app/models/concerns/respondable.rb
module Respondable
  extend ActiveSupport::Concern

  included do
    def update_responds_to_attributes(attributes)
      responds_to_attributes.destroy_all
      attributes.each do |attribute|
        next unless attribute.present?
        name, value = attribute.split('=')
        name.strip!
        next unless name.present?
        value = '' if value.nil?
        responds_to_attributes.create(name: name, value: value)
      end
    end
  end
end
