//this file has been edited to fix a IE support, see line 116
(function($) {

	$.fn.tagit = function(options) {

		var el = this;

		var BACKSPACE		= 8;
		var ENTER			= 13;
		var SPACE			= 32;
		var COMMA			= 44;

		// add the tagit CSS class.
		el.addClass("tagit");

		// create the input field.
		var html_input_field = "<li class=\"tagit-new\"><input class=\"tagit-input\" type=\"text\" /></li>\n";
		el.html (html_input_field);

		tag_input		= el.children(".tagit-new").children(".tagit-input");

		$(this).click(function(e){
			if (e.target.tagName == 'A') {
				// Removes a tag when the little 'x' is clicked.
				// Event is binded to the UL, otherwise a new tag (LI > A) wouldn't have this event attached to it.
				$(e.target).parent().remove();
			}
			else {
				// Sets the focus() to the input field, if the user clicks anywhere inside the UL.
				// This is needed because the input field needs to be of a small size.
				tag_input.focus();
			}
		});

		tag_input.keypress(function(event){
			if (event.which == BACKSPACE) {
				if (tag_input.val() == "") {
					// When backspace is pressed, the last tag is deleted.
					$(el).children(".tagit-choice:last").remove();
				}
			}
			// Comma/Space/Enter are all valid delimiters for new tags.
			else if (event.which == COMMA || event.which == SPACE || event.which == ENTER) {
				event.preventDefault();

				var typed = tag_input.val();
				typed = typed.replace(/,+$/,"");
				typed = typed.replace(/\n/, "");
				typed = typed.trim();

				if (typed != "") {
					if (is_new (typed)) {
						create_choice (typed);
					}
					// Cleaning the input.
					tag_input.val("");
				}
				
				// make sure we scroll to bottom
				var tagitContainer = $(this).closest('.tagit-container');			
				var ulWidth = $(this)[0].offsetLeft - tagitContainer.width()/2;
						
				toX_Str = ulWidth.toString()+'px';
				
				tagitContainer.scrollTo( { top:'0px', left:toX_Str} , 800 );

			}
		});
    /*
		tag_input.autocomplete(options.availableTags, {
			select: function(event,ui){
				if (is_new (ui.item.value)) {
					create_choice (ui.item.value);
				}
				// Cleaning the input.
				tag_input.val("");

				// Preventing the tag input to be update with the chosen value.
				return false;
			}
		});
		*/
		function is_new (value){
			var is_new = true;
			this.tag_input.parents("ul").children(".tagit-choice").each(function(i){
				n = $(this).children("input").val();
				if (value == n) {
					is_new = false;
				}
			})
			return is_new;
		}
		function create_choice (value){
			var el = "";
			el  = "<li class=\"tagit-choice\">";
			el += value;
			el += "<a class=\"close\">x</a>";
			el += "<input type=\"hidden\" style=\"display:none;\" value=\""+value+"\" name=\"item[tags][]\">";
			el += "</li>";
			var li_search_tags = this.tag_input.parent();
			$(el).insertBefore (li_search_tags);
			this.tag_input.val("");
		}
		
		initContainingDiv(this, tag_input);
	};

	String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g,"");
	};
	
	initContainingDiv = function(ul_Element, tag_input){
		$ul_Element = $(ul_Element); 
		$tag_input = tag_input
		
		// @ahed.moawad: renamed from parent to _parent because parent is reserved word in IE
		_parent = $ul_Element.parent();
		
		$newDivContainer = $('<div />').attr('class', 'tagit-container');
		
		// needed to mainain clean internals
		$newDivGrandContainer = $('<div/>').attr('class', 'tagit-grand-container');		
		
		// give the ul a large enough width
		$ul_Element.css('width', '10000px');
		
		// add the element to the div container
		$newDivContainer.append($ul_Element);
		
		$newDivGrandContainer.append($newDivContainer);
		
		// add the div to the old parent
		// @ahed.moawad: renamed from parent to _parent because parent is reserved word in IE
		_parent.append($newDivGrandContainer);
		
		//Get our elements for faster access and set overlay width
		var div = $newDivContainer;
		var ul = $ul_Element;
		
		//Remove scrollbars
		div.css({
			overflow: 'hidden'
		});
		
		//When user move mouse over menu
		div.mousemove(function(e){
			//Get menu width
			var divWidth = div.width();
		
			//Find last image container
			var lastLi = ul.find('li:last-child');
				
			//As images are loaded ul width increases,
			//so we recalculate it each time
			var ulWidth = $tag_input[0].offsetLeft + $newDivContainer.width()/1.5;
			
			var left = (e.pageX - div.offset().left) * (ulWidth - divWidth) / divWidth;
			div.scrollLeft(left);
		});
	}
})(jQuery);
