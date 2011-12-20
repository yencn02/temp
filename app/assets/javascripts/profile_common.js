function userInfoOnReady(){
  $j = jQuery;
  
  $j('.img').hover(
    function () {$j(this).addClass('edit-profile-image');},
    function () {$j(this).removeClass('edit-profile-image');}
  );
}

function commonEvents(){
  $j(".long-text-field").each(function(){
    fixHeight($j(this));
  });
  
  $j(".long-text-field").keyup(function(event){
    if(event.keyCode == '13' || event.keyCode == '8')
      fixHeight($j(this));
  });
}

function fixDateSelectorsSize(){
  $j(".date-composer div[class='selector']").css("width",75);
  $j(".date-composer div[class='selector'] span").css("width",50);
  $j(".date-composer div[class='selector'] select").css("width",90);  
}

function addProfileImageEvent(formString){
  jQuery('#user_info_avatar').change(function(){
    eval(formString);
  });
}

function addAddRelativeEvent(){
  $j("#relatives-container input[type='button']").click(function(){
    relative = $j(this).prev().val();
    if(relative == '' || relative == null || relative == undefined)
      return;
    else {
      relative_element = "<div class='relative-container' data='"+selectedRelative+"'><div class='delete-relative x-div' style='float:left;'>x</div> | <span>"+relative+"</span></div><br />"
      $j(this).prev().before(relative_element);
      $j(this).prev().prev().prev().effect('highlight', {color: '#c4ed19'}, 3000);

      addDeleteRelativeEvent();   
    }
  });
}

function addDeleteRelativeEvent(){
  $j(".delete-relative.x-div").click(function(){
    ec = $j(this).parent();
    ecn = ec.next();
    ecp = ec.parent();
    
    ec.addClass('relative-container-removed');
    ec.detach(); //hide relative container div
    ecn.detach(); //remove br / after relative container
    ecp.css("height", "auto");
  });
}

function fixHeight(element){
  txt = element.val();
  linesCount = txt.split("\n").length;
  newHeight = 18*linesCount;
  element.height(newHeight < 50 ? 50 : newHeight);
}

function replaceEmailsSection(content){
  $j("#emails-container").html(content);
}

function validateEmails(){
  valid = true;
  
  $j("#emails-container input[type='text']").each(function(){
    valid = validateEmail($j(this).val());
  });
  
  if(!valid)
    alert('invalid email(s)');
    
  return valid;
}

function prepareHiddenFields(){
  allSelectedRelatives = ""
   $j('.relative-container').each(function(){
    allSelectedRelatives += $j(this).attr('data') + ',';
  });
  $j('#all_relatives').val(allSelectedRelatives);
  
  addresses = ['town', 'home', 'work', 'university'];
  for(i = 0; i < addresses.length; i++){
    ad = addresses[i];
    country = $j(".address-container[data='"+ad+"'] #country select").val();
    city = $j(".address-container[data='"+ad+"'] #city input").val();
    street1 = $j(".address-container[data='"+ad+"'] input#address-street-1").val();
    street2 = $j(".address-container[data='"+ad+"'] input#address-street-2").val();
    address = country + '$' + city + '$' + street1 + '$' + street2 + '$' + ad;
    $j('#address_'+ad).val(address);
  }
}

function renderNewProfileImage(src){
  $j('#upload-image-container img').attr('src', src);
}

function renderNewProfileImageInPage(src, alt){
  src += '?'+new Date().getTime();
  $j('.img img').attr('src', src);
}

function replaceSection(section, content){
  $j('#'+section+'_section').html(content);
}

function basicInfoShowEvents(){
  $j('#basic-info-edit-link').unbind();
  $j('#basic-info-edit-link').click(function(){
    $j.get('edit_section/basic_info');
  });
}

function addressShowEvents(){
  $j('#addresses-edit-link').unbind();
  $j('#addresses-edit-link').click(function(){
    $j.get('edit_section/addresses');
  });
}

function contactInfoShowEvents(){
  $j('#contact-info-edit-link').unbind();
  $j('#contact-info-edit-link').click(function(){
    $j.get('edit_section/contact_info');    
  });
}


function onUserInfoShowReady(){
  basicInfoShowEvents();
  addressShowEvents();
  contactInfoShowEvents();
}

function basicInfoEditEvents(){
  //fix sex select value
  $j("#user_info_sex").next().find('select').val($j("#user_info_sex").val() == 1 ? "true" : "false");
  //fix date selects width
  date_val = $j('#user_info_birthday').val().split('-'); //yyyy-mm-dd
  dc = $j(".date-composer");
  dc.find("select[name='year']").val(parseInt(date_val[0]));
  dc.find("select[name='month']").val(parseInt(date_val[1]));
  dc.find("select[name='day']").val(parseInt(date_val[2]));
  
  $j("#user_info_sex").next().find('select').change(function(){
    $j("#user_info_sex").val($j("#user_info_sex").next().find('select').val());
  });
  
  $j(".date-composer div[class='selector'] select").each(function(){
    $j(this).change(function(){
      dc = $j(".date-composer");
      y = dc.find("select[name='year']").val();
      m = dc.find("select[name='month']").val();
      d = dc.find("select[name='day']").val();
      val = y+'-'+m+'-'+d;
      
      $j('#user_info_birthday').val(val);
    });
  }); 
  
  addRelativeAutoCompleteEvents();
  addAddRelativeEvent();
  addDeleteRelativeEvent();
  
  fixDateSelectorsSize();
  commonEvents();
}

function addressEditEvents(){
  /* this code fetches cities into cities combo of the country selected on country change
  $j('.address-container').each(function(){
    $j(this).find("#country select").change(function(){
      country_id = $j(this).val();
      address_data = $j(this).parent().parent().parent().attr('data');
      $j.post('/profile/cities/'+country_id, {address_data: address_data});
    });
  });
  */
  
  $j('.address-container').prev().each(function(){
    address = $j(this).val().split('$');
    type = address[4]; 
    $j(".address-container[data='"+type+"'] #country select").val(address[0]);
    $j(".address-container[data='"+type+"'] #city input").val(address[1]);
    $j(".address-container[data='"+type+"'] input#address-street-1").val(address[2]);
    $j(".address-container[data='"+type+"'] input#address-street-2").val(address[3]);
  });
  
  commonEvents();
}

function addRemoveCheckBoxesEvents(){
  $j("#emails-container input[type='checkbox']").each(function(){
    $j(this).click(function(){
      if($j(this).is(':checked')) //colorize email container red
        $j(this).prev().prev().addClass('email-container-removed');
      else
        $j(this).prev().prev().removeClass('email-container-removed');
    });
  });
}

function contactInfoEditEvents(){
  addRemoveCheckBoxesEvents();
  commonEvents();
}

function onUserInfoEditReady(){
  basicInfoEditEvents();
  addressEditEvents();
  contactInfoEditEvents();
  
  commonEvents();
}
