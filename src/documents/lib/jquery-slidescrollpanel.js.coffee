---
umd: true
---

# Import
jQuery = $ = window.jQuery or require('jquery')

# Attach
$.SlideScrollPanel = class SlideScrollPanel
	# Desktop interval
	interval: null

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
		# Remove the interval to stop it firing
		@clearInterval()

		# Stop listening
		@removeListeners()

		# Chain
		@

	# Remove Listeners
	removeListeners: =>
		@$getWrapper()
			.off('mouseleave', @leavePanelHelper)
			.off('touchend', @leavePanelHelper)
		$(window)
			.off('resize', @resize)
		@

	# Add Listeners
	addListeners: =>
		@removeListeners()
		@$getWrapper()
			.on('mouseleave', @leavePanelHelper)
			.on('touchend', @leavePanelHelper)
		$(window)
			.on('resize', @resize)
		@

	# Is touch device?
	# http://stackoverflow.com/a/4819886/130638
	isTouchDevice: ->
		return `!!('ontouchstart' in window) || !!('onmsgesturechange' in window)`

	# Get Direction
	getDirection: ->
		return @config.direction

	# Get Margin
	marginMap:
		right: 'left'
		left: 'right'
		top: 'bottom'
		bottom: 'top'
	getMargin: =>
		margin = @marginMap[@getDirection()]
		return margin

	# Get Axis
	axisMap:
		right: 'scrollLeft'
		left: 'scrollLeft'
		top: 'scrollTop'
		bottom: 'scrollTop'
	getAxis: =>
		axis = @axisMap[@getDirection()]
		return axis

	# Get Property
	propertyMap:
		right: 'width'
		left: 'width'
		top: 'height'
		bottom: 'height'
	getProperty: =>
		property = @propertyMap[@getDirection()]
		return property

	# Get Inverse
	inverseMap:
		right: false
		left: true
		top: true
		bottom: false
	getInverse: =>
		inverse = @inverseMap[@getDirection()]
		return inverse

	# Get Size
	getSize: =>
		property = @getProperty()
		$wrap = @$getWrapper()
		size = $wrap[property]()
		return size

	# Get Offset
	getOffset: =>
		axis = @getAxis()
		$wrap = @$getWrapper()
		offset = $wrap.prop(axis)
		return offset

	# Get Show Props
	getShowProps: =>
		axis = @getAxis()
		opts = {}

		if @getInverse()
			opts[axis] = 0
		else
			opts[axis] = @getSize()

		return opts

	# Get Hide Props
	getHideProps: =>
		axis = @getAxis()
		opts = {}

		if @getInverse()
			opts[axis] = @getSize()
		else
			opts[axis] = 0

		return opts

	# Get $wrap
	$getWrapper: =>
		$wrap = @config.$wrap
		return $wrap

	# Get $content
	$getContent: =>
		$content = @config.$el
		return $content

	# Get $el
	$getEl: => @$getContent()

	# Is Active
	active: (active) =>
		$wrap = @$getWrapper()
		if active is true
			$wrap.addClass('slidescrollpanel-active').show()
			return @
		else if active is false
			$wrap.removeClass('slidescrollpanel-active').hide()
			return @
		else
			active = $wrap.hasClass('slidescrollpanel-active')
			return active

	# Add Interval
	# Necessary for non-touch devices as they do not have touch events
	# TODO: why? we have mouseleave, isn't that good enough?
	addInterval: =>
		# If we are a touch device, then we do not need the helper as we have touch events instead!
		return  if @isTouchDevice()

		# We are on a non-touch device, so need the helper as we don't have touch events!
		@clearInterval()
		@interval = setInterval(@leavePanelHelper, 2000)

		# Chain
		@

	# Clear Interval
	clearInterval: =>
		if @interval?
			clearInterval(@interval)
			@interval = null
		@

	# Resize
	resize: =>
		$wrap = @$getWrapper()
		$content = @$getContent()
		$container = $wrap.parent()
		width = $container.width()
		height = $container.height()

		$content.css({width})   if @config.autoContentWidth
		$content.css({height})  if @config.autoContentHeight
		$wrap.css({width})      if @config.autoWrapWidth
		$wrap.css({height})     if @config.autoWrapHeight

		$content.css('margin-'+@getMargin(), @getSize())

		@

	# Show Panel
	# next()
	showPanel: (next) =>
		@clearInterval()

		$wrap = @$getWrapper()

		if @active() is false
			@resize()
			$wrap.css(opacity:0)
			@active(true)  # must be before prop set
			$wrap.prop(@getHideProps()).css(opacity:1)

		$wrap.stop(true,false).animate @getShowProps(), 400, =>
			$(window).trigger('resize')
			@addInterval()
			return next?()

		# Chain
		@

	# Hide Panel
	# next()
	hidePanel: (next) =>
		@clearInterval()
		$wrap = @$getWrapper()
		$wrap.stop(true,false).animate  @getHideProps(), 400, =>
			@active(false)
			$(window).trigger('resize')
			return next?()

		# Chain
		@

	# Leave Panel Helper
	# Used for the desktop interval
	leavePanelHelper: =>
		if @active()
			offset = @getOffset()
			size =  @getSize()

			if @getInverse()
				shown = offset is 0
				over = offset < size/2
			else
				shown = offset is size
				over = offset > size/2

			# Same
			if shown
				# ignore

			# Still active
			else if over
				@showPanel => @$getEl().trigger('slidescrollpanelin')

			# No longer active
			else
				@hidePanel => @$getEl().trigger('slidescrollpanelout')

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
