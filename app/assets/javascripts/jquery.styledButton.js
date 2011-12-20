/* Copyright (c) 2009 Swizec Teller (swizec AT swizec DOT com || http://www.swizec.com)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * See http://swizec.com/code/styledButton/
 */

jQuery.fn.styledButton = function ( params )
{
	return jQuery(this).each( function ()
	{
		var tempParams = jQuery.extend( {}, params );
		var button = new styledButton( jQuery(this), tempParams );
	} );
}

function styledButton( element, params )
{
	this.element = element;
	this.oldFirefox = ( jQuery.browser.mozilla && parseFloat( jQuery.browser.version ) < 1.9 );
	this.safari3 = ( jQuery.browser.safari && parseFloat( jQuery.browser.version ) < 526 ) ? true : false;
	this.inlineBlock = ( this.oldFirefox ) ? '-moz-inline-block' : 'inline-block';
	this.inParams = params;
	this.params = this.setupDefaultParams( params );

	if ( !this.element.hasClass( this.params.cssClass ) )
	{
		this.info = this.init();
		this.bordersAndBackground();
		this.setupRole();
	}
}

styledButton.prototype.setupDefaultParams = function ( params )
{
	if ( typeof( params ) == "undefined" )
	{
		params = {};
	}
	if ( typeof( params.orientation ) == "undefined" )
	{
		params.orientation = 'alone';
	}
	if ( typeof( params.action ) == "undefined" )
	{
		params.action = function () {};
		params.onclick = function () {};
	}else
	{
		params.onclick = params.action;
	}
	if ( typeof( params.cssClass ) == "undefined" )
	{
		params.cssClass = "button";
	}
	if ( typeof( params.role ) == "undefined" )
	{
		params.role = 'button';
	}
	if ( typeof( params.defaultValue ) == "undefined" )
	{
		params.defaultValue = '';
	}
	if ( params.role == "checkbox" )
	{
		if ( typeof( params.checkboxValue ) != "object" )
		{
			if ( params.defaultValue != '' )
			{
				var tmp = params.defaultValue;
			}else
			{
				var tmp = 'on';
			}
			params.checkboxValue = {};
			params.checkboxValue.on = tmp;
			params.checkboxValue.off = 'off';
		}
		if ( typeof( params.checked ) == "undefined" )
		{
			params.defaultValue = params.checkboxValue.off;
			params.checked = false;
		}else
		{
			params.checked = true;
			params.defaultValue = params.checkboxValue.on;
		}
		params.toggle = true;
		params.action = {};
		params.action.on = function ( calledOn ) { jQuery(calledOn).styledButtonSetValue( params.checkboxValue.on ) };
		params.action.off = function ( calledOn ) { jQuery(calledOn).styledButtonSetValue( params.checkboxValue.off ) };
	}
	if ( params.toggle )
	{
		if ( typeof( params.action ) != "object" )
		{
			var tmp = params.action;
			params.action = {};
			params.action.on = tmp;
			params.action.off = tmp;
		}


		params.onclick = {};
		params.onclick.on = function ( event ) {
						jQuery(this).styledButtonActivate( event );
						params.action.on( jQuery(this) )
					};
		params.onclick.off = function ( event ) {
						jQuery(this).styledButtonDeactivate( event );
						params.action.off( jQuery(this) )
					};
	}
	if ( typeof( params.dropdown ) == "undefined" )
	{
		params.hasDropdown = false;
		params.dropdown = {};
	}else
	{
		params.hasDropdown = true;
		if ( typeof( params.dropdown ) != 'object' )
		{
			params.dropdown = {};
		}
		if ( typeof( params.dropdown.element ) == "undefined" )
		{
			params.dropdown.element = 'ul';
		}
		if ( typeof( params.action ) != "object" )
		{
			var tmp = params.action;
			params.action = {};
			params.action.on = tmp;
			params.action.off = tmp;
		}

		params.toggle = true;
		params.onclick = {};
		params.onclick.on = function ( event ) {
						jQuery(this).styledButtonActivate();
						jQuery(this).styledButtonDropDownActivate();
					};
		params.onclick.off = function ( event ) {
						jQuery(this).styledButtonDeactivate();
						jQuery(this).styledButtonDropDownDeactivate();
					};
	}
	if ( typeof( params.display ) == "undefined" )
	{
		params.display = this.inlineBlock;
	}
	if ( typeof( params.border ) == "undefined" )
	{
		params.border = 1;
	}

	return params;
}

