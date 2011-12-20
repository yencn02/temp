class CreateUserInfo < ActiveRecord::Migration
  def self.up
    create_table :user_infos do |t|
      t.integer :user_id
      t.boolean :sex
      t.date :birthday
      t.string :position
      t.text :study
      t.string :home_town
      t.text :relatives
      t.text :hobbies
      t.string :address_town
      t.string :address_home
      t.string :address_work
      t.string :address_university
      t.integer :email_id
      t.string :phone
      t.string :mobile
      t.string :pobox
      t.string :website
      t.string :twitter_account
      t.string :facebook_account
      
      t.timestamps
    end
  end

  def self.down
    drop_table :user_infos
  end
end
