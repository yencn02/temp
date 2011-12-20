class UserInfosController < ApplicationController 
  layout "home"
  before_filter :get_unvisited_notifications_count, :only => ['show', 'show_section', 'edit', 'update', 'upload_temp_image']
  before_filter :find_user
  
  protect_from_forgery :except => 'summary_info'
  
  def summary_info
    ids_string = params[:ids]
    
    ids_array = ids_string.split ','
    
    users = User.find(:all, 
                      :conditions => ['id in (?)', ids_array], 
                      :select => 'id, first_name, last_name', 
                      :include => :user_info)
    
    result = users.map do |user|
      {:id => user.id,:name => user.name, :avatar_link => profile_avatar_url(:id => user.user_info.id, :style => :thumb)}
    end
    
    render :xml => {:status => 0, :result => result }.to_xml(:root => :result)
  rescue Exception => e
    render :xml => {:status => 1, :message => e.message }.to_xml(:root => :result)
  end
  
  def show
    render
  end
  
  def show_section
    @section = params[:section]
    render
  end
  
  def edit
    @section = params[:section]

    @town_city_name = @user.user_info.city('town').nil? ? "" : @user.user_info.city('town').name
    @home_city_name = @user.user_info.city('home').nil? ? "" : @user.user_info.city('home').name
    @work_city_name = @user.user_info.city('work').nil? ? "" : @user.user_info.city('work').name
    @university_city_name = @user.user_info.city('university').nil? ? "" : @user.user_info.city('university').name
    
    #By Mohamed Magdy
    @country = Hash.new
    @country["town"]  = @user.user_info.address('town').nil? ? "" : Country.find(:first, 
      :conditions => ['name = ? ', @user.user_info.address('town').country.name]).iso2
      
    @country["home"]  = @user.user_info.address('home').nil? ? "" : Country.find(:first, 
      :conditions => ['name = ? ', @user.user_info.address('home').country.name]).iso2
      
    @country["work"]  = @user.user_info.address('work').nil? ? "" : Country.find(:first, 
      :conditions => ['name = ? ', @user.user_info.address('work').country.name]).iso2
      
    @country["university"] = @user.user_info.addresses('university').nil? ? "" : Country.find(:first, 
      :conditions => ['name = ? ', @user.user_info.address('university').country.name]).iso2
    
    #By Mohamed Magdy
    @city = Hash.new
    @city["town"]  = @user.user_info.address('town').nil? ? "" : @user.user_info.address('town').city.name
    @city["home"]  = @user.user_info.address('home').nil? ? "" : @user.user_info.address('home').city.name
    @city["work"]  = @user.user_info.address('work').nil? ? "" : @user.user_info.address('work').city.name
    @city["university"] = @user.user_info.addresses('university').nil? ? "" : @user.user_info.address('university').city.name
    
    #By Mohamed Magdy
    @st_address1 = Hash.new
    @st_address1["town"]  = @user.user_info.address('town').nil? ? "" : @user.user_info.address('town').street1
    @st_address1["home"]  = @user.user_info.address('home').nil? ? "" : @user.user_info.address('home').street1
    @st_address1["work"]  = @user.user_info.address('work').nil? ? "" : @user.user_info.address('work').street1
    @st_address1["university"] = @user.user_info.addresses('university').nil? ? "" : @user.user_info.address('university').street1
    
    #By Mohamed Magdy
    @st_address2 = Hash.new
    @st_address2["town"]  = @user.user_info.address('town').nil? ? "" : @user.user_info.address('town').street2
    @st_address2["home"]  = @user.user_info.address('home').nil? ? "" : @user.user_info.address('home').street2
    @st_address2["work"]  = @user.user_info.address('work').nil? ? "" : @user.user_info.address('work').street2
    @st_address2["university"] = @user.user_info.addresses('university').nil? ? "" : @user.user_info.address('university').street2
    
    # By Mohamed Magdy
    # List all countries in db
    @countries = Country.all
    
    if @section == 'contact_info'
      @user.user_info.emails.build
    end
    
    render
  end
  
  # Edited By Mohamed Magdy
  def update
    @section = params[:section]

    @user_info = current_user.user_info
    @user_info.update_attributes(params[:user_info])
    
    if params[:section] == "basic_info"
      @user_info.destroy_relatives_infos
      
      @relatives_infos = params[:all_relatives].split(',')
      @relatives_infos.each do |r|
        RelativesRelationship.new(:user_info_id => @user_info.id, :relative_info_id => r.to_i).save
      end
    end
    
    if params[:section] == "addresses"
      @user_info.destroy_addresses
      
      address_types = [:town, :home, :work, :university]
      address_types.each do |at|
        # get the name of the country given the iso2 name 2 chars

        country_id = Country.find(:first, :conditions => ["iso2 = ?", params[:users][at]]).id
        # city name
        city_name = params[at][:city]
        
        # find the city in the given country
        city = City.find_by_country_id_and_name(country_id, city_name)
        # if the city is not available create a new one
        city = City.create(:country_id => country_id, :name => city_name) if city.nil?
        # creat the address record
        Address.create(:user_info_id => @user_info.id,
                       :country_id => country_id,
                       :city_id => city.id,
                       :street1 => params[at][:st_1],
                       :street2 => params[at][:st_2],
                       :address_type => at.to_s);
      end
    end
    
    @user_info.save
    
    if params[:section] == "profile_image"
      responds_to_parent do
        render :update do |page|
          page << "renderNewProfileImageInPage('#{profile_avatar_path(@user_info.id, :thumb)}', '#{@user.formatted_name}');"
        end
      end
      # TODO: remove
      return
    end
  end
  
  def get_avatar
    user_info = UserInfo.find(params[:id])
    splits = user_info.avatar(params[:style].to_sym).split('?')
    splits.pop if splits.length > 1
      
    # TODO: user inject
    path = ""
    splits.each do |s|
      path << s
    end
    
    send_file( path,
               :disposition => 'inline',
               :stream => false,
               :filename => "#{user_info.avatar_file_name}")
  end
  
  def get_temp_avatar
  	# TODO: remove path to configuration file
    path = "#{RAILS_ROOT}/system/tmp_imgs/#{params[:id]}_#{params[:name_ext]}"
    send_file( path,
               :disposition => 'inline',
               :stream => false,
               :filename => "#{current_user.name}_avatar")
  end
  
  # By Mohamed Magdy
  def auto_complete_city
    @cities = City.find(:all, :conditions => ['name LIKE ? AND country_id = ?' , "%#{params[:q]}%", session[:country].id], :limit => 10)
    render :text => @cities.map { |city| "#{city.name}" }.join("\n")
  end
  
  def country_name
    session[:country] = Country.find(:first, :conditions => ["name = ?", params[:country]])
    render :nothing => true
  end
  
  def upload_temp_image
    # TODO: is this used in any way ??
    name =  params[:image].original_filename
    # TODO: remove path to configuration file
    directory = "#{RAILS_ROOT}/system/tmp_imgs/"
    name_ext = Time.now.usec
    path = File.join(directory, "#{current_user.user_info.id}_#{name_ext}")
    File.open(path, "wb") { |f| f.write(params[:image].read) }
    
    responds_to_parent do
      render :update do |page|
        page << "renderNewProfileImage('#{profile_temp_avatar_path(current_user.user_info.id, name_ext)}');"
      end
    end
  end
  
  def select_cities_of_country
  end
  
  def edit_profile_image
    respond_to do |format|
      format.js {
        render :partial => "edit_profile_image"
      }
    end
  end
  
  def discard_profile_changes
    render :partial => 'edit_form', :user => @user
  end
  
  private
  def get_unvisited_notifications_count
    @all_unvisited_notifications_count = Notification.for_user(current_user.id).unvisited.grouped_count.count
  end
  
  def find_user
    @user = params[:id] ? UserInfo.find(params[:id]).user : current_user
  end
    
end
