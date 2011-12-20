class RelativesRelationship < ActiveRecord::Base
  belongs_to :user_info,     :class_name => "UserInfo", :foreign_key => "user_info_id"
  belongs_to :relative_info, :class_name => "UserInfo", :foreign_key => "relative_info_id"
end
