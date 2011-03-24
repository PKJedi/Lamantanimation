drawBobbingImage = (ctx, img, time, w, h, x, y) ->
  ctx.save()
  ctx.translate x, y
  ctx.rotate Math.PI*2/360*30 * (Math.sin(time/250)/10)
  ctx.drawImage img, -w/2, -h/2, w, h
  ctx.restore()

w = $(window).width()
h = $(window).height()
lastTime = (new Date()).getTime()
originPos = w/2
players = [{x: -200, y: 86, dx: 0, dy: 0}]
animating = true
animateNext = true

generateWavePositions = ->
  positions = []
  wMT = new MersenneTwister(1337)
  r = 50
  phi = 0
  pos = {x: 0, y: 0}
  while Math.abs(pos.x)-30 < w/2 || Math.abs(pos.y) < h/2
    r += (5 + wMT.random()*10)/(r/200)
    phi = r/15
    pos = {x: r*Math.cos(phi), y: r*Math.sin(phi), lastPos: {x: 0, y: 0}}
    positions.push pos if Math.abs(pos.x)-30 < w/2 && Math.abs(pos.y) < h/2
  return positions
wavePositions = generateWavePositions()

drawMovingWaves = (ctx, time) ->
  wMove = w + 90
  originPos = (wMove + originPos - (time - lastTime)/20)%wMove
  ctx.strokeStyle = 'rgb(0,0,255)'
  
  for start in wavePositions
    pos =
      x: (originPos + w/2 + start.x)%wMove - 60
      y: (start.y + h/2)
    ctx.clearRect start.lastPos.x - 21, start.lastPos.y - 21, 82, 42
    start.lastPos = pos
    ctx.clearRect 0, 0, 82, 42
    ctx.beginPath()
    ctx.arc pos.x, pos.y, 20, -Math.PI/8, -7/8*Math.PI, true
    ctx.stroke()
    ctx.beginPath()
    ctx.arc pos.x + 37, pos.y - 16, 20, Math.PI/8, 7/8*Math.PI, false
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

getDrawImage = (ctx, img) ->
  drawImage = ->
    if !animating && !animateNext
      return
    animateNext = false
    time = (new Date()).getTime()

    ctx.clearRect w/2 - 300, h/2 - 200, 600, 400
    for player in players
      ctx.clearRect w/2 + player.x - 100, h/2 + player.y - 143, 202, 186
      player.x += player.dx
      player.y += player.dy
      player.dx = 0
      player.dy = 0
    drawMovingWaves ctx, time
    drawBobbingImage ctx, img, time,       500, 215, w/2,  h/2
    
    ctx.font = '14px sans-serif'
    ctx.textBaseline = 'top'

    for player in players
      drawBobbingImage ctx, img, time - 250, 200, 86, w/2 + player.x, h/2 + player.y
      drawPlayerText ctx, w/2 + player.x, h/2 + player.y, player.text if player.text
    
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
  '  <object type="application/x-shockwave-flash" width="0" height="0" data="xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1">',
  '    <param name="movie" value=xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1" />',
  '  </object>',
]


$ ->
  a = $('audio')[0]
  support = false
  try
    support = !!a.canPlayType && !!a.play && !((a.canPlayType('audio/ogg') == 'no' || a.canPlayType('audio/ogg') == '') && (a.canPlayType('audio/mpeg') == 'no' || a.canPlayType('audio/mpeg') == ''))
  catch e
    support = false
  $('body').append flashRows.join '\n' if !support
  
  ctx = $('#canvas')[0].getContext '2d'
  w = $(window).width()
  h = $(window).height()
  ctx.canvas.width = w
  ctx.canvas.height = h
  ctx.clearRect 0, 0, w, h

  img = new Image()
  waiter = Object.create waiterProto
  waiter.link img, [
    '/img/lamantiini.svg', 
    '/img/lamantiini.png'
  ]
  img.onload = ->
    setInterval (getDrawImage ctx, img), 35
  waiter.check()
  
  $(window).resize ->
    w = $(window).width()
    h = $(window).height()
    ctx.clearRect 0, 0, w, h
    ctx.canvas.width = w
    ctx.canvas.height = h
    wavePositions = generateWavePositions()
  
  socket = new io.Socket('tappe.lu', {port: 8082})
  socket.connect()
  socket.on 'message', (message) ->
    found = false
    for player in players
      if player.sessionId == message.sessionId
        found = true
        player.dx = message.x - player.x + message.dx
        player.dy = message.y - player.y + message.dy
        player.text = message.text
    if !found
      players.push message
    animateNext = true
      

  window.pressed = {up: 0, down: 0, left: 0, right: 0}
  $(document).bind 'keydown', (event) ->
    switch event.keyCode
      when 37 then pressed.left = 1
      when 38 then pressed.up = 1
      when 39 then pressed.right = 1
      when 40 then pressed.down = 1
  $(document).bind 'keyup', (event) ->
    switch event.keyCode
      when 37 then pressed.left = 0
      when 38 then pressed.up = 0
      when 39 then pressed.right = 0
      when 40 then pressed.down = 0
  $('textarea').bind 'keydown', ->
    return
  .bind 'keyup', ->
    animateNext = true
    players[0].text = $('textarea').val()
    socket.send players[0]
  $('input.music').click ->
    if $('audio')[0].paused
      $('audio')[0].play()
    else
      $('audio')[0].pause()
  $('input.animation').click ->
    animating = !animating
  
  setInterval ->
    players[0].dx += (pressed.right - pressed.left)*5
    players[0].dy += (pressed.down - pressed.up)*5
    if players[0].dx || players[0].dy
      socket.send players[0]
      animateNext = true
  , 33
