class KwikeeProductsController < ApplicationController
  before_action :set_kwikee_product, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /kwikee_products
  # GET /kwikee_products.json
  def index
    @kwikee_products = KwikeeProduct.all
  end

  # GET /kwikee_products/1
  # GET /kwikee_products/1.json
  def show
  end

  # GET /kwikee_products/new
  def new
    @kwikee_product = KwikeeProduct.new
  end

  # GET /kwikee_products/1/edit
  def edit
  end

  # POST /kwikee_products
  # POST /kwikee_products.json
  def create
    @kwikee_product = KwikeeProduct.new(kwikee_product_params)

    respond_to do |format|
      if @kwikee_product.save
        format.html { redirect_to @kwikee_product, notice: 'Kwikee product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_product }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_products/1
  # PATCH/PUT /kwikee_products/1.json
  def update
    respond_to do |format|
      if @kwikee_product.update(kwikee_product_params)
        format.html { redirect_to @kwikee_product, notice: 'Kwikee product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_products/1
  # DELETE /kwikee_products/1.json
  def destroy
    @kwikee_product.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_products_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_product
      @kwikee_product = KwikeeProduct.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_product_params
      params.require(:kwikee_product).permit(:allergens, :brand_id, :brand_name, :cal_from_sat_tran_fat, :calories_per_serving, :carbo_per_serving, :carbo_uom, :case_count, :case_depth, :case_gtin, :case_height, :case_width, :category, :cholesterol_per_serving, :cholesterol_uom, :column_heading, :column_headings, :component_element, :component_elements, :consumable, :container_type, :custom_product_name, :department, :depth, :description, :diabetes_fc_values, :disease_claim, :display_depth, :display_height, :display_width, :division_name, :division_name_2, :dvp_biotin, :dvp_calcium, :dvp_carbo, :dvp_chloride, :dvp_cholesterol, :dvp_chromium, :dvp_copper, :dvp_fiber, :dvp_folic_acid, :dvp_iodide, :dvp_iodine, :dvp_iron, :dvp_magnesium, :dvp_manganese, :dvp_molybdenum, :dvp_niacin, :dvp_panthothenate, :dvp_phosphorus, :dvp_potassium, :dvp_protein, :dvp_riboflavin, :dvp_sat_tran_fat, :dvp_saturated_fat, :dvp_selenium, :dvp_sodium, :dvp_sugar, :dvp_thiamin, :dvp_total_fat, :dvp_vitamin_a, :dvp_vitamin_b12, :dvp_vitamin_b6, :dvp_vitamin_c, :dvp_vitamin_d, :dvp_vitamin_e, :dvp_vitamin_k, :dvp_zinc, :extra_text_2, :extra_text_3, :extra_text_4, :fat_calories_per_serving, :fat_free, :fiber_per_serving, :fiber_uom, :flavor, :footer, :footers, :footnote, :footnotes, :format, :gluten_free, :gpc_attributes_assigned, :gpc_brick_id, :gpc_brick_name, :gpc_class_id, :gpc_class_name, :gpc_family_id, :gpc_family_name, :gpc_segment_id, :gpc_segment_name, :gtin, :guarantee_analysis, :guarantees, :header, :headers, :height, :image_indicator, :indications_copy, :ingredient_code, :ingredients, :insol_fiber_per_serving, :insol_fiber_per_serving_uom, :instruction_copy_1, :instruction_copy_2, :instruction_copy_3, :instruction_copy_4, :instruction_copy_5, :interactions_copy, :is_variant_flag, :kosher, :kwikee_why_buy, :last_publish_date, :legal, :low_fat, :manufacturer_id, :manufacturer_name, :mfr_approved_date, :model, :mono_unsat_fat, :mono_unsat_fat_uom, :multiple_shelf_facings, :name, :nutrient_claim_1, :nutrient_claim_2, :nutrient_claim_3, :nutrient_claim_4, :nutrient_claim_5, :nutrient_claim_6, :nutrient_claim_7, :nutrient_claim_8, :nutrient_disclaimer_1, :nutrient_disclaimer_2, :nutrient_disclaimer_3, :nutrient_disclaimer_4, :nutrition_footnotes_1, :nutrition_footnotes_2, :nutrition_head_1, :nutrition_head_2, :nutrition_label, :omega_3_polyunsat, :omega_3_polyunsat_uom, :omega_6_polyunsat, :omega_6_polyunsat_uom, :omega_9_polyunsat, :omega_9_polyunsat_uom, :organic, :other_nutrient_statement, :override_manufacturer_tasks, :peg_down, :peg_right, :physical_weight_lb, :physical_weight_oz, :poly_unsat_fat, :poly_unsat_fat_uom, :post_consumer, :potassium_per_serving, :potassium_uom, :primary_gtin, :primary_type, :primary_version, :product_count, :product_form, :product_id, :product_name, :product_size, :product_type, :profile_id, :promotion, :protein_per_serving, :protein_uom, :romance_copy_1, :romance_copy_2, :romance_copy_3, :romance_copy_4, :romance_copy_category, :sat_fat_per_serving, :sat_fat_uom, :section_id, :section_name, :segment, :segments, :sensible_solutions, :serving_size, :serving_size_uom, :servings_per_container, :size_description_1, :size_description_2, :sodium_per_serving, :sodium_uom, :sol_fiber_per_serving, :sol_fiber_per_serving_uom, :ss_claim_1, :ss_claim_2, :ss_claim_3, :ss_claim_4, :starch_per_serving, :starch_per_serving_uom, :sub_number, :sugar_per_serving, :sugar_uom, :suger_alc_per_serving, :suger_alc_per_serving_uom, :supplemental_facts, :total_fat_per_serving, :total_fat_uom, :trans_fat_per_serving, :trans_fat_uom, :tray_count, :tray_depth, :tray_height, :tray_width, :unit_container, :unit_size, :unit_uom, :uom, :upc_10, :upc_12, :value, :values, :variant_name_1, :variant_name_2, :variant_value_1, :variant_value_2, :vm_claim_1, :vm_claim_2, :vm_claim_3, :vm_claim_4, :vm_type_1, :vm_type_2, :vm_type_3, :vm_type_4, :warnings_copy, :why_buy_copy, :width)
    end
end
