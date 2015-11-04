(->
  $ = window.jQuery or window.Zepto or window.$

  $.fn.fancySelect = (opts) ->
    isiOS = undefined
    settings = undefined
    if opts == null
      opts = {}
    settings = $.extend({
      forceiOS: false
      includeBlank: false
      optionTemplate: (optionEl) ->
        optionEl.text()
      triggerTemplate: (optionEl) ->
        optionEl.text()

    }, opts)
    isiOS = ! !navigator.userAgent.match(/iP(hone|od|ad)/i)
    @each ->
      copyOptionsToList = undefined
      disabled = undefined
      options = undefined
      sel = undefined
      trigger = undefined
      updateTriggerText = undefined
      wrapper = undefined
      searchTerm = ''
      searchTimeout = undefined
      sel = $(this)
      if sel.hasClass('fancified') or sel[0].tagName != 'SELECT'
        return
      sel.addClass 'fancified'
      sel.css
        width: 1
        height: 1
        display: 'block'
        position: 'absolute'
        top: 0
        left: 0
        opacity: 0
      sel.wrap '<div class="fancy-select">'
      wrapper = sel.parent()
      if sel.data('class')
        wrapper.addClass sel.data('class')
      wrapper.append '<div class="trigger">'
      if !(isiOS and !settings.forceiOS)
        wrapper.append '<ul class="options">'
      trigger = wrapper.find('.trigger')
      options = wrapper.find('.options')
      disabled = sel.prop('disabled')
      if disabled
        wrapper.addClass 'disabled'

      updateTriggerText = ->
        triggerHtml = undefined
        triggerHtml = settings.triggerTemplate(sel.find(':selected'))
        trigger.html triggerHtml

      sel.on 'blur.fs', ->
        if trigger.hasClass('open')
          return setTimeout((->
            trigger.trigger 'close.fs'
          ), 120)
        return
      trigger.on 'close.fs', ->
        trigger.removeClass 'open'
        options.removeClass 'open'
      trigger.on 'click.fs', ->
        offParent = undefined
        parent = undefined
        if !disabled
          trigger.toggleClass 'open'
          if isiOS and !settings.forceiOS
            if trigger.hasClass('open')
              return sel.focus()
          else
            if trigger.hasClass('open')
              parent = trigger.parent()
              offParent = parent.offsetParent()
              if parent.offset().top + parent.outerHeight() + options.outerHeight() + 20 > $(window).height() + $(window).scrollTop()
                options.addClass 'overflowing'
              else
                options.removeClass 'overflowing'
            options.toggleClass 'open'
            if !isiOS
              return sel.focus()
        return
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
        if e.originalEvent and e.originalEvent.isTrusted
          e.stopPropagation()
        else
          updateTriggerText()
      sel.on 'keydown', (e) ->
        hovered = undefined
        newHovered = undefined
        w = undefined
        w = e.which
        hovered = options.find('.hover')
        hovered.removeClass 'hover'
        if !options.hasClass('open')
          if w == 13 or w == 32 or w == 38 or w == 40
            e.preventDefault()
            return trigger.trigger('click.fs')
        else
          if w == 38
            e.preventDefault()
            if hovered.length and hovered.index() > 0
              hovered.prev().addClass 'hover'
            else
              options.find('li:last-child').addClass 'hover'
          else if w == 40
            e.preventDefault()
            if hovered.length and hovered.index() < options.find('li').length - 1
              hovered.next().addClass 'hover'
            else
              options.find('li:first-child').addClass 'hover'
          else if w == 27
            e.preventDefault()
            trigger.trigger 'click.fs'
          else if w == 13
            e.preventDefault()
            hovered.trigger 'mousedown.fs'
          else if w == 9
            if trigger.hasClass('open')
              trigger.trigger 'close.fs'
          else
            clearTimeout searchTimeout
            searchTimeout = setTimeout((->
              searchTerm = ''
              return
            ), 500)
            searchTerm += String.fromCharCode(w).toLowerCase()
            optCount = options.find('li').length + 1
            i = 1
            while i < optCount
              current = options.find('li:nth-child(' + i + ')')
              text = current.text()
              if text.toLowerCase().indexOf(searchTerm) >= 0
                current.addClass 'hover'
                return
              i++
          newHovered = options.find('.hover')
          if newHovered.length
            options.scrollTop 0
            return options.scrollTop(newHovered.position().top - 12)
        return
      options.on 'mousedown.fs', 'li', (e) ->
        clicked = undefined
        clicked = $(this)
        sel.val clicked.data('raw-value')
        if !isiOS
          sel.trigger('blur.fs').trigger 'focus.fs'
        options.find('.selected').removeClass 'selected'
        clicked.addClass 'selected'
        trigger.toggleClass 'selected', clicked.data('raw-value') != ''
        sel.val(clicked.data('raw-value')).trigger('change.fs').trigger('blur.fs').trigger 'focus.fs'
      options.on 'mouseenter.fs', 'li', ->
        hovered = undefined
        nowHovered = undefined
        nowHovered = $(this)
        hovered = options.find('.hover')
        hovered.removeClass 'hover'
        nowHovered.addClass 'hover'
      options.on 'mouseleave.fs', 'li', ->
        options.find('.hover').removeClass 'hover'

      copyOptionsToList = ->
        selOpts = undefined
        updateTriggerText()
        if isiOS and !settings.forceiOS
          return
        selOpts = sel.find('option')
        sel.find('option').each (i, opt) ->
          optHtml = undefined
          opt = $(opt)
          if !opt.prop('disabled') and (opt.val() or settings.includeBlank)
            optHtml = settings.optionTemplate(opt)
            if opt.prop('selected')
              return options.append('<li data-raw-value="' + opt.val() + '" class="selected">' + optHtml + '</li>')
            else
              return options.append('<li data-raw-value="' + opt.val() + '">' + optHtml + '</li>')
          return

      sel.on 'update.fs', ->
        wrapper.find('.options').empty()
        copyOptionsToList()
      copyOptionsToList()

  return
).call this