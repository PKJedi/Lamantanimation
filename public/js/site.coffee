drawBobbingImage = (ctx, img, time, w, h, x, y) ->
  ctx.save()
  ctx.translate x, y
  ctx.rotate Math.PI*2/360*30 * (Math.sin(time/250)/10)
  ctx.drawImage img, -w/2, -h/2, w, h
  ctx.restore()

w = $(window).width()
h = $(window).height()
scale = 980 / w
w /= scale
h /= scale
lastTime = (new Date()).getTime()
originPos = w/2
window.players = [{x: -200, y: 86, dx: 0, dy: 0}]
hostParts = document.location.hostname.split('.')
players[0].host = hostParts[0] if hostParts.length > 2
animating = true
animateNext = true
hostImages = {}

welcomeScreen = () ->
  html = '
<div class="welcome">
</div>
'

generateWavePositions = ->
  positions = []
  wMT = new MersenneTwister(1337)
  r = 50
  phi = 0
  pos = {x: 0, y: 0}
  while Math.abs(pos.x)-30 < w/2 || Math.abs(pos.y) < h/2
    r += (5 + wMT.random()*10)/(r/200)
    phi = r/15
    pos = {x: r*Math.cos(phi), y: r*Math.sin(phi), lastX: 0, lastY: 0}
    positions.push pos if Math.abs(pos.x)-30 < w/2 && Math.abs(pos.y) < h/2
  return positions
wavePositions = generateWavePositions()

drawMovingWaves = (ctx, time) ->
  wMove = w + 90
  originPos = (wMove + originPos - (time - lastTime)/20)%wMove
  ctx.strokeStyle = 'rgb(0,0,255)'
  
  for start in wavePositions
    x = (originPos + w/2 + start.x)%wMove - 60
    y = (start.y + h/2)
    
    ctx.clearRect start.lastX - 21, start.lastY - 21, 82, 42
    start.lastX = x
    start.lastY = y
    ctx.clearRect 0, 0, 82, 42
    ctx.beginPath()
    ctx.arc x, y, 20, -Math.PI/8, -7/8*Math.PI, true
    ctx.stroke()
    ctx.beginPath()
    ctx.arc x + 37, y - 16, 20, Math.PI/8, 7/8*Math.PI, false
    ctx.stroke()
  
drawTextBubble = (ctx) ->
  ctx.fillStyle = 'rgb(255,255,255)'
  ctx.strokeStyle = 'rgb(0,0,0)'
  ctx.beginPath()
  ctx.moveTo 0, 20
  ctx.quadraticCurveTo -20, 20, -20, -20
  ctx.lineTo -100, -20
  ctx.quadraticCurveTo -120, -20, -120, -40
  ctx.lineTo -120, -100
  ctx.quadraticCurveTo -120, -120, -100, -120
  ctx.lineTo 20, -120
  ctx.quadraticCurveTo 40, -120, 40, -100
  ctx.lineTo 40, -40
  ctx.quadraticCurveTo 40, -20, 20, -20
  ctx.lineTo -10, -20
  ctx.quadraticCurveTo -10, 20, 0, 20
  ctx.fill()
  ctx.stroke()

drawText = (ctx, x, y, text, width, maxLines) ->
  lineNum = 0
  overflow = ''
  for line in text.split '\n'
    continue if lineNum >= maxLines
    line = overflow + line
    overflow = ''
    while ctx.measureText(line).width > width && line.length > 2
      overflow = line.slice(-1) + overflow
      line = line.slice 0, -1
    ctx.fillText line, x, y + lineNum*20, width
    lineNum += 1
  drawText ctx, x, y + lineNum*20, overflow, width, maxLines - lineNum if lineNum < maxLines

drawPlayerText = (ctx, x, y, text) ->
  ctx.save()
  ctx.translate x + 60, y - 10
  drawTextBubble ctx
  ctx.fillStyle = 'rgb(0,0,0)'
  drawText ctx, -110, -110, text, 140, 4
  ctx.restore()

drawPlayerImage = (ctx, x, y, image) ->
  ctx.save()
  ctx.translate x, y
  ctx.drawImage image, -image.width/2, -image.height/2, image.width, image.height
  ctx.restore()

