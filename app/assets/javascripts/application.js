// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

/*
 * TODO: .metadata() of html5 is not supported in old browsers
 * 
*/
var lastPageAjaxRequest; 
var lastPageAjaxRequestSerial = 0;

function deserialize(query) { // deserialize a query string back to a normal object
  if (query == '') return null;

  var hash = {};
  var vars = query.split("&");

  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    var k = decodeURIComponent(pair[0]);
    var v = decodeURIComponent(pair[1].replace(/\+/g, '%20'));
    
    if (typeof hash[k] === "undefined") { // If it is the first entry with this name
      if (k.substr(k.length-2) != '[]')  // not end with []. cannot use negative index as IE doesn't understand it
        hash[k] = v;
      else
        hash[k] = [v];            
    }
    else if (typeof hash[k] === "string") { // If subsequent entry with this name and not array
      hash[k] = v;  // replace it    
    }
    else { // If subsequent entry with this name and is array
      hash[k].push(v);
    }
  } 
  
  return hash;
}

function selectAllCheevers() {
	if ($j('input.cheever:checked').length !== $j('input.cheever').length) {
		$j("input.cheever").attr('checked', 'checked');
		$j("input.cheever").parent().addClass('checked');
		document.getElementById('select_all_cheevers').innerHTML = "Deselect All";
	} else {
		$j("input.cheever").attr('checked', null);
		$j("input.cheever").parent().removeClass('checked');
		document.getElementById('select_all_cheevers').innerHTML = "Select All";
	}
}

function selectAllContacts() {
	if($j('input.contact:checked').length !== $j('input.contact').length) {
		$j("input.contact").attr('checked', 'checked');
		$j("input.contact").parent().addClass('checked');
		document.getElementById('select_all_contacts').innerHTML = "Deselect All";
		$selected = "true"
	} else	{
		$j("input.contact").attr('checked', null);
		$j("input.contact").parent().removeClass('checked');	
		document.getElementById('select_all_contacts').innerHTML = "Select All";
	}
}

function seconds(count) {
  return count * 1000;
}

var $j = jQuery;

$j(document).ajaxSend(function(e, xhr, settings) {
  xhr.setRequestHeader("Accept", "text/javascript");

  if(settings.type == 'post')
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");    
});

$j.ajax_without_extensions = $j.ajax;

$j.ajax = function(options) {
  var csrf_param = $j('meta[name="csrf-param"]').attr("content");
  var csrf_token = $j('meta[name="csrf-token"]').attr("content");

  if(options.data === undefined || options.data === null)
    options.data = {};
    
  if(typeof options.data === "string")
    options.data = deserialize(options.data);
    
  if(typeof($current_page) !== 'undefined' && $current_page == "home")
      options.data = $j.extend(true, {filters: filtersData()}, options.data);
  
  csrf = {};
  csrf[csrf_param] = encodeURIComponent(csrf_token);  
  options.data = $j.extend(options.data, csrf);                    
   
  lastPageAjaxRequest = $j.ajax_without_extensions(options);
}

$j.metadata.setType("html5");

/********************** MISC **********************/

function loadFriendsImages(){
  list = $all_friends_images.split(',');
  for(i = 0; i < list.length; i++){
    new Image().src = list[i];
  }
}

/***************** Flash Messages *****************/ 

function flashNotice(msg, options) {
  $j("#flash_messages").html($j('<div id="flash_notice">' + msg + '</div>'));
  
  var defaults = {onUndo: false, onClosed: false};
  $j.extend(defaults, options); 
  
  if(defaults.onUndo !== false) {
    $j("#flash_notice").append('<a>Undo</a>');
    $j("#flash_notice a").click($j.proxy(flashNoticeUndo, defaults));
    
    var counter = $j("<span>" + (10000 / 1000) + "</span>");
    $j("#flash_notice").append(counter);
    setTimeout($j.proxy(flashNoticeCounterUpdate, {nextVal: 9000}), 1000);     
  }  
  
  $j("#flash_notice").fadeIn(600).delay(10000).fadeOut(600, $j.proxy(flashNoticeClosed, defaults));
}

function flashNoticeCounterUpdate() {
  if(this.nextVal >= 0) {
    $j("#flash_notice").children("span").text(this.nextVal / 1000);
    setTimeout($j.proxy(flashNoticeCounterUpdate, {nextVal: this.nextVal - 1000}), 1000);
  }
}

function flashNoticeUndo() {
  $j("#flash_notice").remove();
  this.onUndo();
}

function flashNoticeClosed() {
  $j("#flash_notice").remove();
  if(this.onClosed !== false)
    this.onClosed();
}

/***************** Side Tabs (task lists tabs) *****************/

function replaceSideTabs(content) {  
  $j("#side-tabs").replaceWith(content);
  addSideTabsEvents();
}

function selectedSideTab() {
  return $j("#side-tabs .selected");
}

function selectedSideTabMeta() {
  return selectedSideTab().metadata();
}

function incrementPendingTasks(sideTab) {
  var pendingTasks = sideTab.children(".count");
  pendingTasks.text(parseInt($j.trim(pendingTasks.text())) + 1);
}

function selectSideTab(list_id) {
  resetCurrentPage();
  showContentLoading();  
  //loadTasks({filters: {task_list_id: list_id}});
  loadPageContent('/tasks', {filters: {task_list_id: list_id}});
}

function addSideTabsEvents() {
  $j("#side-tabs li").each(addSideTabEvents);
}

function addSideTabEvents() {
  if($j(this).hasClass("add")) {
    if($unregisteredUser){  
      $j(this).children("a").attr('disabled', 'disabled');
      $j(this).children("a").click(function(){
        showCompleteRegisterationWindow();
        event.preventDefault();
      });
    } else{ //if user is registered
      $j(this).children("a").click(function(){
        loadFriendsImages();
      });
      $j(this).children("a").colorbox();
    }
  } else { //if the side tab is a task list
    title = $j(this).find(".text").text();
    
    if(title.length > 10){
      $j(this).find(".text").text(title.substring(0,8)+"..");
      $j(this).find(".text").css('text-align', 'left');
    }
      
    $j(this).hasClass("selected") ? '' : $j(this).children(".count").hide();
    
    $j(this).children(".link").click(function(e) {
      selectSideTab($j(this).parent().metadata().id);
      e.preventDefault();
    });
    
    $j(this).find(".edit-link").click(function(e) {
      if($unregisteredUser){
        showCompleteRegisterationWindow();
        e.preventDefault();
      } else {
        loadFriendsImages();
        $j(this).colorbox();
      }
    });
    
    $j(this).hover(
      function(){ //hover in
        if($j(this).find(".text").attr('data-title').length > 10){
          timerFn($j(this).find(".text"), $j(this).find(".text").attr('data-title'), 0);
        }
      }, //end of hover in
      function(){ //hover out
        if($j(this).find(".text").attr('data-title').length > 10){
          clearTimeout(t);
          $j(this).find(".text").text($j(this).find(".text").attr('data-title').substring(0,8)+"..");
        }
      } //end of hover out 
    ); //end of hover event    
  }
}

