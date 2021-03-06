# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
# -----------------------------------------------------------------------------
# INPUT INVERTER
# -----------------------------------------------------------------------------

# _slugify(string)
if ! @_slugify
  @_slugify = (string) ->
    return string.toString().toLowerCase()
      .replace(/\s+/g, '-')           # Replace spaces with -
      .replace(/[^\w\-]+/g, '')       # Remove all non-word chars
      .replace(/\-\-+/g, '-')         # Replace multiple - with single -
      .trim()                         # Trim - from start/end of text

class @InputInverter
  constructor: (@name, @value, @config, @object) ->
    @startsWith = @config.startsWith
    @_create_el()

    @inputs = {}

    for name, value of @value
      input = @_add_input(name, value, @config)
      @inputs[name] = input
      @$el.append input.$el

    return this

  # PRIVATE ===================================================================

  _create_el: ->
    @$el =$ "<div class='input-#{ @config.type } #{ @config.klassName }'>"

  _add_input: (name, value) ->
    inputConfig = $.extend {}, @config

    # get input label and type from name, e.g. "Page Title : text"
    labelAndType = name.split(' : ')

    # input label
    inputConfig.label = labelAndType[0].titleize()

    # input type
    inputType  = labelAndType[1]
    inputType ?= @config.defaultInputType || 'text'
    inputType  = $.trim(inputType)

    if ! formagicInputs[inputType]
      inputType = 'text'

    if @startsWith
      # update label if @startsWith is used
      inputConfig.label = inputConfig.label.replace(@startsWith, '').titleize()

      # use hidden input type for blocks that do not start with @startsWith
      if ! name.startsWith(@startsWith)
        inputType = 'hidden'

    # input css class
    inputConfig.klassName = 'inverter-block-' + _slugify(inputConfig.label)
    inputConfig.klass    ?= 'stacked'

    inputClass = formagicInputs[inputType]

    # here we have @config.namePrefix undefined, so the second case works
    # where @name is [_blocks] and name is the name of the block
    inputName = if @config.namePrefix then "#{ @config.namePrefix }#{ @name }[#{ name }]" else "#{ @name }[#{ name }]"
    inputConfig.namePrefix = @config.namePrefix
    # add extra config parameter to save the original block name for hash
    # function to work properly
    inputConfig.blockName = name

    return new inputClass(inputName, value, inputConfig, @object)

  # PUBLIC ====================================================================

  initialize: ->
    for name, input of @inputs
      input.initialize()

    @config.onInitialize?(this)

  hash: (hash={}) ->
    obj = {}
    # workaround for using block names to have consistency
    # while caching and versioning documents
    for key, input of @inputs
      obj[input.config.blockName] = input.$input.val()

    hash[@config.klassName] = obj
    return hash

  updateValue: (@value) ->
    for key, input of @inputs
      input.updateValue(@value[key])

  showErrorMessage: (message) -> ;

  hideErrorMessage: -> ;

formagicInputs['inverter'] = InputInverter
