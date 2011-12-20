class WaitingPageController < ApplicationController

  def index
    @waiting_page = WaitingPage.new
  end
  
  def create
    @waiting_page = WaitingPage.new(params[:waiting_page])
    respond_to do |format|
      format.js do
        unless @waiting_page.save
          flash.now[:error] = @waiting_page.errors.full_messages.join("<br />");
        end
      end
    end
  end

end
