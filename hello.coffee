http = require 'http'
io = require 'socket.io'

counter = 0

header = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>tappe.lu</title>

  <link href="/css/layout.css" media="screen" rel="stylesheet" type="text/css" >
</head>
<body>
'''

footer = '''

  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
  <!--[if IE]><script src="/js/html5.js"></script><![endif]-->
  <script src="/js/mt.js"></script>
  <script src="http://tappe.lu:8082/socket.io/socket.io.js"></script>
  <script src="/js/site.js"></script>
</body></html>
'''

pageString = ->
  header + "  " + ((content for content in arguments).join "\n  ") + footer

server = http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/html'}
  page = [
    '<!-- http://open.spotify.com/album/3sauBmGWcRtEw4BI84yS2t -->',
    '<audio preload="auto" autobuffer autoplay loop>',
    '  <source src="manatee.ogg" type="audio/ogg; codecs=vorbis" />',
    '  <source src="manatee.mp3" type="audio/mpeg" /> -->',
    '</audio>', 
    '<canvas id="canvas" width="1920" height="1200"></canvas>',
    '<div><textarea x-webkit-speech="x-webkit-speech">MMO Lamantarium\narrow keys\nedit this\nchrome works</textarea>',
    '<input type="button" value="music" class="music" /><input type="button" value="animation" class="animation" /></div>'
  ]
  res.end pageString page...
server.listen 8081, "localhost"

ioServer = http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/html'}
  res.end 'blah'
ioServer.listen 8082

buffer = {}
socket = io.listen ioServer
socket.on 'connection', (client) ->
  for sessionId, message of buffer
    client.send message
  client.on 'message', (message) ->
    message.sessionId = client.sessionId
    buffer['' + client.sessionId] = message
    client.broadcast message
  client.on 'disconnect', ->
    message = buffer['' + client.sessionId]
    return if !message
    message.x = 10000
    message.y = 10000
    client.broadcast message
    delete buffer['' + client.sessionId]

console.log 'Server running at http://127.0.0.1:8081/ & *:8082'