function timerFn(el, elT, cntr){
  if(cntr == elT.length){
    cntr = 0;
  }
    
  el.text(elT.substring(cntr, cntr+10));
  t = setTimeout(function(){timerFn(el, elT,++cntr)}, 100);
}

function enableTaskActionButtons(taskId){
  $j(".task-unit[data-id='"+taskId+"'] .task-buttons input").removeAttr("disabled");  
}

function disableTaskActionButtons(taskId){
  $j(".task-unit[data-id='"+taskId+"'] .task-buttons input").attr("disabled","disabled");
}

/***************** Edit Task List Events *****************/

function submitEditTaskList() {
  var uids = new Array();
  $j("#edit_task_list .state-2").each(function() {
    uids.push($j(this).metadata().uid);
  });
  
  $j.post("/task_lists/" + $j("#edit_task_list").metadata().id + "/edit_connections", {uids: uids.join(",")});  
}

function showTaskListFriends(e) {
  $j("#edit_task_list .filter a").removeClass("current");
  $j(this).addClass("current");
  if($j.trim($j(this).text()) == "All")
    $j("#edit_task_list li").show();
  else
    $j("#edit_task_list li:not(.state-2)").hide();
  e.preventDefault();  
}

function editTaskListEvents() {
  $j("#edit_task_list .lightbox-cancel").click($j.colorbox.close);
  $j("#edit_task_list .lightbox-submit").click(submitEditTaskList);
  
  $j("#edit_task_list .filter a:first-child").click(showTaskListFriends);  
  $j("#edit_task_list .filter a:last-child").click(showTaskListFriends);  
  
  $j("#edit_task_list li").click(function() {
    var friendsSpan = $j(".filter a:last-child .start");
    var friendsCount = parseInt(friendsSpan.text().match(/(\d+)/)[0]);
    if($j(this).hasClass("state-2")) {
      $j(this).removeClass();      
      friendsSpan.text("Selected (" + (friendsCount - 1) + ")");
    } else {
      $j(this).removeClass().addClass("state-2");
      friendsSpan.text("Selected (" + (friendsCount + 1) + ")");
    }    
  }); 
}

/***************** New Task Form *****************/

var isTasksListHasFocus = false;

function tasksListAnchorSelctor(){
	return $j('.new-task-as a.jqTransformSelectOpen');
}

function setFocusToTaskListsCombo(){
	tasksListAnchorSelctor().focus();
}

function populate_tasks_lists_combo(){
	$j.get('/users/accessible_task_lists',
				{uid: $j('#task_to_2').val()},
				function(data){eval(data);});
}

function validateExistenceAndUpdateLists(type, value){
	if(type == 'username')
		value = value.split('@')[0];
		

  $j.post('/users/does_user_exist', 
           {type: type, value: value},
           function(data){
           	 eval(data);
             populate_tasks_lists_combo();
           });
}
             
function update_task_lists_combo(toTextInput){	
	
  if($j.contains($j('.new-task-to')[0], $j('.to-user-box')[0])){ // TODO: do we really need to do this check ??.
  	
  	populate_tasks_lists_combo();
  	
  } else { 
  	toUserName = $j(toTextInput).val();
  	 
    if(toUserName == ""){    	 
      setDefaultUser();    
      populate_tasks_lists_combo();  
    } else if (validateEmail(toUserName) && !cheeveItEmail(toUserName)){
    	validateExistenceAndUpdateLists('email', toUserName);             
    } else { 
    	validateExistenceAndUpdateLists('username', toUserName);      
    }
    //TODO: is this commented code really needed?? , make sure error detection is happening
    /*  else {
      jQuery('#task_to_user_name').addClass('new-task-text-error');
    }*/
  } 
}

function addNewTaskFormEvents() {
	tasksListAnchorSelctor()
				.live('focusin', function(){														
														isTasksListHasFocus = true;
														})
				.live('focusout', function(){														
														isTasksListHasFocus = false;
														});
	
  $j("#new_task_form").submit(function() {
    if(invalidNewTaskForm()) return false;
    //simulate a space click in the tag-it input text to endure the last entered value
    $j(".tagit-new .tagit-input").trigger({ type : 'keypress', which : " ".charCodeAt(0) });
    $j(this).find(".new-task-loading").show();
    $j.post($j(this).attr("action"), $j(this).serialize());
    return false;
  });
  
  shortcut.add("Ctrl+T", function() { $j("#new_task_txt").focus(); });
  $j(".submit-btn a").click();
  
  $j("#new_task_txt, #task_to_user_name").keyup(enableNewTaskFormSubmit);  
  // TODO: is this really needed
  $j("#task_to_1, #task_to_2").click(enableNewTaskFormSubmit);
  $j("#task_as").change(enableNewTaskFormSubmit);
  
  $j("label[for='task_private_task']").click(function(){
    $j("#task_private_task").prev().click();
  });
  
  /* new task form scripts */
  $j('.new-task-wrapper .close').click(function() {
    $j('.new-task-wrapper').animate({height: 41}, 500, null, newTaskFormClosed );
    $j(".new-task-wrapper").addClass("small");
    $j("#new_task_txt").addClass("small");
    $j(".new-task-wrapper .hidden-elements-container").hide();
  });
  
  $j(".new-task-wrapper .as-and-tag textarea").keyup(function(){
    if(String.fromCharCode(event.keyCode) == "A") { //when comma is inserted
      $j(this).html("<span class='highlighted-tag'>tag</span>");
    }
  }); 
  
  // TODO: is this really needed ??
  function check_other_radio(){
    if ($j("#task_to_2").is(":checked") && !$j(".task-other-text input").is(":visible")) {
      $j(".task-other-text input").val("");
      $j(".task-other-text input").show().focus();
    } else if($j("#task_to_1").is(":checked")){
      $j(".task-other-text input").hide();
    }       
  }
  
  // TODO: is this really needed
  $j(".task-other-radio input[name='task[to_user_id]']").change(check_other_radio).keyup(check_other_radio);
  
  // TODO: is this really needed
  $j(".task-other-text input").blur(function() {
    $j("#task_to_2").blur();
  });
  
  // Updating task lists
  $j("#task_to_user_name")  	
  	.focusout(function(focusEvent){
    	 // shouldn't do that on focus out and should be done on change and sel changed of the to-box
  	   update_task_lists_combo(this);
  	}
  );
  
  /* TIPS EVENTS */
  //New task text tips events
  $j("#new_task_txt")
  	.focus(function(){$j("#new-task-tip").show();})
  	.focusout(function(){$j("#new-task-tip").hide();});
  //To user tips events
  $j("#task_to_user_name")
  	.focus(function(){
  	   $j("#to-user-tip").text('Type a username or an email');
  	   $j("#to-user-tip").show();
     }) // end of focus in
  	.focusout(function(focusEvent){  	   
  	   $j("#to-user-tip").hide();  	   
  	 }); //end of focus out
  //Task list tips events
  $j(".new-task-as a.jqTransformSelectOpen")
		.live('focus', function(){ 
			$j("#task-as-tip").show();
		}) //end of live focus
		.live('focusout', function(){
			$j("#task-as-tip").hide();
		});  //end of live focus out
  
  //Tags tips events
  $j("#mytags")
		.live('focus', function(){$j("#mytags-tip").show();})
		.live('focusout', function(){$j("#mytags-tip").hide();});

  //isPrivate tips events
   $j(".new-task-wrapper .jqTransformCheckboxWrapper")
		.live('focus', function(){ $j("#private-tip").show();})
		.live('focusout', function(){$j("#private-tip").hide();});
  
  //is private events
  $j(".new-task-wrapper .jqTransformCheckboxWrapper").click(function(){
	 $j(this).find('.jqTransformCheckbox').focus();
  });
}

