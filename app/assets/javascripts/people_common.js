// Common js functions 
UI.People = {};

UI.People.actionDropDownHandlers = function($, prefix) {
  if(prefix === undefined)
    prefix = "";
    
  /* actions dropdown */
  if ($(prefix + " .action-dropdown").size() > 0) {
    $(prefix + " .action-dropdown .list").hide();
    $(prefix + " .action-dropdown a").click(function(){
      $(this).next(".list").slideToggle("fast");
      $(this).toggleClass("active");
      $(this).parents(".action").css('z-index','1000');
      return false;
    });
    $(prefix + " .action-dropdown").hover('',function(){
      $(prefix + " .action-dropdown .list:visible").slideUp("fast");
      $(this).find("a").removeClass("active");
      $(this).parents(".action").css('z-index','1');
	  if ($(this).parents(".scrollpane").size()>0){
		  	$(".scrollpane-inner").css('margin-bottom','0');
			api.reinitialise();
			api2.reinitialise();
	  }
    });
  }
}

UI.People.scrollpaneHandlers = function($) {
  if ($(".scrollpane").size()>0) {
		// for the first scroll
		var element = $("#scrollpane_1").jScrollPane();
		var api = element.data('jsp');
		 $("#scrollpane_1 .action-dropdown").slice(-2).find("a").click(function(){
		  	$("#scrollpane_1 .scrollpane-inner").css('margin-bottom','120px');
			api.reinitialise();
			api.scrollByY(120,'slow');
		  });
		// for the second scroll
		var element2 = $("#scrollpane_2").jScrollPane();
		var api2 = element2.data('jsp');
		 $("#scrollpane_2 .action-dropdown").slice(-2).find("a").click(function(){
		  	$("#scrollpane_2 .scrollpane-inner").css('margin-bottom','120px');
			api2.reinitialise();
			api2.scrollByY(120,'slow');
		  });
		$(".action-dropdown").hover('',function(){
			$(".scrollpane-inner").css('margin-bottom','0');
			api.reinitialise();
			api2.reinitialise();
		});
  }
}  

UI.People.pageScripts = function($) {
  /* People page scripts */
  if ($(".people-tabs").size()>0){
    $(".people-tabs .tab_content").hide(); //Hide all content
    $(".people-tabs ul.tabs li:first").addClass("active").show(); //Activate first tab
    $(".people-tabs .tab_content:first").show(); //Show first tab content
  
    //On Click Event
    $(".people-tabs ul.tabs li").click(function() {
  
      $(".people-tabs ul.tabs li").removeClass("active"); //Remove any "active" class
      $(this).addClass("active"); //Add "active" class to selected tab
      $(".people-tabs .tab_content").hide(); //Hide all tab content
  
      var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
      $(activeTab).fadeIn(); //Fade in the active ID content
      return false;
    });
  }
  
  if ($(".left-tabs-cont").size()>0){
    $(".left-tabs-cont .left-tab_content").hide(); //Hide all content
    $(".left-tabs-cont ul.left-tabs-ul li:first").addClass("active").show(); //Activate first tab
    $(".left-tabs-cont .left-tab_content:first").show(); //Show first tab content
  
    //On Click Event
    $(".left-tabs-cont ul.left-tabs-ul li").click(function() {
  
      $(".left-tabs-cont ul.left-tabs-ul li").removeClass("active"); //Remove any "active" class
      $(this).addClass("active"); //Add "active" class to selected tab
      $(".left-tabs-cont .left-tab_content").hide(); //Hide all tab content
  
      var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
      $(activeTab).fadeIn(); //Fade in the active ID content
      return false;
    });
  }   
}

UI.People.ready = function($) {
  /* initialize scrollpane */
  UI.People.scrollpaneHandlers($);
  UI.People.pageScripts($);
  UI.People.actionDropDownHandlers($);
}

jQuery(document).ready(UI.People.ready);