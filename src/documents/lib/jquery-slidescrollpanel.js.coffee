---
umd: true
---

###
TODO
- Add styling
- Add demo
- Add directions
- Add tests
###

# Import
jQuery = $ = window.jQuery or require('jquery')

# Attach
$.SlideScrollPanel = class SlideScrollPanel
	$el: null
	interval: null

	# Construct our Slide Scroll Panel
	constructor: (@$el) ->
		@$el
			# Remove any old events to avoid duplicates
			.off('mouseleave', @leavePanelHelper)
			.off('touchend', @leavePanelHelper)
			.off('showSlideScrollPanel', @showPanel)
			.off('hideSlideScrollPanel', @hidePanel)

			# Add our new events
			.on('mouseleave', @leavePanelHelper)
			.on('touchend', @leavePanelHelper)
			.on('showSlideScrollPanel', @showPanel)
			.on('hideSlideScrollPanel', @hidePanel)
		@

	# Is touch device?
	# http://stackoverflow.com/a/4819886/130638
	isTouchDevice: ->
		return `
			!!('ontouchstart' in window) // works on most browsers
			|| !!('onmsgesturechange' in window); // works on ie10
			`

	# Get $wrap
	$getWrapper: ->
		$wrap = @$el.find('.slidescrollpanel-panel-wrap')
		return $wrap

	# Get $content
	$getContent: ->
		$content = @$el.find('.slidescrollpanel-panel-content')
		return $content

	# Is ACtive
	isActive: ->
		active = @$el.hasClass('slidescrollpanel-active')
		return active

	# Destroy
	destroy: =>
		# Remove the interval to stop it firing
		@clearInterval()

		# Chain
		@

	# Add Interval
	# Necessary for non-touch devices as they do not have touch events
	# TODO: why? we have mouseleave, isn't that good enough?
	addInterval: ->
		# If we are a touch device, then we do not need the helper as we have touch events instead!
		return  if @isTouchDevice()

		# We are on a non-touch device, so need the helper as we don't have touch events!
		@clearInterval()
		@interval = setInterval(@leavePanelHelper, 2000)

		# Chain
		@

	# Clear Interval
	clearInterval: ->
		if @interval?
			clearInterval(@interval)
			@interval = null
		@

	# Show Panel
	# next()
	showPanel: (next) =>
		@clearInterval()
		$content = @$getContent()
		width = $content.width()
		$content.addClass('active')
		$content.stop(true,false).animate {'scrollLeft':width}, 400, =>
			$(window).trigger('resize')
			@addInterval()
			return next?()
		@

	# Hide Panel
	# next()
	hidePanel: (next) =>
		@clearInterval()
		$content = @$getContent()
		$content.stop(true,false).animate {'scrollLeft':0}, 400, =>
			$content.removeClass('active')
			$(window).trigger('resize')
			return next?()
		@

	# Leave Panel Helper
	# Used for the desktop interval
	leavePanelHelper: =>
		if @isActive()
			$content = @$getContent()
			offset = $content.prop('scrollLeft')
			width = $content.width()

			# Full
			if offset is width
				# ignore

			# Still active
			else if offset > width/2
				@showPanel => @$el.trigger('inSlideScrollPanel')

			# No longer active
			else
				@hidePanel => @$el.trigger('outSlideScrollPanel')
		@

# jQuery Chain Method
$.fn.slideScrollPanel = ->
	# Prepare
	$el = $(@)

	# Attach Slide Scroll Panel
	slideScrollPanel = new SlideScrollPanel($el)

	# Chain
	return $el

# Export
return SlideScrollPanel
