# == Schema Information
#
# Table name: kwikee_api_job_files
#
#  id                :integer          not null, primary key
#  kwikee_api_job_id :integer
#  status            :string(255)
#  file_name         :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

# Basic structure
# Kwikee API has 0 or 1 files per day, in a standard transactional fashion
# KwikeeProduct => KwikeeAsset => KwikeeFile
# Parsing starts from the outside and tunnels in a straight forward transactional
# fashion, insert => insert, update => update, delete => delete.
# Except
# 1) KwikeeFile objects are dependent on the KwikeeAsset and are all deleted
#    and recreated if any update on KwikeeAsset occurs.
# 2) brand, manufacturer, instructions_copy and romance_copy schema objects
#    are all denormalized
#
# All xml files process logs are uploaded to aws

class KwikeeApiJobFile < ActiveRecord::Base
  belongs_to :kwikee_api_job

  def kwikee_custom_data_attribute_fields
    %w(
      name
      value
    )
  end

  def kwikee_external_code_fields
    %w(
      name
      value
      )
  end

  def product_fields
    %w(
      gtin
      primary_gtin
      primary_type
      primary_version
      product_id
      upc_10
      upc_12
    )
  end

  def profile_fields
    %w(
      allergens
      case_count
      case_depth
      case_gtin
      case_height
      case_width
      category
      column_heading
      column_headings
      component_element
      component_elements
      consumable
      container_type
      custom_product_name
      department
      depth
      description
      diabetes_fc_values
      disease_claim
      display_depth
      display_height
      display_width
      division_name
      division_name_2
      extra_text_2
      extra_text_3
      extra_text_4
      fat_free
      flavor
      footer
      footers
      footnote
      footnotes
      format
      gluten_free
      gpc_attributes_assigned
      gpc_brick_id
      gpc_brick_name
      gpc_class_id
      gpc_class_name
      gpc_family_id
      gpc_family_name
      gpc_segment_id
      gpc_segment_name
      guarantee_analysis
      guarantees
      header
      headers
      height
      image_indicator
      indications_copy
      ingredient_code
      ingredients
      interactions_copy
      is_variant_flag
      kosher
      kwikee_why_buy
      last_publish_date
      legal
      low_fat
      mfr_approved_date
      model
      multiple_shelf_facings
      name
      nutrient_claim_1
      nutrient_claim_2
      nutrient_claim_3
      nutrient_claim_4
      nutrient_claim_5
      nutrient_claim_6
      nutrient_claim_7
      nutrient_claim_8
      nutrition_footnotes_1
      nutrition_footnotes_2
      nutrition_head_1
      nutrition_head_2
      organic
      other_nutrient_statement
      override_manufacturer_tasks
      peg_down
      peg_right
      physical_weight_lb
      physical_weight_oz
      post_consumer
      product_count
      product_form
      product_name
      product_size
      product_type
      profile_id
      promotion
      romance_copy_category
      section_id
      section_name
      segment
      segments
      sensible_solutions
      size_description_1
      size_description_2
      ss_claim_1
      ss_claim_2
      ss_claim_3
      ss_claim_4
      supplemental_facts
      tray_count
      tray_depth
      tray_height
      tray_width
      unit_container
      unit_size
      unit_uom
      uom
      value
      values
      variant_name_1
      variant_name_2
      variant_value_1
      variant_value_2
      vm_claim_1
      vm_claim_2
      vm_claim_3
      vm_claim_4
      vm_type_1
      vm_type_2
      vm_type_3
      vm_type_4
      warnings_copy
      width
    )
  end

  def kwikee_nutrition_fields
    %w(
      cal_from_sat_tran_fat
      calories_per_serving
      carbo_per_serving
      carbo_uom
      cholesterol_per_serving
      cholesterol_uom
      dvp_biotin
      dvp_calcium
      dvp_carbo
      dvp_chloride
      dvp_cholesterol
      dvp_chromium
      dvp_copper
      dvp_fiber
      dvp_folic_acid
      dvp_iodide
      dvp_iodine
      dvp_iron
      dvp_magnesium
      dvp_manganese
      dvp_molybdenum
      dvp_niacin
      dvp_panthothenate
      dvp_phosphorus
      dvp_potassium
      dvp_protein
      dvp_riboflavin
      dvp_sat_tran_fat
      dvp_saturated_fat
      dvp_selenium
      dvp_sodium
      dvp_sugar
      dvp_thiamin
      dvp_total_fat
      dvp_vitamin_a
      dvp_vitamin_b12
      dvp_vitamin_b6
      dvp_vitamin_c
      dvp_vitamin_d
      dvp_vitamin_e
      dvp_vitamin_k
      dvp_zinc
      fat_calories_per_serving
      fiber_per_serving
      fiber_uom
      insol_fiber_per_serving
      insol_fiber_per_serving_uom
      mono_unsat_fat
      mono_unsat_fat_uom
      nutrient_disclaimer_1
      nutrient_disclaimer_2
      nutrient_disclaimer_3
      nutrient_disclaimer_4
      nutrition_label
      omega_3_polyunsat
      omega_3_polyunsat_uom
      omega_6_polyunsat
      omega_6_polyunsat_uom
      omega_9_polyunsat
      omega_9_polyunsat_uom
      poly_unsat_fat
      poly_unsat_fat_uom
      potassium_per_serving
      potassium_uom
      protein_per_serving
      protein_uom
      sat_fat_per_serving
      sat_fat_uom
      serving_size
      serving_size_uom
      servings_per_container
      sodium_per_serving
      sodium_uom
      sol_fiber_per_serving
      sol_fiber_per_serving_uom
      starch_per_serving
      starch_per_serving_uom
      sub_number
      sugar_per_serving
      sugar_uom
      suger_alc_per_serving
      suger_alc_per_serving_uom
      total_fat_per_serving
      total_fat_uom
      trans_fat_per_serving
      trans_fat_uom
    )
  end

  def brand_fields
    %w(id name)
  end

  def manufacturer_fields
    %w(id name)
  end

  def kwikee_asset_fields
    %w(asset_id type promotion version view)
  end

  def integer_field_names
    %w(
      asset_id
      brand_id
      gpc_brick_id
      gpc_class_id
      gpc_family_id
      gpc_segment_id
      manufacturer_id
      product_id
    )
  end

  def datetime_field_names
    %w(
      gpc_attributes_assigned
      last_publish_date
      mfr_approved_date
    )
  end

  def process
    @creates ||= ''
    @updates ||= ''
    @deletes ||= ''
    @kp_failures ||= ''
    @ka_failures ||= ''
    create_log_file
    noko_file = Nokogiri::XML(File.new("#{Rails.root}" + '/tmp/' + file_name))
    root = noko_file.root
    products = root.xpath('products/product')
    products.each do |product|
      action = product.xpath('action').children[0].to_s
      case action
      when 'INSERT', 'UPDATE', 'NO CHANGE'
        create_or_update_kwikee_product(product, action)
      when 'DELETE'
        delete_kwikee_product product
      else
        log 'action not supported ' + action.to_s + ' product: ' + product.to_s
      end
    end
    self.status = 'complete'
    save
    close_and_upload_log_file
    process_results_email
  end

  def process_results_email
    subject = 'Processing results for ' + Time.now.strftime('%m-%d-%Y') + ' for replication date ' + kwikee_api_job.replication_date.strftime('%m-%d-%Y')
    message = subject + "\n"
    message += 'The following upcs were created:' + "\n" + @creates.to_s + "\n\n"
    message += 'The following upcs were updated:' + "\n" + @updates.to_s + "\n\n"
    message += 'The following upcs were deleted:' + "\n" + @deletes.to_s + "\n\n"
    message += 'The following products failed and were deleted:' + "\n" + @kp_failures.to_s + "\n\n"
    message += 'The following assets failed and were deleted:' + "\n" + @ka_failures.to_s + "\n\n"
    if KWIKEE_API_ACCESS_LEVELS
      AccessLevel.kwikee_manufacturers.each do |manufacturer|
        message += 'Kwikee Access Level Results:' + "\n"
        message += ' KP  ' + manufacturer.title + ': ' + manufacturer.asset_access_levels.where(restrictable_type: 'KwikeeProduct').count.to_s + "\n"
        message += ' DL  ' + manufacturer.title + ': ' + manufacturer.asset_access_levels.where(restrictable_type: 'DlImage').count.to_s + "\n"
        manufacturer.sub_access_levels.each do |brand|
          message += ' KP      ' + brand.title + ': ' + brand.asset_access_levels.where(restrictable_type: 'KwikeeProduct').count.to_s + "\n"
          message += ' DL      ' + brand.title + ': ' + brand.asset_access_levels.where(restrictable_type: 'DlImage').count.to_s + "\n"
        end
      end
    else
      message += 'Kwikee Access Levels not configured' + "\n"
    end
    message += "\n"
    UserMailer.system_message_email(subject, message, KWIKEE_API_UPDATE_EMAIL).deliver
  end

  def cast_field(field, value)
    value = value.to_datetime if datetime_field_names.include?(field)
    value = value.to_i if integer_field_names.include?(field)
    value
  end

  def kwikee_product_params(product)
    params = {}

    product_fields.each do |f|
      xpath = f
      key = f.to_sym
      params[key] = cast_field(f, product.xpath(xpath).children[0].to_s)
    end

    profile_fields.each do |f|
      xpath = 'data/profile/' + f
      key = f.to_sym
      params[key] = cast_field(f, product.xpath(xpath).children[0].to_s)
    end

    brand_fields.each do |f|
      xpath = 'data/profile/brand/' + f
      key = ('brand_' + f).to_sym
      params[key] = cast_field(f, product.xpath(xpath).children[0].to_s)
    end

    manufacturer_fields.each do |f|
      xpath = 'data/profile/manufacturer/' + f
      key = ('manufacturer_' + f).to_sym
      params[key] = cast_field(f, product.xpath(xpath).children[0].to_s)
    end

    if product.xpath('data/profile/instructions/kwikee_instruction').count > 0
      product.xpath('data/profile/instructions/kwikee_instruction').each_with_index do |f, i|
        index = i + 1
        key = ('instruction_copy_' + index.to_s).to_sym
        params[key] = f.children[0].to_s
        break if index == 5
      end
    end

    if product.xpath('data/profile/romance_copy/kwikee_romance').count > 0
      product.xpath('data/profile/romance_copy/kwikee_romance').each_with_index do |f, i|
        index = i + 1
        key = ('romance_copy_' + index.to_s).to_sym
        params[key] = f.children[0].to_s
        break if index == 4
      end
    end

    if product.xpath('data/profile/why_buy_copy/kwikee_why_buy').count > 0
      product.xpath('data/profile/why_buy_copy/kwikee_why_buy').each_with_index do |f, i|
        index = i + 1
        key = ('why_buy_' + index.to_s).to_sym
        params[key] = f.children[0].to_s
        break if index == 7
      end
    end

    params
  end

  def create_or_update_kwikee_product(product, action)
    product_id = product.xpath('product_id').children[0].to_s.to_i
    log 'KP UPDATE: ' + product_id.to_s
    kp = KwikeeProduct.where(product_id: product_id).take
    # sanity check treat as insert unless KwikeeProduct present?
    return create_kwikee_product(product) unless kp.present?
    return process_product_assets(kp, product) if action == 'NO CHANGE'
    log 'KP UPDATE (before update): ' + kp.inspect.to_s
    kp.update(kwikee_product_params(product))
    log 'KP UPDATE (after  update): ' + kp.inspect.to_s
    kp.save

    @updates += kp.gtin + "\n"
    kp.kwikee_nutritions.destroy_all if kp.kwikee_nutritions.present?
    kp.kwikee_external_codes.destroy_all if kp.kwikee_external_codes.present?
    kp.kwikee_custom_data.destroy_all if kp.kwikee_custom_data.present?
    process_product_nutritions(kp, product)
    process_product_custom_data(kp, product)
    process_product_external_codes(kp, product)
    process_product_assets(kp, product)
  end

  def create_kwikee_product(product)
    kp = KwikeeProduct.new(kwikee_product_params(product))
    kp.save
    log 'KP INSERT: ' + kp.product_id.to_s
    log 'KP INSERT: ' + kp.inspect.to_s

    @creates += kp.gtin + "\n"

    process_product_nutritions(kp, product)
    process_product_custom_data(kp, product)
    process_product_external_codes(kp, product)
    process_product_assets(kp, product)
  end

  def delete_kwikee_product(product)
    product_id = product.xpath('product_id').children[0].to_s.to_i
    log 'KP DELETE: ' + product_id.to_s
    kp = KwikeeProduct.where(product_id: product_id).take
    if kp.present?
      @deletes += kp.gtin + "\n"
      kp.destroy
    else
      # previously deleted
      @deletes += 'product_id: ' + product_id.to_s + "\n"
    end
  end

  # Kwikee Custom Fields

  def process_product_custom_data(kp, product)
    product.xpath('data/profile/custom_data/group').each do |group|
      group_name = group.xpath('name').children[0].to_s
      kcd = kp.kwikee_custom_data.new(name: group_name, kwikee_profile_id: kp.profile_id)
      kcd.save
      attributes = group.xpath('attributes/attribute')
      attributes.each do |attribute|
        log 'KCD attribute: ' + attribute.to_s
        create_kwikee_custom_data_attributes(kcd, attribute)
      end
    end
  end

  def kwikee_custom_data_params(custom_data)
    custom_data_params = {}
    kwikee_custom_data_attribute_fields.each do |f|
      custom_data_field = f.to_sym
      custom_data_params[custom_data_field] = cast_field(f, custom_data.xpath(f).children[0].to_s)
    end
    custom_data_params
  end

  def create_kwikee_custom_data_attributes(kcd, custom_data)
    kcda = kcd.kwikee_custom_data_attributes.new(kwikee_custom_data_params(custom_data))
    kcda.save
    log '  KCDA INSERT: ' + kcda.kwikee_custom_datum.id.to_s
    log '  KCDA INSERT: ' + kcda.inspect.to_s
    # log '  KCD INSERT: ' + kwikee_custom_data_params(custom_data).inspect.to_s
  end

  # Kwikee External Codes

  def process_product_external_codes(kp, product)
    product.xpath('data/profile/external_codes/code').each do |external_code|
      log external_code.to_s
      create_kwikee_external_code(kp, external_code)
    end
  end

  def kwikee_external_code_params(external_code)
    external_code_params = {}
    kwikee_external_code_fields.each do |f|
      external_code_field = f.to_sym
      external_code_params[external_code_field] = cast_field(f, external_code.xpath(f).children[0].to_s)
    end
    external_code_params
  end

  def create_kwikee_external_code(kp, external_code)
    kec = kp.kwikee_external_codes.new(kwikee_external_code_params(external_code))
    kec.save
    log '  KEC INSERT: ' + kec.kwikee_product.id.to_s
    log '  KEC INSERT: ' + kec.inspect.to_s
    # log '  KCD INSERT: ' + kwikee_external_code_params(external_code).inspect.to_s
  end

  # Kwikee Nutrition

  def process_product_nutritions(kp, product)
    product.xpath('data/profile/nutrition/kwikee_nutrition').each do |nutrition|
      create_kwikee_nutrition(kp, nutrition)
    end
  end

  def kwikee_nutrition_params(nutrition)
    nutrition_params = {}
    kwikee_nutrition_fields.each do |f|
      nutrition_field = f.to_sym
      nutrition_params[nutrition_field] = cast_field(f, nutrition.xpath(f).children[0].to_s)
    end
    nutrition_params
  end

  def create_kwikee_nutrition(kp, nutrition)
    kn = kp.kwikee_nutritions.new(kwikee_nutrition_params(nutrition))
    kn.save
    log '  KN INSERT: ' + kn.kwikee_product_id.to_s
    log '  KN INSERT: ' + kn.inspect.to_s
  end

  # Kwikee Asset

  def process_product_assets(kp, product)
    product.xpath('images/asset').each do |asset|
      create_kwikee_asset(kp, asset)
    end
    errors = kp.rebuild_defaults
    @kp_failures += errors if errors.present?
  end

  def create_kwikee_asset(kp, asset)
    action = asset.xpath('action').children[0].to_s

    case action
    when 'INSERT', 'UPDATE'
      # sanity check
      asset_id = asset.xpath('asset_id').children[0].to_s.to_i
      ka = KwikeeAsset.where(asset_id: asset_id).take
      if ka.present?
        log '  KA UPDATE: ' + asset_id.to_s
        log '  KA UPDATE (before update): ' + ka.inspect.to_s
        ka.update(kwikee_asset_params(asset))
        log '  KA UPDATE (after  update): ' + ka.inspect.to_s
        ka.kwikee_files.destroy_all if ka.kwikee_files.present?
      else
        ka = kp.kwikee_assets.new(kwikee_asset_params(asset))
      end
      ka.save
      log '  KA INSERT: ' + ka.asset_id.to_s
      log '  KA INSERT: ' + ka.inspect.to_s

      create_kwikee_files(kp, ka, asset)
    when 'DELETE'
      asset_id = asset.xpath('asset_id').children[0].to_s.to_i
      log '  KA DELETE: ' + asset_id.to_s
      ka = KwikeeAsset.where(asset_id: asset_id).take
      ka.destroy if ka.present?
    else
      log 'action not supported ' + action.to_s + ' asset: ' + asset.to_s
    end
  end

  def kwikee_asset_params(asset)
    asset_params = {}
    kwikee_asset_fields.each do |f|
      asset_field = nil
      if f == 'type'
        asset_field = :asset_type
      else
        asset_field = f.to_sym
      end
      asset_params[asset_field] = cast_field(f, asset.xpath(f).children[0].to_s)
    end
    asset_params
  end

  # Kwikee Files

  def create_kwikee_files(kp, ka, asset)
    asset.xpath('files/file').each do |kwikee_file|
      file_params = {
        extension: kwikee_file.xpath('type').children[0].to_s,
        url: kwikee_file.xpath('url').children[0].to_s,
        kwikee_product_id: kp.id
      }
      kf = ka.kwikee_files.new(file_params)
      kf.save
    end
    ka.reload
    unless ka.thumbnail.present?
      log '! ka.thumbnail.present? '
      log ka.to_yaml
      log ka.kwikee_files.to_yaml
      @ka_failures += "gtin: #{kp.gtin}  view: #{ka.view} version: #{ka.version} promotion: #{ka.promotion} \n"
      ka.destroy
    end
  end

  def log(string)
    @log_file.write(string + "\n")
  end

  def log_file_name
    File.basename(file_name, '.*') + '.log'
  end

  def create_log_file
    tmp_dir = "#{Rails.root}" + '/tmp/'
    @log_file = File.open(tmp_dir + log_file_name, 'w')
  end

  def close_and_upload_log_file
    @log_file.close
    s3 = AWS::S3.new
    key = 'kwikee_api/logs/' + log_file_name
    s3.buckets[ENV['AWS_BUCKET_NAME']].objects[key].write(file: "#{Rails.root}/tmp/" + log_file_name)
  end
  # end
end
