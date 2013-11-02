poptext = (paper, text, color, size, ms) ->
  paper.text 30, Math.floor(Math.random!*300), text
    .attr {'font-size': size, 'fill': color}
    .animate {x: 2*paper.width}, ms

angular.module 'app.controllers' <[ng app.cinema]>
.run <[$rootScope]> ++ ($rootScope) ->
.controller AppCtrl: <[$scope $location $rootScope]> ++ (s, $location, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

.controller About: <[$rootScope $http]> ++ ($rootScope, $http) ->
    $rootScope.activeTab = \about

.controller Danmaku: <[$scope DanmakuStore]> ++ ($scope, DanmakuStore) ->

  $scope.comments = []
  $scope.playedComments = []
  #goAngular = new GoAngular $scope, \comments, { include: [\comments], exclude: [\newComment, \playedComments]} .initialize!
  player = $ \#cinema-player
  {left: x, top: y} = player.offset!
  paper = Raphael x, y, player.width!, player.height! - 30
  $scope.$watch 'comments' (c) ->
    console.log c
    angular.forEach c, (value, index) ->
      if $scope.playedComments[index] == void
        poptext paper, value.text, '#fff', 30, 5000
        $scope.playedComments.push value

  $scope.addComment = ->
    poptext paper, $scope.newComment, '#fff', 30, 5000
    $scope.playedComments.push $scope.newComment
    timestamp = new Date! .getTime!
    created_at = new Date! .getTime!
    DanmakuStore.store $scope.current-video-id, {text: $scope.newComment, timestamp: timestamp, created_at: created_at, type: \content} 

.controller vlist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"
.controller mlylist: <[$scope $http]> ++ ($scope, $http) ->
  $scope.blah = "hello world"

.controller EggNinja: <[$scope]> ++ ($scope) ->
  player = $ \#cinema-player
  crosshair = $ \#crosshair
  egg = $ \#egg
  console.log \bok
  [w,h] = [player.width!, player.height!]
  {top:y, left: x} = player.offset!
  eggninja = $ \#eggninja
  eggninja.offset {top: y, left: x}
  eggninja.css  width: "#{w}px", height: "#{h - 30}px"
  eggninja.on \click (e) ->
    {clientX: mx, clientY: my} = e
    console.log e.clientY
    sy = $(document.body)scrollTop!
    [ww, wh] = [$(document.body)width!, $(window)height!]
    #[ex, ey] = [Math.random!*ww, my + (wh / 4) - parseInt(Math.random! * wh / 2)]
    [ex, ey] = [if Math.random!>0.5 => ww else 0, my + parseInt((wh - my ) / 2)]

    egg = $ \<div></div>
    egg.addClass "rotate egg"
    egg.css \background-image, "url(/img/#{<[egg shoe melon]>[parseInt(Math.random!*4)]}.png)"
    $ document.body .append egg
    egg.offset left: ex - 50, top: ey - 50 + sy .animate left: mx - 50, top: my - 50 + sy
      .animate left: mx - 50, top: my + 50 + sy .fadeOut!

  eggninja.on \mousemove (e) ->
    {clientX: mx, clientY: my} = e
    sy = $(window)scrollTop!
    player.parent!parent!parent!trigger \mousemove
    crosshair.offset top: my - 100 + sy, left: mx - 100

