# == Schema Information
#
# Table name: opt_outs
#
#  id            :integer          not null, primary key
#  email_address :text
#  created_at    :datetime
#  updated_at    :datetime
#

class OptOut < ActiveRecord::Base
end