function setTagItAvailableTags(tagsArray){
  $j(".tagit-container .tagit-input").autocomplete(tagsArray);
}

function cheeveItEmail(email){
  return email.indexOf('@cheeve.it') >= 0 ? true : false;
}

function enableNewTaskFormSubmit() {
  if(invalidNewTaskForm()){
    $j("#task_submit").attr("disabled", "disabled");
    $j("#task_submit").removeClass("selector");
  }
  else {
    $j("#task_submit").removeAttr("disabled");
    $j("#task_submit").addClass("selector");    
  }
}

function isToUserValid(searchText){
	friends = '#{current_user.friends_names}'
	
	if( "#{current_user.name.downcase}" == searchText 
		|| friends.indexOf(searchText) >= 0 
		|| validateEmail(searchText) ){
		return true;
	} else {
		return false;
	}
}

function invalidNewTaskForm() {
  var emptyDescription = ($j.trim($j("#new_task_txt").val()) === "");
  var searchText = $j("#task_to_user_name").val().toLowerCase();

  return (emptyDescription || !isToUserValid(searchText));
}

function updateTaskListsSelect(options) {
	hadFocus = isTasksListHasFocus;										
	
  $j(".new-task-wrapper .new-task-as").html("<select name='task[task_list_id]' id='task_as' class='as'>"+options+"</select><label>As</label>");
  $j(".new-task-wrapper .new-task-as").append("<div id='task-as-tip' class='tip-left' style='bottom: -22px;left:-180px;'>Select a task list</div>");
  $j(".new-task-wrapper .new-task-as").removeClass('jqtransformdone');
  $j(".new-task-wrapper .new-task-as").jqTransform();
  
  enableNewTaskFormSubmit();
    
	if(hadFocus) // return the focus to it's original state
		setFocusToTaskListsCombo();		
}

function addNewTaskAsEvent() { 
  $j('#task_as').live('change', function(){
	 	setFocusToTaskListsCombo();
  });
}

var newTaskFormClosedCallback = null;

function newTaskFormClosed() {
  newTaskFormReset();
  if(newTaskFormClosedCallback) {
    newTaskFormClosedCallback();
    newTaskFormClosedCallback = null;
  }
}

function newTaskFormReset() {
  $j("#new_task_form").resetForm();
  $j(".task-other-text input").hide();
  $j("#new_task_form .new-task-loading").hide();
  $j("#task_submit").attr("disabled", "disabled");
  $j(".to-user-box").remove();
  $j("#is_reassign").val('false');
  $j('#with_cancel').val('false');
  $j("#clone_task").val('-1');
  
  $j(".new-task-wrapper textarea, .new-task-wrapper input[type='text']").each(function(){
    $j(this).removeClass("new-task-text-error");
  });
}

/***************** ColorBox *****************/

$j(document).bind('cbox_complete', function() {
  $j.colorbox.resize();
});

function colorboxClosed(msg) {
  $j(document).bind('cbox_closed', function() {
    alert(msg);
    $j(document).unbind('cbox_closed');
  })
}

function colorboxClose(msg) {
  if(msg)
    colorboxClosed(msg);

  $j.colorbox.close();
}

/***************** Tabs List (for me, from me, my hives) *****************/

function addTabsListEvents() {
  $j("#tab-area div").each(function() {
    $j(this).find("a").click(function(e){
      element = $j(this);
      tabClickFunction(element, e);
    });
  });

  $j('#notifications-tab .close-tab').click(function(){
    $j('#notifications-tab').hide();
    $j('#for-me-tab a').click();
  });
  
}

function clearPage(){
  $j("#main-tasks .inner-container").empty(); 
}

function attachPageLoadingImage(){
  
}

function tabClickFunction(element, e) {
  clearPage();               //remove tasks from task body container
  fixTaskAreaActualHeight(); //fix height
  showContentLoading();
  resetCurrentPage();        //return currentPage counter to 0
        
  var tabList = element.parent();

  if(!$unregisteredUser){
    $j("#tab-area div").removeClass("selected"); //remove selected class from all tabs
    tabList.addClass("selected");                //add selected class for current tab
    $j("#side-tabs").hide();                     //hide side tabs
  }
  
  if(tabList.metadata().tasks == "for_me"){
    $j("#side-tabs").show();
    fixTaskAreaActualHeight();
    loadPageContent('/tasks');
  }
  else if(tabList.metadata().tasks == "from_me"){
    fixTaskAreaActualHeight();
    if($unregisteredUser){
      showCompleteRegisterationWindow();
      loadPageContent('/tasks');
    }
    else{
      loadPageContent('/tasks');
    }
  }
  else if(tabList.metadata().tasks == "my_hives"){
    fixTaskAreaActualHeight();
    if($unregisteredUser){
      showCompleteRegisterationWindow();
      loadPageContent('/tasks');
    }
    else{
      loadPageContent('/news_feeds');
    }
  }
  else if(tabList.metadata().tasks == "notifications"){
    fixTaskAreaActualHeight();
    loadPageContent('/notifications');
  }
  
  e.preventDefault();
} // end of clickFunction()

function disableTabs(){
  $j("#tab-area div").attr('disabled', 'disabled');
}

function enableTabs(){
  $j("#tab-area div").removeAttr('disabled');
}

function resetCurrentPage(){
  $j("#main-tasks").empty();
  $j("#main-tasks").append("<div id='page-loading-container'><img id='page-loading' src='/images/load36.gif' /></div>");
  $currentPage = 1;
}

function incrementCurrentPage(){
  $currentPage++;
}

function showCompleteRegisterationWindow(){
  alert("register first yad");
}

