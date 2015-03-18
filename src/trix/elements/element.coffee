{cloneFragment, handleEvent, makeElement, makeFragment, triggerEvent} = Trix

class HTMLElement
  @prototype = Object.create window.HTMLElement.prototype,
    constructor:
      writable: true
      value: this

class Trix.Element extends HTMLElement
  createdCallback: ->
    @loadStylesheet()
    @loadDefaultContent()
    handleEvent "element-attached", onElement: this, withCallback: (event) =>
      @childAttachedCallback(event.target) unless event.target is this

  attachedCallback: ->
    triggerEvent("element-attached", onElement: this)

  childAttachedCallback: ->

  detachedCallback: ->

  loadStylesheet: ->
    tagName = @tagName.toLowerCase()
    return if document.querySelector("style[data-tag-name='#{tagName}']")

    element = makeElement("style", type: "text/css")
    element.setAttribute("data-tag-name", tagName)
    element.textContent = @getDefaultCSS()

    head = document.querySelector("head")
    head.insertBefore(element, head.firstChild)
    element

  loadDefaultContent: ->
    if @innerHTML is ""
      if content = @getDefaultContent()
        @appendChild(content)

  getDefaultCSS: (css = @constructor.defaultCSS) ->
    css = "%t { display: block }\n#{[css]}"
    css.replace(/%t/g, @tagName.toLowerCase())

  getDefaultContent: ->
    if @constructor.defaultContent?
      cloneFragment(@constructor.defaultContent)
    else if @constructor.defaultHTML?
      makeFragment(@constructor.defaultHTML)
