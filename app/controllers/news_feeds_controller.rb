class NewsFeedsController < CommentableMotivatableController
  before_filter :load_filters
  
  def index
    @filter_type = params[:type]
    @filter_scope = params[:scope]
    
    @news_feeds = NewsFeed.prepare_news_feeds(current_user, @filter_type, @filter_scope)
    
    # TODO: use inject
    # @all_news_feeds_ids = @news_feeds.inject { |acc, news_feed| acc << news_feed.id }.join(',')
    @all_news_feeds_ids = []
    @news_feeds.each do |news_feed|
      @all_news_feeds_ids << news_feed.id
    end
    @all_news_feeds_ids = @all_news_feeds_ids.join(',')

		# TODO: remove render
    render
  end
  
  def create
    params[:news_feed][:user_id] = current_user.id
    unless current_user.user_info.city('home').nil?
      params[:news_feed][:city_id] = current_user.user_info.city('home').id.nil? ? 0 : current_user.user_info.home_city.id
    end
    
    # TODO: use {}.merge(params) instead of modifying params
    @news_feed = NewsFeed.new(params[:news_feed])
    @news_feed.save
  end
  
end
