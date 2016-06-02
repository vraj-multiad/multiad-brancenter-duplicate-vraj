# app/models/concerns/opt_out.rb
module OptOutable
  extend ActiveSupport::Concern

  included do
    def opt_out_emails
      standard
    end

    def standard
      OptOut.all.pluck(:email_address)
    end

    #### Custom handling of external opt_out mechanisms would go here
    #### Custom handling of external opt_out mechanisms would go here
  end
end
