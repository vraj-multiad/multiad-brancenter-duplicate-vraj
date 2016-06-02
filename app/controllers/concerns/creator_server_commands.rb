# module CreatorServerCommands
module CreatorServerCommands
  extend ActiveSupport::Concern

  included do
    def set_element_properties
      %w(name description bounds top left bottom right location size width height rotation skew overprint_black fill_ink frame_ink shadow_ink fill_color frame_color shadow_color fill_color_shade frame_color_shade shadow_color_shade fill_trapping frame_trapping shadow_trapping frame_weight frame_options shadow_offset shadow_outset wrapping_relationships style)
    end

    def format_text_properties
      %w(font fontsize fixed_leading auto_leading tracking horizontal_scale vertical_offset word_space space_before_paragraph space_after_paragraph bold_outset italic_skew outline_weight text_shadow_outset shadow_skew shadow_vertical_scale shadow_horizontal_offset shadow_vertical_offset justification plain embolden italicize underline word_underline outline shadowed condense extend superior inferior superscript subscript upper_case lower_case title_case small_caps color color_shade fill_color fill_color_shade shadow_color shadow_color_shade hyphenate)
    end

    def cs_layer
      # stub, nothing to do here except tell masi to create the proper thumbnail
      ''
    end

    def cs_export(ac_session_history, params_ac_step_id, current_doc_spec)
      # params_export_formats, params_export_bleed
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      cs = ''
      ac_session_history.ac_session_attributes.where(name: 'delete_on_export').pluck(:value).each do |element_name|
        element_spec = current_doc_spec['elements'][element_name]['spec']
        cs += 'delete ' + element_spec + "\n"
      end
      step_params[:export_formats].each do |export_format|
        # for multi-page this will be a loop with a zip at the end
        hidden_layers = ac_session_history.ac_session.hidden_layers['names']
        if export_format == 'PDF'
          cs += cs_pdf_export_commands(step_params[:bleed], hidden_layers)
        elsif export_format == 'BLEED_PDF'
          cs += cs_pdf_export_commands('1', hidden_layers)
        elsif export_format == 'EMAIL'
          cs += cs_email_commands(ac_session_history, params_ac_step_id, current_doc_spec)
        else # spread based exports
          number_of_spreads = current_doc_spec['spreads'].length
          (1..number_of_spreads).to_a.each do |spread_number|
            suffix = '-' + spread_number.to_s + '-' + number_of_spreads.to_s + '.' + export_format.downcase
            cs += cs_process_hidden_layers(hidden_layers, false)
            if export_format == 'JPG'
              cs += 'export spread ' + spread_number.to_s + ' of document 1 as JPEG "__output_path__export' + suffix + '" resolution 300 ppi ' + "\n"
            elsif export_format == 'PNG'
              cs += 'export spread ' + spread_number.to_s + '  of document 1 as PNG "__output_path__export' + suffix + '" resolution 300dpi' + "\n"
            elsif export_format == 'EPS'
              cs += 'export spread ' + spread_number.to_s + '  of document 1 as EPS "__output_path__export' + suffix + '" resolution limiting 300' + "\n"
            end
            cs += cs_process_hidden_layers(hidden_layers, true)
          end
        end
      end

      cs
    end

    def cs_process_hidden_layers(hidden_layers, show)
      cs = ''
      hidden_layers.each do |layer_name|
        cs += 'set visible layer named "' + layer_name.to_s + '" of document 1 to ' + show.to_s + "\n"
        cs += 'set prints layer named "' + layer_name.to_s + '" of document 1 to ' + show.to_s + "\n"
      end
      cs
    end

    def cs_pdf_export_commands(params_export_bleed, hidden_layers, page_number = nil, force_reload = false)
      cs = 'set visible layer named "hide" of document 1 to false' + "\n"
      cs += 'set prints layer named "hide" of document 1 to false' + "\n"
      cs += cs_process_hidden_layers(hidden_layers, false)
      # Work around for some table issues. save the document and re-open it
      if force_reload
        cs += 'save document 1 as "__output_path__-reload' + page_number.to_s + '.crtr"' + "\n"
        cs += 'close document 1' + "\n"
        cs += 'open document "__output_path__-reload' + page_number.to_s + '.crtr"' + "\n"
      end
      if params_export_bleed.present? && params_export_bleed == '1'
        cs += 'export document 1 as PDF "__output_path__export-bleed' + page_number.to_s + '.pdf" bleed 0.5 inches crop marks embed fonts resolution limiting 300 color compression JPEG black and white compression flate' + "\n"
      else
        cs += 'export document 1 as PDF "__output_path__export' + page_number.to_s + '.pdf" embed fonts resolution limiting 300 color compression JPEG black and white compression flate' + "\n"
      end
      cs += cs_process_hidden_layers(hidden_layers, true)
      cs += 'set visible layer named "hide" of document 1 to true' + "\n"
      cs += 'set prints layer named "hide" of document 1 to true' + "\n"
      cs
    end

    def cs_email_commands(ac_session_history, params_ac_step_id, current_doc_spec)
      # export embedded art as layed out in creator template
      cs = ''
      ac_session_history.ac_session.ac_base.graphic_containers.each do |element_name, element_spec|
        cs += 'export ' + element_spec + ' as PNG "__output_path__export_email-' + element_name + '.png" resolution 100dpi background transparent' + "\n"
      end
      cs
    end

    def cs_process_hooks(ac_session_history, ac_step, current_doc_spec)
      cs = ''
      element_names = {}
      # Process previously defined hooks for the current ac_step element
      hook_elements = ['hook:' + ac_step.form_data('element_base_name').to_s]
      element_names[ac_step.form_data('element_base_name').to_s] = ac_step.form_data('element_name').to_s

      # Process hooks defined by this step
      if ac_step.form_data('hooks').present?
        ac_step.form_data('hooks').each do |hook_data|
          _hook, targets = hook_data.flatten
          targets.split(',').each do |target|
            search_target = target.sub(/\(\d+\)/, '')
            hook_elements << 'hook:' + search_target.strip.to_s if search_target.present? && search_target.strip.present?
            element_names[search_target.strip.to_s] = target
          end
        end
      end

      # Process previously defined hooks for the current ac_step targets
      if ac_step.form_data('targets').present?
        ac_step.form_data('targets').split(',').each do |target|
          search_target = target.sub(/\(\d+\)/, '')
          hook_elements << 'hook:' + search_target.strip.to_s if search_target.present? && search_target.strip.present?
          element_names[search_target.strip.to_s] = target
        end
      end
      # get hooks for each element
      ac_session_history.ac_session_attributes.where(name: hook_elements).each do |hook|
        _hook, target_element = hook.name.split(':')
        next unless current_doc_spec['elements'][element_names[target_element]].present?

        element_spec = current_doc_spec['elements'][element_names[target_element]]['spec']

        # determine cs command type set or format
        set_element = set_element_string(hook.value)
        if set_element.present?
          ac_session_history.ac_session_attributes.where(name: hook.value.to_s + '_' + target_element.to_s).each do |hook_target_values|
            cs += cs_set_element(element_spec, set_element, hook_target_values.value)
          end
          next
        end

        format_text_element = format_text_string(hook.value)
        if format_text_element.present?
          ac_session_history.ac_session_attributes.where(name: hook.value.to_s + '_' + target_element.to_s).each do |hook_target_values|
            text_range_spec = 'all text'
            cs += cs_format_text(element_spec, text_range_spec, format_text_element, hook_target_values.value)
          end
          next
        end
      end
      cs
    end

    def set_element_string(property)
      string = ''
      return string unless property.match(/^set_element_/)
      property_name = property.sub(/^set_element_/, '')
      string = property_name.tr('_', ' ') if set_element_properties.include?(property_name)
      string
    end

    def format_text_string(property)
      string = ''
      return string unless property.match(/^format_text_/)
      property_name = property.sub(/^format_text_/, '')
      string = property_name.tr('_', ' ') if format_text_properties.include?(property_name)
      string
    end

    def cs_format_text(element_spec, text_range_spec, format_property, format_value)
      # May extend with sanitizing commands
      'format ' + text_range_spec + ' of textflow of ' + element_spec + ' ' + format_property + ' ' + format_value + "\n"
    end

    def cs_set_element(element_spec, element_property, property_value)
      # May extend with sanitizing commands
      'set element ' + element_property + ' of ' + element_spec + ' to ' + property_value + "\n"
    end

    def cs_replace_image(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # params_option_type, params_option_id, cs_bounds
      # determine element_name
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      cs_bounds = resize_bounds(step_params)

      element_name = ac_step.form_data('element_name')
      element_spec = 'element 1 of ' + current_doc_spec['elements'][element_name]['spec']

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      img_object = LoadAsset.load_asset(type: step_params[:option_type], id: step_params[:option_id])
      ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, img_object.set_attributes)

      cs += 'replace ' + element_spec + ' with graphic '
      case step_params[:option_type]
      when 'AcImage'
        cs += '"__adcreator_materials_path____image_id__/image___image_id__.tif" position center' + "\n"
      when 'DlImage'
        cs += '"__dl_image_path____image_id__/image___image_id__.tif" position center' + "\n"
      end
      cs.gsub!('__image_id__', step_params[:option_id].to_s)

      fit_method = 'scale proportional'
      fit_method = 'fill and crop' if /^g_photo/.match(element_name) || ac_step.form_data('fill_and_crop')
      if cs_bounds != ''
        cs += 'set element bounds of ' + element_spec + ' to ' + cs_bounds + "\n"
      else
        cs += 'fit ' + element_spec + ' to container ' + fit_method + "\n"
        align = ac_step.form_data('align')
        if align.present? && %w(top left bottom right).include?(align)
          container_spec = current_doc_spec['elements'][element_name]['spec']
          cs += 'align ' + element_spec + ' ' + align + ' to ' + container_spec + "\n"
        end
      end

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)

      unless skip_triggers
        cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
        aws += trigger_aws
        multiple_elements += trigger_multiple_elements
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def cs_replace_user_image(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # params_option_id, cs_bounds
      # determine element_name
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      cs_bounds = resize_bounds(step_params)

      element_name = ac_step.form_data('element_name')
      element_spec = 'element 1 of ' + current_doc_spec['elements'][element_name]['spec']

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      img_object = UserUploadedImage.find(step_params[:option_id])
      ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, img_object.set_attributes)

      cs += 'replace ' + element_spec + ' with graphic '
      cs += '"__aws_image_path__" position center' + "\n"

      cs.gsub!('__image_id__', step_params[:option_id].to_s)

      if cs_bounds != ''
        cs += 'set element bounds of ' + element_spec + ' to ' + cs_bounds + "\n"
      else
        fit_method = 'scale proportional'
        fit_method = 'fill and crop' if /^g_photo/.match(element_name)
        cs += 'fit ' + element_spec + ' to container ' + fit_method + "\n"
      end

      aws = aws + ac_session_history.ac_session.user.id.to_s + '|' + img_object.id.to_s + '|' + img_object.image_upload_url

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)

      unless skip_triggers
        cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
        aws += trigger_aws
        multiple_elements += trigger_multiple_elements
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def cs_replace_kwikee_products(ac_session_history, params_ac_step_id, current_doc_spec)
      # params_option_id,
      # determine element_name
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      # iterate over all products despite number chosen to clear out old values
      num_products = ac_step.form_data('max_selections').to_i
      logger.debug 'num_products: ' + num_products.to_s
      logger.debug 'cs_replace_kwikee_products: ' + step_params[:kwikee_product_ids].to_s
      (1..num_products).each do |product_index|
        kwikee_product = nil
        if step_params[:kwikee_product_ids][product_index - 1].present?
          kwikee_product = KwikeeProduct.find(step_params[:kwikee_product_ids][product_index - 1])
          ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, kwikee_product.set_attributes)
        end

        base_image_element_name   = 'c_kwikee_product_photo_' + product_index.to_s
        base_label_element_name   = 't_kwikee_product_label_' + product_index.to_s
        base_data_element_name    = 't_kwikee_product_data_' + product_index.to_s
        base_barcode_element_name = 'c_kwikee_product_barcode_' + product_index.to_s
        image_element_names   = [base_image_element_name]
        label_element_names   = [base_label_element_name]
        data_element_names    = [base_data_element_name]
        barcode_element_names = [base_barcode_element_name]

        (1..9).each do |i|
          image_element_names << base_image_element_name + '-' + i.to_s
          label_element_names << base_label_element_name + '-' + i.to_s
          data_element_names << base_data_element_name + '-' + i.to_s
          barcode_element_names << base_barcode_element_name + '-' + i.to_s
        end
        logger.debug 'image_element_names ' + image_element_names.inspect
        logger.debug 'label_element_names ' + label_element_names.inspect
        logger.debug 'data_element_names ' + data_element_names.inspect
        logger.debug 'barcode_element_names ' + barcode_element_names.inspect
        logger.debug 'current_doc_spec[elements] '
        current_doc_spec['elements'].keys.each do |k|
          logger.debug k.to_s
        end
        # kwikee_product image
        image_element_names.each do |image_element_name|
          logger.debug 'image element trying: ' + image_element_name.to_s
          next unless current_doc_spec['elements'][image_element_name].present?
          multiple_elements << image_element_name
          image_element_spec = 'element 1 of ' + current_doc_spec['elements'][image_element_name]['spec']
          cs += 'replace ' + image_element_spec + ' with graphic '
          if kwikee_product.present? && kwikee_product.default_kwikee_asset.adcreator_creator_image.server_file.present?
            cs += '"__kwikee_product_path__' + kwikee_product.default_kwikee_asset.adcreator_creator_image.server_file + '" position center' + "\n"
            fit_method = 'scale proportional'
            cs += 'fit ' + image_element_spec + ' to container ' + fit_method + "\n"
          else
            cs += '"__blank_image__" position center' + "\n"
          end
        end

        # kwikee_product label
        label_element_names.each do |label_element_name|
          next unless current_doc_spec['elements'][label_element_name].present?
          multiple_elements << label_element_name
          label_element_spec = current_doc_spec['elements'][label_element_name]['spec']
          style_model = 'kwikee_product_label'
          cs += 'replace text all text of textflow of ' + label_element_spec + ' using unicode' + "\n"
          if kwikee_product.present? && ac_step.form_data('kp_label').present?
            label = ac_step.form_data('kp_label')
            cs += sub_kwikee_product_attributes('', label, kwikee_product) + "\n"
          end
          cs += 'end text' + "\n"
          cs += 'apply style model "' + style_model + '" of document 1 to all text of textflow of ' + label_element_spec + "\n"
        end

        # kwikee_product data
        data_element_names.each do |data_element_name|
          logger.debug 'data element trying: ' + data_element_name.to_s
          next unless current_doc_spec['elements'][data_element_name].present?
          multiple_elements << data_element_name
          data_element_spec =  current_doc_spec['elements'][data_element_name]['spec']
          style_model = 'kwikee_product_data'
          cs += 'replace text all text of textflow of ' + data_element_spec + ' using unicode' + "\n"
          if kwikee_product.present? && ac_step.form_data('kp_data').present?
            if ac_step.form_data('kp_table_data').present?
              ac_step.form_data('kp_data').each do |data|
                line = data['format']
                cs += sub_kwikee_product_attributes('', line, kwikee_product) + tab_quad_fixup("\t")
              end
              cs += "\n"
            else
              data_separator = ac_step.form_data('kp_data_separator') || "\q"
              ac_step.form_data('kp_data').each do |data|
                prefix = data['title'].to_s + tab_quad_fixup(data_separator)
                line = data['format'].to_s
                cs += sub_kwikee_product_attributes(prefix, line, kwikee_product) + '\n' + "\n"
              end
            end
          end
          cs += 'end text' + "\n"
          cs += 'apply style model "' + style_model + '" of document 1 to all text of textflow of ' + data_element_spec + "\n"
        end

        # kwikee_product_barcode
        barcode_element_names.each do |barcode_element_name|
          next unless current_doc_spec['elements'][barcode_element_name].present?
          multiple_elements << barcode_element_name
          barcode_element_spec = 'element 1 of ' + current_doc_spec['elements'][barcode_element_name]['spec']
          cs += 'replace ' + barcode_element_spec + ' with graphic '
          if kwikee_product.present? && kwikee_product.kwikee_assets.where(view: 'BC').present? && kwikee_product.kwikee_assets.where(view: 'BC').first.adcreator_creator_image.server_file.present?
            cs += '"__kwikee_product_path__' + kwikee_product.kwikee_assets.where(view: 'BC').first.adcreator_creator_image.server_file + '" position center' + "\n"
            fit_method = 'scale proportional'
            cs += 'fit ' + barcode_element_spec + ' to container ' + fit_method + "\n"
          else
            cs += '"__blank_image__" position center' + "\n"
          end
        end

        ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, kwikee_product.set_attributes) if kwikee_product.present?
      end

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)
      [cs, aws, delete_on_export, multiple_elements]
    end

    def sub_kwikee_product_attributes(prefix, cs_in, kwikee_product)
      cs_out = ''
      cs_in.split('||').each do |cs_line|
        kwikee_product.attributes.each do |k, v|
          cs_line.gsub!(/\$kp_#{k}/, v.to_s) if v.present?
        end
        kwikee_product.custom_data.each do |k, v|
          cs_line.gsub!(/\$#{k}/, v.to_s) if v.present?
        end
        kwikee_product.external_codes.each do |k, v|
          cs_line.gsub!(/\$#{k}/, v.to_s) if v.present?
        end
        if kwikee_product.kwikee_nutritions.present?
          kwikee_product.kwikee_nutritions.first.attributes.each do |k, v|
            cs_line.gsub!(/\$kn_#{k}/, v.to_s) if v.present?
          end
        end
        return prefix + cs_line unless cs_line.match(/\$kp|\$kn|\$kec/) || KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS.present?
        custom_data_groups_found = false
        next unless KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS.present?
        KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS.each do |custom_code_prefix|
          next if custom_data_groups_found
          custom_data_groups_found = cs_line.match(/\$kp|\$kn|\$kec|\$#{custom_code_prefix}/).present?
        end
        return prefix + cs_line unless cs_line.match(/\$kp|\$kn|\$kec/) || custom_data_groups_found
      end
      cs_out
    end

    def tab_quad_fixup(string)
      logger.debug 'string in: ' + string.to_s
      string.gsub!(/\\UE000/, "\uE000")
      string.gsub!(/\\b/, "\uE000")
      string.gsub!(/\\UE003/, "\uE003")
      string.gsub!(/\\q/, "\uE003")
      string.gsub!(/\\U2009/, "\u2009")
      string.gsub!(/\\T/, "\u2009")
      string.gsub!(/\\U0009/, "\u0009")
      string.gsub!(/\\t/, "\u0009")
      logger.debug 'string out: ' + string.to_s
      string
    end

    def cs_replace_text(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # determine element_name
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      text_object = AcText.find_by(name: 'empty')
      text_object = AcText.find(step_params[:option_id]) if step_params[:option_id].present?
      targets = ac_step.form_data('targets')
      form_element_name = ac_step.form_data('element_name')
      elements = [form_element_name]

      elements = targets.split(',') unless targets.nil?

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      elements.each do |element_name|
        element_spec =  current_doc_spec['elements'][element_name]['spec']
        style_model = ac_step.form_data('element_base_name')

        ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, text_object.set_attributes) unless skip_triggers

        cs += 'format ' + element_spec + ' horizontal text scale 100 percent vertical text scale 100 percent' + "\n"
        cs += 'replace text all text of textflow of ' + element_spec + ' using unicode' + "\n"
        cs += '__replace_text__' + "\n"
        # cs += text_object.creator.to_s + "\n"
        cs += 'end text' + "\n"

        is_wysiwyg = false
        ac_session_history.ac_session_attributes.each do |result|
          next unless result.name.to_s == params_ac_step_id.to_s + 'text'
          next unless result.wysiwyg_data?
          is_wysiwyg = true
          # logger.debug('wysiwyg_data found: ' + result.id.to_s + ' -- ' + result.value.to_s)
          # ps = Nokogiri::HTML(result.value).search('p')
          text_data, t_tags, p_tags = result.parse_data
          # logger.debug ps.inspect
          # ps.children.each do |p|
          #   puts 'main parse_element: ' + p.name.to_s
          #   parse_element(p)
          # end
          # return wysiwyg_text(text_data)
          logger.debug 'wysiwyg return: ' + text_data.to_s
          text_data = cleanup_br_input text_data
          cs.gsub!('__replace_text__', text_data.to_s)
          ## format all text to first format from paragraph to set style.
          first_format = true
          p_tags.each do |k, v|
            literal = unicode_to_creator(v['literal'])
            cleanup_br_input literal

            if first_format
              cs += 'format all text of textflow of ' + element_spec + ' plain' + "\n"
              first_format = false
            end
            # align fontname fontsize
            next unless literal
            cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' justification ' + v['align'] + "\n" if v['align']
            cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' fontsize ' + v['fontsize'].to_s + "\n" if v['fontsize'].present? && v['fontsize'].to_i > 0
            cs += (remove_tags_cs k, element_spec)
          end
          t_tags.each do |k, v|
            literal = unicode_to_creator(v['literal'])
            fontname = v['fontname']
            cleanup_br_input literal

            next unless literal
            %w(underline superior inferior word underline superscript subscript).each do |format|
              cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' ' + format + "\n" if v[format].present?
            end
            # convert to proper font for creator for bold/italic/bold italic
            if v['bold'].present? || v['italic'].present? || fontname.present? #### always call to set proper font.
              new_fontname = font_to_c fontname, v
              cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' font "' + new_fontname.to_s + '"' + "\n"
            end
            cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' color "' + v['color'].to_s + '"' + "\n" if v['color'].present?
            cs += 'format literal text' + "\n" + literal + "\nend text\n" + ' of textflow of ' + element_spec + ' fontsize ' + v['fontsize'].to_s + "\n" if v['fontsize'].present? && v['fontsize'].to_i > 0
            cs += (remove_tags_cs k, element_spec)
          end
        end

        unless is_wysiwyg
          cs.gsub!('__replace_text__', text_object.creator.to_s)

          # replace all text variables based upon attributes
          ac_session_history.ac_session_attributes.each do |result|
            # xml = Hash.from_xml('<value>' + result.value.gsub(/\r/,"") + '</value>')
            # logger.debug ("xml: " + xml.inspect)
            name = result.name.to_s
            name = 'text' if name == params_ac_step_id.to_s + 'text' ## support generic text
            sub_text = result.value.to_s.gsub(/\r/, '\n')

            cs.gsub!('__' + name + '__', sub_text.to_s)
            # sub_text = (result.value.to_s).gsub(/\r/,/\n/)
            # logger.debug "-----------------------------------\n" + sub_text.gsub(/\r/,'\n') + "\n-----------------------------------\n"
          end
          cs += 'apply style model "' + style_model + '" of document 1 to all text of textflow of ' + element_spec + "\n"
        end
        cs += 'copyfit textflow of ' + element_spec + ' adjust scale whole words overflow only' + "\n"
      end

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)

      logger.debug 'cs: ' + cs
      cs = tab_quad_fixup(cs)
      unless skip_triggers
        cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
        aws += trigger_aws
        multiple_elements += trigger_multiple_elements
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def cs_replace_text_multiple(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # params_option_id
      # determine element_name
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      # iterate over all products despite number chosen to clear out old values
      num_objects = ac_step.form_data('max_selections').to_i
      (1..num_objects).each do |index|
        element_name = ac_step.form_data('element_base_name') + '_' + index.to_s
        multiple_elements << element_name
        element_spec = current_doc_spec['elements'][element_name]['spec']
        style_model = ac_step.form_data('element_base_name')

        unless step_params[:text_choice_ids][index - 1]
          cs += 'replace text all text of textflow of ' + element_spec + ' using unicode' + "\n"
          cs += 'end text' + "\n"
          next
        end

        text_object = AcText.find(step_params[:text_choice_ids][index - 1])

        ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, text_object.set_attributes) unless skip_triggers

        cs += 'replace text all text of textflow of ' + element_spec + ' using unicode' + "\n"
        cs += text_object.creator.to_s + "\n"
        cs += 'end text' + "\n"

        # replace all text variables based upon attributes
        variable_array = {}
        ac_session_history.ac_session_attributes.each do |result|
          name = result.name.to_s
          name = 'text' if name == params_ac_step_id.to_s + 'text' ## support generic text
          sub_text = result.value.to_s.gsub(/\r/, '\n')
          case name
          when /^@/
            variable_array[name] = [] unless variable_array[name].present?
            variable_array[name] << { step_id: result.ac_step_id, value: sub_text.to_s }
          else
            cs.gsub!('__' + name + '__', sub_text.to_s)
          end
        end
        logger.debug 'variable_array: '
        logger.debug variable_array.to_yaml

        cs += 'apply style model "' + style_model + '" of document 1 to all text of textflow of ' + element_spec + "\n"
        cs += 'copyfit textflow of ' + element_spec + ' adjust scale whole words overflow only' + "\n"
      end

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)

      logger.debug 'cs: ' + cs
      cs = tab_quad_fixup(cs)
      unless skip_triggers
        cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
        aws += trigger_aws
        multiple_elements += trigger_multiple_elements
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def cs_sub_layer_selection(ac_session_history, params_ac_step_id, current_doc_spec, skip_post_process = false)
      # params_option_id,
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      sub_layer_selection = step_params[:sub_layer_selection]

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      # get layer
      sub_layer_element_name = ac_step.form_data('element_name')
      layer_names = current_doc_spec['layer_names']
      layer_id = current_doc_spec['elements'][sub_layer_element_name]['layer']
      layer_name = layer_names[layer_id]

      # background_name
      background_element_name = layer_name + '_background'
      delete_on_export << background_element_name

      # iterate over elements
      current_doc_spec['elements'].each do |element_name, el|
        next unless el['layer'].to_s == layer_id.to_s
        next if element_name.to_s == sub_layer_element_name.to_s
        next if element_name.to_s == background_element_name.to_s
        sub_layer_prefix = "^#{Regexp.escape(layer_name)}_#{sub_layer_selection}_"
        delete_on_export << element_name unless element_name.match(Regexp.new(sub_layer_prefix))
      end

      unless skip_post_process
        cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec) + "\n"

        logger.debug 'cs: ' + cs
        logger.debug 'delete_on_export: ' + delete_on_export.to_s
        cs = tab_quad_fixup(cs)
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def cs_sub_layer_replace_text_multiple(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # params_option_id,

      # init with sub_layer_selection params_options_id takes a scalar length
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      skip_post_process = true

      cs, aws, delete_on_export, multiple_elements = cs_sub_layer_selection(ac_session_history, params_ac_step_id, current_doc_spec, skip_post_process)

      sub_layer_element_name = ac_step.form_data('element_name')
      layer_names = current_doc_spec['layer_names']
      layer_id = current_doc_spec['elements'][sub_layer_element_name]['layer']
      layer_name = layer_names[layer_id]

      element_name_prefix = layer_name + '_' + step_params[:text_choice_ids].length.to_s + '_'

      multiple_elements = []
      step_params[:text_choice_ids].each_with_index do |option_id, index|
        ordinal = index + 1
        element_name = element_name_prefix + ordinal.to_s
        multiple_elements << element_name

        element_spec = current_doc_spec['elements'][element_name]['spec']
        style_model = ac_step.form_data('element_base_name')

        text_object = AcText.find(option_id)

        ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, text_object.set_attributes) unless skip_triggers

        cs += 'replace text all text of textflow of ' + element_spec + ' using unicode' + "\n"
        cs += text_object.creator.to_s + "\n"
        cs += 'end text' + "\n"

        # replace all text variables based upon attributes
        ac_session_history.ac_session_attributes.each do |result|
          name = result.name.to_s
          name = 'text' if name == params_ac_step_id.to_s + 'text' ## support generic text
          sub_text = result.value.to_s.gsub(/\r/, '\n')
          cs.gsub!('__' + name + '__', sub_text.to_s)
        end
        cs += 'apply style model "' + style_model + '" of document 1 to all text of textflow of ' + element_spec + "\n"
        cs += 'copyfit textflow of ' + element_spec + ' adjust scale whole words overflow only' + "\n"
      end

      cs += cs_process_hooks(ac_session_history, ac_step, current_doc_spec)

      logger.debug 'cs: ' + cs
      cs = tab_quad_fixup(cs)

      unless skip_triggers
        cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
        aws += trigger_aws
        multiple_elements += trigger_multiple_elements
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def font_to_c(fontname, tags)
      # font_formats: "Adobe Garamond Pro=garamond;Arial=arial;Arial Narrow=arial narrow;Constantia=constantia;Georgia=georgia;Handscript=handscript;Helvetica=helvetica;Palatino=palatino;Trebuchet MS=trebuchet ms;"
      font = ''
      fontname.sub!(/^'/, '')
      fontname.sub!(/'$/, '')
      case fontname
      when 'trebuchet ms'
        font = 'Trebuchet MS'
      when 'garamond'
        font = 'Adobe Garamond Pro'
      when 'arial'
        font = 'Arial'
      when 'arial narrow'
        font = 'Arial Narrow'
      when 'constantia'
        font = 'Constantia'
      when 'georgia'
        font = 'Georgia'
      when 'handscript'
        font = 'Handscript'
      when 'helvetica'
        font = 'Helvetica Neue'
      when 'palatino'
        font = 'Palatino Linotype'
      else
        font = 'Adobe Garamond Pro'
      end

      if tags['bold'] || tags['italic']
        font += ' Bold' if tags['bold']
        font += ' Italic' if tags['italic']
      else # all non-bold non-italic have regular as last name
        font += ' Regular'
      end

      # fixup Adobe Garamond Bold Regular
      case font
      when 'Adobe Garamond Pro Bold'
        font += ' Regular'
      end
      # logger.debug "font_to_c out: " + font.to_s
      font
    end

    # Because format does not support unicode literals, we need to translate the
    # characters into \UXXXX format
    # match_string =~ s/([\x{0080}-\x{FFFF}])/uc sprintf("\\U%04x", ord($1))/eg;
    # < 003C && > 003E

    def unicode_to_creator(string)
      string.gsub(/([\u0080-\uFFFF])/) do |match|
        ('\U%04x' % $1.ord).upcase
      end
    end

    def remove_tags_cs(tag, element_spec)
      text = 'replace text literal text' + "\n"
      text += '<' + unicode_to_creator(tag) + '>' + "\nend text\n"
      text += ' of textflow of ' + element_spec + ' using unicode' + "\nend text\n"
      text += 'replace text literal text' + "\n" + '</' + unicode_to_creator(tag) + '>' + "\nend text\n"
      text += ' of textflow of ' + element_spec + ' using unicode' + "\nend text\n"
      text
    end

    def cs_image_upload(ac_session_history, params_ac_step_id, current_doc_spec, skip_triggers = false)
      # params_option_id, cs_bounds, params_image_upload,
      ac_step = AcStep.find(params_ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      cs_bounds = resize_bounds(step_params)
      element_name = ac_step.form_data('element_name')

      element_spec = 'element 1 of ' + current_doc_spec['elements'][element_name]['spec']

      cs = ''
      aws = ''
      delete_on_export = []
      multiple_elements = []

      if step_params[:option_id]
        #### replace with uploaded image
        img_object = UserUploadedImage.find(step_params[:option_id])

        # make sure image belongs to user.
        if (img_object.user_id == ac_session_history.ac_session.user_id)
          ac_session_history.set_ac_session_attributes_hash(params_ac_step_id, img_object.set_attributes)

          cs += 'replace ' + element_spec + ' with graphic '
          cs += '"__aws_image_path__" position center' + "\n"

          cs.gsub!('__image_id__', step_params[:option_id].to_s)

          fit_method = 'scale proportional'
          fit_method = 'fill and crop' if /^g_photo/.match(element_name)
          if cs_bounds != ''
            cs += 'set element bounds of ' + element_spec + ' to ' + cs_bounds + "\n"
          else
            cs += 'fit ' + element_spec + ' to container ' + fit_method + "\n"
          end

          aws += ac_session_history.ac_session.user.id.to_s + '|' + img_object.id.to_s + '|' + img_object.image_upload_url
        end

        unless skip_triggers
          cs, trigger_aws, trigger_multiple_elements = triggers(ac_session_history, ac_step, current_doc_spec, cs)
          aws += trigger_aws
          multiple_elements += trigger_multiple_elements
        end

      else
        UserMailer.system_message_email('cs_image_upload: direct upload detected', ac_step.to_yaml.to_s).deliver
      end

      [cs, aws, delete_on_export, multiple_elements]
    end

    def get_new_bounds(element, v_ratio, h_ratio)
      e = {}
      e['top'] = (sprintf('%.2f', (element['top'].to_f * v_ratio))).to_s
      e['left'] = (sprintf('%.2f', (element['left'].to_f * h_ratio))).to_s
      e['bottom'] = (sprintf('%.2f', (element['bottom'].to_f * v_ratio))).to_s
      e['right'] = (sprintf('%.2f', (element['right'].to_f * h_ratio))).to_s
      e.each do |k|
        e[k] = '0.00' if e[k] == '-0.00'
      end
      e
    end

    def cs_resize(ac_session_history, ac_step_id, current_doc_spec)
      # params_resize_height, params_resize_width,
      ac_step = AcStep.find(ac_step_id)
      step_params = ac_step.params(ac_session_history.ac_session_attributes)
      cs = ''

      if current_doc_spec.nil?
        print STDERR 'current_doc_spec is null'
      else
        orig_height = current_doc_spec['size']['height'].to_f
        orig_width = current_doc_spec['size']['width'].to_f
        resize_height = step_params[:resize_height].to_f * 72
        resize_width = step_params[:resize_width].to_f * 72

        v_ratio = resize_height / orig_height
        h_ratio = resize_width / orig_width

        # logger.debug "orig_height: " + orig_height.to_s
        # logger.debug "orig_width: " + orig_width.to_s
        # logger.debug "resize_height: " + resize_height.to_s
        # logger.debug "resize_width: " + resize_width.to_s
        # logger.debug "v_ratio: " + v_ratio.to_s
        # logger.debug "h_ratio: " + h_ratio.to_s

        cs += 'set page size of page 1 of document 1 to horizontal ' + step_params[:resize_width]
        cs += ' inches vertical ' + step_params[:resize_height] + ' inches' + "\n"

        elements = current_doc_spec['elements']
        elements.each do |name, element|
          # logger.debug 'Hash document_xml_spec: ' + element.inspect
          # logger.debug 'name: ' + element['name']
          # logger.debug 'type: ' + element['type']
          e = get_new_bounds(element, v_ratio, h_ratio)

          next unless element['type'] == 'ElRect' || element['type'] == 'ElLine'
          # logger.debug 'set element bounds of ' + element['spec'] + ' to top ' + e['top'] + ' points left ' + e['left'] + ' points bottom ' + e['bottom'] + ' points right ' + e['right'] + ' points '
          cs += 'set element bounds of ' + element['spec'] + ' to top '
          cs += e['top'] + ' points left '
          cs += e['left'] + ' points bottom '
          cs += e['bottom'] + ' points right '
          cs += e['right'] + ' points ' + "\n"
          next unless element['text'] && element['text'].length > 0
          # copy fit overflow only
          # logger.debug "element[text]: " + element['text']
          cs += 'apply style model "' + name + '" of document 1 to all text of textflow of ' + element['spec'] + "\n"
          cs += 'copyfit textflow of ' + element['spec'] + ' adjust scale whole words overflow only' + "\n"
        end

        # do containers first, graphics second
        elements.each do |_name, element|
          # logger.debug 'Hash document_xml_spec: ' + element.inspect
          # logger.debug 'name: ' + element['name']
          # e = get_new_bounds(element, v_ratio, h_ratio)

          next unless element['type'] == 'ElGraphic'
          # set back to original dimensions
          # logger.debug 'set element bounds of ' + element['spec'] + ' to top ' + element['top'] + ' points left ' + element['left'] + ' points bottom ' + element['bottom'] + ' points right ' + element['right'] + ' points '
          cs += 'set element bounds of ' + element['spec'] + ' to top '
          cs += element['top'] + ' points left '
          cs += element['left'] + ' points bottom '
          cs += element['bottom'] + ' points right '
          cs += element['right'] + ' points ' + "\n"
          fit_method = 'scale proportional'
          fit_method = 'fill and crop' if /^g_photo/.match(element['name'])
          cs += 'fit ' + element['spec'] + ' to container ' + fit_method + "\n"
          ## need to parse containment method and carry forward?
        end
      end
      cs
    end

    def resize_bounds(params)
      bounds = ''
      if params[:resize_top].present? && params[:resize_bottom].present? && params[:resize_left].present? && params[:resize_right].present?
        bounds += 'top ' + params[:resize_top].to_f.round(4).to_s + ' points '
        bounds += 'left ' + params[:resize_left].to_f.round(4).to_s + ' points '
        bounds += 'bottom ' + params[:resize_bottom].to_f.round(4).to_s + ' points '
        bounds += 'right ' + params[:resize_right].to_f.round(4).to_s + ' points'
      end
      bounds
    end

    def triggers(ac_session_history, ac_step, current_doc_spec, step_cs)
      trigger_types = %w(auto_process_steps reprocess_steps)
      step_cs = { ac_step.id => step_cs }
      merged_aws = ''
      merged_multiple_elements = []
      return [step_cs[ac_step.id], merged_aws, merged_multiple_elements] unless ac_step.form_data('triggers').present?
      ac_step.form_data('triggers').each do |trigger|
        next unless trigger_types.include?(trigger['type'])
        trigger['data'].each do |trigger_step_name|
          next if trigger['type'] == 'reprocess_steps' && !ac_session_history.finished_step?(name: trigger_step_name)
          ac_step.ac_base.ac_steps.each do |trigger_step|
            # only supported by text steps currently
            next unless trigger_step.name == ac_step.ac_base.name + ':' + trigger_step_name
            skip_triggers = true
            if trigger['type'] == 'auto_process_steps'
              ac_session_history.ac_session_attributes.where(ac_step_id: trigger_step.id).delete_all
              init_auto_process(ac_session_history, trigger_step)
            end
            ac_session_history.ac_session_attributes.reload
            delete_on_export = []
            case trigger_step.form_data('operation')
            when 'sub_layer_replace_text_choice_multiple'
              cs, aws, delete_on_export, multiple_elements = cs_sub_layer_replace_text_multiple(ac_session_history, trigger_step.id, current_doc_spec, skip_triggers)
            when 'replace_text'
              cs, aws, delete_on_export, multiple_elements = cs_replace_text(ac_session_history, trigger_step.id, current_doc_spec, skip_triggers)
            when 'replace_text_multiple'
              cs, aws, delete_on_export, multiple_elements = cs_replace_text_multiple(ac_session_history, trigger_step.id, current_doc_spec, skip_triggers)
            end
            init_delete_on_export_triggers(trigger_step.id, delete_on_export)
            ac_session_history.ac_session_attributes.create(ac_step_id: trigger_step.id, attribute_type: 'user', name: 'finished_step', value: trigger_step.id.to_s)
            # add element_name to multiple_elements array
            merged_multiple_elements << trigger_step.form_data('element_name') if trigger_step.form_data('element_name').present?
            step_cs[trigger_step.id] = cs
            merged_aws += aws if aws.present?
            merged_multiple_elements += multiple_elements if multiple_elements.present?
          end
        end
      end
      merged_cs = step_cs.sort.to_h.values.join

      [merged_cs, merged_aws, merged_multiple_elements]
    end

    def init_auto_process(ac_session_history, ac_step)
      search_params = {}
      search_params[:default] = 1 if ac_step.form_data('default_keyword_name').present?
      case ac_step.form_data('operation')
      when 'replace_text'
        results = ac_step.search(ac_session_history.ac_session.user, ac_session_history.id, search_params)
        if results.present?
          asset = results[0]
          AcSessionAttribute.find_or_create_by(ac_session_history_id: ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'user', name: 'replace_text|option_id', value: asset.id.to_s)
          AcSessionAttribute.find_or_create_by(ac_session_history_id: ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'user', name: 'option_type', value: asset.class.name)
          AcSessionAttribute.find_or_create_by(ac_session_history_id: ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'user', name: 'option_id', value: asset.id.to_s)
          ac_session_history.set_ac_session_attributes_hash(ac_step.id, asset.set_attributes)
        end
      when 'replace_text_multiple', 'sub_layer_replace_text_choice_multiple'
        max_selections = ac_step.form_data('max_selections')
        results = ac_step.search(ac_session_history.ac_session.user, ac_session_history.id, search_params)
        multiple_choices = []
        results.each_with_index do |result, i|
          break if i == max_selections.to_i
          multiple_choices << result.class.name + "|#{result.token}"
          ac_session_history.set_ac_session_attributes_hash(ac_step.id, result.set_attributes) if result.set_attributes.present?
        end
        choices = init_multiple_attributes(ac_step, multiple_choices)
        logger.debug 'init multiple attributes called from init_auto_process for step: ' + ac_step.to_yaml
        logger.debug choices.to_yaml
      end
    end
  end
end