function selectedTabList() {
  return $j("#tab-area .selected").metadata().tasks;
}

/***************** Tasks *****************/

function removeTaskNotice(taskId) {
  $j("#task_notice_" + taskId).remove();
}

function taskNotice(taskId, options) {
  var taskSelector = '.task-unit[data-id="' + taskId + '"]';
  var defaults = {duration: 10000, onUndo: $j.noop, onClosed: $j.noop, counter: false};
  options = $j.extend(defaults, options);
    
  var notice = $j("<div id=\"task_notice_" + taskId + "\" class=\"task-notice\">" + options.msg + "</div>");    
  if(options.onUndo !== $j.noop) {
    var undo = $j("<a title='undo'>Undo</a>");
    undo.click(options.onUndo);
    notice.append(undo); 
  }
  
  if(options.counter) {
    var counter = $j("<span>" + (options.duration / 1000) + "</span>");
    notice.append(counter);
    setTimeout($j.proxy(taskNoticeCounterUpdate, {taskId: taskId, nextVal: options.duration - 1000}), 1000); 
  }      
  
  $j(taskSelector).after(notice);
  notice.fadeIn(600).delay(options.duration).fadeOut(600, function() {    
    $j(this).remove();
    removeTaskNotice(taskId);
    options.onClosed();  
  });
}

function taskNoticeCounterUpdate() {
  if(this.nextVal >= 0) {
    $j("#task_notice_" + this.taskId).children("span").text(this.nextVal / 1000);
    setTimeout($j.proxy(taskNoticeCounterUpdate, {taskId: this.taskId, nextVal: this.nextVal - 1000}), 1000);
  }
}

function replaceTask(taskId, content) {
  $task = $j('.task-unit[data-id="' + taskId + '"]'); 
  $task.replaceWith(content);

  initTaskEvents($task);
}

function initTaskEvents($task, is_private, is_spam){
  $j(".task-unit .task-menu").jqTransform();
  addZIndexCorrectionToTasksMenuSelect();
  if(typeof $task == "undefined")
    addTaskActionEvents();
  else
    addTaskActionEvents($task.attr('data-id'));
}

function changeSpamStateForTasksFromUser(userId, isSpam) {
  $j(".task-unit[data-from='"+userId+"']").each(function(){
    $j(this).find(".task-buttons-spam-actions").hide();
    if(isSpam == "true"){
      $j(this).find(".task-menu div:first").effect("highlight", {color: '#c83c32'}, 2500);
      $j(this).find(".task-body").effect("highlight", {color: '#c83c32'}, 2500, function(){
        var taskDiv = $j(this).closest(".task-unit");
        var hsep = taskDiv.nextUntil(".task-unit");
        taskDiv.hide();
        hsep.hide();
      });
    }
  });
}

function addTaskActionEvents(task_id) {
  if(task_id)
    tasks_selector = ".task-unit[data-id='" + task_id + "']";
  else
    tasks_selector = ".task-unit";
  
  addStyleToCurretTaskState(tasks_selector);
  
  virgin_tasks_selector = tasks_selector + "[data-virgin='true']";
  virgin_tasks = $j(virgin_tasks_selector);
  
  //$j(task_id + " .task-buttons input").unbind('click'); //remove previously added events first
  virgin_tasks.find(".iwill-button").click(function() { changeTaskStatus(this, "will"); });  
  virgin_tasks.find(".idid-button").click(function()  { changeTaskStatus(this, "did"); });  
  virgin_tasks.find(".icant-button").click(function() { changeTaskStatus(this, "cant"); });
  
  virgin_tasks.find(".mark-done").click(function() { assignerChangeTaskStatus(this, "did"); });
  virgin_tasks.find(".cancel").click(function()    { assignerChangeTaskStatus(this, "cancelled"); });
  virgin_tasks.find(".reassign-to-assignee").click(function() { reassignTask(this, "assignee"); });
  virgin_tasks.find(".reassign-to-yourself").click(function() { reassignTask(this, "yourself"); });
  virgin_tasks.find(".reassign-to-other").click(function() { reassignTask(this, "other"); });
  virgin_tasks.find(".cancel-reassign").click(function() { reassignTask(this, "other", true); });
  
  virgin_tasks.find(".task-menu div.jqTransformSelectWrapper ul li a").click(changeTaskTaskList);
  
  // TODO fix this
  addTaskFooterEvents(virgin_tasks);
  
  virgin_tasks.attr('data-virgin', 'false');
}

function addStyleToCurretTaskState(tasks_selector){
  task_items = $j(tasks_selector);
  
  task_items.find(".task-buttons input").removeClass('current');
  task_items.each(function(i, task){
    status = $j(task).attr('data-status');
    $j(task).find(".i"+status+"-button").addClass('current');
  });
}

function changeTaskTaskList() {
  $j(this).closest(".task-unit").find(".task-loading").show();
  var taskMeta = $j(this).closest(".task-unit").metadata();
  new_task_list = $j(this).closest(".task-unit").find('.task-menu select').val();
  $j.post("/tasks/" + taskMeta.id + "/change_task_list", {new_task_list_id: new_task_list, task_list_id: selectedSideTabMeta().id});
  
  if(selectedTabList() == 'notifications'){
    $j.post('/notifications');
  } 
}

function changeTaskStatus(elem, status) {
  var taskItem = $j(elem).closest(".task-unit");
  var taskStatus = taskItem.attr('data-status');
  //renderUndoMsg parameter indicates wheather the undo message should
  //be rendered or not
  renderUndoMsg = true;
  
  if(taskStatus == "'"+status+"'") return;
  if($j(elem).hasClass('current')) return;
  
  taskItem.find(".task-loading").show();

  // add current class the the appropriate button
  $j(elem).addClass('current');
  
  if(selectedTabList() == 'notifications')
    $j.post('/notifications/' + taskItem.attr('data-id') + '/status', {status: status});
  else
    $j.post('/tasks/' + taskItem.attr('data-id') + '/status', {status: status, render_undo_msg: renderUndoMsg});
}

function assignerChangeTaskStatus(elem, status, renderUndoMsg) {
  //renderUndoMsg parameter indicates wheather the undo message should
  //be rendered or not
  if (typeof renderUndoMsg == "undefined") {
    renderUndoMsg = true;
  }

  var taskItem = $j(elem).closest(".task-unit");
  var taskStatus = taskItem.attr('data-status');
  
  if(taskStatus == "'"+status+"'") return;
  if($j(elem).hasClass('current')) return;
  
  taskItem.find(".task-loading").show();

  // add current class the the appropriate button
  $j(elem).addClass('current');
  
  if(selectedTabList() == 'notifications')
    $j.post('/notifications/' + taskItem.attr('data-id') + '/status', {status: status});
  else
    $j.post('/tasks/' + taskItem.attr('data-id') + "/status", {status: status, assigner_action: true, render_undo_msg: renderUndoMsg});
}

