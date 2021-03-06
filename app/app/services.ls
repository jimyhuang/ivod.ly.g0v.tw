angular.module 'app.services' []
.service 'FirebaseRoot': ->
  new Firebase 'https://iv0d.firebaseio.com/'
.service 'DanmakuStats': <[$q PipeService FirebaseRoot]> ++ ($q, PipeService, FirebaseRoot) ->
  root = FirebaseRoot
  updateQueue: (vid, obj) ->
    stats = root.child("stats/#vid")
    newentry = stats.child('queue').push!
    newentry.setWithPriority obj, obj.offset
  updateTotal: (vid, type) ->
    stats = root.child("stats/#vid").child('total')
    stats.once 'value' ->
      obj = {egg: 0, shoe: 0, melon: 0, net: 0, banner: 0, flower: 0, boat: 0, duck: 0}
      obj[type] = 1
      if it.val! === null => stats.set obj
      else
        stats.child(type).once 'value' ->
          stats.child(type).set it.val! + 1
  queryAll: (vid, cb) ->
    queue = root.child("stats/#vid/queue")
    queue.on \value, cb
    null
.service 'DanmakuPaper': ->
  has-net = false
  net-handle = null
  player = $ \#video-wrapper
  {left: x, top: y} = player.offset!
  paper = Raphael x, y, player.width!, player.height! - 30
  update-location = -> $ paper.canvas .css player.offset!
  $ window .on \resize update-location
  update-location!
  poptext: (text, color, size, ms) ->
    paper.text player.width!, Math.floor(Math.random!*300), text
      .attr {'font-size': size, 'fill': color, 'text-shadow': '0 0 10px rgba(255,255,255,0.5)'}
      .animate {x: -paper.width}, ms
  throwEgg: (type, mx, my, ex, ey, sy) ->
    egg = $ "<div class='throw zoom'><div class='rotate'></div></div>"
    egg-inner = egg.find \div .addClass type
    has-net-action = Math.random!>0.5
    egg.appendTo $ \body
    egg.offset left: ex - 75, top: ey - 74 + sy
      ..animate {left: mx - 75, top: my - 74 + sy}, ->
        if !has-net => egg-inner.addClass \break .removeClass "rotate"
        else egg.removeClass \zoom .addClass (if has-net-action => \zoom-inverse else \zoom-inverse-large)
      ..animate({top: my + 74 + sy}) if !has-net
      ..animate({left: ex - 75, top: ey - 74 + sy}) if (has-net and has-net-action)
      ..fadeOut!
  protect: (type) ->
    wrapper = $ \#video-wrapper
    {top:y, left: x} = wrapper.offset!
    [w, h] = [wrapper.width!, wrapper.height!]
    egg = $ \<div></div>
    switch type
    case \raise-net
      has-net := true
      if net-handle => clearTimeout net-handle
      net-handle := setTimeout (->
        has-net := false
        net-handl = null
      ), 3000
      egg.addClass \raise-net
      $ document.body .append egg
      egg.offset left: x, top: y - 150 .animate top: y  .delay 3000 .fadeOut!
    case \white-banner
      egg.addClass \white-banner .text "司法不公  政治迫害"
      $ document.body .append egg
      egg.offset left: x, top: y - 150 .animate top: y - 50  .delay 500 .fadeOut!
      egg = $ \<div></div>
      egg.addClass \coffin
      $ document.body .append egg
      egg.offset left: x - 100, top: y + h - 200 .animate left: x + parseInt(w / 2) - 100  .delay 500 .fadeOut!
    default
      egg.addClass type
      $ document.body .append egg
      egg.offset left: x - 100, top: y + h - 200 .animate left: x + parseInt(w / 2) - 100  .delay 500 .fadeOut!

.service 'DanmakuStore': <[$q FirebaseRoot]> ++ ($q, FirebaseRoot) ->
  root = FirebaseRoot
  store: (vid, obj) ->
    video = root.child("videos/#vid")
    newentry = video.child('danmaku').push!
    newentry.setWithPriority obj, obj.timestamp
  subscribe: (vid, cb) ->
    # also: 'child_changed', 'child_removed' or 'child_moved'
    # use them to maintain list of upcoming danmaku
    root.child("videos/#vid/danmaku").startAt new Date!getTime! - 30s * 1000ms
    .on \child_added, cb
    null
  unsubscribe: (vid) ->
    root.child("videos/#vid/danmaku").off \child_added
.service 'LYModel': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
    base = 'http://api-beta.ly.g0v.tw/v0/collections/'
    _model = {}

    localGet = (key) ->
      deferred = $q.defer!
      promise = deferred.promise
      promise.success = (fn) ->
        promise.then fn
      promise.error = (fn) ->
        promise.then fn
      $timeout ->
        console.log \useLocalCache
        deferred.resolve _model[key]
      return promise

    wrapHttpGet = (key, url, params) ->
      {success, error}:req = $http.get url, params
      req.success = (fn) ->
        rsp <- success
        console.log 'save response to local model'
        _model[key] = rsp
        fn rsp
      req.error = (fn) ->
        rsp <- error
        fn rsp
      return req

    return do
      get: (path, params) ->
        url = base + path
        key = if params => url + JSON.stringify params else url
        key -= /\"/g
        return if _model.hasOwnProperty key
          localGet key
        else
          wrapHttpGet key, url, params

.factory \PipeService, -> do
  listeners: {}
  dispatchEvent: (n, v) -> (@listeners[n] or [])map -> it v
  on: (n, cb) -> @listeners.[][n].push cb
