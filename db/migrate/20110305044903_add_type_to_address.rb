class AddTypeToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :address_type, :string
  end

  def self.down
  end
end
