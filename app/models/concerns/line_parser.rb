# module LineParser
module LineParser
  extend ActiveSupport::Concern

  included do
    def line_parser_image_line(data)
      image_options = {}
      data.split(',').each do |i|
        name, title = i.split(':')
        logger.debug 'line_parser_image_line name: ' + name

        case name
        when /\$upload/
          title = 'Upload Image' if title.nil?
          image_options['upload'] = title
        when /\$profile_logo/
          image_options['profile_logo'] = 'Logo'
        when /align/
          image_options['align'] = title if title.present?
        when /fill_and_crop/
          image_options['fill_and_crop'] = true
        when /scale_proportional/
          image_options['scale_proportional'] = true
        when /auto_submit/
          image_options['auto_submit'] = true
        else
          image_options['keyword_name'] = name
        end
      end
      logger.debug 'line_parser_image_line: ' + image_options.inspect
      image_options
    end

    def line_parser_filters_line(data)
      filters = []
      data.split(',').each do |filter|
        filter_name, sub_filters = filter.split(':')
        name = filter_name.strip
        if sub_filters.present?
          sub_names = []
          sub_filters.split(';').each do |sub_filter|
            sub_names << sub_filter.strip
          end
          filters << { 'name' => name, 'sub_filters' => sub_names }
        else
          filters << name
        end
      end
      logger.debug 'filters: ' + filters.inspect
      filters
    end

    def line_parser_input_line(input_type, data)
      inputs = []
      data.split(',').each do |i|
        name, title, options_keyword, alt_type, required, maxlength = i.split(':')
        input = {}
        input['name'] = name
        input['title'] = title
        input['options_keyword'] = options_keyword
        input['type'] = alt_type || input_type
        input['required'] = false
        input['required'] = true if required.present?
        input['maxlength'] = nil
        input['maxlength'] = maxlength.to_i if maxlength.to_i > 0
        inputs.push input
      end
      logger.debug 'inputs: ' + inputs.inspect
      inputs
    end

    def line_parser_layers_line(data)
      layers = []
      data.split(',').each do |i|
        title, name = i.split(':')
        input = {}
        input['name'] = name
        input['title'] = title
        layers.push input
      end
      logger.debug 'layers: ' + layers.inspect
      layers
    end

    def line_parser_clear_steps_line(data)
      data.split(';')
    end

    def line_parser_required_steps_line(data)
      data.split(';')
    end

    def line_parser_sub_layer_selection_line(data)
      data.split(';')
    end

    def line_parser_sub_layer_text_choice_multiple_line(data)
      data.split(';')
    end

    def line_parser_hook_line(data)
      name, value = data.split(':')
      { name => value }
    end

    def line_parser_triggers_line(data)
      triggers = []
      data.split(';').each do |trigger|
        trigger_type, data = trigger.split(':')
        triggers << { type: trigger_type, data: data.split(',') }
      end
      logger.debug 'triggers: ' + triggers.inspect
      triggers
    end

    def line_parser_kp_data_line(command, data)
      _command_key, title = command.split(':')
      { title: title, format: data }
    end
  end
end