class ChangeSecurityCodeToString < ActiveRecord::Migration
  def self.up
    remove_column :security_codes, :security_code
    add_column :security_codes, :security_code, :string
  end

  def self.down
  end
end
