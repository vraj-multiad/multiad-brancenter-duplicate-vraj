class KwikeeNutritionsController < ApplicationController
  before_action :set_kwikee_nutrition, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /kwikee_nutritions
  # GET /kwikee_nutritions.json
  def index
    @kwikee_nutritions = KwikeeNutrition.all
  end

  # GET /kwikee_nutritions/1
  # GET /kwikee_nutritions/1.json
  def show
  end

  # GET /kwikee_nutritions/new
  def new
    @kwikee_nutrition = KwikeeNutrition.new
  end

  # GET /kwikee_nutritions/1/edit
  def edit
  end

  # POST /kwikee_nutritions
  # POST /kwikee_nutritions.json
  def create
    @kwikee_nutrition = KwikeeNutrition.new(kwikee_nutrition_params)

    respond_to do |format|
      if @kwikee_nutrition.save
        format.html { redirect_to @kwikee_nutrition, notice: 'Kwikee nutrition was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_nutrition }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_nutrition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_nutritions/1
  # PATCH/PUT /kwikee_nutritions/1.json
  def update
    respond_to do |format|
      if @kwikee_nutrition.update(kwikee_nutrition_params)
        format.html { redirect_to @kwikee_nutrition, notice: 'Kwikee nutrition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_nutrition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_nutritions/1
  # DELETE /kwikee_nutritions/1.json
  def destroy
    @kwikee_nutrition.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_nutritions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_nutrition
      @kwikee_nutrition = KwikeeNutrition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_nutrition_params
      params.require(:kwikee_nutrition).permit(:kwikee_product_id, :cal_from_sat_tran_fat, :calories_per_serving, :carbo_per_serving, :carbo_uom, :cholesterol_per_serving, :cholesterol_uom, :dvp_biotin, :dvp_calcium, :dvp_carbo, :dvp_chloride, :dvp_cholesterol, :dvp_chromium, :dvp_copper, :dvp_fiber, :dvp_folic_acid, :dvp_iodide, :dvp_iodine, :dvp_iron, :dvp_magnesium, :dvp_manganese, :dvp_molybdenum, :dvp_niacin, :dvp_panthothenate, :dvp_phosphorus, :dvp_potassium, :dvp_protein, :dvp_riboflavin, :dvp_sat_tran_fat, :dvp_saturated_fat, :dvp_selenium, :dvp_sodium, :dvp_sugar, :dvp_thiamin, :dvp_total_fat, :dvp_vitamin_a, :dvp_vitamin_b12, :dvp_vitamin_b6, :dvp_vitamin_c, :dvp_vitamin_d, :dvp_vitamin_e, :dvp_vitamin_k, :dvp_zinc, :fat_calories_per_serving, :fiber_per_serving, :fiber_uom, :insol_fiber_per_serving, :insol_fiber_per_serving_uom, :mono_unsat_fat, :mono_unsat_fat_uom, :nutrient_disclaimer_1, :nutrient_disclaimer_2, :nutrient_disclaimer_3, :nutrient_disclaimer_4, :nutrition_label, :omega_3_polyunsat, :omega_3_polyunsat_uom, :omega_6_polyunsat, :omega_6_polyunsat_uom, :omega_9_polyunsat, :omega_9_polyunsat_uom, :poly_unsat_fat, :poly_unsat_fat_uom, :potassium_per_serving, :potassium_uom, :protein_per_serving, :protein_uom, :sat_fat_per_serving, :sat_fat_uom, :serving_size, :serving_size_uom, :servings_per_container, :sodium_per_serving, :sodium_uom, :sol_fiber_per_serving, :sol_fiber_per_serving_uom, :starch_per_serving, :starch_per_serving_uom, :sub_number, :sugar_per_serving, :sugar_uom, :suger_alc_per_serving, :suger_alc_per_serving_uom, :total_fat_per_serving, :total_fat_uom, :trans_fat_per_serving, :trans_fat_uom)
    end
end
