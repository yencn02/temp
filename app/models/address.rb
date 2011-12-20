class Address < ActiveRecord::Base
  belongs_to :user_info
  belongs_to :country
  belongs_to :city
  
  def city
    City.find(:first, :conditions => ['id = ?', self.city_id])
  end
end
