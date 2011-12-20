class SecurityCode < ActiveRecord::Base
  belongs_to :user
  
  def self.generate(user_id, user_email, length = 10)
    SecurityCode.new(:user_id => user_id, :security_code => Digest::SHA1.hexdigest(user_email + rand(12341234).to_s)[1..length])
  end

end
