--
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local ngx = ngx
local response, _ = require 'kong.yop.response'()

local stringy = require "stringy"
local json = require "cjson"
local singletons = require "kong.singletons"

local http = require "resty.http"
local uriEncode = ngx.encode_args

local _M = {}

local OAUTH2_SERVER_URL = singletons.configuration["oauth2_server_url"]
if stringy.endswith(OAUTH2_SERVER_URL, "/") then OAUTH2_SERVER_URL = OAUTH2_SERVER_URL:sub(1, #OAUTH2_SERVER_URL - 1) end

_M.process = function(ctx, token)
  local appKey = ctx.appKey
  local httpc = http.new()
  local res, err = httpc:request_uri(OAUTH2_SERVER_URL .. "/oauth/check_token", {
    method = "POST",
    body = uriEncode({ token = token }),
    headers = {
      ['accept'] = "application/json",
      ["Content-Type"] = "application/x-www-form-urlencoded"
    }
  })
  if not res then ngx.log(ngx.NOTICE, "failed to request oauth2 server..: ", err) response.oauth2Exception(appKey, err) end
  local body = json.decode(res.body)
  if res.status ~= 200 then response.oauth2Exception(appKey, body.error) end
  if body.client_id ~= appKey then response.oauth2Exception(appKey, "invalid token:token is not generated by your appKey") end
end
return _M