function reassignTask(elem, targetUser, withCancel) {
  if (typeof withCancel == "undefined") {
    withCancel = false;
  }

  if(targetUser == "other"){ //reassign-to-other ------------------
    //reassign-to-other part --------------------------------------
    //to be clone: description, tags, private/public --------------
    var taskItem = $j(elem).closest(".task-unit");
    //clone description -------------------------------------------
    $j('#new_task_txt').focus();
    desc = taskItem.find("div.discription input[type='hidden']").val();
    $j('#new_task_txt').val(desc);
    //-------------------------------------------------------------
    
    //clone tags --------------------------------------------------
    $j(".tagit-new .tagit-input").focus();
    taskItem.find(".tag-item").each(function(i, tagItem){
      $j(".tagit-new .tagit-input").val($j(tagItem).text());
      $j(".tagit-new .tagit-input").trigger({ type : 'keypress', which : " ".charCodeAt(0) });
    });
    //-------------------------------------------------------------
    
    //clone privacy -----------------------------------------------
    privacy = taskItem.attr('data-privacy');
    if(privacy == "true" && !$j('.jqTransformCheckboxWrapper input').is(':checked'))
      $j('.jqTransformCheckboxWrapper input').trigger('click').trigger('change')
    //-------------------------------------------------------------
    
    //set params fields (is_reassign, clone_task) -----------------
    $j("#is_reassign").val("true");
    $j("#clone_task").val(taskItem.attr('data-id'));
    //-------------------------------------------------------------
    
    $j('#task_to_user_name').focus();
    if(withCancel){ //cancel-and-reassign -------------------------
      $j('#with_cancel').val('true');
      assignerChangeTaskStatus(elem, "cancelled", false);
    }
  } else { //if to yourself or the assignee (receipient)
    var taskItem = $j(elem).closest(".task-unit");
    taskItem.find(".task-loading").show();
    
    var answer = confirm("Do you want to include previous comments?");
    $j.post('/tasks/reassign/' + taskItem.attr('data-id') + "/" + targetUser, {with_comments: answer});
  }
}

function removeTask(task_id) {
  var taskDiv = $j("[data-id='" + task_id + "']");
  var hsep = taskDiv.nextUntil(".task-unit");
  
  if(hsep.length == 0)
    hsep = taskDiv.prev(".h-sep");      
	
  setTimeout($j.proxy(removeTaskDiv, {hsep: hsep, task: taskDiv}), 2000); 
}

function removeTaskDiv() {
  this.hsep.remove();
  this.task.hide(2000, function(){$j(this).remove();});
}

function filtersData() {
  try{
    filter_tags = $j("#filter_tags").val();
    if (filter_tags && filter_tags.charAt(0) == ',')
      filter_tags = filter_tags.substring(1);
    
    return {
      task_list_id: selectedSideTabMeta().id,
      tasks: selectedTabList(),
      status: $j(".show-me select").val(),
      tags: filter_tags,
      page: $currentPage
    };
  } catch(e) {
    return {
      task_list_id: selectedSideTabMeta().id,
      tasks: selectedTabList(),
      status: $j(".show-me select").val(),
      tags: "",
      page: $currentPage
    };  
  }
}

/*************** show me select menu ******************/

function showMeSelectEvents() {
  $j(".show-me div.jqTransformSelectWrapper ul li a").click(function () {
    resetCurrentPage();
    showContentLoading();
    //loadTasks();
    loadPageContent('/tasks'); 
  });

  $j("#filter-tags-wrapper .tag-word-frame a").each(function(){
    $j(this).click(function(){
      fitler_tags = $j('#filter_tags').val();
      removed_tag = $j(this).parent().attr('data-tag');
      $j('#filter_tags').val(fitler_tags.replace(removed_tag+',', ','));
      $j(this).parent().hide();
    
      resetCurrentPage(); 
      showContentLoading();
      //loadTasks();
      loadPageContent('/tasks');
    });  
  });
}

/***************** Load Tasks *****************/

function showContentLoading() {
  $j("#page-loading").show();
}

function hideContentLoading() {
  $j("#page-loading").hide();
}
function showCreateNewsFeedLoading() {
  $j(".share-footer").append("<div class='loading-container' style='float:left;width:32px;height:32px;'> <img src='/images/load36.gif' class='loading' /> <div>");
}

function hideCreateNewsFeedLoading() {
  $j(".share-footer .loading-container").detach();
}

function loadTasks(options) {
  if(options === undefined || options === null)
    options = {};
  
  if (lastPageAjaxRequest){
    lastPageAjaxRequest.abort();
    lastPageAjaxRequest = null;
  }
  $j.get('/tasks', options);
}

/************** Load Notifications ***************/
function updateNotificationsCountDisplay(){
  if (typeof($unvisited_notifications_count) !== 'undefined') {
    count = $unvisited_notifications_count;
    $j('div#navigation-content li.notification span.notification-count').html(count);
    if(count > 0){
      $j('div#navigation-content li.notification span.notification-count').show();
      $j('div#navigation-content li.notification span.notification-icon').addClass('notifications-on');
      $j('div#navigation-content li.notification span.notification-icon').removeClass('notifications-off');
    } else {
      $j('div#navigation-content li.notification span.notification-count').hide();
      $j('div#navigation-content li.notification span.notification-icon').addClass('notifications-off');
      $j('div#navigation-content li.notification span.notification-icon').removeClass('notifications-on');
    }
  }
}

function loadPageContent(url, options){
  if(options === undefined || options === null)
    options = {};
  
  if (lastPageAjaxRequest){
    lastPageAjaxRequest.abort();
    lastPageAjaxRequest = null;
  }
  $j.get(url, options);
}

function addCommentsEventsToTasksInNotification(allNotificationsIds){
  notifications_ids = allNotificationsIds.split(",");
  tasks = jQuery("#notifications-content-wrapper").find('.task');
  i = 0;
  tasks.each(function(){
    task_selector = "#notifications-content-wrapper .notification-content-"+notifications_ids[i]+" .task-unit[data-id=" + $j(this).attr('title') + "]";
    addTaskFooterEvents($j(task_selector));
    i++;
  });
}

function fixNotification(id){
  if(jQuery(".tabs-list li[class='selected']").attr('data-tasks') == "'notifications'"){
    jQuery('.notification-content-'+id).html("You accepted this request");
  }
}

/***************** Task Comments *****************/

