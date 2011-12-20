# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def hsep
    "<div class=\"h-sep\"></div>"
  end
  
  def remove_task_with_status?(visible_status, status)
    visible_status != status && visible_status != "every" && !(visible_status == "pending" && status == "will")
  end
  
  def changed_task_status_msg(task)
    return "You promised to achieve this task" if task.status == TaskStatus[:will]
    return "You confirmed that you did this task" if task.status == TaskStatus[:did] && @for_me
    return "You marked this task as done" if task.status == TaskStatus[:did] && @from_me
    return "You refuesd to do this task" if task.status == TaskStatus[:cant]
    return "You cancelled this task" if task.status == TaskStatus[:cancelled]
    ""
  end
  
  def reassign_task_msg(task)
    return "You reassigned this task to #{task.assignee.formatted_name}" if task.assigner != task.assignee
    return "You reassigned this task to yourself" if task.assigner == task.assignee
  end
  
  
  def select_header_link(name)
    return "selected" if name == "home" && controller_name == "home"
    return "selected" if name == "profile" && controller_name == "user_infos" && (action_name == "show" || action_name == "edit")
    return "selected" if name == "people" && controller_name == "friendships" && action_name == "index"
    ""
  end
  
  def csrf_meta_tag
    if protect_against_forgery?
      %(<meta name="csrf-param" content="#{Rack::Utils.escape_html(request_forgery_protection_token)}"/>\n<meta name="csrf-token" content="#{Rack::Utils.escape_html(form_authenticity_token)}"/>).html_safe
    end
  end  
  
  def hide_if(cond)
    cond ? "style=\"display:none;\"" : ""
  end
  
  def disable_if(cond)
    cond ? "disabled=\"disabled\"" : ""
  end
  
  def show_me_select
    task_statuses = TaskStatus.all
    options = [["All", "every"], ["Pending", "pending"]] + task_statuses.map { |ts| [ts.display_name, ts.name] }
    select_tag("show_me_select", options_for_select(options, "pending"), :autocomplete => "off", :class=>"selector")
  end
  
  def news_feeds_show_me_select
    options = [["All News", "*"], ["Tasks", "Task"], ["Statuses", "Status"], ["Questions", "Question"], ["Links", "Link"]]
    select_tag("filters[type]",options_for_select(options, "every"), :autocomplete => "off", :class=>"selector")
  end
  
  def task_lists_options_for_select(task_lists, escape_js = true)
    if escape_js
      escape_javascript(options_from_collection_for_select(task_lists, 'id', 'title'))
    else
      options_from_collection_for_select(task_lists, 'id', 'title')
    end
  end
  
  def me?(user)
    current_user == user
  end
  
  def get_user_friendly_time(time)
    begin
      from = Time.now - time.time
      if from < 0
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize
      elsif from < 1.day
       (distance_of_time_in_words_to_now time) + ' ago' 
      elsif from < 2.day
        'yesterday' 
      elsif from < 1.year
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize
      else
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize +  ', ' + time.year
      end
    rescue
    end
  end
  
  def get_friendly_day(time)
    begin
      from = Time.now - time.time
      if from < 0
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize
      elsif from < 1.day
       'Today' 
      elsif from < 2.day
        'Yesterday' 
      elsif from < 1.year
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize
      else
        Date::MONTHNAMES[time.month][0..2] + ' ' + time.day.ordinalize +  ', ' + time.year
      end
    rescue
    end
  end
  
  def generate_flying_form_for_file(my_params)
    url = my_params[:url]
    file_element_id = my_params[:file_element_id]
    html = "function fn() {var f = document.createElement('form');f.target='upload_frame';var d = document.getElementById('ajax-form-wrapper');f.style.display = 'none';f.method = 'POST';f.multipart = true;f.action = '#{url}';f.setAttribute('id', 'ajax-form');d.appendChild(f);var m = document.createElement('input');m.setAttribute('type', 'hidden');m.setAttribute('name', '_method');m.setAttribute('value', 'post');f.appendChild(m);var s = document.createElement('input');s.setAttribute('type', 'hidden');s.setAttribute('name', 'authenticity_token');s.setAttribute('value', '#{form_authenticity_token}');f.appendChild(s);var file = document.getElementById('#{file_element_id}').cloneNode(true);file.setAttribute('id','image');file.setAttribute('name','image');f.appendChild(file);f.enctype='multipart/form-data';f.submit();return false;}fn();"
  end
  
  def button_to_destroy(my_params)
    caption = my_params[:caption]
    url = my_params[:url]
    confirm_msg = my_params[:confirm_msg]
    style_class = my_params[:style_class]
    ajax = my_params[:ajax]
    
    # TODO: use jquery forms to remove all this JS code
    if ajax
      html = <<-STR
              <input type='button' class='#{style_class}' value='#{caption}' onclick="if (confirm('#{confirm_msg}')) 
              { 
                var f = document.createElement('form');
                var d = document.getElementById('ajax-destroy-wrapper');
                f.style.display = 'none'; 
                f.method = 'POST'; 
                f.action = '#{url}';
                f.setAttribute('id', 'ajax-destroy-form');
                d.appendChild(f);
                var m = document.createElement('input'); 
                m.setAttribute('type', 'hidden'); 
                m.setAttribute('name', '_method'); 
                m.setAttribute('value', 'delete'); 
                f.appendChild(m);
                var s = document.createElement('input'); 
                s.setAttribute('type', 'hidden'); 
                s.setAttribute('name', 'authenticity_token'); 
                s.setAttribute('value', '#{form_authenticity_token}'); 
                f.appendChild(s);
                new Ajax.Request('#{url}', {asynchronous:true, evalScripts:true, parameters:Form.serialize(document.getElementById('ajax-destroy-form'))}); 
                return false;
              };
              return false;"></input>
            STR
    else
      html = <<-STR
              <input type='button' class='#{style_class}' value='#{caption}' onclick="if (confirm('#{confirm_msg}')) 
              { var f = document.createElement('form'); 
                f.style.display = 'none'; 
                this.parentNode.appendChild(f); 
                f.method = 'POST'; 
                f.action = '#{url}';
                var m = document.createElement('input'); 
                m.setAttribute('type', 'hidden'); 
                m.setAttribute('name', '_method'); 
                m.setAttribute('value', 'delete'); 
                f.appendChild(m);
                var s = document.createElement('input'); 
                s.setAttribute('type', 'hidden'); 
                s.setAttribute('name', 'authenticity_token'); 
                s.setAttribute('value', '#{form_authenticity_token}'); 
                f.appendChild(s);f.submit(); 
              };
              return false;"></input>
            STR
    end
    html            
  end
  
  def button_to_custom(options)
    caption = options[:caption]
    url = options[:url]
    confirm_msg = options[:confirm_msg]
    style_class = options[:style_class]
    method = options[:method] == nil ? 'POST' : options[:method]
    ajax = options[:ajax]
    auth = options[:authenticity_token] == nil ? true : options[:authenticity_token] 
    additional_params = options[:additional_params] ? options[:additional_params] : []
    auth_text = ''
    if auth
      auth_text = <<-STR
                    var s = document.createElement('input'); 
                    s.setAttribute('type', 'hidden'); 
                    s.setAttribute('name', 'authenticity_token'); 
                    s.setAttribute('value', '#{form_authenticity_token}'); 
                    f.appendChild(s);
                  STR
    end
    
    additional_params_text = ''
    if additional_params.length > 0
      additional_params.each do |ap|
        additional_params_text << <<-STR
                                    var s_#{ap[:key]} = document.createElement('input'); 
                                    s_#{ap[:key]}.setAttribute('type', 'hidden'); 
                                    s_#{ap[:key]}.setAttribute('name', '#{ap[:key]}');
                                    s_#{ap[:key]}.setAttribute('value', document.getElementById('#{ap[:value]}').value); 
                                    f.appendChild(s_#{ap[:key]});
                                  STR
      end
    end
    
    confirmation_text = confirm_msg == nil ? "" : "if (confirm('#{confirm_msg}'))"
    
    # TODO: use jquery forms
    if ajax
      html = <<-STR
              <input type='button' class='#{style_class}' value='#{caption}' onclick="#{confirmation_text} 
              { 
                var f = document.createElement('form');
                f.style.display = 'none'; 
                f.method = 'POST'; 
                f.action = '#{url}';
                f.setAttribute('id', 'ajax-destroy-form');
                var m = document.createElement('input'); 
                m.setAttribute('type', 'hidden'); 
                m.setAttribute('name', '_method'); 
                m.setAttribute('value', '#{method}'); 
                f.appendChild(m);
                #{auth_text}
                #{additional_params_text}
                new Ajax.Request('#{url}', {asynchronous:true, evalScripts:true, parameters:Form.serialize(f)}); 
                return false;
              };
              return false;"></input>
            STR
    else
      html = <<-STR
              <input type='button' class='#{style_class}' value='#{caption}' onclick="#{confirmation_text}
              { var f = document.createElement('form'); 
                f.style.display = 'none'; 
                this.parentNode.appendChild(f); 
                f.method = 'POST'; 
                f.action = '#{url}';
                var m = document.createElement('input'); 
                m.setAttribute('type', 'hidden'); 
                m.setAttribute('name', '_method'); 
                m.setAttribute('value', '#{method}'); 
                f.appendChild(m);
                #{auth_text}
                #{additional_params_text}
                f.appendChild(s);f.submit(); 
              };
              return false;"></input>
            STR
    end
    html            
  end
  
  def button_to_location(my_params)
    caption = my_params[:caption]
    url = my_params[:url]
    confirm_msg = my_params[:confirm_msg]
    style_class = my_params[:style_class]
    confirmation_text = confirm_msg == nil ? "" : "if (confirm('#{confirm_msg}'))"
    
    # TODO: use rails helpers
    "<input type='button' class='#{style_class}' value='#{caption}' onclick=\"#{confirmation_text}{ location.href = '#{url}' };return false;\"></input>"
  end
  
  def combo_tag(my_params)
    name = my_params[:name]
    default = my_params[:default]
    options = my_params[:options]
    
    # TODO: use rails helpers
    options_html = ""
    options.each do |o|
      options_html << "<option value='#{o[:value]}'>#{o[:label]}</option>"
    end
    
    # TODO: use rails helpers
    html = <<-STR
            <select>
              <option value='#{default[:value]}'> - #{default[:label]} - </option>
              #{options_html}
            </select>
           STR
  end
  
  def date_tag
    months_html = ""
     (1..12).each do |m|
      months_html << "<option value='#{m}'>#{Date::MONTHNAMES[m]}</option>"
    end
    
    days_html = ""
     (1..31).each do |d|
      days_html << "<option value='#{d}'>#{d}</option>"
    end
    
    years_html = ""
    Time.now.year.downto(1901) do |y|
      years_html << "<option value='#{y}'>#{y}</option>"
    end
    
    html = <<-STR
            <div class="date-composer">
              <div style="display:inline">
              <select name="month">
                <option value='0'> - Month - </option>
                #{months_html}
              </select>
              </div>
              <div style="display:inline">
              <select name="day">
                <option value='0'> - Day - </option>
                #{days_html}
              </select>
              </div>
              <div style="display:inline">
              <select name="year">
                <option value='0'> - Year - </option>
                #{years_html}
              </select>
              </div>
            </div>
          STR
  end
  
  def auto_complete_row_data u
    if u.is_a? User
      return [u.name,
      u.username + '@cheeve.it',
      profile_avatar_path(u.user_info.id, :medium),
      u.pending_tasks.to_s,
      u.id.to_s,
      u.user_info.id]
    elsif !u.nil?
      return [u.name, 
              u.email,
              '/images/email-avatar.png',
              0,
              'other',
              -1]
    end
  end
  
  def trim_text(text, length = 18)
    text.length > length ? "#{text[0,length]}..." : text
  end
  
  def auto_complete_row_data_to_javascript_array u
    begin
      array = auto_complete_row_data u
      array_elements_str = array.map{|e| "'#{e}'" }.join ','
      return "[ #{array_elements_str} ]"
    rescue
      return "[]"
    end
  end
  
  def get_full_url(base_url)
    return base_url + request.path + get_params_as_url_friendly
  end
  
  def get_params_as_url_friendly
    count = 0
    param_size = request.query_parameters.size
    parameters = ""
    
    for param in request.query_parameters
      parameter = "#{param[0]}=#{param[1]}"
      
      if count == 0
        parameter = "?#{parameter}"
      else
        parameter = "&#{parameter}"
      end
      
      count += 1
      parameters += parameter
    end
    
    return parameters
  end
end
