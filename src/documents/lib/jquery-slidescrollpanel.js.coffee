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

		# Styles to apply to the wrap
		wrapStyles:
			margin: 0
			padding: 0
			position: 'absolute'
			top: 0
			left: 0
			overflow: 'auto'
			'z-index': 100
			border: '2px solid red'

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
			@$getContent()
				.off('touchstart', @enterPanelHelper)
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
			@$getContent()
				.on('touchstart', @enterPanelHelper)
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
		if active?
			if active is true
				$wrap.addClass('slidescrollpanel-active').show()
			else if active is false
				$wrap.removeClass('slidescrollpanel-active').hide()
		else
			active = $wrap.hasClass('slidescrollpanel-active')
			return active

		# Chain
		return @

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
		$wrap = @$getWrapper()

		if @active() is false
			@resize()
			$wrap.css(opacity:0)
			@active(true)  # must be before prop set
			$wrap.prop(@getHideProps()).css(opacity:1)

		$wrap.stop(true,false).animate @getShowProps(), 400, =>
			$(window).trigger('resize')
			return next?()

		# Chain
		@

	# Hide Panel
	# next()
	hidePanel: (next) =>
		$wrap = @$getWrapper()
		$wrap.stop(true,false).animate @getHideProps(), 400, =>
			@active(false)
			$(window).trigger('resize')
			return next?()

		# Chain
		@

	# Enter Panel Helper
	enterPanelHelper: (event) =>
		# Prepare
		active = @active()

		# Handle
		console.log 'enter', active, event.currentTarget.className, event
		if active
			@enable(event)

		# Chain
		@

	# Enable
	enable: (event) =>
		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Disable
		if @isTouchDevice()
			currentOffset = $wrap.data('currentOffset')
			if currentOffset
				positionOffset =
					left: 0
				console.log 'enable:', JSON.stringify(currentOffset), JSON.stringify(positionOffset)
				$wrap.css(positionOffset)
				$wrap.prop(currentOffset)
				$wrap.data('currentOffset', null)
		else
			$wrap.css('pointer-events': 'auto')

		# Kill Timer
		if @leavePanelHelperTimer
			clearTimeout(@leavePanelHelperTimer)
			@leavePanelHelperTimer = null

		# Chain
		@

	# Disable
	disable: (event) =>
		# Prepare
		$wrap = @$getWrapper()
		$content = @$getContent()

		# Disable
		if @isTouchDevice()
			showOffset = @getShowProps()
			currentOffset =
				scrollLeft: @getOffset()
			positionOffset =
				left: parseInt($content.offset().left, 10) - parseInt($wrap.offset().left, 10)
			console.log 'disable:', currentOffset, positionOffset, showOffset
			$wrap.css(positionOffset)
			$wrap.prop(showOffset)
			$wrap.data('currentOffset', currentOffset)
		else
			$wrap.css('pointer-events': 'none')
			$content.css('pointer-events': 'auto')

		# Chain
		@

	# Leave Panel Helper
	leavePanelHelperTimer: null
	leavePanelHelper: (event,opts={}) =>
		# Prepare
		active = @active()

		# Handle
		console.log 'leave', active, event.currentTarget.className, event
		if active
			if @isTouchDevice()
				@disable()
			else
				# Kill Timer
				if @leavePanelHelperTimer
					clearTimeout(@leavePanelHelperTimer)
					@leavePanelHelperTimer = null

				# Create Timer
				if opts.waited isnt true
					@leavePanelHelperTimer = setTimeout(
						=> @leavePanelHelper(event,{waited:true})
						1000
					)
				else
					@disable()


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
