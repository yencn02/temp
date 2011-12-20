# edit this file to contain credentials for the OAuth services you support.
# each entry needs a corresponding token model.
#
# eg. :twitter => TwitterToken, :hour_feed => HourFeedToken etc.
#
# OAUTH_CREDENTIALS={
#   :twitter=>{
#     :key=>"",
#     :secret=>""
#   },
#   :google=>{
#     :key=>"",
#     :secret=>"",
#     :scope=>"" # see http://code.google.com/apis/gdata/faq.html#AuthScopes
#   },
#   :agree2=>{
#     :key=>"",
#     :secret=>""
#   },
#   :fireeagle=>{
#     :key=>"",
#     :secret=>""
#   },
#   :hour_feed=>{
#     :key=>"",
#     :secret=>"",
#     :options=>{ # OAuth::Consumer options
#       :site=>"http://hourfeed.com" # Remember to add a site for a generic OAuth site
#     }
#   },
#   :nu_bux=>{
#     :key=>"",
#     :secret=>"",
#     :super_class=>"OpenTransactToken",  # if a OAuth service follows a particular standard 
#                                         # with a token implementation you can set the superclass
#                                         # to use
#     :options=>{ # OAuth::Consumer options
#       :site=>"http://nubux.heroku.com" 
#     }
#   }
# }
# 

# TODO: move to YAML file and load it here
OAUTH_CREDENTIALS={
  :google=>
    {
      :key=>"cheeveit.intra.badrit.com", 
      :secret=>"KnZqPBmfnkReTBqJt3TALYQ6",
      :scope=>"https://www.google.com/m8/feeds/", 
      :options => {:site => "http://www.google.com", 
      :request_token_path => "/accounts/OAuthGetRequestToken", 
      :access_token_path => "/accounts/OAuthGetAccessToken", 
      :authorize_path=> "/accounts/OAuthAuthorizeToken"}  
    },
#    yahoo api id => MoAtIY78
    :yahoo=>
    {
      :key=>"dj0yJmk9SDM4U2JhamNrU2JyJmQ9WVdrOVRXOUJkRWxaTnpnbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD02OQ", 
      :secret=>"e2333d5ff2f09ab841bd6543a269b7c2c8276381",
      :scope=>"http://social.yahooapis.com/v1/user/{guid}/contacts", 
      :options => {:site => "http://www.yahoo.com", 
      :request_token_path => "/accounts/OAuthGetRequestToken", 
      :access_token_path => "/accounts/OAuthGetAccessToken", 
      :authorize_path=> "/accounts/OAuthAuthorizeToken"}  
    }
} unless defined? OAUTH_CREDENTIALS

load 'oauth/models/consumers/service_loader.rb'