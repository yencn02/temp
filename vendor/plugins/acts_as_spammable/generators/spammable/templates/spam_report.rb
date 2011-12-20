class SpamReport < ActiveRecord::Base

  belongs_to :reporter, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :reportee, :class_name => 'User', :foreign_key => 'reportee_id'
    
  default_scope :order => 'spam_reports.created_at ASC'

end
