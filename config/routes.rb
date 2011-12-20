CheeveIt::Application.routes.draw do  
  root :to => "home#index" 

  match '/updates' => 'home#user_updates', :as => :user_updates, :via => :get
  match '/calculate_tags' => 'home#fetch_tags', :as => :calculate_tags
  match '/external_action/:external_action' => 'home#external_action', :as => :external_action
  match '/external_action/registered_action/:external_action/:user_id/:task_id/:user_action' => 'home#external_action', :as => :external_registered_user_action
  match '/unregistered/:unregistered_user_id/:security_code' => 'home#index', :as => :unregistered_home, :via => :get
  match '/show_registration_required' => 'home#show_registration_required', :as => :show_registration_required
  match '/unregistered/:unregistered_user_id/:security_code/:task_id/:status' => 'tasks#unregistered_user_action', :as => :unregistered_user_action, :via => :get
  match '/unregistered/sign_out' => 'application#unregistered_sign_out', :as => :unregistered_user_logout
  match '/commentable/create_comment/:commentable_type/:commentable_id' => 'commentable_motivatable#create_comment', :as => :create_comment, :via => :post
  match '/commentable/destroy_comment/:commentable_type/:commentable_id/:comment_id' => 'commentable_motivatable#destroy_comment', :as => :destroy_comment
  match '/motivatable/:motivatable_type/:motivatable_id' => 'commentable_motivatable#motivation_action', :as => :motivation_action
  
  resources :tasks do
    member do
      post :status
      post :change_task_list
      post :toggle_privacy
      post :add_tag_to
      post :remove_tag_from
    end
  end

  match '/tasks/remind/:id' => 'tasks#remind', :as => :remind, :via => :get
  match '/registered/:user_id/:task_id/:user_action' => 'tasks#registered_user_action', :as => :registered_user_action, :via => :get
  match '/tasks/reassign/:id/:target_user' => 'tasks#reassign_task', :as => :reassign_task, :via => :post
  
  resources :task_lists do
    member do
      post :edit_connections
      get :small_photo
    end
  end

  resources :task_list_connections, :only => [:create, :destroy]
  resources :news_feeds
  
  match '/notifications/:task_id/status' => 'notifications#change_task_status', :as => :notificaitons_task_status
  match '/notifications' => 'notifications#index', :as => :notifications  
  match '/change_spam_state/:reportee_id/:state' => 'users#change_spam_state', :as => :change_spam_state, :method => :post
  match '/users/does_user_exist' => 'users#does_user_exist', :as => :does_user_exist, :method => :post
  match '/users/kill_me_and_sign_out' => 'users#kill_me_and_sign_out', :as => :kill_me_and_sign_out, :method => :post
  match 'rest/log_in' => 'rest_sessions#log_in', :as => :rest_sign_in
  match 'rest/log_out' => 'rest_sessions#log_out', :as => :rest_sign_out
  match 'rest/retrieve_salt_for_user' => 'rest_sessions#retrieve_salt_for_user', :as => :rest_sign_out
  match '/users/email_available' => 'users#email_available', :as => :email_available, :via => :get
  match '/users/username_available' => 'users#username_available', :as => :username_available, :via => :get
  match '/users/ac_friends' => 'users#auto_complete_friends', :as => :auto_complete_user_friends, :via => :get
  match '/users/accessible_task_lists' => 'users#accessible_task_lists', :as => :user_accessible_task_lists, :via => :get 
  match '/accept_all' => 'friendships#accept_all', :as => :invite_all
  match '/invite_all' => 'friendships#invite_all', :as => :invite_all
  match '/invite_non_cheevers' => 'friendships#invite_non_cheevers', :as => :invite_all
  match '/import_people' => 'friendships#import_people', :as => :import_people
  match '/people' => 'friendships#index', :as => :friendships
  match '/people/search' => 'friendships#search', :as => :search_cheeve_people
  match '/people/import' => 'friendships#people_import', :as => :people_import
  
  resources :friendships, :only => [] do
    collection do
      get :accepted_friends
    end
    member do
      get :accepted
      put :deny
      get :invited
      put :accept
      post :invite
    end
  end

  resources :user_infos
  
  match '/profile/city' => 'user_infos#auto_complete_city', :as => :auto_complete_city, :via => :get
  match '/profile/country' => 'user_infos#country_name', :as => :country_name, :via => :get
  match '/profile/users_summary_info' => 'user_infos#summary_info', :as => :summary_info, :via => :get
  match '/profile/:id' => 'user_infos#show', :as => :profile, :via => :get
  match '/profile/:id/edit' => 'user_infos#edit', :as => :profile_edit, :via => :get 
  match 'profile/edit_section/:section' => 'user_infos#edit', :as => :profile_edit_section, :via => :get 
  match 'profile/show_section/:section' => 'user_infos#show_section', :as => :profile_show_section, :via => :get 
  match '/profile/:id/avatar_image/:style' => 'user_infos#get_avatar', :as => :profile_avatar, :via => :get
  match '/profile/:id/temp_avatar_image/:name_ext' => 'user_infos#get_temp_avatar', :as => :profile_temp_avatar, :via => :get 
  match '/profile/:id/edit_avatar_image' => 'user_infos#edit_profile_image', :as => :profile_edit_avatar, :via => :get
  match '/profile/upload/temp/image' => 'user_infos#upload_temp_image', :as => :profile_upload_temp_image, :via => :post
  match '/profile/cities/:country_id' => 'user_infos#select_cities_of_country', :as => :select_cities_of_country, :via => :get 
  match 'images/:action/:style' => 'images#avatar', :as => :user_avatar, :via => :get
  match 'images/:action/:id/:style' => 'images#task_list', :as => :task_list_photo, :via => :get
  match 'wp' => 'waiting_page#index', :as => :waiting_page, :via => :get
  match 'wp' => 'waiting_page#create', :as => :waiting_page, :via => :post
  match '/' => 'home#index'
  match '/comatose/admin' => 'comatose#index', :as => :comatose_root
  
  resources :oauth_consumers do
    member do
      get :callback
    end
  end
  
  devise_for :users
end

