# == Schema Information
#
# Table name: ac_bases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  expired    :boolean          default(FALSE)
#  status     :string(255)      default("inprocess")
#

# class AcBase < ActiveRecord::Base
class AcBase < ActiveRecord::Base
  has_many :ac_steps
  has_many :ac_creator_templates
  has_many :ac_sessions

  def active_elements
    # get a list of element_names referenced in ac_steps
    elements = []
    logger.debug 'ac_base: ' + id.to_s
    ac_steps.each do |ac_step|
      step_elements = []
      logger.debug '  ac_step: ' + ac_step.id.to_s

      # step targets or element_name
      if ac_step.form_data('targets').present?
        targets = ac_step.form_data('targets')
        logger.debug '  targets: ' + ac_step.form_data('targets').to_s
        (step_elements << targets.split(',')).flatten! unless targets.nil?
      else
        # step element_name
        step_elements << ac_step.form_data('element_name')
        logger.debug '  element_name: ' + ac_step.form_data('element_name').to_s
      end

      # step hook elements
      if ac_step.form_data('hooks').present?
        ac_step.form_data('hooks').each do |hook_data|
          _hook, targets = hook_data.flatten
          logger.debug '  hook targets: ' + targets.to_s
          (step_elements << targets.split(',')).flatten! unless targets.nil?
        end
      end

      # clean up step_elements and append to elements array
      step_elements.each do |step_element|
        next unless step_element.present?
        logger.debug '    step_element_name: ' + step_element.to_s
        elements << step_element unless elements.include?(step_element)
      end
    end
    elements
  end

  def text_step
  end

  def graphic_containers
    graphics = {}
    doc_spec = JSON.parse(ac_creator_templates.first.document_spec_xml)
    doc_spec['elements'].each do |element_name, element_data|
      logger.debug 'element_name: ' + element_name.to_s
      next unless element_data['type'] == 'ElGraphic'
      # check for for parent container
      element_hash = get_element_with_spec(doc_spec['elements'], element_data['spec'].gsub(/element named "#{element_name}" of /, ''))
      element_hash = { element_name => element_data['spec'] } unless element_hash.present?
      graphics.merge!(element_hash) if element_hash
    end
    graphics
  end

  def get_element_with_spec(elements, spec)
    elements.each do |element_name, element_data|
      return { element_name => spec } if element_data['spec'] == spec
    end
    nil
  end
end