styledButton.prototype.init = function ( )
{
	var element = this.element;
	var params = this.params;

	if ( !jQuery(this).is( '.'+params.cssClass ) )
	{
		element.addClass( params.cssClass );
	}
	element.addClass( "parent" );
	element.val( params.defaultValue );

	// this is here because otherwise sizes get calculated wrongly
	if ( params.hasDropdown )
	{
		this.hideDropdown();
	}

	var oldContent = element.html();
	var width = element.outerWidth();
	var height = element.outerHeight();
	var padding = {
			top: (element.outerHeight()-element.height())/2,
			left: (element.outerWidth()-element.width())/2
		}
	var innerLeft = 0;

	if ( this.safari3 )
	{
		innerLeft = -4;
	}else if ( jQuery.browser.safari && params.hasDropdown )
	{
		if ( params.hasDropdown )
		{
			width += padding.left;
		}
	}

	if ( jQuery.browser.msie )
	{
		if ( params.orientation == 'right' || params.orientation == 'center' )
		{
			innerLeft = -1;
		}
		if ( params.hasDropdown )
		{
			height -= 1;
		}
	}

	element.wrapInner( jQuery('<span></span>').css({
							'padding' : padding.top+'px 0px '+padding.top+'px '+padding.left+'px',
							'margin' : 0,
							'z-index' : 1,
							'position' : 'absolute',
							'left' : innerLeft+'px',
							'display' : this.inlineBlock,
							'-moz-user-select' : 'none'
						})
		 			);

	var widthDelta = 0;
	if ( this.oldFirefox && params.orientation == 'right' )
	{
		widthDelta = 4;
	}

	element.css( {
		'cursor' : 'pointer',
		'padding-right': 0,
		'margin-left' : '-1px',
		'display' : params.display,
		'width' : width-padding.left+1+widthDelta
	} )
	.hover( function () {
			if ( !jQuery(this).hasClass( 'hover' ) )
			{
				jQuery(this).addClass( 'hover' );
				jQuery(this).contents().styledButtonHover();
			}
		},
		function () {
			jQuery(this).removeClass( 'hover' );
			jQuery(this).removeClass( 'down' );
			jQuery(this).contents().styledButtonUnhover();
		})
	.mousedown( function () {
			if ( !jQuery(this).hasClass( 'down' ) )
			{
				jQuery(this).addClass( 'down' );
				jQuery(this).contents().styledButtonMouseDown();
			}
		})
	.mouseup( function () {
			jQuery(this).removeClass( 'down' );
			jQuery(this).contents().styledButtonMouseUp();
		});

	if ( this.oldFirefox && params.display != 'block' )
	{
		element.css({
			'float' : 'left',
			'clear' : ( params.clear ) ? params.orientation : 'none',
			'margin-top' : ( params.clear ) ? '1em' : 0
		});
	}

	if ( !params.toggle )
	{
		element.click( params.onclick );
	}else
	{
		if ( params.checked )
		{
			element.toggle( params.onclick.off, params.onclick.on );
		}else
		{
			element.toggle( params.onclick.on, params.onclick.off );
		}
	}

	var info = { 'oldContent' : oldContent, 'width' : width, 'height' : height, 'padding' : padding, 'border' : params.border };

	return info;
}

