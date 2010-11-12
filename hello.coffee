http = require 'http'

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
  <script src="/js/site.js"></script>
</body></html>
'''

pageString = ->
  header + "  " + ((content for content in arguments).join "\n  ") + footer

http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/html'}
  page = [
    '<!-- http://open.spotify.com/album/3sauBmGWcRtEw4BI84yS2t -->',
    '<audio preload="auto" autobuffer autoplay loop>',
    '  <source src="manatee.ogg" type="audio/ogg; codecs=vorbis" />',
    '  <source src="manatee.mp3" type="audio/mpeg" /> -->',
    '</audio>', 
    'Hello World, ' + (counter += 1), 
    '<canvas id="canvas" width="1920" height="1200"></canvas>'
  ]
  res.end pageString page...
.listen 8081, "127.0.0.1"


console.log 'Server running at http://127.0.0.1:8081/'