getDrawImage = (ctx, img) ->
  clearBuffer = []
  drawImage = ->
    if !animating && !animateNext
      return
    animateNext = false
    time = (new Date()).getTime()
    ctx.clearRect w/2 - 300, h/2 - 200, 600, 400

    for coords in clearBuffer
      ctx.clearRect coords...
    clearBuffer.length = 0

    for player in players
      player.x += player.dx
      player.y += player.dy
      clearBuffer.push([w/2 + player.x - 102, h/2 + player.y - 143, 204, 200])
      player.scale ?= 1
      player.scale = -1 if player.dx < 0
      player.scale = 1 if player.dx > 0

    #players[0].dx = 0
    #players[0].dy = 0
    drawMovingWaves ctx, time
    drawBobbingImage ctx, img, time,       500, 233, w/2,  h/2
    
    ctx.font = '14px sans-serif'
    ctx.textBaseline = 'top'

    for player in players
      playerImage = img
      if player.host && hostImages[player.host] && hostImages[player.host].width
        playerImage = hostImages[player.host]
      ctx.save()
      ctx.translate w/2 + player.x, h/2 + player.y
      ctx.scale player.scale, 1
      drawBobbingImage ctx, playerImage, time - 250, 200, 93, 0, 0
      drawPlayerText ctx, 0, 0, player.text if player.text
      drawPlayerImage ctx, 0, 0, player.Image if player.Image && player.Image.width
      ctx.restore()
    
    lastTime = time

# just for loading svg in supporting browser, needs refactor
waiterProto = {
  img: null
  possibilities: []
  pos: 0
  drawn: false
  link: (img, possibilities) ->
    @img = img
    @possibilities = possibilities
    @check = =>
      return if @drawn
      @try() if @possibilities[@pos]
    @try = =>
      @img.src = @possibilities[@pos]
      @pos += 1
    img.onerror = @check
}

# Crockfords Object.create
if typeof Object.create != 'function'
  Object.create = (o) ->
    F = ->
    F.prototype = o
    new F()

flashRows = [
  '  <object type="application/x-shockwave-flash" width="0" height="0" data="xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1">'
  '    <param name="movie" value=xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1" />'
  '  </object>'
]

