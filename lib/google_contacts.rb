require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'digest/sha1'
require 'rexml/document'

module Contacts
  class Google < Struct.new(:email)
    
    attr_accessor :auth
    
    def authenticate!      
      hdrs = {'Content-Type' => 'application/x-www-form-urlencoded'}
      options = {
        :oauth_consumer_key => "cheeveit.intra.badrit.com",
        :oauth_nonce => ActiveSupport::SecureRandom.hex(16),
        :oauth_signature_method => "HMAC-SHA1",
        :oauth_timestamp => Time.now.to_i,
        :scope => "http://www.google.com/m8/feeds",
        :oauth_callback => people_url,
        :oauth_version => "1.0",
        :xoauth_displayname => "Cheeveit Development" 
      }
      
      
      
      http = Net::HTTP.new("www.google.com", 443)      
      http.use_ssl = true    
      res, body = http.get("/accounts/OAuthGetRequestToken", options, hdrs)
    
      cd res
    
      return false unless res.code == "200"
  
      self.auth = body[/Auth=(.*)/, 1]
    end
    
    def contacts
      return nil unless authenticate!
      
      hdrs = {'Authorization' => "GoogleLogin auth=#{auth}"}
      http = Net::HTTP.new("www.google.com", 80)
      res, body = http.get("/m8/feeds/contacts/#{email}/full?max-results=10000", hdrs)
      
      return false unless res.code == "200"
      
      cd body
      
      doc = REXML::Document.new(res.body)
      feed = doc.elements['feed']    
    
      friends = []
      feed.elements.each('//entry') do |entry|
        friend = {}
        friend[:name] = entry.elements['title'].text.to_s.strip if entry.elements['title']
      
        entry.elements.each('gd:email') do |gd_email|
          rel = gd_email.attributes['rel']
          friend[:email] = gd_email.attributes['address'].to_s.strip if rel =~ /#home$/
          friend[:email] ||= gd_email.attributes['address'].to_s.strip if rel =~ /#work$/
          friend[:email] ||= gd_email.attributes['address'].to_s.strip if rel =~ /#other$/          
        end
        
        name, email = friend[:name], friend[:email]      
        friends << friend unless name.blank? && email.blank? 
      end
    
      friends        
    end
    
  end
end