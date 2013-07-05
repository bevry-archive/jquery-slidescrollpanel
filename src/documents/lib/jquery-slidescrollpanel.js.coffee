---
umd: true
---

# Import
jQuery = $ = window.jQuery or require('jquery')

# Attach
$.SlideScrollPanel = class SlideScrollPanel
	# Configuration
	config:
		# Debug
		debug: false

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

		# The classname to apply to the wrapper when the panel is visible
		wrapVisibleClass: 'slidescrollpanel-visible'

		# Auto Show Above Percentage
		autoShowAbove: 0.7

		# Auto Hide Below Percentage
		autoHideBelow: 0.3

		# Keep Visible By
		keepVisibleBy: false

		# Force the wrapper to be position by this property instead of the default
		forcedPositionProperty: false

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

	# Log
	log: (args...) =>
		# Log
		if @config.debug
			if false
				$('.demo-description').append('<div>'+JSON.stringify(args)+'</div>')
			else if console?.log?
				console.log.apply(console, args)
			else
				alert JSON.stringify(args)

		# Chain
		@

	# Remove Listeners
	removeListeners: =>
		if @isTouchDevice()
			@$getWrapper()
				.off('touchmove',  @enterPanelHelper)
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
				.on('touchmove',  @enterPanelHelper)
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
		sizeValue = @$getWrapper()['inner'+sizeProperty.substr(0,1).toUpperCase()+sizeProperty.substr(1)]()
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
		positionProperty = @config.forcedPositionProperty or @positionPropertyMap[@getDirection()]
		return positionProperty

	# Is Position Inverted
	isPositionInverted: =>
		positionInverted = @config.forcedPositionProperty and @config.forcedPositionProperty isnt @positionPropertyMap[@getDirection()]
		return positionInverted

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
	getHidePositionValue: (invertCheck=true) =>
		positionValue = @getSizeValue()
		positionValue *= -1  if @isInverse()
		positionValue *= -1  if invertCheck and @isPositionInverted()
		positionValue += 'px'
		return positionValue

	# Get Desired Position Value
	getDesiredPositionValue: =>
		positionValue = (@getShowAxisValue()-@getAxisValue())
		positionValue *= -1  if @isPositionInverted()
		positionValue += 'px'
		return positionValue

	# Get Position Percent
	getPositionPercent: =>
		percentVisible = 1 - parseInt(@getPositionValue(), 10) / parseInt(@getHidePositionValue(false), 10)
		return percentVisible

	# Get Position Styles
	getPositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = @getPositionValue()
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

	# Get Desired Position Styles
	getDesiredPositionStyles: =>
		opts = {}
		opts[@getPositionProperty()] = @getDesiredPositionValue()
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

	# Get Desired Axis Value
	getDesiredAxisValue: =>
		if @isInverse()
			axisValue = parseInt(@getShowPositionValue(), 10) - parseInt(@getPositionValue(), 10)
		else
			if @isPositionInverted()
				axisValue = parseInt(@getPositionValue(), 10) - parseInt(@getHidePositionValue(), 10)
			else
				axisValue = parseInt(@getHidePositionValue(), 10) - parseInt(@getPositionValue(), 10)
		return axisValue

	# Get Axis Percent
	getAxisPercent: =>
		if @isInverse()
			percentVisible = 1 - @getAxisValue() / @getHideAxisValue()
		else
			percentVisible = @getAxisValue() / @getShowAxisValue()
		return percentVisible

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

	# Get Desired Axis Properties
	getDesiredAxisProperties: =>
		opts = {}
		opts[@getAxisProperty()] = @getDesiredAxisValue()
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
	isActive: =>
		active = @$getWrapper().hasClass(@config.wrapActiveClass)
		return active
	isInactive: =>
		return @isActive() is false

	# Is Visible
	isVisible: (active) =>
		active = @$getWrapper().hasClass(@config.wrapVisibleClass)
		return active
	isInvisible: =>
		return @isVisible() is false

	# Resize
	resize: =>
		# Fetch
		$wrap = @$getWrapper()
		$content = @$getContent()
		$container = $wrap.parent()
		width = parseInt($container.css('width'), 10)
		height = parseInt($container.css('height'), 10)

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
		# Log
		@log 'showPanel'

		# Prepare
		$wrap = @$getWrapper()

		# Prepare
		$wrap.show()
		@resize()

		# Init
		if @isInvisible()
			# $wrap.prop(@getHideAxisProperties())
			# $wrap.css(@getShowPositionStyles())
			$wrap.css(@getHidePositionStyles())
			$wrap.prop(@getShowAxisProperties())
		else
			# @enable(null, {alterClass:false})
			@disable()

		# Animate
		# animateOpts = @getShowAxisProperties()
		animateOpts = @getShowPositionStyles()
		$wrap.stop(true,false).animate animateOpts, 400, =>
			$wrap.addClass(@config.wrapVisibleClass)
			if @isTouchDevice()
				@disable()
			else
				@enable()
			$(window).trigger('resize')
			@$getEl().trigger('slidescrollpanelin')
			return next?()

		# Chain
		@

	# Hide Panel
	# next()
	hidePanel: (next) =>
		# Log
		@log 'hidePanel'

		# No point in hiding if we are already hidden
		return @  if @isInvisible()

		# Prepare
		$wrap = @$getWrapper()

		# Prepare
		@resize()

		# Init
		# @enable(null, {alterClass:false})
		@disable()

		# Prepare Animation
		# animateOpts = @getHideAxisProperties()
		animateOpts = @getHidePositionStyles()

		# Keep visible by
		if @config.keepVisibleBy
			positionProperty = @getPositionProperty()
			positionValue = parseInt(animateOpts[positionProperty], 10)
			keepVisibleBy = parseFloat(@config.keepVisibleBy, 10)
			keepVisibleBy *= @getSizeValue()  if keepVisibleBy < 1  # support percentages
			newPositionValue = if @isInverse() then (positionValue + keepVisibleBy) else (positionValue - keepVisibleBy)
			newPositionValue += 'px'
			animateOpts[positionProperty] = newPositionValue

		# Animate
		$wrap.stop(true,false).animate animateOpts, 400, =>
			$wrap.removeClass(@config.wrapVisibleClass)  unless @config.keepVisibleBy
			$(window).trigger('resize')
			@$getEl().trigger('slidescrollpanelout')
			return next?()

		# Chain
		@

	# Enable
	enable: (event,opts={}) =>
		# No point in enabling if we are already enabled
		return @  if @isActive()

		# Log
		@log 'enable'

		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Disable
		$wrap.prop(@getDesiredAxisProperties())
		$wrap.css(@getShowPositionStyles())
		$wrap.addClass(@config.wrapActiveClass)  if opts.alterClass isnt false

		# Chain
		@

	# Disable
	disable: (event,opts={}) =>
		# No point in disabling if we are already disabled
		return @  if @isInactive()

		# Log
		@log 'disable'

		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Disable
		$wrap.css(@getDesiredPositionStyles())
		$wrap.prop(@getShowAxisProperties())
		$wrap.removeClass(@config.wrapActiveClass)  if opts.alterClass isnt false

		# Chain
		@

	# Enable Helper
	# z-index ordering for active items should be handled by the implementor's css
	enableHelper: (event,opts={}) =>
		# Log
		@log 'enableHelper'

		# Kill Android Hack
		$(document.body).off('click', @disableHelper)

		# Enable
		@enable(event, opts)

		# Chain
		@

	# Disable
	disableHelper: (event,opts={}) =>
		# Log
		@log 'disableHelper'

		# Check if we were clicked outside
		if event.type is 'click'
			$target = $(event.originalEvent.target)
			has = @$getContent().has($target).length isnt 0
			if has
				return @

		# Kill Android Hack
		$(document.body).off('click', @disableHelper)

		# Disable
		apply = =>
			# Prepare
			percentVisible = @getAxisPercent()

			# Auto Show
			if @config.autoShowAbove and percentVisible >= @config.autoShowAbove
				@showPanel()  if percentVisible

			# Auto Hide
			else if percentVisible and @config.autoHideBelow and percentVisible <= @config.autoHideBelow
				@hidePanel()

			# Keep visible
			else
				@disable(event, opts)

		# Android has an issue where scrollLeft can only applied after a manual click event
		# so we will need to wait for a click event to happen
		# we've tried feature detection here, to see if the axis gets applied correctly
		# and it does get applied correctly, it just doesn't refresh the view
		isAndroid = navigator.userAgent.toLowerCase().indexOf('android') isnt -1
		if event? and event.type is 'touchend' and isAndroid
			$(document.body).one('click', @disableHelper)
		else
			apply()

		# Chain
		@

	# Enter Panel Helper
	enterPanelHelper: (event) =>
		# Kill Timer
		if @leavePanelHelperTimer?
			clearTimeout(@leavePanelHelperTimer)
			@leavePanelHelperTimer = null

		# No point in enabling if we are already active
		return @  if @isInvisible() or @isActive()

		# Log
		@log 'enterPanelHelper', @isVisible(), @isActive()

		# Handle
		@enableHelper(event)

		# Chain
		@

	# Leave Panel Helper
	leavePanelHelperTimer: null
	leavePanelHelper: (event,opts={}) =>
		# No point in enabling if we are already inactive
		return @  if @isInvisible() or @isInactive()

		# Log
		@log 'leavePanelHelper', @isVisible(), @isActive()

		# Touch devices we can fire disable right away
		if @isTouchDevice()
			@disableHelper(event)

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
				@disableHelper(event)

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
