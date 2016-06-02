# == Schema Information
#
# Table name: ac_session_histories
#
#  id                      :integer          not null, primary key
#  name                    :text
#  expired                 :boolean          default(FALSE)
#  previous_ac_document_id :integer
#  ac_document_id          :integer
#  ac_session_id           :integer
#  created_at              :datetime
#  updated_at              :datetime
#  saved                   :boolean
#

# class AcSessionHistory < ActiveRecord::Base
class AcSessionHistory < ActiveRecord::Base
  scope :available, -> { where expired: false }
  include ActionView::Helpers::TextHelper

  has_one :ac_creator_template, through: :ac_session
  has_many :ac_session_attributes
  has_many :ac_exports
  belongs_to :ac_session
  belongs_to :ac_document

  def first_ac_session_attribute(attribute_name)
    return nil unless ac_session_attributes.present?
    ac_session_attributes.each do |ac_session_attribute|
      return ac_session_attribute.value if ac_session_attribute.name == attribute_name && ac_session_attribute.value.present?
    end
    nil
  end

  def expire!
    return unless allow_expire?
    self.expired = true
    save
  end

  def allow_expire?
    # ordered document, but not yet fulfilled
    return false if incomplete_order?
    # still in approval queue
    return false if pending_approval?
    true
  end

  def pending_approval?
    ac_exports.joins(:operation_queues).merge(OperationQueue.approve_documents.incomplete).any?
  end

  def incomplete_order?
    ac_exports.joins(order_items: [:order]).merge(Order.incomplete).any?
    # ac_exports.joins(:order_items).present?
  end

  def finished_steps
    AcStep.joins(:ac_session_attributes).where(ac_session_attributes: { ac_session_history_id: id, name: 'finished_step' })
  end

  def finished_step?(params)
    fail unless params[:id].present? || params[:name].present?
    finished_steps.each do |finished_step|
      return true if params[:id].present? && finished_step.id == params[:id]
      # partial match on suffix <ac_base_name>:<element_name>
      match_string = ':' + params[:name].to_s
      return true if params[:name].present? && finished_step.name.match(/#{Regexp.escape(match_string)}/)
    end
    false
  end

  def footnotes
    ac_session_attributes.where(name: '@footnote').order(:ac_step_id, :id)
  end

  def set_ac_session_attributes_hash(ac_step_id, set_attributes)
    # att_hash = Hash[set_attributes.scan(/(\w+)=(\w+)/).map { |(name, value)| [name.to_s, value.to_s] }]
    logger.debug 'set_ac_attributes.inspect: ' + set_attributes.inspect
    logger.debug 'set_ac_attributes.count: ' + set_attributes.count.to_s
    set_attributes.each do |set_att|
      logger.debug 'set_att.inspect: ' + set_att.inspect
      att = AcSessionAttribute.new(
        ac_session_history_id: id,
        ac_step_id: ac_step_id,
        attribute_type: 'system',
        name: set_att.name,
        value: set_att.value
      )
      att.save
    end
  end

  def get_step_hooks_for_element(element_base_name)
    # ac_session_attributes.where("name like 'hook:?'", element_name)
    ac_session_attributes.where(name: 'hook:' + element_base_name)
  end

  def email_text_replacements
    text_replacements = [{ 'name' => 'current_year', 'value' => Time.now.year.to_s }, { 'name' => 'APP_DOMAIN', 'value' => APP_DOMAIN }]
    # ac_session_attributes = {}
    # ac_session.user.attributes.each do |k, v|
    #   ac_session_attributes['$' + k] = v
    # end
    ac_session.ac_base.ac_steps.each do |ac_step|
      next unless %w(replace_text replace_text_multiple).include?(ac_step.form_data('operation'))

      targets = [ac_step.form_data('element_name')]
      targets = ac_step.form_data('targets').split(',') if ac_step.form_data('targets')

      if ac_step.form_data('ac_step_type') == 'text_choice_multiple'
        element_base_name = ac_step.form_data('element_base_name')
        num_elements = ac_step.form_data('max_selections').to_i
        # init
        (1..num_elements).each do |index|
          # step_attributes_found = false
          name_value_pair = {}
          name_value_pair['name'] = element_base_name + '_' + index.to_s
          name_value_pair['value'] = ''
          ac_session_attributes.where(ac_step_id: ac_step.id).each do |attribute|
            puts "AcText:#{index}"
            next unless attribute.name.match(/^AcText:#{index}$/)
            puts "passed AcText:#{index}"
            name_value_pair['value'] = AcText.find(attribute.value.to_i).html
            next unless name_value_pair['value'].match(/__/)
            # process 2 levels deep...
            ac_session_attributes.each do |sub_attr|
              name_value_pair['value'].gsub!('__' + sub_attr.name.to_s + '__', sub_attr.value || '')
            end
          end

          # # Session attribute substitution
          # if step_attributes_found
          #   ac_session_attributes.where(ac_step_id: ac_step.id).each do |attribute|
          #     next if attribute.name.match(/^replace_text\|option_id/)
          #     # process ac_text string
          #     name_value_pair['value'].gsub!('__' + attribute.name.to_s + '__', attribute.value)
          #   end
          # end

          text_replacements << name_value_pair
        end
      else
        targets.each do |target|
          name_value_pair = {}
          name_value_pair['name'] = target.to_s
          # default copy
          name_value_pair['value'] = simple_format(ac_step.form_data('default_copy'))
          # session subs
          step_attributes_found = false
          ac_session_attributes.where(ac_step_id: ac_step.id).each do |attribute|
            next unless attribute.name.match(/^replace_text\|option_id/)
            name_value_pair['value'] = AcText.find(attribute.value.to_i).html
            step_attributes_found = true
          end
          # Session attribute substitution
          if step_attributes_found
            ac_session_attributes.each do |attribute|
              next if attribute.name.match(/^replace_text\|option_id/)
              # process ac_text string
              name_value_pair['value'].gsub!('__' + attribute.name.to_s + '__', attribute.value || '')
              next unless attribute.value.match(/__/)
              # process 2 levels deep...
              ac_session_attributes.each do |sub_attr|
                name_value_pair['value'].gsub!('__' + sub_attr.name.to_s + '__', sub_attr.value || '')
              end
            end
          end

          text_replacements << name_value_pair
        end

      end

      ac_session_attributes.where("name like 'email_%'").each  do |attribute|
        # add substitution string to support hooks and look values
        text_replacements << { 'name' => attribute.name, 'value' => attribute.value }
      end
    end

    text_replacements
  end
end
