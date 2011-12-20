class UserInfo < ActiveRecord::Base
  belongs_to :user
  has_many :emails
  has_many :relatives_relationships, :class_name => "RelativesRelationship", :foreign_key => "user_info_id" 
  has_many :relatives_infos, :source => :relative_info, :through => :relatives_relationships
  has_attached_file :avatar,
                    :styles => { :small => "24x24#", :medium => "64x64#" ,:thumb => "100x100#" },
                    :path => ":rails_root/system/:class/:attachment/:id/:style/:basename.:extension",
                    :url => ":rails_root/system/:class/:attachment/:id/:style/:basename.:extension",
                    :default_url => "/images/missing_photo.png"
  has_many :addresses
  
  accepts_nested_attributes_for :emails, :allow_destroy => true, :reject_if => proc { |attrs| attrs['email'].blank? }
  accepts_nested_attributes_for :addresses, :allow_destroy => true, :reject_if => proc { |attrs| attrs['email'].blank? }    
  
  def sex_as_string
    sex ? 'Male' : 'Female'
  end
  
  def destroy_relatives_infos  	
    relatives_infos.each do |r|
      rs = RelativesRelationship.find_by_user_info_id_and_relative_info_id(self.id, r.id);
      rs.destroy
    end  
  end
  
  def destroy_addresses
  	# TODO: addresses.map(&:destroy)
  	# or use { || } blocks style for one line blocks
    addresses.each do |a|
      a.destroy
    end
  end
  
  def city(type)
    begin
      address(type).city
    rescue
      nil
    end
  end
  
  def home_country
    begin
      address('home').country.name
    rescue
      ''
    end
  end
  
  def address(type)
    addresses.each do |a|
      if a.address_type == type
        return a
      end
    end
    return nil
  end
  
  # TODO: helper method not model
  def address_as_string(type)
    ad = address(type)
    begin
      ad.nil? ? nil : "#{ad.country.name}, #{ad.city.name}, #{ad.street1}, #{ad.street2}"
    rescue
      "sorry, bad address"
    end
  end
  
  # TODO: helper method not model  
  def address_as_ids(type)
    ad = address(type)
    begin
      ad.nil? ? nil : "#{ad.country.id}$#{ad.city.id}$#{ad.street1}$#{ad.street2}$#{ad.address_type}"
    rescue
      "0$0$0$0$0"
    end
  end    
    
end
