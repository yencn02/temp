require 'digest/sha1'

class RestSessionsController < ApplicationController
  before_filter :get_user_by_mail, :only => [:retrieve_salt_for_user, :log_in]
  after_filter :clean_after_login, :only => [:log_out]
  
  def retrieve_salt_for_user
    render :xml => {:status => 0, :salt => @user.password_salt, :nonce => ::Digest::SHA1::hexdigest(Time.now.to_s) }.to_xml(:root => :result)
  rescue Exception => e
    render :xml => {:status => 1, :message => e.message }.to_xml(:root => :result)
  end
  
  def log_in
    client_crypted_pass = params[:cpw]
    
    nonce = params[:nonce]
    logger.info 'second step before SSH: ' + "#{@user.encrypted_password}--#{nonce}"
    server_crypted_pass_step1 = ::Digest::SHA1::hexdigest("#{@user.encrypted_password}--#{nonce}")
    logger.info 'second step after SSH: ' + server_crypted_pass_step1
    
    
    nonce2 = params[:cnonce]
    logger.info 'third step before SSH : ' + "#{server_crypted_pass_step1}--#{nonce2}"
    server_crypted_pass = ::Digest::SHA1::hexdigest("#{server_crypted_pass_step1}--#{nonce2}")
    logger.info 'third step after SSH : ' + server_crypted_pass
    
    logger.info '--------------------------------------'
    logger.info 'Client crypted ' + client_crypted_pass
    logger.info 'Server crypted ' + server_crypted_pass
    
    unless client_crypted_pass == server_crypted_pass
      raise Exception.new 'Invalid login info'
    end
    
    @user.reset_authentication_token!
    
    render :xml => {:status => 0, :auth_token => @user.authentication_token }.to_xml(:root => :result)
  rescue ActiveRecord::RecordInvalid
    render :xml => {:status => 1, :message => 'Invalid Login Info', :details => @user.errors.inspect }.to_xml(:root => :result)
  rescue Exception => e
    render :xml => {:status => 1, :message => 'Invalid Login Info', :details => e.inspect }.to_xml(:root => :result)
  end
  
  def log_out
    if !authenticate(:user)
      raise Exception.new('Invalid Token')
    end
    
    user = current_user
    user = user.reload # a must after reading current_user, because devise, mess it up.
    
    user.authentication_token = nil
    user.save!
    
    render :xml => {:status => 0 }.to_xml(:root => :result)
  rescue Exception => e
    render :xml => {:status => 1, :message => e.message }.to_xml(:root => :result)
  end
  
  protected
  def clean_after_login
    sign_out(:user)
  end
  
  def get_user_by_mail
    unless params[:email]
      raise Exception.new('Email not given')
    end
    
    @user = User.find_by_email(params[:email])
    
    unless @user
      raise Exception.new('No user fount with email : ' + params[:email])
    end
  end
end
