class AddSsoFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :sso_flag, :boolean, default: false
  end
end
