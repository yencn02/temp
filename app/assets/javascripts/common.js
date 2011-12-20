// Common js functions 

// fixing the conflict issues with prototype
jQuery.noConflict();

UI = {};

// scripts intiated in document.ready
UI.commonScripts = function($){
  // script to add the on focus effects on the form inputs
  $('input[type="button"], input[type="submit"], button').addClass("button");
  $('input[type="text"], input[type="password"]').addClass("input-text");
  $('input[type="text"], input[type="password"]').addClass("input-text-normal");
  $('input[type="text"], input[type="password"]').focus(function() {
    $(this).removeClass("input-text-normal").addClass("input-text-focus");
    if (this.value == this.defaultValue){
      this.value = '';
    }
    if(this.value != this.defaultValue){
      this.select();
    }
  });
  $('input[type="text"], input[type="password"]').blur(function() {
    $(this).removeClass("input-text-focus").addClass("input-text-normal");
    if ($.trim(this.value) == ''){
      this.value = (this.defaultValue ? this.defaultValue : '');
    }
  }); 
  
  /* fire the tooltip script */
  $('.tipsy').tipsy({gravity: 's'}); 
  
}

(function($) {
	UI.commonScripts();
})(jQuery);
