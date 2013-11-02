angular.module 'app.services' []
.service 'DanmakuStore': <[$q]> ++ ($q) ->
  root = new Firebase 'https://ivod.firebaseio.com/'
  store: (vid, obj) ->
    # ref
    #newentry = video.child('danmaku').push!
    #newentry.setWithPriority {content: \text, timestamp: ts}, ts
    #newentry.setWithPriority obj, ts
  subscribe: (vid, cb) ->
    # also: 'child_changed', 'child_removed' or 'child_moved'
    # use them to maintain list of upcoming danmaku
    root.child("videos/#vid/danmaku").on \child_added cb
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