function addTaskFooterEvents(tasks) {
  // Open/Close comments section
  tasks.find(".notes, .comment-and-motivate").click(function(e) {
    var taskItem = $j(this).closest(".task-unit");
    
    if(taskItem.find(".comments").is(':visible')) {
      taskItem.css("height", "");
      taskItem.find(".comments").hide();
    }
    else {
      taskItem.css("height", "auto");
      taskItem.find(".comments").show();
      taskItem.find(".comments comment_comment").focus();
      
      if (parseInt(taskItem.find(".motivate-count").html()) == 0)
        taskItem.find(".motivate-line").hide();
      else
        taskItem.find(".motivate-line").show();
    }    
    e.preventDefault();
  });
  
  tasks.each(function(){
    updateSubmitButtonDisplay('.task-unit[data-id=' + $j(this).attr("data-id") + ']');  
  });
  
  commentableCommentsActions(tasks);
  
  tasks.each(function(){
    $j(this).find(".motivate").click(function(){
      id = $j(this).closest(".task-unit").attr('data-id');
      $j.get("/motivatable/Task/"+id);
      return false;
    });
    
    addMoreEvents($j(this));
    
    $j(this).find(".tags,.tag-item").click(function(e){
      addTagEditorOpenCloseEvent($j(this));
    });
    
    $j(this).bind('mouseoveroutside', function(){
      hideTagEditor($j(this).find('.tag-editor'));
    });
    
    styleActionButton($j(this));
  });

  tagEditors = $j(".tag-editor");
  tagEditors.each(function(){
    $j(this).bind('clickoutside', function(){
      try{
        target = $j(event.target)
        if(!(target.hasClass('tags') || target.hasClass('tag-item')) && 
            (target.closest('.task-unit').metadata().id == $j(this).metadata().id)){
          hideTagEditor($j(this));
        }
      } catch(ex){}
    });
  });
  
  tasks.find("li.send-reminder").click(function(){
    id = $j(this).closest(".task-unit").attr('data-id');
    $j.get('/tasks/remind/'+id);
  });
}

function updateTaskReminders(taskId, remindersCount, lastReminderAt){
  reminderContainer = $j(".task-unit[data-id='"+taskId+"'] .reminder-container");
  if(!reminderContainer.is(':visible'))
    reminderContainer.show();
    
  reminderContainer.attr('title', 'Last Reminder: ' + lastReminderAt);
  reminderContainer.find('.reminder-count').text(remindersCount);
}

function styleActionButton(task){
  task.find("span.admin-menu").styledButton({
    'orientation' : 'alone',
    'dropdown' : { 'element' : 'ul' },
    'role' : 'select',
    'defaultValue' : 'default value',
    'name' : 'dummy',
    'cssClass' : 'styledButton',
    'clear' : true
  });
}

function addMoreEvents(task){
  task.find(".more").click(function(){
    buildDescription($j(this).closest('.task-unit'), $j(this).text());
  });
}

function addTagEditorOpenCloseEvent(element){
  task_id = element.closest('.task-unit').metadata().id;
  tag_editor = $j(".tag-editor[data-id='"+task_id+"']");
  tag_editor.find("input[type='text']").keyup(function(event){
    if(event.keyCode == 13){
      tag_editor.find("input[type='button']")[0].click();
    }
  });
  if(tag_editor.hasClass('hidden')){
    tag_editor.show();
    tag_editor.find("input[type='text']").focus();
    offset = $j(this).offset(); 
    tag_editor.removeClass('hidden');
    tag_editor.css('left', element.position().left - 30);
    tag_editor.css('top', element.position().top + 10);
  } else {
    hideTagEditor(tag_editor);
  }
}

function hideTagEditor(tagEditor){
  tagEditor.hide();
  tagEditor.addClass('hidden');
}

function addNewsFeedCommentsEvents(newsFeedSelector){
  var newsFeed = $j(newsFeedSelector);
  newsFeed.find(".notes").click(function(e) {
    var newsFeedItem = $j(this).closest(".newsfeed-item");
    
    if(newsFeedItem.css("height") === "auto") {
      newsFeedItem.css("height", "");
      newsFeedItem.find(".comments").hide();
    }
    else {
      newsFeedItem.css("height", "auto");
      newsFeedItem.find(".comments").show();      
    }    
    
    e.preventDefault();
  });
  
  newsFeed.each(function(){
    //showHideSubmitButton($j(this).attr("data-id"));
    updateSubmitButtonDisplay(newsFeedSelector);
  });
  
  commentableCommentsActions(newsFeed);

  newsFeed.each(function(){
    $j(this).find(".motivate-action").click(function(){
      id = $j(this).parent().parent().attr('data-id');
      $j.get("/motivatable/NewsFeed/"+id);
      return false;
    });
  });  
}

//response to motivation action
function updateMotivationDisplay(motivatableType, motivatableId, count, newAction, newMotivationLine){
  var motivation = null;
  
  //select motivation
  if(motivatableType == 'Task')
    motivation = $j(".task-unit[data-id='"+motivatableId+"']");
  else
    motivation = $j(".newsfeed-item[data-id='"+motivatableId+"']");
  //----------------------------------------------------------

  //update values
  motivation.find('.motivate').html(newAction);
  motivation.find('.motivate-count').html(count);
  //----------------------------------------------------------
  
  //update motivation line display
  motivationLine = motivation.closest('.task-unit').find('.motivate-line');
  motivationLine.replaceWith(newMotivationLine);
  //----------------------------------------------------------
  
  //update comments and motivations icons display and motivation line display
  updateCommentsMotivationsDisplay(motivation.closest('.task-unit'));
  //----------------------------------------------------------
}

function commentableCommentsActions(commentable) {
  //commentable.find(".comments form").unbind();
  
  commentable.find(".comments form").submit(function(e) {
    $j.post($j(this).attr("action"), $j(this).serialize());
    return false;
  });      
}

function replaceCommentableComments(commentableSelector, comments, commentsCount, isVisible) {
  var commentableItem = $j(commentableSelector);
  commentableItem.find(".comments").replaceWith(comments);
  if(isVisible) {
    commentableItem.css("height", "auto");
    commentableItem.find(".comments").show();
  }
  
  commentableItem.find(".comment-count").text(commentsCount);
  
  commentableCommentsActions(commentableItem);
  
  updateCommentsMotivationsDisplay(commentableItem);
}

function updateCommentsMotivationsDisplay(commentableItem){
  if(parseInt(commentableItem.find(".comment-count").html()) > 0 ||
     parseInt(commentableItem.find(".motivate-count").html()) > 0)
     commentableItem.find(".comment-and-motivate").show('slow');
  else
    commentableItem.find(".comment-and-motivate").hide('slow');
    
  if(parseInt(commentableItem.find(".motivate-count").html()) > 0)
    commentableItem.find(".motivate-line").show();
  else
    commentableItem.find(".motivate-line").hide();
}

function replaceCommentableCommentsAfterDestroy(commentableSelector, commentId, commentsCount) {
  var commentableItem = $j(commentableSelector);
  commentableItem.find(".comment-unit[data-id='"+commentId+"']").addClass('comment_removed');
  commentableItem.find(".comment-unit[data-id='"+commentId+"']").fadeOut();
  commentableItem.find(".comment-count").text(commentsCount);
  
  updateCommentsMotivationsDisplay(commentableItem);
}

