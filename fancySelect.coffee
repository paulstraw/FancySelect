$ = window.jQuery || window.Zepto || window.$

$.fn.fancySelect = (opts = {}) ->
  settings = $.extend({
    forceiOS: false
    includeBlank: false
    optionTemplate: (optionEl) ->
      return optionEl.text()
    triggerTemplate: (optionEl) ->
      return optionEl.text()
  }, opts)

  isiOS = !!navigator.userAgent.match /iP(hone|od|ad)/i

  return this.each ->
    sel = $(this)
    return if sel.hasClass('fancified') || sel[0].tagName != 'SELECT'
    sel.addClass('fancified')

    # hide the native select
    sel.css
      width: 1
      height: 1
      display: 'block'
      position: 'absolute'
      top: 0
      left: 0
      opacity: 0

    # some global setup stuff
    sel.wrap '<div class="fancy-select">'
    wrapper = sel.parent()

    wrapper.addClass(sel.data('class')) if sel.data('class')

    wrapper.append '<div class="trigger">'
    wrapper.append '<ul class="options">' unless isiOS && !settings.forceiOS

    trigger = wrapper.find '.trigger'
    options = wrapper.find '.options'

    # disabled in markup?
    disabled = sel.prop('disabled')
    if disabled
      wrapper.addClass 'disabled'

    updateTriggerText = ->
      triggerHtml = settings.triggerTemplate(sel.find(':selected'))
      trigger.html(triggerHtml)

    sel.on 'blur.fs', ->
      if trigger.hasClass 'open'
        setTimeout ->
          trigger.trigger 'close.fs'
        , 120

    trigger.on 'close.fs', ->
      trigger.removeClass 'open'
      options.removeClass 'open'

    trigger.on 'click.fs', ->
      unless disabled
        trigger.toggleClass 'open'

        # fancySelect defaults to using native selects with a styled trigger on mobile
        # don't show the options if we're on mobile and haven't set `forceiOS`
        if isiOS && !settings.forceiOS
          if trigger.hasClass 'open'
            sel.focus()
        else
          if trigger.hasClass 'open'
            parent = trigger.parent()
            offParent = parent.offsetParent()

            # TODO 20 is very static
            if (parent.offset().top + parent.outerHeight() + options.outerHeight() + 20) > $(window).height() + $(window).scrollTop()
              options.addClass 'overflowing'
            else
              options.removeClass 'overflowing'

          options.toggleClass 'open'

          sel.focus() unless isiOS

    sel.on 'enable', ->
      sel.prop 'disabled', false
      wrapper.removeClass 'disabled'
      disabled = false
      copyOptionsToList()

    sel.on 'disable', ->
      sel.prop 'disabled', true
      wrapper.addClass 'disabled'
      disabled = true

    sel.on 'change.fs', (e) ->
      if e.originalEvent && e.originalEvent.isTrusted
        # discard firefox-only automatic event when hitting enter, we want to trigger our own
        e.stopPropagation()
      else
        updateTriggerText()

    # keyboard control
    sel.on 'keydown', (e) ->
      w = e.which
      hovered = options.find('.hover')
      hovered.removeClass('hover')

      if !options.hasClass('open')
        if w in [13, 32, 38, 40] # enter, space, up, down
          e.preventDefault()
          trigger.trigger 'click.fs'
      else
        if w == 38 # up
          e.preventDefault()
          if hovered.length && hovered.index() > 0 # move up
            hovered.prev().addClass('hover')
          else # move to bottom
            options.find('li:last-child').addClass('hover')
        else if w == 40 # down
          e.preventDefault()
          if hovered.length && hovered.index() < options.find('li').length - 1 # move down
            hovered.next().addClass('hover')
          else # move to top
            options.find('li:first-child').addClass('hover')
        else if w == 27 # escape
          e.preventDefault()
          trigger.trigger 'click.fs'
        else if w in [13, 32] # enter, space
          e.preventDefault()
          hovered.trigger 'mousedown.fs'
        else if w == 9 # tab
          if trigger.hasClass 'open' then trigger.trigger 'close.fs'

        newHovered = options.find('.hover')
        if newHovered.length
          options.scrollTop 0
          options.scrollTop newHovered.position().top - 12

    # Handle item selection, and
    # Add class selected to selected item
    options.on 'mousedown.fs', 'li', (e) ->
      clicked = $(this)

      sel.val(clicked.data('raw-value'))

      sel.trigger('blur.fs').trigger('focus.fs') unless isiOS

      options.find('.selected').removeClass('selected')
      clicked.addClass 'selected'
      trigger.addClass 'selected'
      return sel.val(clicked.data('raw-value')).trigger('change.fs').trigger('blur.fs').trigger('focus.fs')

    # handle mouse selection
    options.on 'mouseenter.fs', 'li', ->
      nowHovered = $(this)
      hovered = options.find('.hover')
      hovered.removeClass 'hover'

      nowHovered.addClass 'hover'

    options.on 'mouseleave.fs', 'li', ->
      options.find('.hover').removeClass('hover')

    copyOptionsToList = ->
      # update our trigger to reflect the select (it really already should, this is just a safety)
      updateTriggerText()

      return if isiOS && !settings.forceiOS

      # snag current options before we add a default one
      selOpts = sel.find 'option'

      # generate list of options for the fancySelect

      sel.find('option').each (i, opt) ->
        opt = $(opt)

        if !opt.prop('disabled') && (opt.val() || settings.includeBlank)
          # Generate the inner HTML for the option from our template
          optHtml = settings.optionTemplate(opt)

          # Is there a select option on page load?
          if opt.prop('selected')
            options.append "<li data-raw-value=\"#{opt.val()}\" class=\"selected\">#{optHtml}</li>"
          else
            options.append "<li data-raw-value=\"#{opt.val()}\">#{optHtml}</li>"

    # for updating the list of options after initialization
    sel.on 'update.fs', ->
      wrapper.find('.options').empty()
      copyOptionsToList()

    copyOptionsToList()
