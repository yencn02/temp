require 'oauth/controllers/consumer_controller'

class OauthConsumersController < ApplicationController
  include Oauth::Controllers::ConsumerController
  
  def index
    @consumer_tokens=ConsumerToken.all :conditions=>{:user_id=>current_user.id}
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
  end
  
  protected
  
  # Change this to decide where you want to redirect user to after callback is finished.
  # params[:id] holds the service name so you could use this to redirect to various parts
  # of your application depending on what service you're connecting to.
  def go_back
    
    if current_user.google
      @access_token = current_user.google.client
      
      # TODO: move the url to a configuration file YAML
      @string = @access_token.get('https://www.google.com/m8/feeds/contacts/default/full?max-results=1000');
      
      doc = REXML::Document.new(@string.body.to_s)
      
      @suggestions = []
      
      doc.elements.each('feed/entry') do |e|
        if e.elements['gd:email']
          email = e.elements['gd:email'].attributes['address']
          title = e.elements['title'].text || email
          
          # TODO: make the function return the value to be added to suggestions 
          # and use inject not each
          process_contact_email title, email
        end
      end      

      redirect_to :controller => 'friendships', :action => 'index', :finding_people => @suggestions.join("-")
    end
    
  end
  
  def process_contact_email name, email
  	# TODO: string matching in database is not case sensitive
    # TODO: search in users contacts also, because the email could be of the contacts other than the main one
    user = User.find(:first, :conditions => ["lower(email) = ?", email.downcase])
    # add condition that it is not a friend of current user
    # TODO: use && and !
    if user and current_user.id != user.id and not current_user.friends.include? user
      @suggestions << user.id
    else
      contact = Contact.find(:first, :conditions => {:email => email})
      # TODO: use && and user unless and remove the return
      if contact and current_user.contacts.include? contact
        contact.name = name
        contact.save!
        return
      else
        current_user.contacts << Contact.create(:name => name, :email => email)
      end
    end
  end
end