styledButton.prototype.bordersAndBackground = function ()
{
	var element = this.element;
	var params = this.params;
	var info = this.info;

	info.sizeDelta = 0;
	if ( jQuery.browser.msie )
	{
		info.sizeDelta = info.border*2;
	}

	if ( params.orientation == 'left' )
	{
		this.background( {
				'width' : (info.width-info.border),
				'height' : info.height,
				'border' : info.border,
				'sizeDelta' : info.sizeDelta
			});
		this.bordersLeft( info );
	}else if ( params.orientation == 'center' )
	{
		this.background( {
				'width' : (info.width-info.border*2),
				'height' : info.height,
				'marginLeft' : info.border,
				'border' : info.border,
				'sizeDelta' : info.sizeDelta
			});
		this.bordersCenter( info );
	}else if ( params.orientation == 'right' )
	{
		this.background( {
				'width' : (info.width-info.border),
				'height' : info.height,
				'marginLeft' : info.border,
				'border' : info.border,
				'sizeDelta' : info.sizeDelta
			});
		this.bordersRight( info );
	}else if ( params.orientation == 'alone' )
	{
		this.background( info );
		this.bordersAlone( info );
	}
}

styledButton.prototype.background = function ( info )
{
	var element = this.element;
	var marginLeft = ( typeof( info.marginLeft ) != "undefined" ) ? info.marginLeft : 0;

	element.append( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : info.height,
							'z-index' : 0,
							'position' : 'absolute',
							'display' : this.inlineBlock,
							'margin-left' : marginLeft,
							'padding' : 0
						})
						.attr( 'class', 'background main' )
					);
	element.append( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : Math.floor( 4*info.height/10 )-info.sizeDelta,
							'font-size' : Math.floor( 4*info.height/10 )-info.sizeDelta,
							'z-index' : 0,
							'position' : 'absolute',
							'top' : 0,
							'display' : this.inlineBlock,
							'margin-left' : marginLeft
						})
						.attr( 'class', 'background top' )
					);
	element.append( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : Math.floor( 5*info.height/10 )-info.sizeDelta,
							'font-size' : Math.floor( 5*info.height/10 )-info.sizeDelta,
							'z-index' : 0,
							'position' : 'absolute',
							'bottom' : 0,
							'margin-top' : Math.floor( 5*info.height/10 )-info.sizeDelta,
							'margin-left' : marginLeft,
							'display' : this.inlineBlock
						})
						.attr( 'class', 'background bottom' )
					);
}

styledButton.prototype.bordersAlone = function ( info )
{
	var element = this.element;

	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : info.height+info.sizeDelta,
							'margin' : (-info.border)+'px 0 0 0',
							'display' : this.inlineBlock,
							'position' : 'absolute',
							'background' : 0,
							'border-left' : '0px',
							'border-right' : '0px'
						})
						.attr( 'class', 'border top' )
					);
	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width+info.sizeDelta,
							'height' : info.height,
							'margin' : (-info.padding.top+1)+'px 0px 0px '+(-info.padding.left)+'px',
							'display' : this.inlineBlock,
							'border-top' : '0px',
							'border-bottom' : '0px'
						})
						.attr( 'class', 'border side' )
					);
}

styledButton.prototype.bordersLeft = function ( info )
{
	var element = this.element;

	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : info.height+info.sizeDelta,
							'margin' : (-info.border)+'px 0 0 0',
							'display' : this.inlineBlock,
							'position' : 'absolute',
							'background' : 0,
							'border-left' : '0px',
							'border-right' : '0px'
						})
						.attr( 'class', 'border top' )
					);
	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width-info.border+info.sizeDelta,
							'height' : info.height,
							'margin' : (-info.padding.top+info.border)+'px 0px 0px '+(-info.padding.left)+'px',
							'display' : this.inlineBlock,
							'border-top' : '0px',
							'border-bottom' : '0px'
						})
						.attr( 'class', 'border side left' )
					);
}

