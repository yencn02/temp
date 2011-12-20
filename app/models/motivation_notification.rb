class MotivationNotification < ActiveRecord::Base
  has_one :notification, :as => :resource
end
