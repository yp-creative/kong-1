--
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-22
-- Time: 下午4:46
-- To change this template use File | Settings | File Templates.
--
local json = require "cjson"
local dyups = require "ngx.dyups"
local singletons = require "kong.singletons"
local log = require "kong.yop.log"
local cache = ngx.shared.yop
local stringy = require "stringy"
local ngx, table, pairs, ipairs, next, tostring, string = ngx, table, pairs, ipairs, next, tostring, string
local resty_lock = require "resty.lock"
local http = require "resty.http"
local uriEncode = ngx.encode_args

local CACHE_LOCK_OPTION = {
  exptime = 10,
  timeout = 5
}

local POST_HEADER_OPTIONS = {
  ['accept'] = "application/json",
  ["Content-Type"] = "application/x-www-form-urlencoded"
}


local url, expireTime = singletons.configuration["yop_hessian_url"], singletons.configuration["yop_cache_expired_seconds"]
if stringy.endswith(url, "/") then url = url:sub(1, #url - 1) end
log.notice_u("init", "use yop_hessian_url: ", url)

local CACHE_KEYS = {
  API = "api:",
  APP = "app:",
  TRANSFORMER = "tf:",
  VALIDATOR = "va:",
  IGNORE_SIGN_FIELDS = "isf:",
  WHITELIST = "wl:",
  APP_AUTH = "auth:",
  DEFAULT_VALUES = "dv:",
  SECRET = "secret:",
  UPSTREAM = "up:"
}

local _M = {}

function _M.rawset(key, value) return cache:set(key, value, expireTime) end

function _M.set(key, value) if value then value = json.encode(value) end return _M.rawset(key, value) end

function _M.rawget(key) return cache:get(key) end

function _M.get(key)
  local value, flags = _M.rawget(key)
  if value then value = json.decode(value) end
  return value, flags
end

function _M.delete(key) cache:delete(key) end

function _M.delete_all() cache:flush_all() cache:flush_expired() end

function _M.get_or_set(original_key, key, cb)
  local value = _M.get(key)
  if value then return value end

  local lock, err = resty_lock:new("cache_locks", CACHE_LOCK_OPTION)
  if not lock then log.error("could not create lock: ", err) return end

  local elapsed, err = lock:lock(key)
  if not elapsed then log.error("failed to acquire cache lock: ", err) end

  value = _M.get(key)

  if not value then
    -- Get from closure
    value = cb(original_key)
    if value then
      local ok, err = _M.set(key, value)
      if not ok then log.error(err) end
    end
  end

  local ok, err = lock:unlock()
  if not ok and err then log.error("failed to unlock: ", err) end
  return value
end

local function post(path, param)
  local httpc = http.new()
  local res, err = httpc:request_uri(url .. "/" .. path, {
    method = "POST",
    body = uriEncode(param),
    headers = POST_HEADER_OPTIONS
  })
  --  如果未能远程请求成功，此处需返回nil，以便下次请求还能继续远程请求
  if not res then log.notice("failed to request: ", err) return nil end
  return json.decode(res.body)
end

function _M.cacheApi(api)
  return _M.get_or_set(api, CACHE_KEYS.API .. api, function(api)
    log.notice("remote get api info,apiUri: " .. api)
    local o = post("api", { apiUri = api })
    if o == nil then return nil end
    if not next(o) then return {} end

    --  api basic info
    local basic = o.basic
    local endClass, endMethod = basic.endClass, basic.endMethod

    local i = endClass:find("%.[^.]*$")
    if i then endClass = endClass:sub(i + 1) end
    basic.bareClass = endClass

    i = endMethod:find("%(")
    if i then endMethod = endMethod:sub(1, i - 1) end
    endMethod = endMethod:gsub("void ", "")
    basic.bareMethod = stringy.strip(endMethod)

    local endServiceUrl = basic.endServiceUrl
    if endServiceUrl then
      i = endServiceUrl:find("//")
      if i then endServiceUrl = endServiceUrl:sub(i + 2) end
      i = endServiceUrl:find("/")
      if i then basic.endServiceUrl = endServiceUrl:sub(1, i - 1) end
    end

    local params = o.params
    local transformer, defaultValues, ignoreSignFields = {}, {}, { sign = true, encrypt = true }
    for _, value in pairs(params) do
      local ei, paramName, endParamName, defaultValue = value.endParamIndex, value.paramName, value.endParamName, value.defaultValue
      if ei >= #transformer then for k = #transformer, ei, 1 do table.insert(transformer, {}) end end
      if endParamName == nil or stringy.strip(endParamName) == '' then endParamName = paramName end
      --    transformer info
      transformer[ei + 1][endParamName] = { paramName = paramName, prefixes = stringy.split(endParamName, ".") }

      --    default value info
      if defaultValue ~= nil then defaultValues[paramName] = defaultValue end

      --ignore sign?
      if value.ignoreSign then ignoreSignFields[paramName] = true end
    end
    _M.set(CACHE_KEYS.TRANSFORMER .. api, transformer)
    _M.set(CACHE_KEYS.DEFAULT_VALUES .. api, defaultValues)
    _M.set(CACHE_KEYS.VALIDATOR .. api, o.validators)
    _M.set(CACHE_KEYS.IGNORE_SIGN_FIELDS .. api, ignoreSignFields)
    return basic
  end)
end

function _M.getTransformer(api) return _M.get(CACHE_KEYS.TRANSFORMER .. api) end

function _M.getValidator(api) return _M.get(CACHE_KEYS.VALIDATOR .. api) end

function _M.getDefaultValues(apiUri) return _M.get(CACHE_KEYS.DEFAULT_VALUES .. apiUri) end

function _M.getIgnoreSignFields(api) return _M.get(CACHE_KEYS.IGNORE_SIGN_FIELDS .. api) end

function _M.cacheIPWhitelist(api)
  return _M.get_or_set(api, CACHE_KEYS.WHITELIST .. api, function(api)
    log.notice("remote get api whitelist info,apiUri: " .. api)
    local o = post("limit", { apiUri = api })
    if o == nil then return nil end
    if not next(o) then return {} end
    local whitelist = {}
    for _, value in pairs(o) do
      if value.limitType == 'WHITELIST' and value.status == 'ENABLE' then
        for _, w in pairs(value.whitelist) do whitelist[w] = true end
      end
    end
    return whitelist
  end)
end


function _M.cacheApp(app)
  return _M.get_or_set(app, CACHE_KEYS.APP .. app, function(appKey)
    log.notice("remote get app info,appKey: " .. appKey)
    return post("app", { appKey = appKey })
  end)
end


function _M.cacheAppAuth(appKey)
  return _M.get_or_set(appKey, CACHE_KEYS.APP_AUTH .. appKey, function(appKey)
    log.notice("remote get app authorization info,appKey: " .. appKey)
    local o = post("auth", { appKey = appKey })
    if o == nil then return nil end
    if not next(o) then return {} end

    local authorization = {}
    for _, value in pairs(o) do authorization[tostring(value.apiId)] = true end
    return authorization
  end)
end


function _M.cacheUpstream(backendApp)
  return _M.get_or_set(backendApp, CACHE_KEYS.UPSTREAM .. backendApp, function(backendApp)
    log.notice("remote get backend app info,backendApp: " .. backendApp)
    local o = post("upstream", { backendApp = backendApp })
    if o == nil then return nil end
    if not next(o) then return {} end
    for _, value in ipairs(o) do
      local name = value.name
      local servers = "server " .. table.concat(value.servers, ";\nserver ") .. ";"
      log.notice(string.format('dyups.update(%s, "%s")', name, servers))
      local status, rv = dyups.update(name, servers)
      if status ~= 200 then log.warn(string.format('dyups.update(%s, "%s") failed: %s', name, servers, tostring(rv))) return nil end
    end
    return o
  end)
end

return _M
