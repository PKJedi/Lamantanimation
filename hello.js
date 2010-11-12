(function() {
  var counter, footer, header, http, pageString;
  http = require('http');
  counter = 0;
  header = '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title>tappe.lu</title>\n\n  <link href="/css/layout.css" media="screen" rel="stylesheet" type="text/css" >\n</head>\n<body>';
  footer = '\n  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>\n  <!--[if IE]><script src="/js/html5.js"></script><![endif]-->\n  <script src="/js/mt.js"></script>\n  <script src="/js/site.js"></script>\n</body></html>';
  pageString = function() {
    var _a, _b, _c, _d, content;
    return header + "  " + ((function() {
      _a = []; _c = arguments;
      for (_b = 0, _d = _c.length; _b < _d; _b++) {
        content = _c[_b];
        _a.push(content);
      }
      return _a;
    }).apply(this, arguments).join("\n  ")) + footer;
  };
  http.createServer(function(req, res) {
    var page;
    res.writeHead(200, {
      'Content-Type': 'text/html'
    });
    page = ['<!-- http://open.spotify.com/album/3sauBmGWcRtEw4BI84yS2t -->', '<audio preload="auto" autobuffer autoplay loop>', '  <source src="manatee.ogg" type="audio/ogg; codecs=vorbis" />', '  <source src="manatee.mp3" type="audio/mpeg" /> -->', '</audio>', 'Hello World, ' + (counter += 1), '<canvas id="canvas" width="1920" height="1200"></canvas>'];
    return res.end(pageString.apply(this, page));
  }).listen(8081, "127.0.0.1");
  console.log('Server running at http://127.0.0.1:8081/');
})();
