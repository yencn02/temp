
logger = Rails.logger

if Rails.env == 'development' || Rails.env == 'localhost' || Rails.env == 'test' 
  def logger.c
    instance_variable_get("@log").truncate(0)
  end
  
  def logger.d(var)
    info var.to_yaml
    info "----------" * 10
  end
  
  def logger.cd(var)
    c
    d(var)
  end
  
  def logger.debug_variables(bind)
    vars = eval('local_variables + instance_variables', bind)
    vars.each do |var|
      debug "#{var} = #{eval(var, bind).inspect}"
    end
  end
  
else
  def logger.c
    # Do nothing in other environments
  end
  
  def logger.d(var)
    
  end
  
  def logger.cd(var)
    
  end
  
  def logger.debug_variables(bind)
    
  end
end

def c
  Rails.logger.c
end

def cd(var)
  Rails.logger.cd(var)
end

def d(var)
  Rails.logger.d(var)
end

def debug_variables(bind)
  Rails.logger.debug_variables(bind)
end
