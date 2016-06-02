# == Schema Information
#
# Table name: kwikee_nutritions
#
#  id                          :integer          not null, primary key
#  kwikee_product_id           :integer
#  cal_from_sat_tran_fat       :text
#  calories_per_serving        :text
#  carbo_per_serving           :text
#  carbo_uom                   :text
#  cholesterol_per_serving     :text
#  cholesterol_uom             :text
#  dvp_biotin                  :text
#  dvp_calcium                 :text
#  dvp_carbo                   :text
#  dvp_chloride                :text
#  dvp_cholesterol             :text
#  dvp_chromium                :text
#  dvp_copper                  :text
#  dvp_fiber                   :text
#  dvp_folic_acid              :text
#  dvp_iodide                  :text
#  dvp_iodine                  :text
#  dvp_iron                    :text
#  dvp_magnesium               :text
#  dvp_manganese               :text
#  dvp_molybdenum              :text
#  dvp_niacin                  :text
#  dvp_panthothenate           :text
#  dvp_phosphorus              :text
#  dvp_potassium               :text
#  dvp_protein                 :text
#  dvp_riboflavin              :text
#  dvp_sat_tran_fat            :text
#  dvp_saturated_fat           :text
#  dvp_selenium                :text
#  dvp_sodium                  :text
#  dvp_sugar                   :text
#  dvp_thiamin                 :text
#  dvp_total_fat               :text
#  dvp_vitamin_a               :text
#  dvp_vitamin_b12             :text
#  dvp_vitamin_b6              :text
#  dvp_vitamin_c               :text
#  dvp_vitamin_d               :text
#  dvp_vitamin_e               :text
#  dvp_vitamin_k               :text
#  dvp_zinc                    :text
#  fat_calories_per_serving    :text
#  fiber_per_serving           :text
#  fiber_uom                   :text
#  insol_fiber_per_serving     :text
#  insol_fiber_per_serving_uom :text
#  mono_unsat_fat              :text
#  mono_unsat_fat_uom          :text
#  nutrient_disclaimer_1       :text
#  nutrient_disclaimer_2       :text
#  nutrient_disclaimer_3       :text
#  nutrient_disclaimer_4       :text
#  nutrition_label             :text
#  omega_3_polyunsat           :text
#  omega_3_polyunsat_uom       :text
#  omega_6_polyunsat           :text
#  omega_6_polyunsat_uom       :text
#  omega_9_polyunsat           :text
#  omega_9_polyunsat_uom       :text
#  poly_unsat_fat              :text
#  poly_unsat_fat_uom          :text
#  potassium_per_serving       :text
#  potassium_uom               :text
#  protein_per_serving         :text
#  protein_uom                 :text
#  sat_fat_per_serving         :text
#  sat_fat_uom                 :text
#  serving_size                :text
#  serving_size_uom            :text
#  servings_per_container      :text
#  sodium_per_serving          :text
#  sodium_uom                  :text
#  sol_fiber_per_serving       :text
#  sol_fiber_per_serving_uom   :text
#  starch_per_serving          :text
#  starch_per_serving_uom      :text
#  sub_number                  :text
#  sugar_per_serving           :text
#  sugar_uom                   :text
#  suger_alc_per_serving       :text
#  suger_alc_per_serving_uom   :text
#  total_fat_per_serving       :text
#  total_fat_uom               :text
#  trans_fat_per_serving       :text
#  trans_fat_uom               :text
#  created_at                  :datetime
#  updated_at                  :datetime
#

class KwikeeNutrition < ActiveRecord::Base
  belongs_to :kwikee_product

  default_scope { order(kwikee_product_id: :asc, sub_number: :asc) }
end
