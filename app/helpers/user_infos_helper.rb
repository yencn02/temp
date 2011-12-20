module UserInfosHelper
  
  def countries_combo_tag(params)
  	# TODO: use inject
    options = []
    Country.all(:order => "name ASC").each do |c|
      options << {:value=>c.id, :label=>c.name}
    end
    combo_tag({:name=>params[:name], :default=>{:value=>0, :label=>"Select country"}, :options=>options})
  end
  
  def cities_combo_tag(params)
  	# TODO: remove return and use inject
    if(params[:country_id].nil?)
      return ""
    else
      options = []
      City.cities_of_coutry(params[:country_id]).each do |c|
        options << {:value=>c.id, :label=>c.name}
      end
      combo_tag({:name=>params[:name], :default=>{:value=>0, :label=>"Select city"}, :options=>options})
    end
  end    
  
end
