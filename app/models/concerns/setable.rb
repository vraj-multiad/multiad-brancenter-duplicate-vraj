# app/models/concerns/setable.rb
module Setable
  extend ActiveSupport::Concern

  included do
    def update_set_attributes(attributes)
      set_attributes.destroy_all
      attributes.each do |attribute|
        next unless attribute.present?
        name, value = attribute.split('=')
        name.strip!
        next unless name.present?
        value = '' if value.nil?
        set_attributes.create(name: name, value: value)
      end
    end
  end
end