styledButton.prototype.bordersCenter = function ( info )
{
	var element = this.element;

	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : info.height+info.sizeDelta,
							'margin' : (-info.border)+'px 0 0 '+(-info.border)+'px',
							'display' : this.inlineBlock,
							'position' : 'absolute',
							'background' : 0,
							'border-left' : '0px',
							'border-right' : '0px'
						})
						.attr( 'class', 'border top' )
					);
	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width-info.border*2+info.sizeDelta,
							'height' : info.height,
							'margin' : (-info.padding.top+info.border)+'px 0px 0px '+(-info.padding.left+info.border)+'px',
							'display' : this.inlineBlock,
							'border-top' : '0px',
							'border-bottom' : '0px'
						})
						.attr( 'class', 'border side center' )
					);
}

styledButton.prototype.bordersRight = function ( info )
{
	var element = this.element;

	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width,
							'height' : info.height+info.sizeDelta,
							'margin' : (-info.border)+'px 0 0 '+(-info.border)+'px',
							'display' : this.inlineBlock,
							'position' : 'absolute',
							'background' : 0,
							'border-left' : '0px',
							'border-right' : '0px'
						})
						.attr( 'class', 'border top' )
					);
	element.wrapInner( jQuery('<span></span>').css({
							'width' : info.width-info.border+info.sizeDelta,
							'height' : info.height,
							'margin' : (-info.padding.top+info.border)+'px 0px 0px '+(-info.padding.left+info.border)+'px',
							'display' : this.inlineBlock,
							'border-top' : '0px',
							'border-bottom' : '0px'
						})
						.attr( 'class', 'border side right' )
					);
}

styledButton.prototype.hideDropdown = function ()
{
	var element = this.element;

	while ( !element.is( this.params.dropdown.element ) && element.contents().size() > 0 )
	{
		element = element.contents();
	}
	if ( element.is( this.params.dropdown.element ) )
	{
		for ( var i = 0; i < element.size(); i += 1 )
		{
			if ( element.eq( i ).is( this.params.dropdown.element ) )
			{
				element.eq( i ).css({ "display" : "none" });
			}
		}
	}
}

styledButton.prototype.setupRole = function ()
{
	var element = this.element;
	var params = this.params;

	element.attr( "role", params.role);

	if ( params.role != "button" )
	{
		element.append( '<input type="hidden" value="'+params.defaultValue+'" name="'+params.name+'"/>' );
	}

	if ( params.hasDropdown )
	{
		this.setupDropDown();
	}
	if ( params.role == "select" )
	{
		this.setupRoleSelect();
	}
	if ( params.role == "checkbox" && params.checked )
	{
		element.styledButtonActivate();
	}
}

styledButton.prototype.setupDropDown = function ()
{
	var element = this.element;
	var params = this.params;
	var info = this.info;

	while ( !element.is( params.dropdown.element ) && element.contents().size() > 0 )
	{
		element = element.contents();
	}

	var marginDelta = -1;
	if ( this.safari3 )
	{
		marginDelta = 3;
	}

	var topDelta = 0;
	var widthDelta = -4;
	if ( jQuery.browser.msie )
	{
		topDelta = info.padding.top*3+params.border;
		widthDelta = 1;
	}

	if ( element.is( params.dropdown.element ) )
	{
		for ( var i = 0; i < jQuery(element).size(); i += 1 )
		{
			if ( element.eq( i ).is( this.params.dropdown.element ) )
			{
				element.eq( i ).addClass( "dropdown" )
				.css( {
					'display' : 'none',
					'position' : 'absolute',
					'left' : '0px',
					'margin' : (info.padding.top+topDelta)+'px 0px 0px '+marginDelta+'px',
					'width' : info.width+widthDelta,
					'padding-right' : 0,
					'z-index' : 3
				});
			}
		}
	}
}

