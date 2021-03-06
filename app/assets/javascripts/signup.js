jQuery(document).ready(function($) {
  function addHelp(id, info) {
    $("#" + id).focus(function() {
      if($(this).data("show_help") === undefined) {
        $(this).parent().next(".col-3").html('<div class="txt-info">' + info + '</div>');
      }
    });
    
    $("#" + id).blur(function() {
      if($(this).val() != "") {
        $(this).data("show_help", false);
      }
      else {
        $(this).parent().next(".col-3").html("");
      }
    });
  }
  
  addHelp("txt_first_name", "enter your first name");  
  addHelp("txt_last_name", "enter your last name");
  addHelp("txt_username", "pick a uinque username");
  
  
  var validator = $("#signup_form").validate({
    debug: true,
    onsubmit: false,
    errorClass: "txt-error",
    errorElement: "div",
    rules: {
      "user[first_name]": "required",
      "user[last_name]": "required",
      "user[email]": {
        required: true,
        email: true,
        remote: {
          url: "/users/email_available",
          type: "get",
          data: {
            authenticity_token: function() { return $("input[name='authenticity_token']").val(); }
          },
          beforeSend: function(xhr) {
            $("#txt_email").parent().next(".col-3").html('<div class="txt-info"><img src="/images/small_ajax_indicator.gif" /> checking availability ...</div>');
          }
        }
      },
      "user[username]": {
        required: true,
        remote: {
          url: "/users/username_available",
          type: "get",
          data: {
            authenticity_token: function() { return $("input[name='authenticity_token']").val(); }
          },
          beforeSend: function(xhr) {
            $("#txt_username").parent().next(".col-3").html('<div class="txt-info"><img src="/images/small_ajax_indicator.gif" /> checking availability ...</div>');
          }          
        }
      },
      "user[password]": {
        required: true,
        minlength: 6
      },
      "user[password_confirmation]": {
        required: true,
        minlength: 6,
        equalTo: "#txt_password"
      },
      "user[terms_of_service]": "required"      
    },
    messages: {
      "user[first_name]": "should be a first name",
      "user[last_name]": "should be a last name",
      "user[email]": {
        required: "should look like an email address",
        email: "should look like an email address",
        minlength: "should look like an email address"
      },
      "user[username]": {
        required: "username can't be blank"
      },      
      "user[password]": {
        required: "6 characters or more",
        minlength: jQuery.format("enter at least {0} characters")
      },
      "user[password_confirmation]": {
        required: "repeat your password",
        minlength: jQuery.format("enter at least {0} characters"),
        equalTo: "enter the same password as above"
      },
      "user[terms_of_service]": "you should agree on our terms of service and privacy policy first"
    },
    success: function(label) {
      label.removeClass().addClass("txt-good").text("OK");
    },
    errorPlacement: function(error, element) {
      if(element.is(":checkbox")) {
        error.appendTo(element.parent()); 
      }
      else {
        element.parent().next(".col-3").html(error);
      }
    }        
  });
    
});
