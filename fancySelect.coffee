$.fn.fancySelect = (opts) ->
  settings = $.extend({
    forceMobile: false
  }, opts)

  isMobile = !!navigator.userAgent.match /Mobile|webOS/i

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

    wrapper.addClass(sel.data('class'))

    wrapper.append '<div class="trigger">'
    wrapper.append '<ul class="options">' unless isMobile && !settings.forceMobile

    trigger = wrapper.find '.trigger'
    options = wrapper.find '.options'

    #disabled in markup?
    disabled = sel.prop('disabled')
    if disabled
      wrapper.addClass 'disabled'

    updateTriggerText = ->
      trigger.text sel.find(':selected').text()

    sel.on 'blur', ->
      if trigger.hasClass 'open'
        setTimeout ->
          trigger.trigger 'close'
        , 120

    trigger.on 'close', ->
      trigger.removeClass 'open'
      options.removeClass 'open'

    trigger.on 'click', ->
      unless disabled
        trigger.toggleClass 'open'

        # fancySelect defaults to using native selects with a styled trigger on mobile
        # don't show the options if we're on mobile and haven't set `forceMobile`
        if isMobile && !settings.forceMobile
          if trigger.hasClass 'open'
            sel.focus()
        else
          if trigger.hasClass 'open'
            parent = trigger.parent()
            offParent = parent.offsetParent()

            #todo 20 is very static
            if (parent.offset().top + parent.outerHeight() + options.outerHeight() + 20) > $(window).height()
              options.addClass 'overflowing'
            else
              options.removeClass 'overflowing'

          options.toggleClass 'open'

          sel.focus()

    sel.on 'enable', ->
      sel.prop 'disabled', false
      wrapper.removeClass 'disabled'
      disabled = false
      copyOptionsToList()

    sel.on 'disable', ->
      sel.prop 'disabled', true
      wrapper.addClass 'disabled'
      disabled = true

    sel.on 'change', (e) ->
      if e.originalEvent and e.originalEvent.isTrusted
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
          trigger.trigger 'click'
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
          trigger.trigger 'click'
        else if w in [13, 32] # enter, space
          e.preventDefault()
          hovered.trigger 'click'
        else if w == 9 # tab
          if trigger.hasClass 'open' then trigger.trigger 'close'

        newHovered = options.find('.hover')
        if newHovered.length
          options.scrollTop 0
          options.scrollTop newHovered.position().top - 12

    # handle item selection
    options.on 'click', 'li', ->
      sel.val($(this).data('value')).trigger('change').trigger('blur').trigger('focus')

    # handle mouse selection
    options.on 'mouseenter', 'li', ->
      nowHovered = $(this)
      hovered = options.find('.hover')
      hovered.removeClass 'hover'

      nowHovered.addClass 'hover'

    options.on 'mouseleave', 'li', ->
      options.find('.hover').removeClass('hover')

    copyOptionsToList = ->
      return if isMobile && !settings.forceMobile

      # snag current options before we add a default one
      selOpts = sel.find 'option'

      # generate list of options for the fancySelect
      sel.find('option').each (i, opt) ->
        opt = $(opt)

        if opt.val() && !opt.prop('disabled')
          options.append "<li data-value=\"#{opt.val()}\">#{opt.text()}</li>"

      # update our trigger to reflect the select (it really already should, this is just a safety)
      updateTriggerText()

    sel.on 'update', ->
      wrapper.find('.options').empty()
      copyOptionsToList()

    copyOptionsToList()
