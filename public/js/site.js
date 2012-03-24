(function() {
  var animateNext, animating, drawBobbingImage, drawMovingWaves, drawPlayerImage, drawPlayerText, drawText, drawTextBubble, flashRows, generateWavePositions, getDrawImage, h, hostImages, hostParts, lastTime, originPos, scale, w, waiterProto, wavePositions, welcomeScreen;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  drawBobbingImage = function(ctx, img, time, w, h, x, y) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(Math.PI * 2 / 360 * 30 * (Math.sin(time / 250) / 10));
    ctx.drawImage(img, -w / 2, -h / 2, w, h);
    return ctx.restore();
  };
  w = $(window).width();
  h = $(window).height();
  scale = 980 / w;
  w /= scale;
  h /= scale;
  lastTime = (new Date()).getTime();
  originPos = w / 2;
  window.players = [
    {
      x: -200,
      y: 86,
      dx: 0,
      dy: 0
    }
  ];
  hostParts = document.location.hostname.split('.');
  if (hostParts.length > 2) {
    players[0].host = hostParts[0];
  }
  animating = true;
  animateNext = true;
  hostImages = {};
  welcomeScreen = function() {
    var html;
    return html = '\
<div class="welcome">\
</div>\
';
  };
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
      w;
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
  drawPlayerImage = function(ctx, x, y, image) {
    ctx.save();
    ctx.translate(x, y);
    ctx.drawImage(image, -image.width / 2, -image.height / 2, image.width, image.height);
    return ctx.restore();
  };
  getDrawImage = function(ctx, img) {
    var clearBuffer, drawImage;
    clearBuffer = [];
    return drawImage = function() {
      var coords, player, playerImage, time, _i, _j, _k, _len, _len2, _len3, _ref;
      if (!animating && !animateNext) {
        return;
      }
      animateNext = false;
      time = (new Date()).getTime();
      ctx.clearRect(w / 2 - 300, h / 2 - 200, 600, 400);
      for (_i = 0, _len = clearBuffer.length; _i < _len; _i++) {
        coords = clearBuffer[_i];
        ctx.clearRect.apply(ctx, coords);
      }
      clearBuffer = [];
      for (_j = 0, _len2 = players.length; _j < _len2; _j++) {
        player = players[_j];
        player.x += player.dx;
        player.y += player.dy;
        clearBuffer.push([w / 2 + player.x - 102, h / 2 + player.y - 143, 204, 200]);
        if ((_ref = player.scale) == null) {
          player.scale = 1;
        }
        if (player.dx < 0) {
          player.scale = -1;
        }
        if (player.dx > 0) {
          player.scale = 1;
        }
      }
      players[0].dx = 0;
      players[0].dy = 0;
      drawMovingWaves(ctx, time);
      drawBobbingImage(ctx, img, time, 500, 233, w / 2, h / 2);
      ctx.font = '14px sans-serif';
      ctx.textBaseline = 'top';
      for (_k = 0, _len3 = players.length; _k < _len3; _k++) {
        player = players[_k];
        playerImage = img;
        if (player.host && hostImages[player.host] && hostImages[player.host].width) {
          playerImage = hostImages[player.host];
        }
        ctx.save();
        ctx.translate(w / 2 + player.x, h / 2 + player.y);
        ctx.scale(player.scale, 1);
        drawBobbingImage(ctx, playerImage, time - 250, 200, 93, 0, 0);
        if (player.text) {
          drawPlayerText(ctx, 0, 0, player.text);
        }
        if (player.Image && player.Image.width) {
          drawPlayerImage(ctx, 0, 0, player.Image);
        }
        ctx.restore();
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
    var $a, a, ctx, editedText, flashPlaying, hostImage, img, key, port, sendPlayer, support, value, waiter;
    $a = $('audio');
    a = $a[0];
    support = false;
    try {
      support = !!a.canPlayType && !!a.play && !((a.canPlayType('audio/ogg') === 'no' || a.canPlayType('audio/ogg') === '') && (a.canPlayType('audio/mpeg') === 'no' || a.canPlayType('audio/mpeg') === ''));
    } catch (e) {
      support = false;
    }
    flashPlaying = false;
    if (!support) {
      $('body').append(flashRows.join('\n'));
      flashPlaying = true;
    } else {
      $a.bind('canplaythrough', function() {
        $a.unbind('canplaythrough');
        $a.bind('ended', function() {
          this.pause();
          this.currentTime = 0;
          return this.play();
        });
        return a.play();
      });
    }
    ctx = $('#canvas')[0].getContext('2d');
    w = $(window).width();
    h = $(window).height();
    ctx.canvas.width = w;
    ctx.canvas.height = h;
    ctx.clearRect(0, 0, w, h);
    scale = w / 980;
    ctx.scale(scale, scale);
    w /= scale;
    h /= scale;
    wavePositions = generateWavePositions();
    img = new Image();
    waiter = Object.create(waiterProto);
    waiter.link(img, ['/img/new_manatee.svg', '/img/new_manatee.png']);
    img.onload = function() {
      return setInterval(getDrawImage(ctx, img), 35);
    };
    waiter.check();
    hostImages = {
      lapsi: 'svg',
      punainen: 'png',
      sininen: 'png',
      'xn--vihre-kra': 'png'
    };
    for (key in hostImages) {
      value = hostImages[key];
      hostImage = new Image();
      hostImage.src = 'img/host/' + key + '.' + value;
      hostImages[key] = hostImage;
    }
    $(window).resize(function() {
      w = $(window).width();
      h = $(window).height();
      ctx.clearRect(0, 0, w, h);
      ctx.canvas.width = w;
      ctx.canvas.height = h;
      scale = w / 980;
      ctx.scale(scale, scale);
      w /= scale;
      h /= scale;
      return wavePositions = generateWavePositions();
    });
    port = 8081;
    if ($.browser.opera) {
      port = 80;
    }
    window.socket = io.connect('http://tappe.lu:' + port);
    socket.on('player', function(message) {
      var found, player, _i, _len, _ref;
      found = false;
      for (_i = 0, _len = players.length; _i < _len; _i++) {
        player = players[_i];
        if (player.id === message.id) {
          found = true;
          if ((message.x != null) && (message.y != null)) {
            player.x = message.x;
            player.y = message.y;
            player.dx = 0;
            player.dy = 0;
          } else {
            if (message.dx != null) {
              player.dx = message.dx;
            }
            if (message.dy != null) {
              player.dy = message.dy;
            }
          }
          if (message.text != null) {
            player.text = message.text;
          }
          if (message.image && player.image !== message.image) {
            player.image = message.image;
            if ((_ref = player.Image) == null) {
              player.Image = new Image();
            }
            player.Image.src = player.image;
          }
          if (message.host != null) {
            player.host = message.host;
          }
        }
      }
      if (!found && message.id) {
        if (message.image) {
          message.Image = new Image();
          message.Image.src = message.image;
        }
        players.push(message);
      }
      return animateNext = true;
    });
    socket.on('you', function(message) {
      var _base, _ref;
      if ((message.image != null)) {
        players[0].image = message.image;
        if ((_ref = (_base = players[0]).Image) == null) {
          _base.Image = new Image();
        }
        return players[0].Image.src = players[0].image;
      }
    });
    window.shoot = function() {
      return socket.emit('animation', {
        type: 'blast'
      });
    };
    $('textarea')[0].ondragover = function() {
      $('textarea').css('background', 'silver');
      return false;
    };
    $('textarea')[0].ondragend = function() {
      $('textarea').css('background', 'white');
      return false;
    };
    $('textarea')[0].ondrop = function(event) {
      var file, reader;
      event.preventDefault();
      file = event.dataTransfer.files[0];
      reader = new FileReader();
      reader.onload = function(loadEvent) {
        if (loadEvent.target.result.length > 8096) {
          $('textarea').val("That's too big!");
          return;
        }
        players[0].image = loadEvent.target.result;
        if (!players[0].Image) {
          players[0].Image = new Image();
        }
        return players[0].Image.src = loadEvent.target.result;
      };
      reader.readAsDataURL(file);
      return false;
    };
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
        case 17:
          return shoot();
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
    ctx.canvas.ontouchstart = function() {
      ctx.canvas.ontouchmove = function(e) {
        var dx, dy;
        dx = e.touches[0].clientX - (w * scale) / 2 - players[0].x * scale;
        dy = e.touches[0].clientY - (h * scale) / 2 - players[0].y * scale;
        if (dx > 50) {
          pressed.right = 1;
          pressed.left = 0;
        } else if (dx < -50) {
          pressed.left = 1;
          pressed.right = 0;
        } else {
          pressed.left = 0;
          pressed.right = 0;
        }
        if (dy > 50) {
          pressed.down = 1;
          pressed.up = 0;
        } else if (dy < -50) {
          pressed.up = 1;
          pressed.down = 0;
        } else {
          pressed.up = 0;
          pressed.down = 0;
        }
        return false;
      };
      return ctx.canvas.ontouchend = function(e) {
        var pressed;
        pressed = {
          up: 0,
          down: 0,
          left: 0,
          right: 0
        };
        ctx.canvas.ontouchmove = null;
        return ctx.canvas.ontouchend = null;
      };
    };
    sendPlayer = (function() {
      var lastPlayerSent;
      lastPlayerSent = {};
      return function(player) {
        var always, item, key, playerToSend, _results;
        playerToSend = {};
        always = ['host'];
        for (key in player) {
          item = player[key];
          if (__indexOf.call(always, key) >= 0 || (key !== 'Image' && !(key in lastPlayerSent && lastPlayerSent[key] === item))) {
            playerToSend[key] = item;
          }
        }
        if (player.dx !== 0 || player.dy !== 0) {
          delete playerToSend.x;
          delete playerToSend.y;
        } else {
          delete playerToSend.dx;
          delete playerToSend.dy;
        }
        if ((playerToSend.x != null) || (playerToSend.y != null)) {
          playerToSend.x = player.x;
          playerToSend.y = player.y;
        }
        if (!$.isEmptyObject(playerToSend)) {
          socket.emit('player', playerToSend);
          _results = [];
          for (key in playerToSend) {
            item = playerToSend[key];
            _results.push(lastPlayerSent[key] = item);
          }
          return _results;
        }
      };
    })();
    editedText = false;
    $('textarea').bind('keydown', function() {}).bind('click', function() {
      if (!editedText) {
        $('textarea').val('');
      }
      return editedText = true;
    }).bind('keyup', function() {
      animateNext = true;
      players[0].text = $('textarea').val();
      return sendPlayer(players[0]);
    });
    $('input.music').click(function() {
      if (!support && flashPlaying) {
        $('object').remove();
        return flashPlaying = false;
      } else if (!support && !flashPlaying) {
        $('body').append(flashRows.join('\n'));
        return flashPlaying = true;
      } else if (support && $('audio')[0].paused) {
        return $('audio')[0].play();
      } else if (support) {
        return $('audio')[0].pause();
      }
    });
    $('input.animation').click(function() {
      return animating = !animating;
    });
    return setInterval(function() {
      players[0].dx += (pressed.right - pressed.left) * 5;
      players[0].dy += (pressed.down - pressed.up) * 5;
      sendPlayer(players[0]);
      if (players[0].dx || players[0].dy) {
        return animateNext = true;
      }
    }, 33);
  });
}).call(this);
