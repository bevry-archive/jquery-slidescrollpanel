/*global define:false require:false */
(function (name, context, definition) {
	if (typeof module != 'undefined' && module.exports) module.exports = definition();
	else if (typeof define == 'function' && define.amd) define(definition);
	else context[name] = definition();
})('jquery-slidescrollpanel', this, function() {
  var $, SlideScrollPanel, jQuery,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  jQuery = $ = window.jQuery || require('jquery');

  $.SlideScrollPanel = SlideScrollPanel = (function() {
    SlideScrollPanel.prototype.config = {
      debug: false,
      $el: null,
      $wrap: null,
      direction: 'right',
      autoContentWidth: true,
      autoContentHeight: true,
      autoWrapWidth: true,
      autoWrapHeight: true,
      disableDelay: 1 * 1000,
      wrapActiveClass: 'slidescrollpanel-active',
      wrapVisibleClass: 'slidescrollpanel-visible',
      autoShowAbove: 0.7,
      autoHideBelow: 0.3,
      keepVisibleBy: false,
      forcedPositionProperty: false,
      wrapStyles: {
        margin: 0,
        padding: 0,
        position: 'absolute',
        top: 0,
        left: 0,
        overflow: 'auto',
        'z-index': 100
      },
      contentStyles: {
        margin: 0,
        padding: 0,
        width: '100%',
        display: 'inline-block'
      }
    };

    function SlideScrollPanel(opts) {
      var $content, $wrap, key, value;
      if (opts == null) {
        opts = {};
      }
      this.leavePanelHelper = __bind(this.leavePanelHelper, this);
      this.enterPanelHelper = __bind(this.enterPanelHelper, this);
      this.disableHelper = __bind(this.disableHelper, this);
      this.enableHelper = __bind(this.enableHelper, this);
      this.disable = __bind(this.disable, this);
      this.enable = __bind(this.enable, this);
      this.hidePanel = __bind(this.hidePanel, this);
      this.showPanel = __bind(this.showPanel, this);
      this.resize = __bind(this.resize, this);
      this.isInvisible = __bind(this.isInvisible, this);
      this.isVisible = __bind(this.isVisible, this);
      this.isInactive = __bind(this.isInactive, this);
      this.isActive = __bind(this.isActive, this);
      this.$getEl = __bind(this.$getEl, this);
      this.$getContent = __bind(this.$getContent, this);
      this.$getWrapper = __bind(this.$getWrapper, this);
      this.getDesiredAxisProperties = __bind(this.getDesiredAxisProperties, this);
      this.getHideAxisProperties = __bind(this.getHideAxisProperties, this);
      this.getShowAxisProperties = __bind(this.getShowAxisProperties, this);
      this.getAxisProperties = __bind(this.getAxisProperties, this);
      this.getAxisPercent = __bind(this.getAxisPercent, this);
      this.getDesiredAxisValue = __bind(this.getDesiredAxisValue, this);
      this.getHideAxisValue = __bind(this.getHideAxisValue, this);
      this.getShowAxisValue = __bind(this.getShowAxisValue, this);
      this.getAxisValue = __bind(this.getAxisValue, this);
      this.getAxisProperty = __bind(this.getAxisProperty, this);
      this.getDesiredPositionStyles = __bind(this.getDesiredPositionStyles, this);
      this.getHidePositionStyles = __bind(this.getHidePositionStyles, this);
      this.getShowPositionStyles = __bind(this.getShowPositionStyles, this);
      this.getPositionStyles = __bind(this.getPositionStyles, this);
      this.getPositionPercent = __bind(this.getPositionPercent, this);
      this.getDesiredPositionValue = __bind(this.getDesiredPositionValue, this);
      this.getHidePositionValue = __bind(this.getHidePositionValue, this);
      this.getShowPositionValue = __bind(this.getShowPositionValue, this);
      this.getPositionValue = __bind(this.getPositionValue, this);
      this.isPositionInverted = __bind(this.isPositionInverted, this);
      this.getPositionProperty = __bind(this.getPositionProperty, this);
      this.getDesiredMarginStyles = __bind(this.getDesiredMarginStyles, this);
      this.getMarginStyles = __bind(this.getMarginStyles, this);
      this.getDesiredMarginValue = __bind(this.getDesiredMarginValue, this);
      this.getMarginValue = __bind(this.getMarginValue, this);
      this.getMarginProperty = __bind(this.getMarginProperty, this);
      this.getSizeValue = __bind(this.getSizeValue, this);
      this.getSizeProperty = __bind(this.getSizeProperty, this);
      this.isInverse = __bind(this.isInverse, this);
      this.addListeners = __bind(this.addListeners, this);
      this.removeListeners = __bind(this.removeListeners, this);
      this.log = __bind(this.log, this);
      this.destroy = __bind(this.destroy, this);
      this.config = JSON.parse(JSON.stringify(this.config));
      for (key in opts) {
        if (!__hasProp.call(opts, key)) continue;
        value = opts[key];
        this.config[key] = value;
      }
      $content = this.config.$el;
      if (this.config.$wrap) {
        $wrap = this.config.$wrap;
      } else {
        $wrap = $("<div/>");
        $content.wrap($wrap);
        this.config.$wrap = $wrap = $content.parent();
      }
      $wrap.hide().data('slidescrollpanel', this).addClass("slidescrollpanel-wrap").css(this.config.wrapStyles);
      $content.data('slidescrollpanel', this).addClass("slidescrollpanel-content slidescrollpanel-direction-" + (this.getDirection())).css(this.config.contentStyles);
      this.addListeners();
      this;
    }

    SlideScrollPanel.prototype.destroy = function() {
      this.removeListeners();
      return this;
    };

    SlideScrollPanel.prototype.log = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.config.debug) {
        if (false) {
          $('.demo-description').append('<div>' + JSON.stringify(args) + '</div>');
        } else if ((typeof console !== "undefined" && console !== null ? console.log : void 0) != null) {
          console.log.apply(console, args);
        } else {
          alert(JSON.stringify(args));
        }
      }
      return this;
    };

    SlideScrollPanel.prototype.removeListeners = function() {
      if (this.isTouchDevice()) {
        this.$getWrapper().off('touchmove', this.enterPanelHelper).off('touchend', this.leavePanelHelper);
      } else {
        this.$getContent().off('mouseenter', this.enterPanelHelper).off('mouseleave', this.leavePanelHelper);
        this.$getWrapper().off('scroll', this.leavePanelHelper);
      }
      $(window).off('resize', this.resize);
      return this;
    };

    SlideScrollPanel.prototype.addListeners = function() {
      this.removeListeners();
      if (this.isTouchDevice()) {
        this.$getWrapper().on('touchmove', this.enterPanelHelper).on('touchend', this.leavePanelHelper);
      } else {
        this.$getContent().on('mouseenter', this.enterPanelHelper).on('mouseleave', this.leavePanelHelper);
        this.$getWrapper().on('scroll', this.leavePanelHelper);
      }
      $(window).on('resize', this.resize);
      return this;
    };

    SlideScrollPanel.prototype.isTouchDevice = function() {
      return !!('ontouchstart' in window) || !!('onmsgesturechange' in window);
    };

    SlideScrollPanel.prototype.getDirection = function() {
      return this.config.direction;
    };

    SlideScrollPanel.prototype.inverseMap = {
      right: false,
      left: true,
      top: true,
      bottom: false
    };

    SlideScrollPanel.prototype.isInverse = function() {
      var direction, inverse;
      direction = this.getDirection();
      inverse = this.inverseMap[direction];
      return inverse;
    };

    SlideScrollPanel.prototype.sizePropertyMap = {
      right: 'width',
      left: 'width',
      top: 'height',
      bottom: 'height'
    };

    SlideScrollPanel.prototype.getSizeProperty = function() {
      var direction, sizeProperty;
      direction = this.getDirection();
      sizeProperty = this.sizePropertyMap[direction];
      return sizeProperty;
    };

    SlideScrollPanel.prototype.getSizeValue = function() {
      var sizeProperty, sizeValue;
      sizeProperty = this.getSizeProperty();
      sizeValue = this.$getWrapper()['inner' + sizeProperty.substr(0, 1).toUpperCase() + sizeProperty.substr(1)]();
      return sizeValue;
    };

    SlideScrollPanel.prototype.marginPropertyMap = {
      right: 'margin-left',
      left: 'margin-right',
      top: 'margin-bottom',
      bottom: 'margin-top'
    };

    SlideScrollPanel.prototype.getMarginProperty = function() {
      var direction, marginProperty;
      direction = this.getDirection();
      marginProperty = this.marginPropertyMap[direction];
      return marginProperty;
    };

    SlideScrollPanel.prototype.getMarginValue = function() {
      var margin, marginProperty;
      marginProperty = this.getMarginProperty();
      margin = this.$getContent().css(marginProperty);
      return marginValue;
    };

    SlideScrollPanel.prototype.getDesiredMarginValue = function() {
      return this.getSizeValue();
    };

    SlideScrollPanel.prototype.getMarginStyles = function() {
      var opts;
      opts = {};
      opts[this.getMarginProperty()] = this.getMarginValue();
      return opts;
    };

    SlideScrollPanel.prototype.getDesiredMarginStyles = function() {
      var opts;
      opts = {};
      opts[this.getMarginProperty()] = this.getDesiredMarginValue();
      return opts;
    };

    SlideScrollPanel.prototype.positionPropertyMap = {
      right: 'left',
      left: 'left',
      top: 'top',
      bottom: 'top'
    };

    SlideScrollPanel.prototype.getPositionProperty = function() {
      var positionProperty;
      positionProperty = this.config.forcedPositionProperty || this.positionPropertyMap[this.getDirection()];
      return positionProperty;
    };

    SlideScrollPanel.prototype.isPositionInverted = function() {
      var positionInverted;
      positionInverted = this.config.forcedPositionProperty && this.config.forcedPositionProperty !== this.positionPropertyMap[this.getDirection()];
      return positionInverted;
    };

    SlideScrollPanel.prototype.getPositionValue = function() {
      var positionProperty, positionValue;
      positionProperty = this.getPositionProperty();
      positionValue = this.$getWrapper().css(positionProperty);
      return positionValue;
    };

    SlideScrollPanel.prototype.getShowPositionValue = function() {
      var positionValue;
      positionValue = '0px';
      return positionValue;
    };

    SlideScrollPanel.prototype.getHidePositionValue = function(invertCheck) {
      var positionValue;
      if (invertCheck == null) {
        invertCheck = true;
      }
      positionValue = this.getSizeValue();
      if (this.isInverse()) {
        positionValue *= -1;
      }
      if (invertCheck && this.isPositionInverted()) {
        positionValue *= -1;
      }
      positionValue += 'px';
      return positionValue;
    };

    SlideScrollPanel.prototype.getDesiredPositionValue = function() {
      var positionValue;
      positionValue = this.getShowAxisValue() - this.getAxisValue();
      if (this.isPositionInverted()) {
        positionValue *= -1;
      }
      positionValue += 'px';
      return positionValue;
    };

    SlideScrollPanel.prototype.getPositionPercent = function() {
      var percentVisible;
      percentVisible = 1 - parseInt(this.getPositionValue(), 10) / parseInt(this.getHidePositionValue(false), 10);
      return percentVisible;
    };

    SlideScrollPanel.prototype.getPositionStyles = function() {
      var opts;
      opts = {};
      opts[this.getPositionProperty()] = this.getPositionValue();
      return opts;
    };

    SlideScrollPanel.prototype.getShowPositionStyles = function() {
      var opts;
      opts = {};
      opts[this.getPositionProperty()] = this.getShowPositionValue();
      return opts;
    };

    SlideScrollPanel.prototype.getHidePositionStyles = function() {
      var opts;
      opts = {};
      opts[this.getPositionProperty()] = this.getHidePositionValue();
      return opts;
    };

    SlideScrollPanel.prototype.getDesiredPositionStyles = function() {
      var opts;
      opts = {};
      opts[this.getPositionProperty()] = this.getDesiredPositionValue();
      return opts;
    };

    SlideScrollPanel.prototype.axisPropertyMap = {
      right: 'scrollLeft',
      left: 'scrollLeft',
      top: 'scrollTop',
      bottom: 'scrollTop'
    };

    SlideScrollPanel.prototype.getAxisProperty = function() {
      var axisProperty, direction;
      direction = this.getDirection();
      axisProperty = this.axisPropertyMap[direction];
      return axisProperty;
    };

    SlideScrollPanel.prototype.getAxisValue = function() {
      var axisProperty, axisValue;
      axisProperty = this.getAxisProperty();
      axisValue = this.$getWrapper().prop(axisProperty);
      return axisValue;
    };

    SlideScrollPanel.prototype.getShowAxisValue = function() {
      var axisValue;
      axisValue = this.isInverse() ? 0 : this.getSizeValue();
      return axisValue;
    };

    SlideScrollPanel.prototype.getHideAxisValue = function() {
      var axisValue;
      axisValue = this.isInverse() ? this.getSizeValue() : 0;
      return axisValue;
    };

    SlideScrollPanel.prototype.getDesiredAxisValue = function() {
      var axisValue;
      if (this.isInverse()) {
        axisValue = parseInt(this.getShowPositionValue(), 10) - parseInt(this.getPositionValue(), 10);
      } else {
        if (this.isPositionInverted()) {
          axisValue = parseInt(this.getPositionValue(), 10) - parseInt(this.getHidePositionValue(), 10);
        } else {
          axisValue = parseInt(this.getHidePositionValue(), 10) - parseInt(this.getPositionValue(), 10);
        }
      }
      return axisValue;
    };

    SlideScrollPanel.prototype.getAxisPercent = function() {
      var percentVisible;
      if (this.isInverse()) {
        percentVisible = 1 - this.getAxisValue() / this.getHideAxisValue();
      } else {
        percentVisible = this.getAxisValue() / this.getShowAxisValue();
      }
      return percentVisible;
    };

    SlideScrollPanel.prototype.getAxisProperties = function() {
      var opts;
      opts = {};
      opts[this.getAxisProperty()] = this.getAxisValue();
      return opts;
    };

    SlideScrollPanel.prototype.getShowAxisProperties = function() {
      var opts;
      opts = {};
      opts[this.getAxisProperty()] = this.getShowAxisValue();
      return opts;
    };

    SlideScrollPanel.prototype.getHideAxisProperties = function() {
      var opts;
      opts = {};
      opts[this.getAxisProperty()] = this.getHideAxisValue();
      return opts;
    };

    SlideScrollPanel.prototype.getDesiredAxisProperties = function() {
      var opts;
      opts = {};
      opts[this.getAxisProperty()] = this.getDesiredAxisValue();
      return opts;
    };

    SlideScrollPanel.prototype.$getWrapper = function() {
      var $wrap;
      $wrap = this.config.$wrap;
      return $wrap;
    };

    SlideScrollPanel.prototype.$getContent = function() {
      var $content;
      $content = this.config.$el;
      return $content;
    };

    SlideScrollPanel.prototype.$getEl = function() {
      return this.$getContent();
    };

    SlideScrollPanel.prototype.isActive = function() {
      var active;
      active = this.$getWrapper().hasClass(this.config.wrapActiveClass);
      return active;
    };

    SlideScrollPanel.prototype.isInactive = function() {
      return this.isActive() === false;
    };

    SlideScrollPanel.prototype.isVisible = function(active) {
      active = this.$getWrapper().hasClass(this.config.wrapVisibleClass);
      return active;
    };

    SlideScrollPanel.prototype.isInvisible = function() {
      return this.isVisible() === false;
    };

    SlideScrollPanel.prototype.resize = function() {
      var $container, $content, $wrap, height, width;
      $wrap = this.$getWrapper();
      $content = this.$getContent();
      $container = $wrap.parent();
      width = parseInt($container.css('width'), 10);
      height = parseInt($container.css('height'), 10);
      if (this.config.autoContentWidth) {
        $content.css({
          width: width
        });
      }
      if (this.config.autoContentHeight) {
        $content.css({
          height: height
        });
      }
      if (this.config.autoWrapWidth) {
        $wrap.css({
          width: width
        });
      }
      if (this.config.autoWrapHeight) {
        $wrap.css({
          height: height
        });
      }
      $content.css(this.getDesiredMarginStyles());
      return this;
    };

    SlideScrollPanel.prototype.showPanel = function(next) {
      var $wrap, animateOpts,
        _this = this;
      this.log('showPanel');
      $wrap = this.$getWrapper();
      $wrap.show();
      this.resize();
      if (this.isInvisible()) {
        $wrap.css(this.getHidePositionStyles());
        $wrap.prop(this.getShowAxisProperties());
      } else {
        this.disable();
      }
      animateOpts = this.getShowPositionStyles();
      $wrap.stop(true, false).animate(animateOpts, 400, function() {
        $wrap.addClass(_this.config.wrapVisibleClass);
        if (_this.isTouchDevice()) {
          _this.disable();
        } else {
          _this.enable();
        }
        $(window).trigger('resize');
        _this.$getEl().trigger('slidescrollpanelin');
        return typeof next === "function" ? next() : void 0;
      });
      return this;
    };

    SlideScrollPanel.prototype.hidePanel = function(next) {
      var $wrap, animateOpts, keepVisibleBy, newPositionValue, positionProperty, positionValue,
        _this = this;
      this.log('hidePanel');
      if (this.isInvisible()) {
        return this;
      }
      $wrap = this.$getWrapper();
      this.resize();
      this.disable();
      animateOpts = this.getHidePositionStyles();
      if (this.config.keepVisibleBy) {
        positionProperty = this.getPositionProperty();
        positionValue = parseInt(animateOpts[positionProperty], 10);
        keepVisibleBy = parseFloat(this.config.keepVisibleBy, 10);
        if (keepVisibleBy < 1) {
          keepVisibleBy *= this.getSizeValue();
        }
        newPositionValue = this.isInverse() ? positionValue + keepVisibleBy : positionValue - keepVisibleBy;
        newPositionValue += 'px';
        animateOpts[positionProperty] = newPositionValue;
      }
      $wrap.stop(true, false).animate(animateOpts, 400, function() {
        if (!_this.config.keepVisibleBy) {
          $wrap.removeClass(_this.config.wrapVisibleClass);
        }
        $(window).trigger('resize');
        _this.$getEl().trigger('slidescrollpanelout');
        return typeof next === "function" ? next() : void 0;
      });
      return this;
    };

    SlideScrollPanel.prototype.enable = function(event, opts) {
      var $content, $wrap;
      if (opts == null) {
        opts = {};
      }
      if (this.isActive()) {
        return this;
      }
      this.log('enable');
      $wrap = this.$getWrapper();
      $content = this.$getContent();
      $wrap.prop(this.getDesiredAxisProperties());
      $wrap.css(this.getShowPositionStyles());
      if (opts.alterClass !== false) {
        $wrap.addClass(this.config.wrapActiveClass);
      }
      return this;
    };

    SlideScrollPanel.prototype.disable = function(event, opts) {
      var $content, $wrap;
      if (opts == null) {
        opts = {};
      }
      if (this.isInactive()) {
        return this;
      }
      this.log('disable');
      $wrap = this.$getWrapper();
      $content = this.$getContent();
      $wrap.css(this.getDesiredPositionStyles());
      $wrap.prop(this.getShowAxisProperties());
      if (opts.alterClass !== false) {
        $wrap.removeClass(this.config.wrapActiveClass);
      }
      return this;
    };

    SlideScrollPanel.prototype.enableHelper = function(event, opts) {
      if (opts == null) {
        opts = {};
      }
      this.log('enableHelper');
      $(document.body).off('click', this.disableHelper);
      this.enable(event, opts);
      return this;
    };

    SlideScrollPanel.prototype.disableHelper = function(event, opts) {
      var $target, apply, has, isAndroid,
        _this = this;
      if (opts == null) {
        opts = {};
      }
      this.log('disableHelper');
      if (event.type === 'click') {
        $target = $(event.originalEvent.target);
        has = this.$getContent().has($target).length !== 0;
        if (has) {
          return this;
        }
      }
      $(document.body).off('click', this.disableHelper);
      apply = function() {
        var percentVisible;
        percentVisible = _this.getAxisPercent();
        if (_this.config.autoShowAbove && percentVisible >= _this.config.autoShowAbove) {
          if (percentVisible) {
            return _this.showPanel();
          }
        } else if (percentVisible && _this.config.autoHideBelow && percentVisible <= _this.config.autoHideBelow) {
          return _this.hidePanel();
        } else {
          return _this.disable(event, opts);
        }
      };
      isAndroid = navigator.userAgent.toLowerCase().indexOf('android') !== -1;
      if ((event != null) && event.type === 'touchend' && isAndroid) {
        $(document.body).one('click', this.disableHelper);
      } else {
        apply();
      }
      return this;
    };

    SlideScrollPanel.prototype.enterPanelHelper = function(event) {
      if (this.leavePanelHelperTimer != null) {
        clearTimeout(this.leavePanelHelperTimer);
        this.leavePanelHelperTimer = null;
      }
      if (this.isInvisible() || this.isActive()) {
        return this;
      }
      this.log('enterPanelHelper', this.isVisible(), this.isActive());
      this.enableHelper(event);
      return this;
    };

    SlideScrollPanel.prototype.leavePanelHelperTimer = null;

    SlideScrollPanel.prototype.leavePanelHelper = function(event, opts) {
      var _this = this;
      if (opts == null) {
        opts = {};
      }
      if (this.isInvisible() || this.isInactive()) {
        return this;
      }
      this.log('leavePanelHelper', this.isVisible(), this.isActive());
      if (this.isTouchDevice()) {
        this.disableHelper(event);
      } else if (event.type !== 'scroll' || (this.leavePanelHelperTimer != null)) {
        if (this.leavePanelHelperTimer != null) {
          clearTimeout(this.leavePanelHelperTimer);
          this.leavePanelHelperTimer = null;
        }
        if (opts.waited !== true) {
          this.leavePanelHelperTimer = setTimeout(function() {
            return _this.leavePanelHelper(event, {
              waited: true
            });
          }, this.config.disableDelay);
        } else {
          this.disableHelper(event);
        }
      }
      return this;
    };

    return SlideScrollPanel;

  })();

  $.fn.slideScrollPanel = function(opts) {
    var $el, slideScrollPanel;
    if (opts == null) {
      opts = {};
    }
    $el = $(this);
    opts.$el = $el;
    slideScrollPanel = new SlideScrollPanel(opts);
    return $el;
  };

  return SlideScrollPanel;

});