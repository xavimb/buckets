_ = require 'underscore'
getSlug = require 'speakingurl'

module.exports =
  render: ->
    @delegate 'keyup', 'input[data-sluggify]', @keyUpSluggify

    # Defer to ensure view is fully rendered
    _.defer =>
      return if @disposed

      # Automatically focus the first visible input (on non-touch devices)
      $firstField = @$('.form-control').eq(0)
      $firstField.focus() unless Modernizr.touch

      # Prep slugs
      @$('.input-slug').each (i, el) ->
        $slug = $(el)
        $slug.data 'has-value', $slug.val()?.length > 0

  formParams: ->
    # Uses jQuery formParams, but don't try to convert number values to numbers, etc.
    @$el.formParams no

  submit: (promise) ->
    $btn = @$('.ladda-button').ladda()
    $btn.ladda 'start'

    promise.always ->
      $btn.ladda 'stop' if $btn?.data('ladda')
    .fail _.bind(@renderServerErrors, @)

  renderServerErrors: (res) ->
    # First let's get rid of the old ones
    @clearFormErrors()

    if errors = res?.responseJSON?.errors
      _.each errors, (error) =>
        if error.type is 'required' or error.message is 'required'
          message = '<span class="label label-danger">Required</span>'
        else
          message = error.message

        @$ """[name="#{error.path}"]"""
          .closest '.form-group'
          .find('.help-block').remove().end()
          .addClass 'has-error'
          .append """
            <span class="help-block">#{message}</span>
          """

      @$('.has-error').eq(0).find('[name]').eq(0).focus()

  clearFormErrors: ->
    @$('.help-block').remove()
    @$('.has-error').removeClass('has-error')

  keyUpSluggify: (e) ->
    $el = @$(e.currentTarget)
    val = $el.val()
    $target = @$("input[name=\"#{$el.data('sluggify')}\"]")

    return if $target.data('has-value')

    $target.val getSlug val
