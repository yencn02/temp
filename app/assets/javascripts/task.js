/**
 * @author mostafaali
 */

  function initTask(task, isPrivate, showSpam, userMarkedAsSpam,
                    changeSpamStateToSpamUrl, changeSpamStateToNotSpamUrl){
	  taskMenu =  $j('.task-menu', task);
	  iKnowLink = $j('.i-know-link', task);
	  iDontKnowLink =  $j('.i-dont-know-link', task);
	  
	  initMenu(taskMenu, isPrivate);
	  initSpamLinkEvents(iKnowLink, changeSpamStateToNotSpamUrl, 
	                     iDontKnowLink, changeSpamStateToSpamUrl);
    if(showSpam == "true") //showSpam is text not boolean
      task.find(".task-buttons").hide();
    else
      task.find(".task-buttons-spam-actions").hide();
    
    if(userMarkedAsSpam == "true")  //userMarkedAsSpam is text not boolean
      task.find(".spam-flag").show();

    buildDescription(task);
  }
  
  function buildDescription(task, moreOrLess){
    //building description
    descContainer = $j('.discription div', task);
    fullDesc = $j('.discription input', task).val();
    tagsRegEx1 = new RegExp();
    tagsRegEx2 = new RegExp();
    tagsRegEx1.compile("\<([^\>]+)\>");   //regex for tag opening e.g. <div>
    tagsRegEx2.compile("\</([^\>]+)\>");  //regex for tag closing e.g. </div>
    desc = fullDesc.replace(tagsRegEx1, ""); //remove tag opening
    desc = desc.replace(tagsRegEx2, ""); //remove tag closing
    
    //creating links for 
    linkRegEx = new RegExp();
    linkRegEx.compile("(^[A-Za-z]+://)?[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\?\/.=]+$"); //regex for links
    newDesc = "";
    desc = desc.split(" ");
    for(i = 0; i < desc.length; i++){
      if(linkRegEx.test(desc[i])){
        protocol = ""
        if(desc[i].indexOf("://") < 0) //if url doesn't contain a protocol (http, https, ftp,...) 
          protocol = "http://"
        newDesc += "<a href='"+protocol+desc[i]+"' target='_blank' class='link-inside-decription'>"+desc[i]+"</a> "  
      } else {
        newDesc += desc[i] + " "
      }
    }
            
    shortDesc = newDesc.substring(0,119) + "...";

    if(newDesc.length > 120)
      descContainer.addClass('large');

    if(descContainer.hasClass('large')){
      task.find(".more").remove();
      if(moreOrLess == 'more'){
        descContainer.html(newDesc);
        descContainer.after("<a class='hand-pointer more'>less</a>");
      } else {
        descContainer.html(shortDesc);
        descContainer.after("<a class='hand-pointer more'>more</a>");
      }
      addMoreEvents(task);
    }
    else
      descContainer.html(newDesc);
  }
  
  function initSpamLinkEvents(iKnowLink, changeSpamStateToNotSpamUrl,
                              iDontKnowLink, changeSpamStateToSpamUrl){
    iKnowLink.click(function(){
      $taskUnit = $j(this).closest('.task-unit');
	    $j('.task-spam-loading', $taskUnit).show();
	    $j.post(changeSpamStateToNotSpamUrl);
    });
    
    iDontKnowLink.click(function(){
      $taskUnit = $j(this).closest('.task-unit');
	    $j('.task-spam-loading', $taskUnit).show();
	    $j.post(changeSpamStateToSpamUrl);
    });
  } 
  
  function initMenu(taskMenu, isPrivate){
  	if (taskMenu && taskMenu.length > 0) {
  		if (isPrivate == "true") { //isPrivate is a text not a boolean
  			setLocked($j(taskMenu[0]));
  		} else {
  			setUnlocked($j(taskMenu[0]));
  		}
  	}
  }
    
  function togglePrivacy(el){
    $el = $j(el)
    task_id = $j(el).closest(".task-unit").metadata().id;
    $j.post('/tasks/'+task_id+'/toggle_privacy');
    taskMenu = $el.closest('.task-menu');
    
    if(el.className == "lock") {
      setUnlocked(taskMenu);  
    } else {
      setLocked(taskMenu);
    }
  }
  
  function setLocked($el){
    $el.find('.unlocked').hide();
    $el.find('.locked').show();
  }
  
  function setUnlocked($el){
    $el.find('.unlocked').show();
    $el.find('.locked').hide();
  }
  