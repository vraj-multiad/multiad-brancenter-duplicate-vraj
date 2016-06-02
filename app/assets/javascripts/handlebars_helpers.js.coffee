Handlebars.registerHelper 'nobreak', (options) ->
  string = options.fn(this)
  string = string.replace /[ ]/g, '&nbsp;' # https://github.com/jashkenas/coffeescript/issues/3410
  string.replace /-/g, '&#8209;' # non-breaking hyphen
