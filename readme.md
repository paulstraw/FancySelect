FancySelect
===========

A better select for discerning web developers everywhere, lovingly crafted by [Octopus Creative](http://octopuscreative.com). You can download it here, or [check out the demo](http://code.octopuscreative.com/fancyselect/).

Basic Usage
-----------

FancySelect is easy to use. Just include jQuery or Zepto, target any `select` element on the page, and call `.fancySelect()` on it. If the select has an option with no value, it'll be used as a sort of placeholder text.

By default, FancySelect uses native selects and styles only the trigger on iOS devices. To override this, pass an object with `forceiOS` set to `true` when initializing it.

FancySelect also passes any classes specified in the select's `data-class` attribute, which you can use to style specific FancySelect instances.


### HTML

``` html
<select class="basic">
  <option value="">Select something…</option>
  <option>Lorem</option>
  <option>Ipsum</option>
  <option>Dolor</option>
  <option>Sit</option>
  <option>Amet</option>
</select>
```

### JavaScript

``` javascript
$('.basic').fancySelect();
```


Updating Options
----------------

If the options in your select change after initializing FancySelect, you can tell it to rebuild the list of options by triggering `update.fs` on the select element.

### JavaScript

``` javascript
var mySelect = $('.my-select');

mySelect.fancySelect();

mySelect.append('<option>Foo</option><option>Bar</option>');

mySelect.trigger('update.fs');
```

Enabling/Disabling
------------------

FancySelect will automatically pick up your `select`'s `disabled` property on initialization. If you need to enable or disable it again later, you can do that by triggering `enable.fs` or `disable.fs` on your select element.

### HTML

``` html
<select class="my-select" disabled>
	<option>First Option</option>
	<option>Second Option</option>
</select>
```

### JavaScript

``` javascript
var mySelect = $('.my-select');
mySelect.fancySelect(); // currently disabled because of html property

// later…
mySelect.trigger('enable.fs'); // now enabled

// even later…
mySelect.trigger('disable.fs'); // now disabled again
```


Including Blank Option
----------------------

FancySelect can include the blank option in the options list if you pass the `includeBlank` parameter:

### JavaScript

```
var mySelect = $('.my-select');
mySelect.fancySelect({includeBlank: true});
```

Templates
---------

If you need to do something fancy with the trigger or the individual options, you can use `triggerTemplate` or `optionTemplate`, which are both functions passed an `option` element (jQuery-wrapped) and returning an HTML string to render.


### HTML

``` html
<select class="bulbs">
	<option data-icon="old">Incandescent</option>
	<option data-icon="curly">CFL</option>
	<option data-icon="work">Halogen</option>
</select>
```

``` javascript
$('.bulbs').fancySelect({
	optionTemplate: function(optionEl) {
		return optionEl.text() + '<div class="icon-' + optionEl.data('icon') + '"></div>';
	}
}
})
```

Triggering the change event
---------------------------

You can listen to the `change.fs` event in order to trigger the DOM's change event on the `<select>` element.

### HTML

``` html
<select class="my-select" disabled>
	<option>First Option</option>
	<option>Second Option</option>
</select>
```

### JavaScript

``` javascript
var mySelect = $('.my-select');
mySelect.fancySelect().on('change.fs', function() {
	$(this).trigger('change.$');
}); // trigger the DOM's change event when changing FancySelect
```


Contributions
-------------

Any contribution is absolutely welcome, but please review the contribution guidelines before getting started.

