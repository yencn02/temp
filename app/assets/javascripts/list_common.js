// Common js functions for list window
var listOfAllFriendsHtml;
var listOfSelectedFriendsIDs;
var currentlyHiddenElemensAsStr = "";
var selectedFriendsCount = 0;
var mouse_is_inside = false;

UI.List = {};

UI.List.ready = function($) {
  // inline edit
  $(".inline-edit-toggle").click(function(){
    $(".inline-edit-form input:text").val($(this).html());
    $(this).toggle();
    $(this).next().toggle();  
  });
  $(".inline-edit-form input:button").click(function(){
    $(this).parent().toggle();  
    $(this).parent().prev().toggle(); 
  });
  $(".inline-edit-form .save").click(function(){
    $(".inline-edit-toggle").html($(".inline-edit-form input:text").val());
  });
  // filter switching
  $(".filter a").click(function(){
    $(".filter a").toggleClass("current");  
  });
  
  //handlers on friends elements are separated to be used by other functions
  addFriendsHandlers('new');
  addFriendsHandlers('edit');
  
  // toggle the icon dropdown 
  $(".icon-list .icon-main a").click(function(){
    if($(this).parents(".icon-list").hasClass("icon-list-closed")) {
      $(this).parents(".icon-list").removeClass("icon-list-closed");
      $(this).parents(".icon-list").addClass("icon-list-open");
    } else {
      $(this).parents(".icon-list").addClass("icon-list-closed");
      $(this).parents(".icon-list").removeClass("icon-list-open");
    }
  });

  // close the icon dropdown when click outside
  $('.icon-dropdown, .icon-main').hover(function(){
      mouse_is_inside=true; 
  }, function(){ 
      mouse_is_inside=false; 
  });

  $("body").mouseup(function(){ 
    if(!mouse_is_inside) {
      $(".icon-list").addClass("icon-list-closed");
      $(".icon-list").removeClass("icon-list-open");
    }
  });
}

UI.List.handlers = function($) {
  $j(".lightbox-cancel").click(function(){
    $j.colorbox.close();
    $j('body').removeClass('transparent-overlay');
    $j('list-box').removeClass('on-top');
  });
  
  $j(".lightbox-submit").click(function(){
    $j.colorbox.close();
    $j('body').removeClass('transparent-overlay');
    $j('list-box').removeClass('on-top');
  });
  
  //for each icon in the list, when clicked, close list and set icon to the selected one
  img_ancrs = $j(".icon-dropdown-head a");
  img_ancrs.each(function(){
    $(this).click(function(){
      img_name = $(this).attr('title');
      $j("#task_list_icon_name").val(img_name);
      $j("#icon-selector-image").attr('src','images/list_icons/'+img_name);
      $j(".icon-list .icon-main").parents(".icon-list").addClass("icon-list-closed");
      $j(".icon-list .icon-main").parents(".icon-list").removeClass("icon-list-open");
    });
  });
  
  //when moving away from the list, close it
  $(".icon-list .icon-main a").blur(function(){
    $j(".icon-list .icon-main").parents(".icon-list").addClass("icon-list-closed");
    $j(".icon-list .icon-main").parents(".icon-list").removeClass("icon-list-open");
  });
  
  //handle (all, selected) tools in new form
  $j(".new .tools .show-all").click(function(){
    $j(this).addClass("current");
    $j(".new .tools .show-selected").removeClass("current");
    fixShownFriends('new', 0, listOfAllFriendsHtml); //0 means show all
  });
  $j(".new .tools .show-selected").click(function(){
    $j(this).addClass("current");
    $j(".new .tools .show-all").removeClass("current");
    if(canPerformSelectedAction('new')){
      deselectedList = prepareDeselectedFriendsForHide('new');
      fixShownFriends('new', deselectedList, listOfAllFriendsHtml);
    }
  });
  
  //handle (all, selected) tools in edit form
  $j(".edit .tools .show-all").click(function(){
    $j(this).addClass("current");
    $j(".edit .tools .show-selected").removeClass("current");
    fixShownFriends('edit', 0, listOfAllFriendsHtml); //0 means show all
  });
  $j(".edit .tools .show-selected").click(function(){
    $j(this).addClass("current");
    $j(".edit .tools .show-all").removeClass("current");
    if(canPerformSelectedAction('edit')){
      deselectedList = prepareDeselectedFriendsForHide('edit');
      fixShownFriends('edit', deselectedList, listOfAllFriendsHtml);
    }
  });
  
  //handle search box changes
  $j(".new .search-box .search-text").keyup(function(){
    hiddenList = [];
    token = $j(this).val();
    if(token != ''){
      $j(".new .people-list li").each(function(){
        if ($j(this).find(".friend-name").html().indexOf(token, 0) == -1){
          hiddenList.push($j(this).attr('title'));
        }
      });
      fixShownFriends('new', hiddenList, $j(".new .people-list").html());
    } else {
      fixShownFriends('new', hiddenList, listOfAllFriendsHtml);
    }
  });
    
  $j(".edit .search-box .search-text").keyup(function(){
    hiddenList = [];
    token = $j(this).val();
    if(token != ''){
      $j(".edit .people-list li").each(function(){
        if ($j(this).find(".friend-name").html().indexOf(token, 0) == -1){
          hiddenList.push($j(this).attr('title'));
        }
      });
      fixShownFriends('edit', hiddenList, $j(".edit .people-list").html());
    } else {
      fixShownFriends('edit', hiddenList, listOfAllFriendsHtml);
    }
  });    
  
}

