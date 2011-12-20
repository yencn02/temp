class TaskNotification < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  has_one :notification, :as => :resource
  belongs_to :task
end