$ ->
  $a = $ 'audio'
  a = $a[0]
  support = false
  try
    support = !!a.canPlayType && !!a.play && !((a.canPlayType('audio/ogg') == 'no' || a.canPlayType('audio/ogg') == '') && (a.canPlayType('audio/mpeg') == 'no' || a.canPlayType('audio/mpeg') == ''))
  catch e
    support = false
  flashPlaying = false
  if !support
    $('body').append flashRows.join '\n'
    flashPlaying = true
  else
    $a.bind 'canplaythrough', ->
      $a.unbind 'canplaythrough'
      $a.bind 'ended', ->
        this.pause()
        this.currentTime = 0
        this.play()
      a.play()
  
  ctx = $('#canvas')[0].getContext '2d'
  w = $(window).width()
  h = $(window).height()
  ctx.canvas.width = w
  ctx.canvas.height = h
  ctx.clearRect 0, 0, w, h
  scale = w / 980
  ctx.scale scale, scale
  w /= scale
  h /= scale
  wavePositions = generateWavePositions()

  img = new Image()
  waiter = Object.create waiterProto
  waiter.link img, [
    '/img/new_manatee.svg', 
    '/img/new_manatee.png'
  ]
  img.onload = ->
    setInterval (getDrawImage ctx, img), 35
  waiter.check()
  
  hostImages = {lapsi: 'svg', punainen: 'png', sininen: 'png', 'xn--vihre-kra': 'png'}
  for key, value of hostImages
    hostImage = new Image()
    hostImage.src = 'img/host/' + key + '.' + value
    hostImages[key] = hostImage
  
  $(window).resize ->
    w = $(window).width()
    h = $(window).height()
    ctx.clearRect 0, 0, w, h
    ctx.canvas.width = w
    ctx.canvas.height = h
    scale = w / 980
    ctx.scale scale, scale
    w /= scale
    h /= scale
    wavePositions = generateWavePositions()
  
  window.socket = io.connect()
  socket.on 'player', (message) ->
    found = false
    for player in players
      if player.id == message.id
        found = true
        if message.x? && message.y?
          player.x = message.x
          player.y = message.y
          player.dx = 0
          player.dy = 0
        else
          player.dx = message.dx if message.dx?
          player.dy = message.dy if message.dy?
        player.text = message.text if message.text?
        if message.image && player.image != message.image
          player.image = message.image
          player.Image ?= new Image()
          player.Image.src = player.image
        if message.host?
          player.host = message.host
    if !found && message.id
      if (message.image)
        message.Image = new Image()
        message.Image.src = message.image
      players.push message
        
    animateNext = true

  socket.on 'you', (message) ->
    if (message.image?)
      players[0].image = message.image
      players[0].Image ?= new Image()
      players[0].Image.src = players[0].image

  window.shoot = ->
    socket.emit 'animation', {type: 'blast'}
  
  $('textarea')[0].ondragover = () ->
    $('textarea').css 'background', 'silver'
    false
  $('textarea')[0].ondragend = () ->
    $('textarea').css 'background', 'white'
    false
  $('textarea')[0].ondrop = (event) ->
    event.preventDefault()
    file = event.dataTransfer.files[0]
    reader = new FileReader()
    reader.onload = (loadEvent) ->
      if loadEvent.target.result.length > 8096
        $('textarea').val "That's too big!"
        return
      players[0].image = loadEvent.target.result
      players[0].Image = new Image() if !players[0].Image
      players[0].Image.src = loadEvent.target.result
    reader.readAsDataURL(file)
    false

  window.pressed = {up: 0, down: 0, left: 0, right: 0}
  $(document).bind 'keydown', (event) ->
    switch event.keyCode
      when 37 then pressed.left = 1
      when 38 then pressed.up = 1
      when 39 then pressed.right = 1
      when 40 then pressed.down = 1
      when 17 then shoot()
  $(document).bind 'keyup', (event) ->
    switch event.keyCode
      when 37 then pressed.left = 0
      when 38 then pressed.up = 0
      when 39 then pressed.right = 0
      when 40 then pressed.down = 0
  ctx.canvas.ontouchstart = ->
    ctx.canvas.ontouchmove = (e) ->
      dx = e.touches[0].clientX - (w*scale)/2 - players[0].x*scale
      dy = e.touches[0].clientY - (h*scale)/2 - players[0].y*scale
      if dx > 50
        pressed.right = 1
        pressed.left = 0
      else if dx < -50
        pressed.left = 1
        pressed.right = 0
      else
        pressed.left = 0
        pressed.right = 0
      if dy > 50
        pressed.down = 1
        pressed.up = 0
      else if dy < -50
        pressed.up = 1
        pressed.down = 0
      else
        pressed.up = 0
        pressed.down = 0
      false
    ctx.canvas.ontouchend = (e) ->
      pressed = {up: 0, down: 0, left: 0, right: 0}
      ctx.canvas.ontouchmove = null
      ctx.canvas.ontouchend = null
  
  sendPlayer = do () ->
    lastPlayerSent = {}
    (player) ->
      playerToSend = {}
      always = ['host']
      for key, item of player
        playerToSend[key] = item if key in always || (key != 'Image' && !(key of lastPlayerSent && lastPlayerSent[key] == item))

      if player.dx != 0 || player.dy != 0
        delete playerToSend.x
        delete playerToSend.y
      else
        delete playerToSend.dx
        delete playerToSend.dy

      if playerToSend.x? || playerToSend.y?
        playerToSend.x = player.x
        playerToSend.y = player.y

      if not $.isEmptyObject playerToSend
        socket.emit 'player', playerToSend
        for key, item of playerToSend
          lastPlayerSent[key] = item
  
  editedText = false
  $('textarea').bind 'keydown', ->
    return
  .bind 'click', ->
    if !editedText
      $('textarea').val ''
    editedText = true
  .bind 'keyup', ->
    animateNext = true
    players[0].text = $('textarea').val()
    sendPlayer players[0]
  $('input.music').click ->
    if !support && flashPlaying
      $('object').remove()
      flashPlaying = false
    else if !support && !flashPlaying
      $('body').append flashRows.join '\n'
      flashPlaying = true
    else if support && $('audio')[0].paused
      $('audio')[0].play()
    else if support
      $('audio')[0].pause()
  $('input.animation').click ->
    animating = !animating
  
  setInterval ->
    players[0].dx = (pressed.right - pressed.left)*5
    players[0].dy = (pressed.down - pressed.up)*5

    sendPlayer players[0]

    if players[0].dx || players[0].dy
      animateNext = true
  , 33

