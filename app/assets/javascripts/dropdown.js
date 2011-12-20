// JavaScript Document
$j = jQuery;
$j(document).ready(function() {
  $j(".drop-down img.flag").addClass("flagvisibility");

  $j(".drop-down dt a").click(function() {
    $j(".drop-down dd ul").toggle();
  });
              
  $j(".drop-down dd ul li a").click(function() {
    var text = $j(this).html();
    $j(".drop-down dt a span").html(text);
    $j(".drop-down dd ul").hide();
    $j("#result").html("Selected value is: " + getSelectedValue("sample"));
  });
              
  function getSelectedValue(id) {
    return $j("#" + id).find("dt a span.value").html();
  }
  
  $j(document).bind('click', function(e) {
    var $clicked = $j(e.target);
    if (! $clicked.parents().hasClass("drop-down"))
        $j(".drop-down dd ul").hide();
  });
  
  $j("#flagSwitcher").click(function() {
    $j(".drop-down img.flag").toggleClass("flagvisibility");
  });
});