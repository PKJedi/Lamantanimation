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
  

getDrawImage = (ctx, img) ->
  drawImage = ->
    time = (new Date()).getTime()

    ctx.clearRect w/2 - 300, h/2 - 200, 600, 400
    drawMovingWaves ctx, time
    drawBobbingImage ctx, img, time,       500, 215, w/2,  h/2
    drawBobbingImage ctx, img, time - 250, 200, 86,  w/2 - 160, h/2 + 60
    
    lastTime = time
    setTimeout drawImage, 35

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
  img = new Image()
  waiter = Object.create waiterProto
  waiter.link img, [
    '/img/lamantiini.svg', 
    '/img/lamantiini.png'
  ]
  img.onload = getDrawImage ctx, img
  waiter.check()
  
  $(window).resize ->
    w = $(window).width()
    h = $(window).height()
    ctx.clearRect 0, 0, w, h
    ctx.canvas.width = w
    ctx.canvas.height = h
    wavePositions = generateWavePositions()
