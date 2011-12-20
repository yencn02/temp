// Common js functions 

// fixing the conflict issues with prototype
jQuery.noConflict();
     
jQuery.ajaxSetup({
'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});     
     
 // scripts intiated in document.ready
jQuery(document).ready(function($){
   // script to add the on focus effects on the form inputs
   $('input[type="text"]').addClass("input-text-normal");
	$('input[type="text"]').focus(function() {
		$(this).removeClass("input-text-normal").addClass("input-text-focus");
        if (this.value == this.defaultValue){
        	this.value = '';
    	}
        if(this.value != this.defaultValue){
	    	this.select();
        }
    });
    $('input[type="text"]').blur(function() {
    	$(this).removeClass("input-text-focus").addClass("input-text-normal");
        if ($.trim(this.value) == ''){
        	this.value = (this.defaultValue ? this.defaultValue : '');
    	}
    });
    
    $('#new_waiting_page').submit(function() {
      var email = $('#waiting_page_email').attr("value");
      var validRegExp = /^[^@]+@[^@]+.[a-z]{2,}$/i;
      if (email.search(validRegExp) == -1){                
        $("#waiting_page_email").tipTip({
          content: "Please enter a valid email address.",
          keepAlive: true,
          activation: "manual"
        });        
        
        $('#waiting_page_email').data('active_tiptip')();
                
        return false;
      }
            
      $.post(this.action, this.serialize());
      return false;  
    });    
 });