function newsFeedsOnReady(){
  $j = jQuery;
  
  $j('#filters_type').change(function(){
    showContentLoading();
    scope_val = 0;
    if($j("#arround-me").hasClass('news-feeds-scope-on'))
      scope_val = 1;
      
    loadPageContent('/news_feeds', {type: $j(this).val(), scope: scope_val});
  });
  
  $j("#my-connections").click(function(){
    showContentLoading();
    if(!$j("#my-connections").hasClass('news-feeds-scope-on')){
      $j("#my-connections").addClass('news-feeds-scope-on');
      $j("#arround-me").removeClass('news-feeds-scope-on');
      
      loadPageContent('/news_feeds', {type: $j('#filters_type').val(), scope: $j(this).attr('data')});
    }
  });
  
  $j("#arround-me").click(function(){
    showContentLoading();
    if(!$j("#arround-me").hasClass('news-feeds-scope-on')){
      $j("#arround-me").addClass('news-feeds-scope-on');
      $j("#my-connections").removeClass('news-feeds-scope-on');
      loadPageContent('/news_feeds', {type: $j('#filters_type').val(), scope: $j(this).attr('data')});
    }
  });
  
  $j(".newsfeed-item").each(function(){
    addNewsFeedCommentsEvents('.newsfeed-item.'+$j(this).attr('data-id'));
  });
}
