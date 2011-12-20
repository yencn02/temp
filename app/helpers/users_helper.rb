module UsersHelper
	# TODO: remove all return statements 
	
  def user_errors(user, field)
    unless user.errors[field].empty?
      <<-STRING
        <div class="txt-error server-validation">
          #{user.errors[field]}
        </div>
      STRING
    else 
      ''
    end  
  end
  
  def edit_form_tag(params)
    type = params[:type]
    id = params[:id]
    case type
      when :text
        value = params[:value]
        html = <<-STR 
                <div id='#{id}' class="inline-edit-form #{type}">
                  <input type="text" value='#{value}' onkeyup=\"if (event.keyCode == 13) jQuery(this).next().trigger('click'); else if(event.keyCode == 27) jQuery(this).next().next().trigger('click');\"/>
                  <input type="button" value="Save" class="save" />
                  <input type="button" value="Cancel" class="cancel" />
                </div>
               STR
        return html
      when :long_text
        value = params[:value]
        html = <<-STR 
                <div id='#{id}' class="inline-edit-form #{type}">
                  <textarea style="float:left" "onkeyup=\"if(event.keyCode == 27) jQuery(this).next().next().trigger('click');\">#{value}</textarea>
                  <input style="float:left" type="button" value="Save" class="save" />
                  <input style="float:left" type="button" value="Cancel" class="cancel" />
                </div>
               STR
        return html
      when :date
        value = params[:value]
        html = <<-STR 
                <div id='#{id}' class="inline-edit-form #{type}">
                  #{date_tag}
                  <input type="button" value="Save" class="save" />
                  <input type="button" value="Cancel" class="cancel" />
                </div>
               STR
        return html
      when :select
        options = params[:options]
				options_text = ''
				options.each do |o|
					options_text << "<option value='#{o[:value]}'>#{o[:label]}</option>"
				end
        html = <<-STR
                <div id='#{id}' class="inline-edit-form #{type}">
                  <select onkeyup=\"if (event.keyCode == 13) jQuery(this).next().trigger('click'); else if(event.keyCode == 27) jQuery(this).next().next().trigger('click');\">
									  #{options_text}
									</select>
                  <input type="button" value="Save" class="save" />
                  <input type="button" value="Cancel" class="cancel" />
                </div>
               STR
        return html
    end  
  end

end
