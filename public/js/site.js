(function() {
  var animateNext, animating, drawBobbingImage, drawMovingWaves, drawPlayerText, drawText, drawTextBubble, flashRows, generateWavePositions, getDrawImage, h, lastTime, originPos, players, w, waiterProto, wavePositions;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  drawBobbingImage = function(ctx, img, time, w, h, x, y) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(Math.PI * 2 / 360 * 30 * (Math.sin(time / 250) / 10));
    ctx.drawImage(img, -w / 2, -h / 2, w, h);
    return ctx.restore();
  };
  w = $(window).width();
  h = $(window).height();
  lastTime = (new Date()).getTime();
  originPos = w / 2;
  players = [
    {
      x: -200,
      y: 86,
      dx: 0,
      dy: 0
    }
  ];
  animating = true;
  animateNext = true;
  generateWavePositions = function() {
    var phi, pos, positions, r, wMT;
    positions = [];
    wMT = new MersenneTwister(1337);
    r = 50;
    phi = 0;
    pos = {
      x: 0,
      y: 0
    };
    while (Math.abs(pos.x) - 30 < w / 2 || Math.abs(pos.y) < h / 2) {
      r += (5 + wMT.random() * 10) / (r / 200);
      phi = r / 15;
      pos = {
        x: r * Math.cos(phi),
        y: r * Math.sin(phi),
        lastPos: {
          x: 0,
          y: 0
        }
      };
      if (Math.abs(pos.x) - 30 < w / 2 && Math.abs(pos.y) < h / 2) {
        positions.push(pos);
      }
    }
    return positions;
  };
  wavePositions = generateWavePositions();
  drawMovingWaves = function(ctx, time) {
    var pos, start, wMove, _i, _len, _results;
    wMove = w + 90;
    originPos = (wMove + originPos - (time - lastTime) / 20) % wMove;
    ctx.strokeStyle = 'rgb(0,0,255)';
    _results = [];
    for (_i = 0, _len = wavePositions.length; _i < _len; _i++) {
      start = wavePositions[_i];
      pos = {
        x: (originPos + w / 2 + start.x) % wMove - 60,
        y: start.y + h / 2
      };
      ctx.clearRect(start.lastPos.x - 21, start.lastPos.y - 21, 82, 42);
      start.lastPos = pos;
      ctx.clearRect(0, 0, 82, 42);
      ctx.beginPath();
      ctx.arc(pos.x, pos.y, 20, -Math.PI / 8, -7 / 8 * Math.PI, true);
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(pos.x + 37, pos.y - 16, 20, Math.PI / 8, 7 / 8 * Math.PI, false);
      _results.push(ctx.stroke());
    }
    return _results;
  };
  drawTextBubble = function(ctx) {
    ctx.fillStyle = 'rgb(255,255,255)';
    ctx.strokeStyle = 'rgb(0,0,0)';
    ctx.beginPath();
    ctx.moveTo(0, 20);
    ctx.quadraticCurveTo(-20, 20, -20, -20);
    ctx.lineTo(-100, -20);
    ctx.quadraticCurveTo(-120, -20, -120, -40);
    ctx.lineTo(-120, -100);
    ctx.quadraticCurveTo(-120, -120, -100, -120);
    ctx.lineTo(20, -120);
    ctx.quadraticCurveTo(40, -120, 40, -100);
    ctx.lineTo(40, -40);
    ctx.quadraticCurveTo(40, -20, 20, -20);
    ctx.lineTo(-10, -20);
    ctx.quadraticCurveTo(-10, 20, 0, 20);
    ctx.fill();
    return ctx.stroke();
  };
  drawText = function(ctx, x, y, text, width, maxLines) {
    var line, lineNum, overflow, _i, _len, _ref;
    lineNum = 0;
    overflow = '';
    _ref = text.split('\n');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      if (lineNum >= maxLines) {
        continue;
      }
      line = overflow + line;
      overflow = '';
      while (ctx.measureText(line).width > width && line.length > 2) {
        overflow = line.slice(-1) + overflow;
        line = line.slice(0, -1);
      }
      ctx.fillText(line, x, y + lineNum * 20, width);
      lineNum += 1;
    }
    if (lineNum < maxLines) {
      return drawText(ctx, x, y + lineNum * 20, overflow, width, maxLines - lineNum);
    }
  };
  drawPlayerText = function(ctx, x, y, text) {
    ctx.save();
    ctx.translate(x + 60, y - 10);
    drawTextBubble(ctx);
    ctx.fillStyle = 'rgb(0,0,0)';
    drawText(ctx, -110, -110, text, 140, 4);
    return ctx.restore();
  };
  getDrawImage = function(ctx, img) {
    var drawImage;
    return drawImage = function() {
      var player, time, _i, _j, _len, _len2;
      if (!animating && !animateNext) {
        return;
      }
      animateNext = false;
      time = (new Date()).getTime();
      ctx.clearRect(w / 2 - 300, h / 2 - 200, 600, 400);
      for (_i = 0, _len = players.length; _i < _len; _i++) {
        player = players[_i];
        ctx.clearRect(w / 2 + player.x - 100, h / 2 + player.y - 143, 202, 186);
        player.x += player.dx;
        player.y += player.dy;
        player.dx = 0;
        player.dy = 0;
      }
      drawMovingWaves(ctx, time);
      drawBobbingImage(ctx, img, time, 500, 215, w / 2, h / 2);
      ctx.font = '14px sans-serif';
      ctx.textBaseline = 'top';
      for (_j = 0, _len2 = players.length; _j < _len2; _j++) {
        player = players[_j];
        drawBobbingImage(ctx, img, time - 250, 200, 86, w / 2 + player.x, h / 2 + player.y);
        if (player.text) {
          drawPlayerText(ctx, w / 2 + player.x, h / 2 + player.y, player.text);
        }
      }
      return lastTime = time;
    };
  };
  waiterProto = {
    img: null,
    possibilities: [],
    pos: 0,
    drawn: false,
    link: function(img, possibilities) {
      this.img = img;
      this.possibilities = possibilities;
      this.check = __bind(function() {
        if (this.drawn) {
          return;
        }
        if (this.possibilities[this.pos]) {
          return this["try"]();
        }
      }, this);
      this["try"] = __bind(function() {
        this.img.src = this.possibilities[this.pos];
        return this.pos += 1;
      }, this);
      return img.onerror = this.check;
    }
  };
  if (typeof Object.create !== 'function') {
    Object.create = function(o) {
      var F;
      F = function() {};
      F.prototype = o;
      return new F();
    };
  }
  flashRows = ['  <object type="application/x-shockwave-flash" width="0" height="0" data="xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1">', '    <param name="movie" value=xspf_player_slim.swf?playlist_url=pl.xspf&autoplay=1&repeat_playlist=1" />', '  </object>'];
  $(function() {
    var a, ctx, img, socket, support, waiter;
    a = $('audio')[0];
    support = false;
    try {
      support = !!a.canPlayType && !!a.play && !((a.canPlayType('audio/ogg') === 'no' || a.canPlayType('audio/ogg') === '') && (a.canPlayType('audio/mpeg') === 'no' || a.canPlayType('audio/mpeg') === ''));
    } catch (e) {
      support = false;
    }
    if (!support) {
      $('body').append(flashRows.join('\n'));
    }
    ctx = $('#canvas')[0].getContext('2d');
    w = $(window).width();
    h = $(window).height();
    ctx.canvas.width = w;
    ctx.canvas.height = h;
    ctx.clearRect(0, 0, w, h);
    img = new Image();
    waiter = Object.create(waiterProto);
    waiter.link(img, ['/img/lamantiini.svg', '/img/lamantiini.png']);
    img.onload = function() {
      return setInterval(getDrawImage(ctx, img), 35);
    };
    waiter.check();
    $(window).resize(function() {
      w = $(window).width();
      h = $(window).height();
      ctx.clearRect(0, 0, w, h);
      ctx.canvas.width = w;
      ctx.canvas.height = h;
      return wavePositions = generateWavePositions();
    });
    socket = new io.Socket('tappe.lu', {
      port: 8082
    });
    socket.connect();
    socket.on('message', function(message) {
      var found, player, _i, _len;
      found = false;
      for (_i = 0, _len = players.length; _i < _len; _i++) {
        player = players[_i];
        if (player.sessionId === message.sessionId) {
          found = true;
          player.dx = message.x - player.x + message.dx;
          player.dy = message.y - player.y + message.dy;
          player.text = message.text;
        }
      }
      if (!found) {
        players.push(message);
      }
      return animateNext = true;
    });
    window.pressed = {
      up: 0,
      down: 0,
      left: 0,
      right: 0
    };
    $(document).bind('keydown', function(event) {
      switch (event.keyCode) {
        case 37:
          return pressed.left = 1;
        case 38:
          return pressed.up = 1;
        case 39:
          return pressed.right = 1;
        case 40:
          return pressed.down = 1;
      }
    });
    $(document).bind('keyup', function(event) {
      switch (event.keyCode) {
        case 37:
          return pressed.left = 0;
        case 38:
          return pressed.up = 0;
        case 39:
          return pressed.right = 0;
        case 40:
          return pressed.down = 0;
      }
    });
    $('textarea').bind('keydown', function() {}).bind('keyup', function() {
      animateNext = true;
      players[0].text = $('textarea').val();
      return socket.send(players[0]);
    });
    $('input.music').click(function() {
      if ($('audio')[0].paused) {
        return $('audio')[0].play();
      } else {
        return $('audio')[0].pause();
      }
    });
    $('input.animation').click(function() {
      return animating = !animating;
    });
    return setInterval(function() {
      players[0].dx += (pressed.right - pressed.left) * 5;
      players[0].dy += (pressed.down - pressed.up) * 5;
      if (players[0].dx || players[0].dy) {
        socket.send(players[0]);
        return animateNext = true;
      }
    }, 33);
  });
}).call(this);
