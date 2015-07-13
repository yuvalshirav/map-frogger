@App.Utils =

  # http://www.html5rocks.com/en/mobile/fullscreen/
  requestFullScreen: ->
    doc = window.document
    el = $('#map-wrapper')[0]

    requestFullScreen = el.requestFullscreen || el.mozRequestFullScreen || el.webkitRequestFullScreen || el.msRequestFullscreen
    cancelFullScreen = doc.exitFullscreen || doc.mozCancelFullScreen || doc.webkitExitFullscreen || doc.msExitFullscreen
    requestFullScreen.call(el)

    if !doc.fullscreenElement && !doc.mozFullScreenElement && !doc.webkitFullscreenElement && !doc.msFullscreenElement
      requestFullScreen.call(el)

  isMobileOrTablet: ->
    @mobileOrTablet ?= window.matchMedia("screen and (max-width: 767px), (min-device-width: 768px) and (max-device-width: 1024px)").matches

  getOrientation: ->
    window.screen?.orientation?.type?.split?('-')[0]

  loadGoogleMaps: ->
    new RSVP.Promise (resolve) ->
      window._resolveGoogleMapsLoaded = resolve
      script = document.createElement('script')
      script.type = 'text/javascript'
      script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=false&callback=_resolveGoogleMapsLoaded'
      document.body.appendChild(script)


