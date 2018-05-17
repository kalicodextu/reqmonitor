local p = "/usr/local/openresty/lualib/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s", p, p, m_package_path)
local mongo = require "resty.mongol"
local json = require "cjson"

local conn = mongo:new()
conn:set_timeout(1000)
local ok,err = conn:connect("127.0.0.1", 27017)
if not ok then
    ngx.say("connect failed"..err)
end

-- conn database
local db = conn:new_db_handle("RecordDB")
local ok, err = db:auth("", "")
if ok then
    ngx.say("user auth sucess"..ok)
end

-- get collection
local coll = db:get_col('record')

-- get req info
local h, err = ngx.req.get_headers()
local host_value
local user_agent_value
local req_url
local remote_addr
if err == "truncated" then
else
    host_value = h["HOST"]
    user_agent_value = h["USER-AGENT"]
end
remote_addr = ngx.var.remote_addr
req_url = ngx.var['uri']

-- store in db
local data = {ReqURL=req_url, RemoteAddr=remote_addr, HOST=host_value, UserAgent=user_agent_value}
local docs = {data}
local rsok, err = coll:insert(docs, 0, 0)
if err then
    ngx.say('error--'..err)
else
    ngx.say('ok'..rsok)
end
if conn then
    conn:close()
end
