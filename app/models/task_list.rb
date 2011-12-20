class TaskList < ActiveRecord::Base
  belongs_to :user

  has_many :connections, :class_name => "TaskListConnection", :dependent => :destroy
  has_many :editors, :through => :connections, :source => :editor
  has_many :tasks, :dependent => :destroy
  
  scope :except, lambda { |tl| {:conditions => ["id <> #{tl.id}"]} }
  scope :accessible_for, lambda { |user| {:include => :connections, :conditions => {:task_list_connections => {:user_id => user.id}}}}

  validates_presence_of :title, :user_id
  
  before_create { |t| t.icon_name ||= 'all' }  
  before_destroy { |t| t.editable }
  
  def validate_on_update
    errors.add_to_base("This task list is not editable") unless self.editable
  end 
  
  def editor?(friend)
    self.editors.include?(friend)
  end
  
  def destroy_all_connections
    self.connection.delete("delete from #{::TaskListConnection.table_name} where task_list_id = #{self.id}")
  end
  
  def pending_tasks
    self.tasks.pending.count
  end
  
  def accessible_for_user?(user)
    connections.each do |c|
      if c.user_id == user.id
        return true
      end
    end
    return false
  end

end
