class TaskStatus < ActiveRecord::Base
  acts_as_enumerated :order => "created_at desc"
  
  def waiting?
    self == TaskStatus[:waiting]   
  end
  
  def will?
    self == TaskStatus[:will]
  end
  
  def did?
    self == TaskStatus[:did]
  end

  def cant?
    self == TaskStatus[:cant]
  end
  
  def cancelled?
    self == TaskStatus[:cancelled]
  end
  
  def pending?
    self == TaskStatus[:waiting] || self == TaskStatus[:will]    
  end

end
