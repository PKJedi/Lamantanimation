http = require 'http'

counter = 0

blast = [
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAUAgMAAADeh4MlAAAAAXNSR0IArs4c6QAAAAlQTFRFpGN1/wAA8P8AGDtHmgAAAAF0Uk5TAEDm2GYAAABRSURBVDjLY2AYBSAgGhpCD0tCHehhSQCt7WDNWrWUHpaspHmkcK2ivSWMUatWrRq1hJQ4ob0lwNRFF0uW0r5cEQ2jfWakW9lFh7KeHkX9YAIAVCcbn7esZH4AAAAASUVORK5CYII='
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAUAgMAAADeh4MlAAAAAXNSR0IArs4c6QAAAAlQTFRFpGMV/wAA8P8Ak40LfwAAAAF0Uk5TAEDm2GYAAABPSURBVDjLY2AYBUiANTSULpYE0MOSEFrbwRi1aiU9LFlF80hhWkUHS8KAlkwdtYSUOJlKj9RFD0tWhtIhx9M+M9Kt7HKgfTEsSoeiflAAAAXTHFOczYJ/AAAAAElFTkSuQmCC'
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAUAgMAAADeh4MlAAAAAXNSR0IArs4c6QAAAAlQTFRFpGPk/wAA8P8AUYQ6EgAAAAF0Uk5TAEDm2GYAAABPSURBVDjLY2AYBRiANTSULpYE0MOSEFrbwRi1aiU9LFlF80hhWkUHS8KAlkwdtYSUOJlKj9RFD0tWhtIhx9M+M9Kt7HKgfTEsSoeifoABAFvYHFOMa+WjAAAAAElFTkSuQmCC'
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAUAgMAAADeh4MlAAAAAXNSR0IArs4c6QAAAAlQTFRFpGO3/wAA8P8AQ7nJOAAAAAF0Uk5TAEDm2GYAAABPSURBVDjLY2AYBbgAa2goXSwJoIclIbS2gzFq1Up6WLKK5pHCtIoOloQBLZk6agkpcTKVHqmLHpasDKVDjqd9ZqRb2eVA+2JYlA5F/UABAJWLHFPEkf8jAAAAAElFTkSuQmCC'
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAAUAgMAAADeh4MlAAAAAXNSR0IArs4c6QAAAAlQTFRFpGOV/wAA8P8AG5vhjQAAAAF0Uk5TAEDm2GYAAACCSURBVDjLvdWxDcMwDERRQoAKewAXGUFTZAQXYgqPkCm8BHuW0U0ZeYivW+ABOlI0g9NuWihpLesbRmRtOI7kS4EjOhQnXbvEI0VxRccnONw7/lrh3w7XLo0VyAyN2OaX8OLrAqQMx0f4aeVDL+Oz76I/SCkPHknbcWRm/9UFyLyMf8aLM/aV2LSgAAAAAElFTkSuQmCC'
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAAXNSR0IArs4c6QAAAANQTFRFAAAAp3o92gAAAAF0Uk5TAEDm2GYAAAAKSURBVAjXY2AAAAACAAHiIbwzAAAAAElFTkSuQmCC'
]

header = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="user-scalable=no, width=device-width" />
  <title>tappe.lu</title>

  <link href="/css/layout.css" media="screen" rel="stylesheet" type="text/css" >
</head>
<body>
'''

footer = '''

  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
  <!--[if IE]><script src="/js/html5.js"></script><![endif]-->
  <script src="/js/mt.js"></script> <!-- Mersenne Twister for seedable random -->
  <script src="http://[HOST]/socket.io/socket.io.js"></script>
  <script src="/js/site.js"></script>
<audio preload="auto" autobuffer audio="true" src="Nerf_Herder_-_Stand_By_Your_Manatee.mp3">
  <source src="Nerf_Herder_-_Stand_By_Your_Manatee.ogg" type="audio/ogg; codecs=vorbis" />
  <source src="Nerf_Herder_-_Stand_By_Your_Manatee.mp3" type="audio/mpeg" />
</audio>
</body></html>
'''

pageString = ->
  header + "  " + ((content for content in arguments).join "\n  ") + footer

port = parseInt process.argv[2], 10

server = http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/html'}
  page = [
    '<canvas id="canvas" width="1920" height="1200"></canvas>',
    '<div><input type="button" value="music" class="music" /><input type="button" value="animation" class="animation" />'
    '<a href="http://oglio.com/nerf-herder-iv">Nerf Herder - (Stand By Your) Manatee</a>',
    '<textarea>Manatee chat pool\narrow keys or touch\nedit this textarea\ndrag an image here</textarea></div>',
  ]
  responseString = pageString page...
  responseString = responseString.replace /\[HOST\]/, req.headers.host
  res.end responseString
server.listen port

io = (require 'socket.io').listen server

io.configure 'production', ->
  io.enable 'browser client etag'
  io.set 'log level', 1

  io.set 'transports', [
    'websocket'
    'flashsocket'
    'htmlfile'
    'xhr-polling'
    'jsonp-polling'
  ]

buffer = {}
io.sockets.on 'connection', (socket) ->
  for id, message of buffer
    socket.emit 'player', message
  socket.on 'player', (message) ->
    message.id = socket.id
    broadcast = {}
    if buffer[socket.id]
      for key, value of message
        if value? && (typeof value != 'string' || value.length < 8096)
          buffer[socket.id][key] = value
          if key in ['x', 'y']
            buffer[socket.id].dx = 0
            buffer[socket.id].dy = 0
          broadcast[key] = value
    else
      buffer[socket.id] = message

    socket.broadcast.volatile.emit 'player', broadcast
  socket.on 'animation', (message) ->
    return if message.type != 'blast'
    animPos = 0
    emitFrame = (pos) ->
      socket.broadcast.volatile.emit 'player', {id: socket.id, image: blast[pos]}
      socket.volatile.emit 'you', {image: blast[pos]}
    animInterval = setInterval ->
      emitFrame animPos
      animPos += 1
      if animPos == blast.length - 1
        clearInterval animInterval
        setTimeout ->
          emitFrame animPos
        , 250
    , 100

  socket.on 'disconnect', ->
    message = buffer[socket.id]
    return if !message
    message.x = 10000
    message.y = 10000
    socket.broadcast.emit 'player', message
    delete buffer['' + socket.id]

console.log 'Server running at *:' + port