function replaceEditorTagList(taggable_id, content, allTags){
  tagEditor = $j(".tag-editor[data-id='"+taggable_id+"']");
  tagEditor.find(".tag-inner-container").html(content);
  
  tagEditor.closest('.task-unit').find('.tag-item').detach();
  
  allTags = allTags.split(',');
  for(i = 0; i < allTags.length; i++){
    tagEditor.before("<span class='tag-item' data-tag='"+allTags[i]+"'>"+allTags[i]+"</span>");
    tagEditor.closest('.task-unit').find('.tag-item:last').click(function(){addTagEditorOpenCloseEvent($j(this))});
  }
  tagEditor.find("input[type='text']").val("");
  tagEditor.find("input[type='text']").focus();
}

function removeTagFromEditorTagList(taggable_id, tag){
  tagElement = $j(".task-unit[data-id='"+taggable_id+"'] .tag-word-frame[data-tag='"+tag+"']");
  // tagElement.addClass('tag-word-frame-removed'); // to turn background to red
  tagElement.animate({'opacity': '0'}, '3000', function(){$j(this).hide('slow');});
  
  tagElement.closest('.task-unit').find(".tag-item[data-tag='"+tag+"']").detach();
  
  tagEditor = $j(".tag-editor[data-id='"+taggable_id+"']");
  tagEditor.find("input[type='text']").focus();
}

function destroyComment(taskId){
  var taskItem = $j(".task-unit[data-id='" + taskId + "']");
  taskItem.height(0);
}

function updateSubmitButtonDisplay(itemSelector, keyCode) {
  var commentableItem;
  var comments_widget;
  var submit_widget;
  
  commentableItem = $j(itemSelector);
  commentableItem.each(function(){
    comments_widget = $j(this).find("#comment_comment");
    submit_widget = $j(this).find("#comment_submit");
    //expand/shrink comments box on enter ('13')/backspace ('8')
    if(keyCode == '13' || keyCode == '8'){
      txt = comments_widget.val();
      linesCount = txt.split("\n").length;
      newHeight = 16*linesCount;
      comments_widget.height(newHeight < 32 ? 32 : newHeight);
    }
      
    if(comments_widget.val()=='' || comments_widget.val()=='Add comment...'){
      submit_widget.hide();
    }
    else{
      submit_widget.show();
      submit_widget.removeAttr('disabled');
    }
  });
  
}

/***************** Requests Events *****************/

function addRequestsEvents() {
  $j(".content-right .requests-content .edit-link").click(function(){
    acceptFriendshipRequest($j(this));
  });
}

function acceptFriendshipRequest(element) {
  element.colorbox();
}

/***************** People Page Events *****************/

function addFindConnectionEvents() {
  for(i = 1; i < 5; i++){
    tab_form = '#left_tab'+i+' form'
    $j(tab_form).submit(function() {
      $j.post($j(this).attr("action"), $j(this).serialize(), function(data) {
        $j("#tab2 .results").html(data);
        $j(tab_form).resetForm().focus();
      });
      return false;
    });
  }
}

function addAllConnectionTabEvents() {
  $j(".people-tabs .tabs a[href='#tab1']").click(loadAllConnectionsTab);
  allConnectionsActions();    
}

function replaceAllConnectionsTab(content) {
  $j("#tab1").replaceWith(content);
  UI.People.actionDropDownHandlers($j, "#tab1");
  allConnectionsActions();    
}

function allConnectionsActions() {
  $j(".action .list input:checkbox").change(updateFriendPermissionList);    
}

function loadAllConnectionsTab(e) {
  var page = $j(this).metadata().page; 
  $j.get("/friendships/accepted_friends", {page: page});
  e.preventDefault();
}

function updateFriendPermissionList() {
  var tlid = $j(this).metadata().id;
  var fid = $j(this).closest(".action").metadata().id;
  
  if($j(this).is(":checked"))
    $j.post("/task_list_connections/", {tlid: tlid, fid: fid});
  else
    $j.post("/task_list_connections/" + tlid, {fid: fid, '_method': 'delete'})
}

function updateFriendPermissionListCount(fid, listCount) {
  $j(".action[data-id='" + fid + "'] .bg a").text(listCount);
}

function showHideNotificationContent(id){
    content = jQuery('.notification-content-'+id);
    c_wrapper = null;
    c_wrapper = content.parent();
    
    c_header = c_wrapper.find('.notification-header');
    if(content.is(':visible')){
      c_wrapper.height(28);
      
      c_header.removeClass('notification-wrapper-open');
      content.hide('slow');
      if(c_wrapper.find(".notification-content").hasClass('comment-notification')){
        taskItem = c_wrapper.find(".task-unit");
        taskItem.css("height", "");
        taskItem.find(".comments").hide();
      }
    } else {
      c_wrapper.height(28);
      c_wrapper.css('height', 'auto');
      c_header.addClass('notification-wrapper-open');
      content.show('slow');
      if(c_wrapper.find(".notification-content").hasClass('comment-notification')){
        taskItem = c_wrapper.find(".task-unit");
        taskItem.css("height", "auto");
        taskItem.find(".comments").show();
      }
    }
  }

/***************** Polling Events *****************/

function addPollingEvents() {
  //window.setTimeout("retreiveUpdates()", seconds(10));  
}

function retreiveUpdates() {
  $j.get("/updates", {
    complete: function() {
      window.setTimeout("retreiveUpdates()", seconds(10));
    }
  });    
}
/***************** juggernaut data event handler *****************/

function pushDataRecieved(data) {
	if (data.data_type == 'new_notifications_count') {
		$unvisited_notifications_count = data.new_notifications_count;
		updateNotificationsCountDisplay();
	} else {
		alert('not known notification')
	}
	
	
}
/***************** jQuery document ready handlers *****************/

function homeEvents() {
  addTabsListEvents(); // for me, from me, my hives tab
  addSideTabsEvents(); // All, Personal, Family, Friends tabs
  jQuery('form.jqtransform').jqTransform();
  jQuery('.row.p-rel.jqtransform').jqTransform();
  addZIndexCorrectionToItemSelect('.row.p-rel.jqtransform');
  updateNotificationsCountDisplay();
  addTaskActionEvents(); // task actions (i will, i did, i can't)
  showMeSelectEvents(); // show me select menu events
  addRequestsEvents(); // add friend requests events
  addPollingEvents();
  newTaskErrorsEvents();
  addNewTaskFormEvents(); // adding new task events
  addKeyboardActionsToJQTransform();
  addNewTaskTagsEvents();
  fixTasksAreaHeight();
  addNewTaskAsEvent();
  addUnregisteredEvents();
  addUnregisteredUserNotificationsEvents();
  addUserInfoEvents();
  
  //if($after_load_accept_friendship == 'accept_friendship')
}

