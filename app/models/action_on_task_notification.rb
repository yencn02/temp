class ActionOnTaskNotification < ActiveRecord::Base
  has_one :task_notification, :as => :resource
end