function addFriendsHandlers(newOrEdit){
  // people list click
  $j("."+newOrEdit+" .people-list-scroll li").click(function(){
    if($j(this).hasClass("state-2")) {
      $j(this).removeClass("state-2");
      $j(this).find(".list-deselct").remove();
      
      listOfSelectedFriendsIDs = listOfSelectedFriendsIDs.replace($j(this).attr('title') + ',', '')
    }
    else {
      $j(this).addClass("state-2");
      $j(this).prepend('<a class="list-deselct"></a>');
      
      listOfSelectedFriendsIDs += $j(this).attr('title') + ',';
    }
  });
}

function prepareDeselectedFriendsForHide(newOrEdit){
  deselectedFriends = "";
  elements = $j("."+newOrEdit+" .people-list li");
  elements.each(function(){
    if($j(this).hasClass("state-2")){ //if selected
      deselectedFriends.replace($j(this).attr("title") + ',', "");
    } else {
      deselectedFriends += $j(this).attr("title") + ",";
    }  
  });
  
  str = deselectedFriends.substring(0, deselectedFriends.length-1); //to remove the last surplus comma
  str = currentlyHiddenElemensAsStr + str 
  return str.split(",");
}

function canPerformSelectedAction(newOrEdit){
  var can = false;
  elements = $j("."+newOrEdit+" .people-list li");
  elements.each(function(){
    if(!$j(this).hasClass("state-2")){ //if deselected
      can = true;
    }
  });
  
  return can;
}

function prepareSelectedFriendsForShow(newOrEdit){
  selectedFriendsCount = 0;
  selectedFriends = "";
  elements = $j("."+newOrEdit+" .people-list li");
  elements.each(function(){
    if($j(this).hasClass("state-2")){ //if selected
      $j(this).prepend('<a class="list-deselct"></a>');
      selectedFriends += $j(this).attr("title") + ",";
      selectedFriendsCount++;
    } else {
      selectedFriends.replace($j(this).attr("title") + ',', "");
    }  
  });
  
  str = selectedFriends.substring(0, selectedFriends.length-1);
  return str.split(",");
}

function prepareSelectedFriendsForSubmit(newOrEdit){
  elements = $j("."+newOrEdit+" .people-list li");
  elements.each(function(){
    if($j(this).hasClass("state-2")){ //if selected
      addToSelectedFriends(newOrEdit, $j(this).attr("title"));
    } else {
      removeFromSelectedFriends(newOrEdit, $j(this).attr("title"));
    }  
  });
}

function addToSelectedFriends(newOrEdit,id){
  value = $j("#task_list_selected_friends_"+newOrEdit).val() + id + ',';
  $j("#task_list_selected_friends_"+newOrEdit).val(''+value);  
}

function removeFromSelectedFriends(newOrEdit,id){
  value = $j("#task_list_selected_friends_"+newOrEdit).val().replace(id + ',', "");
  $j("#task_list_selected_friends_"+newOrEdit).val(''+value);  
}

function initListOfAllFriends(newOrEdit){
  listOfAllFriendsHtml = $j('.'+newOrEdit+' .people-list').html();
  if(newOrEdit == 'new')
    listOfSelectedFriendsIDs = "";
  else
    listOfSelectedFriendsIDs = prepareSelectedFriendsForShow('edit').join(",") + ',';
}

function fixShownFriends(newOrEdit, hiddenElements, sourceHtmlString){
  //show all elements
  $j("."+newOrEdit+" .people-list").html(sourceHtmlString);
  
  //remove selection highlight from all elements as initial state
  $j("."+newOrEdit+" .people-list li").each(function(){
    $j(this).removeClass("state-2");  
  });
  
  //hide deselected elements in the case, 'selected'
  currentlyHiddenElemensAsStr = '';
  if(hiddenElements != 0){
    for(i=0; i < hiddenElements.length; i++){
      currentlyHiddenElemensAsStr += hiddenElements[i] + ','
      $j("."+newOrEdit+" .people-list li[title='"+hiddenElements[i]+"']").remove();  
    }  
  }
  
  //add selection highlight for selected elements
  selectedElements = listOfSelectedFriendsIDs.split(",");
  for(i = 0; i < selectedElements.length; i++){
    $j("."+newOrEdit+" .people-list li[title='"+selectedElements[i]+"']").addClass("state-2");
    $j("."+newOrEdit+" .people-list li[title='"+selectedElements[i]+"']").prepend('<a class="list-deselct"></a>');
  }
  
  //add actions to newly generated elements
  addFriendsHandlers(newOrEdit);
}

//jQuery(document).ready(UI.List.ready);
//jQuery(document).ready(UI.List.handlers);
