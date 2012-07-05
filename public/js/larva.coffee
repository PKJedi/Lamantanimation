
larva = do () ->
  {
    requestAnimationFrame: do () ->
      fn =
        window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.oRequestAnimationFrame ||
        window.msRequestAnimationFrame ||
        (callback, element) ->
          window.setTimeout callback, 1000/60
      ->
        fn.apply window, arguments

    cancelRequestAnimationFrame: do () ->
      fn =
        window.cancelCancelRequestAnimationFrame ||
        window.webkitCancelRequestAnimationFrame ||
        window.mozCancelRequestAnimationFrame ||
        window.oCancelRequestAnimationFrame ||
        window.msCancelRequestAnimationFrame ||
        window.clearTimeout
      ->
        fn.apply window, arguments
  }

if define?
  define larva
else
  window.Larva = larva

