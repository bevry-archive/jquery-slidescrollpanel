---
umd: true
---

# Import
jQuery = $ = window.jQuery or require('jquery')

# Attach
$.SlideScrollPanel = class SlideScrollPanel
	# Configuration
	config:
		# jQuery Element for our panel
		$el: null

		# jQuery Element our panel is wrapped in
		$wrap: null

		# Direction that our panel should slide in from
		direction: 'right'

		# Should we auto set the panel's width?
		autoContentWidth: true

		# Should we auto set the panel's height?
		autoContentHeight: true

		# Should we auto set the wrap's width?
		autoWrapWidth: true

		# Should we auto set the wrap's height?
		autoWrapHeight: true

		# How long should we wait on desktop devices for the user to scroll again
		disableDelay: 1*1000

		# The classname to apply to the wrapper when the panel is active
		wrapActiveClass: 'slidescrollpanel-active'

		# Styles to apply to the wrap
		wrapStyles:
			margin: 0
			padding: 0
			position: 'absolute'
			top: 0
			left: 0
			overflow: 'auto'
			'z-index': 100

		# Styles to apply to the content
		contentStyles:
			margin: 0
			padding: 0
			width: '100%'
			display: 'inline-block'

	# Construct our Slide Scroll Panel
	# Options are shallow merged (meaning styles will be replaced, rather than combined)
	constructor: (opts={}) ->
		# Dereference
		@config = JSON.parse JSON.stringify @config
		for own key,value of opts
			@config[key] = value

		# Apply
		$content = @config.$el

		# Wrapper
		if @config.$wrap
			$wrap = @config.$wrap
		else
			$wrap = $("<div/>")
			$content.wrap($wrap)
			@config.$wrap = $wrap = $content.parent()

		# Wrap
		$wrap
			# Attach
			.hide()
			.data('slidescrollpanel', @)
			.addClass("slidescrollpanel-wrap")

			# Style
			.css(@config.wrapStyles)

		# Content
		$content
			# Attach
			.data('slidescrollpanel', @)
			.addClass("slidescrollpanel-content slidescrollpanel-direction-#{@getDirection()}")

			# Style
			.css(@config.contentStyles)

		# Listeners
		@addListeners()

		# Chain
		@

	# Destroy
	destroy: =>
		# Stop listening
		@removeListeners()

		# Chain
		@

	# Remove Listeners
	removeListeners: =>
		if @isTouchDevice()
			@$getWrapper()
				.off('touchstart', @enterPanelHelper)
				.off('touchend',   @leavePanelHelper)
		else
			@$getContent()
				.off('mouseenter', @enterPanelHelper)
				.off('mouseleave', @leavePanelHelper)
			@$getWrapper()
				.off('scroll',     @leavePanelHelper)
		$(window)
			.off('resize', @resize)
		@

	# Add Listeners
	addListeners: =>
		@removeListeners()
		if @isTouchDevice()
			@$getWrapper()
				.on('touchstart', @enterPanelHelper)
				.on('touchend',   @leavePanelHelper)
		else
			@$getContent()
				.on('mouseenter', @enterPanelHelper)
				.on('mouseleave', @leavePanelHelper)
			@$getWrapper()
				.on('scroll',     @leavePanelHelper)
		$(window)
			.on('resize', @resize)
		@

	# Is touch device?
	# http://stackoverflow.com/a/4819886/130638
	isTouchDevice: ->
		return `!!('ontouchstart' in window) || !!('onmsgesturechange' in window)`


	# =================================
	# Getters

	# Get Direction
	getDirection: ->
		return @config.direction


	# ---------------------------------
	# Inverse

	# Map
	inverseMap:
		right: false
		left: true
		top: true
		bottom: false

	# Get Inverse
	isInverse: =>
		direction = @getDirection()
		inverse = @inverseMap[direction]
		return inverse


	# ---------------------------------
	# Size

	# Size Property Map
	sizePropertyMap:
		right: 'width'
		left: 'width'
		top: 'height'
		bottom: 'height'

	# Get Size Property
	getSizeProperty: =>
		direction = @getDirection()
		sizeProperty = @sizePropertyMap[direction]
		return sizeProperty

	# Get Size Value
	getSizeValue:  =>
		sizeProperty = @getSizeProperty()
		sizeValue = @$getWrapper()['outer'+sizeProperty.substr(0,1).toUpperCase()+sizeProperty.substr(1)]()
		return sizeValue


	# ---------------------------------
	# Margin

	# Margin Property Map
	marginPropertyMap:
		right: 'margin-left'
		left: 'margin-right'
		top: 'margin-bottom'
		bottom: 'margin-top'

	# Get Margin Property
	getMarginProperty: =>
		direction = @getDirection()
		marginProperty = @marginPropertyMap[direction]
		return marginProperty

	# Get Margin
	getMarginValue: =>
		marginProperty = @getMarginProperty()
		margin = @$getContent().css(marginProperty)
		return marginValue

	# Get Desired Margin Value
	getDesiredMarginValue: =>
		return @getSizeValue()

	# Get Margin Styles
	getMarginStyles: =>
		opts = {}
		opts[@getMarginProperty()] = @getMarginValue()
		return opts

	# Get Desired Margin Styles
	getDesiredMarginStyles: =>
		opts = {}
		opts[@getMarginProperty()] = @getDesiredMarginValue()
		return opts


	# ---------------------------------
	# Position

	# Position Property Map
	positionPropertyMap:
		right: 'left'
		left: 'left'
		top: 'top'
		bottom: 'top'

	# Get Position Property
	getPositionProperty: =>
		direction = @getDirection()
		positionProperty = @positionPropertyMap[direction]
		return positionProperty

	# Get Position Value
	getPositionValue: =>
		positionProperty = @getPositionProperty()
		positionValue = @$getWrapper().css(positionProperty)
		return positionValue

	# Get Show Position Value
	getShowPositionValue: =>
		positionValue = '0px'
		return positionValue

	# Get Hide Position Value
	getHidePositionValue: =>
		positionValue = @getSizeValue()+'px'
		return positionValue

	# Get Desired Position Value
	getDesiredPositionValue: =>
		positionValue = (@getShowAxisValue()-@getAxisValue())+'px'
		return positionValue

	# Get Position Styles
	getPositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = @getPositionValue()
		return opts

	# Get Desired Position Styles
	getDesiredPositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = (@getShowAxisValue()-@getAxisValue())+'px'
		return opts

	# Get Show Position Styles
	getShowPositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = @getShowPositionValue()
		return opts

	# Get Hide Props Styles
	getHidePositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = @getHidePositionValue()
		return opts


	# ---------------------------------
	# Axis

	# Axis Property Map
	axisPropertyMap:
		right: 'scrollLeft'
		left: 'scrollLeft'
		top: 'scrollTop'
		bottom: 'scrollTop'

	# Get Axis Property
	getAxisProperty: =>
		direction = @getDirection()
		axisProperty = @axisPropertyMap[direction]
		return axisProperty

	# Get Axis
	getAxisValue: =>
		axisProperty = @getAxisProperty()
		axisValue = @$getWrapper().prop(axisProperty)
		return axisValue

	# Get Show Axis Value
	getShowAxisValue: =>
		axisValue = if @isInverse() then 0 else @getSizeValue()
		return axisValue

	# Get Hide Axis Value
	getHideAxisValue: =>
		axisValue = if @isInverse() then @getSizeValue() else 0
		return axisValue

	# Get Axis Properties
	getAxisProperties: =>
		opts = {}
		opts[@getAxisProperty()] = @getAxisValue()
		return opts

	# Get Show Axis Properties
	getShowAxisProperties: =>
		opts = {}
		opts[@getAxisProperty()] = @getShowAxisValue()
		return opts

	# Get Hide Axis Properties
	getHideAxisProperties: =>
		opts = {}
		opts[@getAxisProperty()] = @getHideAxisValue()
		return opts


	# ---------------------------------
	# Elements

	# Get $wrap
	$getWrapper: =>
		$wrap = @config.$wrap
		return $wrap

	# Get $content
	$getContent: =>
		$content = @config.$el
		return $content

	# Get $el
	$getEl: =>
		return @$getContent()


	# =================================
	# Methods

	# Is Active
	active: (active) =>
		$wrap = @$getWrapper()
		if active?
			if active is true
				@enable()
			else if active is false
				@disable()
		else
			active = $wrap.hasClass(@config.wrapActiveClass)
			return active

		# Chain
		@

	# Resize
	resize: =>
		# Fetch
		$wrap = @$getWrapper()
		$content = @$getContent()
		$container = $wrap.parent()
		width = parseInt($container.css('width'), 10)
		height = parseInt($container.css('width'), 10)

		# Update Sizes
		$content.css({width})   if @config.autoContentWidth
		$content.css({height})  if @config.autoContentHeight
		$wrap.css({width})      if @config.autoWrapWidth
		$wrap.css({height})     if @config.autoWrapHeight

		# Update Margin
		$content.css(@getDesiredMarginStyles())

		# Chain
		@

	# Show Panel
	# next()
	showPanel: (next) =>
		# Prepare
		$wrap = @$getWrapper()

		# Initialize
		if $wrap.is(':visible') is false
			@resize()
			$wrap.css(opacity:0)
			@active(true)  # must be before prop set
			$wrap.prop(@getHideAxisProperties()).css(opacity:1)
		else
			@active(true)

		# Show
		$wrap.stop(true,false).animate @getShowAxisProperties(), 400, =>
			$(window).trigger('resize')
			return next?()

		# Chain
		@

	# Hide Panel
	# next()
	hidePanel: (next) =>
		# Prepare
		$wrap = @$getWrapper()

		# Hide
		@active(true)
		$wrap.stop(true,false).animate @getHideAxisProperties(), 400, =>
			# Disable
			@active(false)
			$(window).trigger('resize')
			return next?()

		# Chain
		@

	# Enable
	# z-index ordering for active items should be handled by the implementor's css
	enable: (event) =>
		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Kill Timer
		if @leavePanelHelperTimer?
			clearTimeout(@leavePanelHelperTimer)
			@leavePanelHelperTimer = null

		# Class
		$wrap.addClass(@config.wrapActiveClass).show()

		# Enable
		$wrap.css(@getShowPositionStyles())

		# Position
		cachedProperties = $wrap.data('cachedProperties')
		if cachedProperties
			$wrap.prop(cachedProperties)
			$wrap.data('cachedProperties', null)

		# Chain
		@

	# Disable
	disable: (event) =>
		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Kill Timer
		if @leavePanelHelperTimer?
			clearTimeout(@leavePanelHelperTimer)
			@leavePanelHelperTimer = null

		# Disable
		$wrap.removeClass(@config.wrapActiveClass)

		# Apply
		apply = =>
			return  if $wrap.hasClass(@config.wrapActiveClass)
			$wrap.data('cachedProperties', @getAxisProperties())
			$wrap.css(@getDesiredPositionStyles())
			$wrap.prop(@getShowAxisProperties())

		# Android has an issue where scrollLeft can only applied after a manual click event
		# so we will need to wait for a click event to happen
		isAndroid = navigator.userAgent.toLowerCase().indexOf('android')
		if event?.type is 'touchend' and isAndroid
			$(document.body).one('click', apply)
		else
			apply()

		# Chain
		@

	# Enter Panel Helper
	enterPanelHelper: (event) =>
		# Handle
		@enable(event)

		# Chain
		@

	# Leave Panel Helper
	leavePanelHelperTimer: null
	leavePanelHelper: (event,opts={}) =>
		# Handle
		active = @active()
		if active

			# Touch devices we can fire disable right away
			if @isTouchDevice()
				@disable(event)

			# Desktop devices we need to ensure:
			# 1. that we are not the initial scroll event
			# 2. that we have waited a while after the last event
			else if event.type isnt 'scroll' or @leavePanelHelperTimer?
				# Kill Timer
				if @leavePanelHelperTimer?
					clearTimeout(@leavePanelHelperTimer)
					@leavePanelHelperTimer = null

				# Create Timer
				if opts.waited isnt true
					@leavePanelHelperTimer = setTimeout(
						=> @leavePanelHelper(event, {waited:true})
						@config.disableDelay
					)
				else
					@disable(event)


			###
			offset = @getOffset()
			size =  @getSize()

			# Fetch values
			if @getInverse()
				shown = offset is 0
				over  = offset < size/2
			else
				shown = offset is size
				over  = offset > size/2

			# Same
			if shown
				# ignore

			# Still active
			else if over
				@showPanel => @$getEl().trigger('slidescrollpanelin')

			# No longer active
			else
				@hidePanel => @$getEl().trigger('slidescrollpanelout')
			###

		# Chain
		@

# jQuery Chain Method
$.fn.slideScrollPanel = (opts={}) ->
	# Prepare
	$el = $(@)

	# Attach Slide Scroll Panel
	opts.$el = $el
	slideScrollPanel = new SlideScrollPanel(opts)

	# Chain
	return $el

# Export
return SlideScrollPanel
