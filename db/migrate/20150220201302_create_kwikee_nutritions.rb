class CreateKwikeeNutritions < ActiveRecord::Migration
  def change
    create_table :kwikee_nutritions do |t|
      t.integer :kwikee_product_id
      t.text :cal_from_sat_tran_fat
      t.text :calories_per_serving
      t.text :carbo_per_serving
      t.text :carbo_uom
      t.text :cholesterol_per_serving
      t.text :cholesterol_uom
      t.text :dvp_biotin
      t.text :dvp_calcium
      t.text :dvp_carbo
      t.text :dvp_chloride
      t.text :dvp_cholesterol
      t.text :dvp_chromium
      t.text :dvp_copper
      t.text :dvp_fiber
      t.text :dvp_folic_acid
      t.text :dvp_iodide
      t.text :dvp_iodine
      t.text :dvp_iron
      t.text :dvp_magnesium
      t.text :dvp_manganese
      t.text :dvp_molybdenum
      t.text :dvp_niacin
      t.text :dvp_panthothenate
      t.text :dvp_phosphorus
      t.text :dvp_potassium
      t.text :dvp_protein
      t.text :dvp_riboflavin
      t.text :dvp_sat_tran_fat
      t.text :dvp_saturated_fat
      t.text :dvp_selenium
      t.text :dvp_sodium
      t.text :dvp_sugar
      t.text :dvp_thiamin
      t.text :dvp_total_fat
      t.text :dvp_vitamin_a
      t.text :dvp_vitamin_b12
      t.text :dvp_vitamin_b6
      t.text :dvp_vitamin_c
      t.text :dvp_vitamin_d
      t.text :dvp_vitamin_e
      t.text :dvp_vitamin_k
      t.text :dvp_zinc
      t.text :fat_calories_per_serving
      t.text :fiber_per_serving
      t.text :fiber_uom
      t.text :insol_fiber_per_serving
      t.text :insol_fiber_per_serving_uom
      t.text :mono_unsat_fat
      t.text :mono_unsat_fat_uom
      t.text :nutrient_disclaimer_1
      t.text :nutrient_disclaimer_2
      t.text :nutrient_disclaimer_3
      t.text :nutrient_disclaimer_4
      t.text :nutrition_label
      t.text :omega_3_polyunsat
      t.text :omega_3_polyunsat_uom
      t.text :omega_6_polyunsat
      t.text :omega_6_polyunsat_uom
      t.text :omega_9_polyunsat
      t.text :omega_9_polyunsat_uom
      t.text :poly_unsat_fat
      t.text :poly_unsat_fat_uom
      t.text :potassium_per_serving
      t.text :potassium_uom
      t.text :protein_per_serving
      t.text :protein_uom
      t.text :sat_fat_per_serving
      t.text :sat_fat_uom
      t.text :serving_size
      t.text :serving_size_uom
      t.text :servings_per_container
      t.text :sodium_per_serving
      t.text :sodium_uom
      t.text :sol_fiber_per_serving
      t.text :sol_fiber_per_serving_uom
      t.text :starch_per_serving
      t.text :starch_per_serving_uom
      t.text :sub_number
      t.text :sugar_per_serving
      t.text :sugar_uom
      t.text :suger_alc_per_serving
      t.text :suger_alc_per_serving_uom
      t.text :total_fat_per_serving
      t.text :total_fat_uom
      t.text :trans_fat_per_serving
      t.text :trans_fat_uom

      t.timestamps
    end
     remove_column :kwikee_products, :cal_from_sat_tran_fat
     remove_column :kwikee_products, :calories_per_serving
     remove_column :kwikee_products, :carbo_per_serving
     remove_column :kwikee_products, :carbo_uom
     remove_column :kwikee_products, :cholesterol_per_serving
     remove_column :kwikee_products, :cholesterol_uom
     remove_column :kwikee_products, :dvp_biotin
     remove_column :kwikee_products, :dvp_calcium
     remove_column :kwikee_products, :dvp_carbo
     remove_column :kwikee_products, :dvp_chloride
     remove_column :kwikee_products, :dvp_cholesterol
     remove_column :kwikee_products, :dvp_chromium
     remove_column :kwikee_products, :dvp_copper
     remove_column :kwikee_products, :dvp_fiber
     remove_column :kwikee_products, :dvp_folic_acid
     remove_column :kwikee_products, :dvp_iodide
     remove_column :kwikee_products, :dvp_iodine
     remove_column :kwikee_products, :dvp_iron
     remove_column :kwikee_products, :dvp_magnesium
     remove_column :kwikee_products, :dvp_manganese
     remove_column :kwikee_products, :dvp_molybdenum
     remove_column :kwikee_products, :dvp_niacin
     remove_column :kwikee_products, :dvp_panthothenate
     remove_column :kwikee_products, :dvp_phosphorus
     remove_column :kwikee_products, :dvp_potassium
     remove_column :kwikee_products, :dvp_protein
     remove_column :kwikee_products, :dvp_riboflavin
     remove_column :kwikee_products, :dvp_sat_tran_fat
     remove_column :kwikee_products, :dvp_saturated_fat
     remove_column :kwikee_products, :dvp_selenium
     remove_column :kwikee_products, :dvp_sodium
     remove_column :kwikee_products, :dvp_sugar
     remove_column :kwikee_products, :dvp_thiamin
     remove_column :kwikee_products, :dvp_total_fat
     remove_column :kwikee_products, :dvp_vitamin_a
     remove_column :kwikee_products, :dvp_vitamin_b12
     remove_column :kwikee_products, :dvp_vitamin_b6
     remove_column :kwikee_products, :dvp_vitamin_c
     remove_column :kwikee_products, :dvp_vitamin_d
     remove_column :kwikee_products, :dvp_vitamin_e
     remove_column :kwikee_products, :dvp_vitamin_k
     remove_column :kwikee_products, :dvp_zinc
     remove_column :kwikee_products, :fat_calories_per_serving
     remove_column :kwikee_products, :fiber_per_serving
     remove_column :kwikee_products, :fiber_uom
     remove_column :kwikee_products, :insol_fiber_per_serving
     remove_column :kwikee_products, :insol_fiber_per_serving_uom
     remove_column :kwikee_products, :mono_unsat_fat
     remove_column :kwikee_products, :mono_unsat_fat_uom
     remove_column :kwikee_products, :nutrient_disclaimer_1
     remove_column :kwikee_products, :nutrient_disclaimer_2
     remove_column :kwikee_products, :nutrient_disclaimer_3
     remove_column :kwikee_products, :nutrient_disclaimer_4
     remove_column :kwikee_products, :nutrition_label
     remove_column :kwikee_products, :omega_3_polyunsat
     remove_column :kwikee_products, :omega_3_polyunsat_uom
     remove_column :kwikee_products, :omega_6_polyunsat
     remove_column :kwikee_products, :omega_6_polyunsat_uom
     remove_column :kwikee_products, :omega_9_polyunsat
     remove_column :kwikee_products, :omega_9_polyunsat_uom
     remove_column :kwikee_products, :poly_unsat_fat
     remove_column :kwikee_products, :poly_unsat_fat_uom
     remove_column :kwikee_products, :potassium_per_serving
     remove_column :kwikee_products, :potassium_uom
     remove_column :kwikee_products, :protein_per_serving
     remove_column :kwikee_products, :protein_uom
     remove_column :kwikee_products, :sat_fat_per_serving
     remove_column :kwikee_products, :sat_fat_uom
     remove_column :kwikee_products, :serving_size
     remove_column :kwikee_products, :serving_size_uom
     remove_column :kwikee_products, :servings_per_container
     remove_column :kwikee_products, :sodium_per_serving
     remove_column :kwikee_products, :sodium_uom
     remove_column :kwikee_products, :sol_fiber_per_serving
     remove_column :kwikee_products, :sol_fiber_per_serving_uom
     remove_column :kwikee_products, :starch_per_serving
     remove_column :kwikee_products, :starch_per_serving_uom
     remove_column :kwikee_products, :sub_number
     remove_column :kwikee_products, :sugar_per_serving
     remove_column :kwikee_products, :sugar_uom
     remove_column :kwikee_products, :suger_alc_per_serving
     remove_column :kwikee_products, :suger_alc_per_serving_uom
     remove_column :kwikee_products, :total_fat_per_serving
     remove_column :kwikee_products, :total_fat_uom
     remove_column :kwikee_products, :trans_fat_per_serving
     remove_column :kwikee_products, :trans_fat_uom

     remove_column :kwikee_products, :why_buy_copy
     add_column :kwikee_products, :why_buy_1, :text
     add_column :kwikee_products, :why_buy_2, :text
     add_column :kwikee_products, :why_buy_3, :text
     add_column :kwikee_products, :why_buy_4, :text
     add_column :kwikee_products, :why_buy_5, :text
     add_column :kwikee_products, :why_buy_6, :text
     add_column :kwikee_products, :why_buy_7, :text
  end
end
