require 'active_record'

# ActsAsSpammable
module Badr
  module Acts 
    module Spammable 

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_spammable(options={})
          has_many :spam_reports
          
          has_many :spammed_users, :through => :spam_reports,
                   :foreign_key => :reporter, :as => :reporter, :source => :reportee, 
                   :conditions => "spam = 1"
                   
          has_many :not_spammed_users, :through => :spam_reports, 
                   :foreign_key => :reporter, :as => :reporter, :source => :reportee, 
                   :conditions => "spam = 0"
          
          include Badr::Acts::Spammable::InstanceMethods
          extend Badr::Acts::Spammable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to find all spammed objects, with options for ActiveRecord::find method
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper methods to check spam state
        def user_marked_as_spam?(reportee)
          spammed_users.include?(reportee) ? true : false  
        end
        
        def user_marked_as_not_spam?(reportee)
          not_spammed_users.include?(reportee) ? true : false  
        end
        
        def user_spam_state_normal?(reportee)
          !(user_marked_as_spam?(reportee) || user_marked_as_not_spam?(reportee))
        end
   
        #setters
        def mark_user_as_spam(reportee)
          report = SpamReport.find_by_user_id_and_reportee_id(self.id, reportee.id)
          if report
            report.spam = true
            report.save
          else
            SpamReport.create(:user_id => self.id, :reportee_id => reportee.id, :spam => true)
          end
        end

        def mark_user_as_not_spam(reportee)
          report = SpamReport.find_by_user_id_and_reportee_id(self.id, reportee.id)
          if report
            report.spam = false
            report.save
          else
            SpamReport.create(:user_id => self.id, :reportee_id => reportee.id, :spam => false)
          end
        end
        
        def reset_spam_state_for_user(reportee)
          report = SpamReport.find_by_user_id_and_reportee_id(self.id, reportee.id)
          report.destroy if report
        end
        
      end
                
    end
                
  end
end

ActiveRecord::Base.send(:include, Badr::Acts::Spammable)
