$j = jQuery;

function checkScroll() {
  if($currentPage < $totalPages){
    if (nearBottomOfPage()) {
      incrementCurrentPage();
      showContentLoading();
      fixTaskAreaActualHeight();
      
      if(selectedTabList() == "notifications")
        loadPageContent('/notifications')
      else
        loadPageContent('/tasks');
    } else {
      setTimeout("checkScroll()", 250);
    }
  } else {
    hideContentLoading();
  }
}

function nearBottomOfPage() {
  isNear = scrollDistanceFromBottom() <= 150;
  return isNear;
}

function scrollDistanceFromBottom(argument) {
  var pageY;
  var innerHeight;
  
  if(window.pageYOffset)
     pageY=window.pageYOffset;
  else
     pageY=document.documentElement.scrollTop;
  
  if(window.innerHeight)
    innerHeight = window.innerHeight;
  else
    innerHeight = document.documentElement.clientHeight
  
  return pageHeight() - (pageY + innerHeight);
}

function pageHeight() {
  return Math.max(document.body.scrollHeight, document.body.offsetHeight);
}

jQuery(document).ready(function($) { 
	checkScroll(); 
});