styledButton.prototype.setupRoleSelect = function ()
{
	var element = this.element;
	var params = this.params;
	var info = this.info;

	while ( !element.is( params.dropdown.element ) && element.contents().size() > 0 )
	{
		element = element.contents();
	}

	if ( element.is( params.dropdown.element ) )
	{
		for ( var i = 0; i < element.size(); i += 1 )
		{
			if ( element.eq( i ).is( this.params.dropdown.element ) )
			{
				element.eq( i ).children().click( function () {
						var value = jQuery(this).attr( "value" );
						if ( typeof( value ) != "string" )
						{
							value = jQuery(this).html();
						}
						jQuery(this).styledButtonSetValue( value );
					} );
			}
		}
	}
}

//
// behaviour functions
//

jQuery.fn.styledButtonSetValue = function ( value )
{
	var element = jQuery(this);

	while ( !element.is( ".parent" ) && element.parent().size() > 0 )
	{
		element = element.parent();
	}

	jQuery(element).val( value );
	if ( !jQuery.browser.msie )
	{
		jQuery(element).change();
	}

	while ( !element.is( "input" ) && element.contents().size() > 0 )
	{
		element = element.contents();
	}

	jQuery(element).val( value )
}

jQuery.fn.styledButtonHover = function ()
{
	jQuery(this).addClass( 'hover' );

	if ( jQuery(this).children().size() > 0 )
	{
		jQuery(this).children().styledButtonHover();
	}
}

jQuery.fn.styledButtonUnhover = function ()
{
	jQuery(this).removeClass( 'hover' );
	jQuery(this).removeClass( 'down' );

	if ( jQuery(this).contents().size() > 0 )
	{
		jQuery(this).contents().styledButtonUnhover();
	}
}

jQuery.fn.styledButtonMouseDown = function ()
{
	jQuery(this).addClass( 'down' );

	if ( jQuery(this).contents().size() > 0 )
	{
		jQuery(this).contents().styledButtonMouseDown();
	}
}

jQuery.fn.styledButtonMouseUp = function ()
{
	jQuery(this).removeClass( 'down' );

	if ( jQuery(this).contents().size() > 0 )
	{
		jQuery(this).contents().styledButtonMouseUp();
	}
}

jQuery.fn.styledButtonActivate = function ()
{
	jQuery(this).addClass( 'active' );

	if ( jQuery(this).contents().size() > 0 )
	{
		jQuery(this).contents().styledButtonActivate();
	}
}

jQuery.fn.styledButtonDeactivate = function ()
{
	jQuery(this).removeClass( 'active' );

	if ( jQuery(this).contents().size() > 0 )
	{
		jQuery(this).contents().styledButtonDeactivate();
	}
}

jQuery.fn.styledButtonDropDownActivate = function ()
{
	if ( !jQuery(this).is( '.dropdown' ) )
	{
		jQuery(this).children().styledButtonDropDownActivate();
	}else
	{
		for ( var i = 0; i < jQuery(this).size(); i += 1 )
		{
			if ( jQuery(this).eq( i ).is( ".dropdown" ) )
			{
				if ( jQuery.browser.msie )
				{
					jQuery(this).eq( i ).css( "display", "block" );
				}else
				{
					jQuery(this).eq( i ).slideDown( 60 );
				}
			}
		}
	}
}

jQuery.fn.styledButtonDropDownDeactivate = function ()
{
	if ( !jQuery(this).is( '.dropdown' ) )
	{
		jQuery(this).contents().styledButtonDropDownDeactivate();
	}else
	{
		for ( var i = 0; i < jQuery(this).size(); i += 1 )
		{
			if ( jQuery(this).eq( i ).is( ".dropdown" ) )
			{
				if ( jQuery.browser.msie )
				{
					jQuery(this).eq( i ).css( "display", "none" );
				}else
				{
					jQuery(this).eq( i ).slideUp( 20 );
				}
			}
		}
	}
}
