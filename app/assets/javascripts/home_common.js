// Common js functions 
UI.Home = {};

UI.Home.toggleNotificationsAndMessages = function($) {
  // toggle the notifications and messages panels in the header
  $("#navigation-bar li.notification a").click(function(){
  	if (typeof($current_page) !== 'undefined') {
  		if ($current_page == "home")
  			jQuery("#tab-area a.notifications").trigger('click');
  		else 
  			location.href = location.protocol + "//" + location.host + "#notifications";
  	}
  });
  
  $(".notifications-slide a").click(function(){
    $(".notifications-slide").slideToggle();
    $j(".tabs-list li").removeClass("selected");
    $j(".tabs-list li").last().addClass("selected");
    showContentLoading();
    $j("#side-tabs").hide();
    location.href = location.protocol+"//"+location.host+"#notifications";
  });
  
  $(".messages-toggle").click(function(){
    $(".notifications-toggle").removeClass("opened");
    $(".notifications-slide").slideUp();
    $(this).toggleClass("opened");
    $(".messages-slide").slideToggle();
  });
  
  var mouse_is_inside = false;
  $('.header-slides').hover(function(){ 
      mouse_is_inside=true; 
  }, function(){ 
      mouse_is_inside=false; 
  });
  
  $(".wrapper").mouseup(function(){ 
    if(! mouse_is_inside) {
      $(".notifications-toggle").removeClass("opened");
      $(".notifications-slide").slideUp();
      $(".messages-toggle").removeClass("opened");
      $(".messages-slide").slideUp();
    }
  }); 
  
  var latest_index = 100;
  // toggle the cancel menu 
  	$(".cancel").click(function(){
  		$(this).closest(".from-me-actions").find(".cancel-dd").slideToggle();
  		$(this).closest(".task-unit").css('z-index',latest_index);
  		latest_index += 1;	
  		return false;		
  	}
	);

	$(".from-me-actions").hover('',function(){
		$(".cancel-dd").slideUp();
	});
	
}

nextZIndex = 20;

function addZIndexCorrectionToTasksMenuSelect(){
  jQuery(".task-unit div.jqTransformSelectWrapper").click(function(){
    jQuery(this).css('z-index', nextZIndex++);
  });
  
  jQuery(".task-unit div.jqTransformSelectWrapper a").click(function(){
    jQuery(this).closest(".jqTransformSelectWrapper").css('z-index', nextZIndex++);
  });
}

function addZIndexCorrectionToItemSelect(itemSelector){
  jItem = jQuery(itemSelector);
  jItem.find("div.jqTransformSelectWrapper").click(function(){
    jQuery(this).css('z-index', nextZIndex++);
  });
  
  jItem.find("div.jqTransformSelectWrapper a").click(function(){
    jQuery(this).closest(".jqTransformSelectWrapper").css('z-index', nextZIndex++);
  });
}

UI.Home.ready = function($) {
  UI.Home.toggleNotificationsAndMessages($);
  updateNotificationsCountDisplay();
  addZIndexCorrectionToTasksMenuSelect();
}

jQuery(document).ready(UI.Home.ready);