function addUnregisteredEvents(){
  if($unregisteredUser){
    var evt = document.createEvent("MouseEvents");
    evt.initMouseEvent("click", true, true)
    $j(".show-me div.jqTransformSelectWrapper ul li a")[1].dispatchEvent(evt);
  }
}

function addUserInfoEvents(){
  $j('#complete-registration-wrapper input').click(function(){
    alert('signup');
  });
  
  $j('#complete-registration-wrapper a').click(function(){
    //TODO: add merge part
  });
}

function addUnregisteredUserNotificationsEvents(){
  $j(".unregistered-notification-wrapper .signup").click(function(){
    alert('signup');
  });
  
  $j(".unregistered-notification-wrapper .tour").click(function(){
    alert('tour');
  });
  
  $j("show-registration-required").colorbox();
}

function addNewTaskTagsEvents() {
	$j('.tagit-input').live('focus', function(){
		$j('.new-task-wrapper div.tagit-grand-container').addClass('focused');
	});
	
	$j('.tagit-input').live('focusout', function(){
		$j('.new-task-wrapper div.tagit-grand-container').removeClass('focused');
	});
}

function profileEvents() {
  jQuery('form.jqtransform').jqTransform();
  jQuery('.row.p-rel.jqtransform').jqTransform();
  newTaskErrorsEvents();
  addNewTaskFormEvents(); // adding new task events
  addKeyboardActionsToJQTransform();
  
  //FOR TESTING PURPOSES ONLY, TO BE DELETED ON QA REQUEST
  jQuery('#kill-current-user').click(function(){
    if(confirm('this user will be destroyed, are you sure')){
      jQuery.get("/users/sign_out");
      jQuery.post("/users/kill_me_and_sign_out");
    }
  });
}

function peopleEvents() {
  jQuery('form.jqtransform').jqTransform();
  jQuery('.row.p-rel.jqtransform').jqTransform();
  addFindConnectionEvents();  
  addAllConnectionTabEvents();
  newTaskErrorsEvents();
  addNewTaskFormEvents(); // adding new task events
  addKeyboardActionsToJQTransform();
}

//task area minimum height to be equal to the
//the height of task lists
function fixTasksAreaHeight(){
  height = $j('#side-tabs').height()+42;
  $j('#main-and-right').css('min-height', height);
}

//task area height to extend to contain all shown tasks
//in addition to a 100px margin in the bottom for loading
//icon convenience
function fixTaskAreaActualHeight(){
  $j('#main-and-right').css('height', 'auto');
  height = $j('#main-and-right').height();
  $j('#main-and-right').height(height + 100);
}

function newTaskErrorsEvents(){
  $j(".new-task-wrapper textarea").focusout(function(){
    if($j(this).val() == "")
      $j(this).addClass("new-task-text-error");
    else
      $j(this).removeClass("new-task-text-error");
  });
  
  $j(".new-task-wrapper textarea, .new-task-wrapper input[type='text']").focusin(function(){
    $j(this).removeClass("new-task-text-error");
  });
}

function addRightSideTagsEvetns(){
  $j("#right-side .tag-content .tag-box").each(function(){
    $j(this).click(function(){
      tag = $j(this).html();
      if(!tagIsPresentedInFilters(tag)){
        $j("#filter_tags").val($j("#filter_tags").val()+tag+",");
        resetCurrentPage();
        showContentLoading();
        //loadTasks();
        loadPageContent('/tasks');
      }
    });
  });
}

function tagIsPresentedInFilters(tag){
  presented = false;
  $j("#filter-tags-wrapper .tag-word-frame").each(function(){
    if(tag == $j(this).attr('data-tag'))
      presented = true;
  });
  return presented;
}

function createRightSideTags(tags){
  tags = tags.split(',');
  if(tags.length == 0)
    $j('#right-side .tag-display').hide();
  else {
    $j('#right-side .tag-display .tag-content').empty();
    $j('#right-side .tag-display').show();
    tagsElements = ""
    for(i = 0; i < tags.length; i++)
      tagsElements += "<a class='tag-box hand-pointer'>"+tags[i]+"</a>"
    $j('#right-side .tag-display .tag-content').html(tagsElements);
  }  
  
  addRightSideTagsEvetns();
  
  //fix the autocomplete list of tags
  setTagItAvailableTags(tags);
}

// for static pages (those of CMS like about-us,...
function miscEvents() {
  addNewTaskFormEvents(); // adding new task events
}

jQuery(document).ready(function($) {
  if (typeof($current_page) !== 'undefined') {
  	if ($current_page == "home") {
  		homeEvents();
  		//check if user is comming to notification page from a non-home page (profile or people)
  		pageRedirect = location.href.split('#').length > 1 ? location.href.split('#')[1] : '';
  		if (pageRedirect == 'notifications') {
  			jQuery("#tab-area a.notifications").trigger('click');
  		} else { //else check if there has been an external action (action from email)
  		  if($redirectAfterLoad == 'for_me') {
          jQuery("#tab-area a.for-me").trigger('click');
        } else if ($redirectAfterLoad == 'from_me') {
          jQuery("#tab-area a.from-me").trigger('click');
        } else if ($redirectAfterLoad == 'show_spam_report') {
          flashNotice("Task Reported As Spam");
          jQuery("#tab-area a.for-me").trigger('click');
        } else if (/profile=.*/.match($redirectAfterLoad)) {
          //redirect to profile page
          location.href = location.protocol+"//"+location.host+"/profile/"+$redirectAfterLoad.split('=')[1];
        } else {
          jQuery("#tab-area a.for-me").trigger('click');
        }
        $redirectAfterLoad = "";
  		}
  	} else if ($current_page == "profile") {
  		profileEvents();
  	} else if ($current_page == "people"){ 
  		peopleEvents();
	  }
  } else {
  	miscEvents();
  }
}); 

function validateEmail(str){
  validRegExp = /^[^@]+@[^@]+.[a-z]{2,}$/i;
  valid = true;
  
  if (str.search(validRegExp) == -1)
    valid = false;
  
  return valid;
}

function selectAll()
{
	$j("input.cheever").attr('checked', 'checked');
	$j("input.cheever").parent().addClass('checked');
}

function addKeyboardActionsToJQTransform(){
  $j('.jqTransformSelectWrapper li a').each(function(){
      $j(this).click(function(){
      $j(this).closest('ul li').removeClass("selected");
      $j(this).parent().next().addClass("selected");
    });
  });
}

String.prototype.getWidth = function(styleObject){
  var test = document.createElement("span");
  document.body.appendChild(test);
  test.style.visibility = "hidden";
  for(var i in styleObject){
    test.style[i] = styleObject[i];
  }
  test.innerHTML = this;
  var w = test.offsetWidth;
  document.body.removeChild(test);
  return w;
}
