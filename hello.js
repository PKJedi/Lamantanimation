(function() {
  var buffer, counter, footer, header, http, io, ioServer, pageString, server, socket;
  http = require('http');
  io = require('socket.io');
  counter = 0;
  header = '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title>tappe.lu</title>\n\n  <link href="/css/layout.css" media="screen" rel="stylesheet" type="text/css" >\n</head>\n<body>';
  footer = '\n<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>\n<!--[if IE]><script src="/js/html5.js"></script><![endif]-->\n<script src="/js/mt.js"></script>\n<script src="http://tappe.lu:8082/socket.io/socket.io.js"></script>\n<script src="/js/site.js"></script>\n</body></html>';
  pageString = function() {
    var content;
    return header + "  " + (((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        content = arguments[_i];
        _results.push(content);
      }
      return _results;
    }).apply(this, arguments)).join("\n  ")) + footer;
  };
  server = http.createServer(function(req, res) {
    var page;
    res.writeHead(200, {
      'Content-Type': 'text/html'
    });
    page = ['<!-- http://open.spotify.com/album/3sauBmGWcRtEw4BI84yS2t -->', '<audio preload="auto" autobuffer autoplay loop>', '  <source src="manatee.ogg" type="audio/ogg; codecs=vorbis" />', '  <source src="manatee.mp3" type="audio/mpeg" /> -->', '</audio>', '<canvas id="canvas" width="1920" height="1200"></canvas>', '<div><textarea x-webkit-speech="x-webkit-speech">MMO Lamantarium\narrow keys\nedit this\nchrome works</textarea>', '<input type="button" value="music" class="music" /><input type="button" value="animation" class="animation" /></div>'];
    return res.end(pageString.apply(null, page));
  });
  server.listen(8081, "localhost");
  ioServer = http.createServer(function(req, res) {
    res.writeHead(200, {
      'Content-Type': 'text/html'
    });
    return res.end('blah');
  });
  ioServer.listen(8082);
  buffer = {};
  socket = io.listen(ioServer);
  socket.on('connection', function(client) {
    var message, sessionId;
    for (sessionId in buffer) {
      message = buffer[sessionId];
      client.send(message);
    }
    client.on('message', function(message) {
      message.sessionId = client.sessionId;
      buffer['' + client.sessionId] = message;
      return client.broadcast(message);
    });
    return client.on('disconnect', function() {
      message = buffer['' + client.sessionId];
      if (!message) {
        return;
      }
      message.x = 10000;
      message.y = 10000;
      client.broadcast(message);
      return delete buffer['' + client.sessionId];
    });
  });
  console.log('Server running at http://127.0.0.1:8081/ & *:8082');
}).call(this);
