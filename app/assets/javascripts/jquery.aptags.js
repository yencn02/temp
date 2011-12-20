/**
 * jQuery.fn.aptags - Tag box useful for placement on a form for entering arbitrary
 * tagging information.
 * 
 * http://www.adampresley.com
 * 
 * This file is part of jQuery.aptags.
 *
 * jQuery.aptags is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * jQuery.aptags is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with jQuery.aptags.  If not, see <http://www.gnu.org/licenses/>.
 *  
 * @author Adam Presley
 * @copyright Copyright (c) 2009 Adam Presley
 * @param {Object} config
 */
jQuery.fn.aptags = function(config) {
	
	__c = jQuery.extend({
		hiddenFieldName: '__aptags_value',
		tagDivName: 'tagbox',
		value: '',
		minTagLength: 1,
		
		minTagLengthMessage: 'Tag does not meet the minimum requirements',
		duplicateTagMessage: 'Tag already selected'
	}, config);
	
	function __createSpans(el, v, __c, f)
	{
		var r1 = /%replace%/g;
		
		var values = [];
		var o = 0;
		var i = 0;
		
		var s = '';
		var shtml = '<span class="apTagSpan" name="aptags_span_%replace%" id="aptags_span_%replace%"><a href="javascript:void(0);">%replace%</a></span>';
		
		//
		// Fire the event saying we are going to add a tag.
		//
		$(el).trigger('beforeTagAdded', v);
		
		//
		// Get the values from the box.
		//
		values = v.split(',');

		for (o = 0; o < values.length; o++)
		{
			v = values[o];
			s = shtml.replace(r1, v);
	
			//
			// Validate the entry.
			//
			if (v.length < __c.minTagLength) 
			{
		  		$(el).trigger('tagError', __c.minTagLengthMessage);
				return false;
			}
		  
			if (f) 
			{
			  	c = $('#' + __c.hiddenFieldName).val().split(',');
			  	for (i = 0; i < c.length; i++) 
				{
			  		if (c[i] == v) 
					{ 	  		
						$(el).trigger('tagError', __c.duplicateTagMessage);
						return false; 
					}
			  	}
		  	}
		  
			//
			// Put it in the hidden field.
			//
			$('#' + __c.hiddenFieldName).val($('#' + __c.hiddenFieldName).val() + (($('#' + __c.hiddenFieldName).val().length) ? ',' : '') + v);
			$(el).val('').focus();
			
			//
			// Add this to the visual div.
			//
			$('#' + __c.tagDivName).append(s).bind('click', { __c: __c, el: el }, function(e) {
				var el = $(e.target).parent();
				var v = $(e.target).html();
				var values = $('#' + e.data.__c.hiddenFieldName).val().split(',');
				var i = 0;
				
				//
				// Fire the event saying we are going to remove a tag.
				//
				$(e.data.el).trigger('beforeTagRemoved', v);
				
				el.remove();
				
				//
				// Remove item from hidden field.
				//
				for(i = 0; i < values.length; i++)
				{
					if (values[i] == v)
					{
						values.splice(i, 1);
						break;
					}
				}
				
				//
				// Put the new set back.
				//
				$('#' + e.data.__c.hiddenFieldName).val(values.join(','));
	
				//
				// Fire the event saying we removed a tag.
				//
				$(e.data.el).trigger('tagRemoved', v);
			
				$(e.data.el).focus();
			});

			//
			// Fire the event saying we added a tag.
			//
			$(el).trigger('tagAdded', v);
		}
	}
	
	return this.each(function() 
	{
		//
		// Issue: http://plugins.jquery.com/node/10903
		// Multiple calls to component creates multiple DOM elements with
		// same name/id.
		//
		if ($('#' + __c.hiddenFieldName).length <= 0)
		{
			//
			// Create our hidden field for posting values to.
			//
			var t = '<input type="hidden" name="' + __c.hiddenFieldName + '" id="' + __c.hiddenFieldName + '" value="" />';
			$(this).after(t);
			
			//
			// Create a div to put the tags into visually.
			//
			var d = '<div name="' + __c.tagDivName + '" id="' + __c.tagDivName + '" class="apTagDiv" />';
			$(this).after(d);
		}
		
		if (__c.value.length > 0)
		{
			var values = __c.value.split(',');
			var i = 0;
			
			//
			// Issue: http://plugins.jquery.com/node/10903
			// Clear existing spans.
			//
			$('.apTagSpan').remove();
			
			for (i = 0; i < values.length; i++) 
			{
		 		__createSpans(this, values[i], __c, false);
		 	}
		}
		
		//
		// Hook to the keypress event.
		//
		$(this).bind('keypress', { __c: __c }, function(e) {
			
			var c = '';
			var i = 0;
			
			var v = $(this).val();
			
			if (e.keyCode == 13)
			{
				e.stopPropagation();
				e.preventDefault();
				
				__createSpans(this, v, e.data.__c, true);
			}
			
		});
	});
	
};
