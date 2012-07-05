(function() {
  var larva;

  larva = (function() {
    return {
      requestAnimationFrame: (function() {
        var fn;
        fn = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
          return window.setTimeout(callback, 1000 / 60);
        };
        return function() {
          return fn.apply(window, arguments);
        };
      })(),
      cancelRequestAnimationFrame: (function() {
        var fn;
        fn = window.cancelCancelRequestAnimationFrame || window.webkitCancelRequestAnimationFrame || window.mozCancelRequestAnimationFrame || window.oCancelRequestAnimationFrame || window.msCancelRequestAnimationFrame || window.clearTimeout;
        return function() {
          return fn.apply(window, arguments);
        };
      })()
    };
  })();

  if (typeof define !== "undefined" && define !== null) {
    define(larva);
  } else {
    window.Larva = larva;
  }

}).call(this);
