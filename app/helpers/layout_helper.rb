# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def javascript_head_block(&block)
    content_for(:head) { javascript_tag(&block) }
  end
  
  def stylesheet_defer(*args)
    content_for(:defer_scripts) { stylesheet_link_tag(*args) }
  end

  def javascript_defer(*args)
    content_for(:defer_scripts) { javascript_include_tag(*args) }
  end
  
  def javascript_defer_block(&block)
    content_for(:defer_scripts) { javascript_tag(&block) }
  end  
  
end
