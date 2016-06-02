# module ApplicationHelper
module ApplicationHelper
  def link_to_add_dynamic_form_inputs(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    dynamic_form_inputs = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
    link_to(name, '#', class: "add_dynamic_form_inputs", data: { id: id, dynamic_form_inputs: dynamic_form_inputs.gsub("\n", '') })
  end

  def countries
    [
      ['Select Country', ''],
      ['United States', 'US'],
      ['Canada', 'CA']
    ]
  end

  def us_states
    [
      ['Select State', ''],
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

  def can_provinces
    [
      ['Select Province', ''],
      ['Alberta', 'AB'],
      ['British Columbia', 'BC'],
      ['Manitoba', 'MB'],
      ['New Brunswick', 'NB'],
      ['Newfoundland', 'NF'],
      ['Northwest Territories', 'NT'],
      ['Nova Scotia', 'NS'],
      ['Ontario', 'ON'],
      ['Prince Edward Island', 'PE'],
      ['Quebec', 'QC'],
      ['Saskatchewan', 'SK'],
      ['Yukon', 'YT']
    ]
  end

  def profile_priority_countries
    %w(US CA)
  end

  def profile_state_select
    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes

    us_states

    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes
    #### This may be custom extra padding for git purposes
  end

  # custom client stuff defined here.
  def case_study_geography
    []
  end

  def case_study_drill_down
    {}
  end
end

