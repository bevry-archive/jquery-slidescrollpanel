---
umd: true
---

# Import
jQuery = $ = window.jQuery or require('jquery')

###
TODO
- Add styling
- Add demo
- Add directions
- Add tests
###

# Attach
$.SlideScrollPanel = class SlideScrollPanel
	$el: null
	interval: null
	direction: null

	# Construct our Slide Scroll Panel
	constructor: (opts) ->
		# Apply
		$content = @$el = opts.$el
		@direction = opts.direction or 'right'

		# Wrapper
		$wrap = $("<div class=\"slidescrollpanel-wrap slidescrollpanel-direction-#{@direction}\"/>").hide()

		# Style
		$wrap.add($content).css(
			margin: 0
			padding: 0
		)
		$wrap.css(
			position: 'absolute'
			top: 0
			left: 0
			overflow: 'auto'
			'z-index': 100
		)
		$content.css(
			display: 'inline-block'
		)

		# Content
		$content
			# Attach us
			.data('slidescrollpanel', @)
			.addClass('slidescrollpanel-content')

			# Wrap
			.wrap($wrap)


		# Listeners
		@addListeners()

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

	# Get Margin
	marginMap:
		right: 'left'
		left: 'right'
		top: 'bottom'
		bottom: 'top'
	getMargin: =>
		margin = @marginMap[@direction]
		return margin

	# Get Axis
	axisMap:
		right: 'scrollLeft'
		left: 'scrollLeft'
		top: 'scrollTop'
		bottom: 'scrollTop'
	getAxis: =>
		axis = @axisMap[@direction]
		return axis

	# Get Property
	propertyMap:
		right: 'width'
		left: 'width'
		top: 'height'
		bottom: 'height'
	getProperty: =>
		property = @propertyMap[@direction]
		return property

	# Get Inverse
	inverseMap:
		right: false
		left: true
		top: true
		bottom: false
	getInverse: =>
		inverse = @inverseMap[@direction]
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
		$wrap = @$el.parent()
		return $wrap

	# Get $content
	$getContent: =>
		$content = @$el
		return $content

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

	# Destroy
	destroy: =>
		# Remove the interval to stop it firing
		@clearInterval()

		# Stop listening
		@removeListeners()

		# Chain
		@

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
		$wrap.add($content).css(
			width: $container.width()
			height: $container.height()
		)
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
				@showPanel => @$el.trigger('slidescrollpanelin')

			# No longer active
			else
				@hidePanel => @$el.trigger('slidescrollpanelout')

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
