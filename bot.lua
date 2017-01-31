package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
.. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
http = require("socket.http")
https = require("ssl.https")
http.TIMEOUT = 10
JSON = require('dkjson')
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
serpent = require('serpent')
serp = require 'serpent'.block
sudo_users = {
    218722292,
    yourid,
    0
}

---- function leave
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end

function is_sudo(msg)
  local var = false
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end

function is_normal(msg)
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local mutel = redis:sismember('muteusers:'..chat_id,user_id)
  if mutel then
    return true
  end
  if not mutel then
    return false
  end
end
-- function owner
function is_owner(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local group_mods = redis:get('owners:'..chat_id)
  if group_mods == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end
--- function promote
function is_mod(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  if redis:sismember('mods:'..chat_id,user_id) then
    var = true
  end
  if  redis:get('owners:'..chat_id) == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end

-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do
      spaces = spaces .. '  '
    end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
      value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or
    type(value) == 'thread' or
    type(value) == 'userdata' or
    value == nil then --@JoveTeam
    print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
end


local function setowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  redis:set('owners:'..ch,user)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🎗 #کاربر *'..user..'* به عنوان _مالک_ منصوب شد\n🎗 کانال: @JoveTeam', 1, 'md')
  print(user)
end

local function deowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🎗 #کاربر *'..user..'* ازسمت _مالکیت_ محروم شد\n🎗 کانال: @JoveTeam', 1, 'md')
  print(user)
end

 local database = 'http://vip.opload.ir/vipdl/94/11/amirhmz/'
local function setmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:sadd('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🎗 #کاربر *'..user..'* به عنوان _مدیر_ منصوب شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

local function remmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:srem('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🎗 #کاربر *'..user..'* ازمقام _مدیریت_ عزل شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

function kick_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Kicked')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🔹کاربر *'..result.sender_user_id_..'* اخراج_ شد_\n🎗 کانال: @JoveTeam', 1, 'md')
end

function ban_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Banned')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #انجام شد!\n🔹کاربر *'..result.sender_user_id_..'* بن_ شد_\n🎗 کانال: @JoveTeam', 1, 'md')
end


local function setmute_reply(extra, result, success)
  vardump(result)
  redis:sadd('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #کاربر *'..result.sender_user_id_..'* به لیست _ساکت شدگان_ افزوده شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

local function demute_reply(extra, result, success)
  vardump(result)
  redis:srem('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '🏅 #کاربر *'..result.sender_user_id_..'* ازلیست _ساکت شدگان_ حذف شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

function setphoto(chat_id, photo)
 tdcli_function ({
   ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
  photo_ = getInputFile(photo)
  }, dl_cb, nil)
end

function delete_msg(chatid,mid)
  tdcli_function ({
 ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
 dl_cb, nil)
end

function tdcli_update_callback(data)
  vardump(data)

  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      if input:match("^[#!/][Pp][Ii][Nn][Gg]$") and is_sudo(msg) or input:match("^[Pp][Ii][Nn][Gg]$") and is_sudo(msg) or input:match("^پینگ$") and is_sudo(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅Pong!', 1, 'md')

      end
			
if input:match("^[#!/][Ii][Dd]$") and is_mod(msg) or input:match("^[Ii][Dd]$") and is_mod(msg) or input:match("^ایدی$") then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '> _شناسه سوپر گروه:_ `'..string.sub(chat_id, 5,14)..'`\n> _شناسه شما:_ `'..user_id..'`\n> _کانال:_  @JoveTeam', 1, 'md')
  end

	
      if input:match("^[#!/][Pp][Ii][Nn]$") and reply_id and is_owner(msg) or input:match("^[Pp][Ii][Nn]$") and reply_id and is_owner(msg) or input:match("^پین$") and reply_id and is_owner(msg) or input:match("^سنجاق$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅پیام <code>سنجاق</code> شد\n🎗 کانال: @JoveTeam', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^[#!/][Uu][Nn][Pp][Ii][Nn]$") and reply_id and is_owner(msg) or input:match("^[Uu][Nn][Pp][Ii][Nn]$") and reply_id and is_owner(msg) or input:match("^حذف پین$") and reply_id and is_owner(msg) or input:match("^حذف سنجاق$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅پیام <code>سنجاق</code> حذف شد\n🎗 کانال: @JoveTeam', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end


      -----------------------------------------------------------------------------------------------------------------------------
      if input:match('^[!#/]([Ss]etowner)$') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^([Ss]etowner)$') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^تنظیم مالک$') and is_owner(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setowner_reply,nil)
      end
      if input:match('^[!#/](Dd]elowner)$') and is_sudo(msg) and msg.reply_to_message_id_ or input:match('^(Dd]elowner)$') and is_sudo(msg) and msg.reply_to_message_id_ or input:match('^حذف مالک$') and is_sudo(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,deowner_reply,nil)
      end

      if input:match('^[!#/]([Oo]wner)$') or input:match('^([Oo]wner)$') or input:match('^مالک$') then
        local hash = 'owners:'..chat_id
        local owner = redis:get(hash)
        if owner == nil then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🔸گروه `مالک` ندارد \n🎗 کانال: @JoveTeam', 1, 'md')
        end
        local owner_list = redis:get('owners:'..chat_id)
        text85 = '🎗 `مالک گروه:`\n\n '..owner_list
        tdcli.sendText(chat_id, 0, 0, 1, nil, text85, 1, 'md')
      end
      if input:match('^[/!#]setowner (.*)') and not input:find('@') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        redis:set('owners:'..chat_id,input:match('^[/!#]setowner (.*)'))
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]setowner (.*)')..' به عنوان `مالک` منصوب شد\n🎗 کانال: @JoveTeam', 1, 'md')
      end

      if input:match('^[/!#]setowner (.*)') and input:find('@') and is_owner(msg) then
        function Inline_Callback_(arg, data)
          redis:del('owners:'..chat_id)
          redis:set('owners:'..chat_id,input:match('^[/!#]setowner (.*)'))
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]setowner (.*)')..' به عنوان `مالک` منصوب شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^[/!#]setowner (.*)')}, Inline_Callback_, nil)
      end


      if input:match('^[/!#]delowner (.*)') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]delowner (.*)')..' از عنوان `مالک` محروم شد\n🎗 کانال: @JoveTeam', 1, 'md')
      end
      -----------------------------------------------------------------------------------------------------------------------
      if input:match('^[/!#]promote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^promote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^ارتقا') and is_owner(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmod_reply,nil)
end
if input:match('^[/!#]demote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^demote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^عزل') and is_owner(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,remmod_reply,nil)
end
			
			sm = input:match('^[/!#]promote (.*)') or input:match('^promote (.*)') or input:match('^ارتقا (.*)')
if sm and is_owner(msg) then
  redis:sadd('mods:'..chat_id,sm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #انجام شد!\n🏅 #کاربر '..sm..'به عنوان _مدیر_ منصوب شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

dm = input:match('^[/!#]demote (.*)') or input:match('^demote (.*)') or input:match('^عزل (.*)')
if dm and is_owner(msg) then
  redis:srem('mods:'..chat_id,dm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #انجام شد\n🏅 #کاربر '..dm..'از مقام _مدیر_ عزل شد\n🎗 کانال: @JoveTeam', 1, 'md')
end

if input:match('^[/!#]modlist') and is_mod(msg) or input:match('^modlist') and is_mod(msg) or input:match('^لیست مدیران') and is_mod(msg) then
if redis:scard('mods:'..chat_id) == 0 then
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅گروه _مدیری_ ندارد', 1, 'md')
end
local text = "🏅 `لیست مدیران` : \n"
for k,v in pairs(redis:smembers('mods:'..chat_id)) do
text = text.."_"..k.."_ - *"..v.."*\n"
end
tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'md')
end
-------------------------------------------------------------
			if input:match('^[/!#]setlink (.*)') and is_owner(msg) then
redis:set('link'..chat_id,input:match('^[/!#]setlink (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, 'لينک گروه ذخيره شد🏅\n_کانال_: @JoveTeam', 1, 'html')
end

if input:match('^[/!#]link$') and is_mod(msg) or input:match('^link$') and is_mod(msg) or input:match('^لينک$') and is_mod(msg) then
link = redis:get('link'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅لينک گروه :\n'..link, 1, 'html')
end

		-------------------------------------------------------
		if input:match('^[/!#]setrules (.*)') and is_owner(msg) then
redis:set('gprules'..chat_id,input:match('^[/!#]setrules (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅قوانين ثبت شد', 1, 'html')
end

if input:match('^[/!#]rules$') and is_mod(msg) or input:match('^rules$') and is_mod(msg) or input:match('^قوانين$') and is_mod(msg) then
rules = redis:get('gprules'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅قوانين گروه :\n'..rules, 1, 'html')
end
--------------------------------------------------------------------------
local res = http.request(database.."joke.db")
	local joke = res:split(",")
 if input:match'[!/#](joke)' and is_mod(msg) or input:match'(joke)' and is_mod(msg) then
 local run = joke[math.random(#joke)]
 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, run..'\n\n*Jove Team*: @JoveTeam', 1, 'md')
 end
      ---------------------------------------------------------------------------------------------------------------------------------

      if input:match("^[#!/][Aa]dd$") and is_sudo(msg) or input:match("^[Aa]dd$") and is_sudo(msg) or input:match("^اضافه$") and is_sudo(msg) then
       redis:sadd('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅 _گروه جدید به لیست مدیریتی افزوده شد!_ 🏅\n🏅 افزوده شده توسط: *'..msg.sender_user_id_..'*\n🏅ورژن 8.0 ژوپیتر(اوربیتال)🏅\n🎗 کانال: @JoveTeam', 1, 'md')
     end
      -------------------------------------------------------------------------------------------------------------------------------------------
      if input:match("^[#!/][Rr]em$") and is_sudo(msg) or input:match("^[Rr]em$") and is_sudo(msg) or input:match("^حذف گروه$") and is_sudo(msg) then
        redis:srem('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅 _گروه از لیست مدیریتی حذف شد!_ 🏅\n🏅 حذف شده توسط: *'..msg.sender_user_id_..'*\n🏅ورژن 8.0 ژوپیتر(اوربیتال)🏅\n🎗 کانال: @JoveTeam ', 1, 'md')
      end
      -----------------------------------------------------------------------------------------------------------------------------------------------
      -----------------------------------------------------------------------
      if input:match('^[!#/](kick)$') and is_mod(msg) or input:match('^(kick)$') and is_mod(msg) or input:match('^اخراج$') and is_mod(msg) then
        tdcli.getMessage(chat_id,reply,kick_reply,nil)
      end

      if input:match('^[!#/]kick (.*)') and not input:find('@') and is_mod(msg) then
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[!#/]kick (.*)')..' `اخراج`شد\n🎗 کانال: @JoveTeam', 1, 'md')
        tdcli.changeChatMemberStatus(chat_id, input:match('^[!#/]kick (.*)'), 'Kicked')
      end

      if input:match('^[!#/]kick (.*)') and input:find('@') and is_mod(msg) then
        function Inline_Callback_(arg, data)
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[!#/]kick (.*)')..' `اخراج`شد\n🎗 کانال: @JoveTeam', 1, 'md')
          tdcli.changeChatMemberStatus(chat_id, data.id_, 'Kicked')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^[!#/]kick (.*)')}, Inline_Callback_, nil)
      end
      --------------------------------------------------------
      ----------------------------------------------------------
      if input:match('^[/!#]muteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^muteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^ساکت کردن') and is_mod(msg) and msg.reply_to_message_id_ then
        redis:set('tbt:'..chat_id,'yes')
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmute_reply,nil)
      end
      if input:match('^[/!#]unmuteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^unmuteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^-ساکت کردن') and is_mod(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,demute_reply,nil)
      end
      mu = input:match('^[/!#]muteuser (.*)') or input:match('^muteuser (.*)') or input:match('^ساکت کردن (.*)')
      if mu and is_mod(msg) then
        redis:sadd('muteusers:'..chat_id,mu)
        redis:set('tbt:'..chat_id,'yes')
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..mu..' به `لیست ساکت شدگان` افزوده شد\n🎗 کانال: @JoveTeam', 1, 'md')
      end
      umu = input:match('^[/!#]unmuteuser (.*)') or input:match('^unmuteuser (.*)') or input:match('^-ساکت کردن (.*)')
      if umu and is_mod(msg) then
        redis:srem('muteusers:'..chat_id,umu)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..umu..' از `لیست ساکت شدگان` حذف شد\n🎗 کانال: @JoveTeam', 1, 'md')
      end

      if input:match('^[/!#]muteusers') and is_mod(msg) or input:match('^muteusers') and is_mod(msg) or input:match('^لیست ساکت شدگان') and is_mod(msg) then
        if redis:scard('muteusers:'..chat_id) == 0 then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅گروه هیچ `فرد ساکت شده ای` ندارد🏅', 1, 'md')
        end
        local text = "🏅لیست ساکت شدگان:\n"
        for k,v in pairs(redis:smembers('muteusers:'..chat_id)) do
          text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
        end
        tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'html')
      end
      -------------------------------------------------------

      --lock links
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock link$") and is_mod(msg) and groups or input:match("^lock link$") and is_mod(msg) and groups or input:match("^قفل لینک$") and is_mod(msg) and groups then
        if redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل لینک _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('lock_linkstg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل لینک _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock links$") and is_mod(msg) and groups or input:match("^unlock links$") and is_mod(msg) and groups or input:match("^بازکردن لینک$") and is_mod(msg) and groups then
        if not redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل لینک _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('lock_linkstg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل لینک _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock username
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock username$") and is_mod(msg) and groups or input:match("^lock username$") and is_mod(msg) and groups or input:match("^قفل نام کاربری$") and is_mod(msg) and groups then
        if redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل نام کاربری _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('usernametg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل نام کاربری _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock username$") and is_mod(msg) and groups or input:match("^unlock username$") and is_mod(msg) and groups or input:match("^بازکردن نام کاربری$") and is_mod(msg) and groups then
        if not redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل نام کاربری _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('usernametg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل نام کاربری _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock tag
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock tag$") and is_mod(msg) and groups or input:match("^lock tag$") and is_mod(msg) and groups or input:match("^قفل تگ$") and is_mod(msg) and groups then
        if redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل تگ _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('tagtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل تگ _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock tag$") and is_mod(msg) and groups or input:match("^unlock tag$") and is_mod(msg) and groups or input:match("^بازکردن تگ$") and is_mod(msg) and groups then
        if not redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل تگ _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('tagtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل تگ _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock forward
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock forward$") and is_mod(msg) and groups or input:match("^lock forward$") and is_mod(msg) and groups or input:match("^قفل فروارد$") and is_mod(msg) and groups then
        if redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل فروارد _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('forwardtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل فروارد _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock forward$") and is_mod(msg) and groups or input:match("^unlock forward$") and is_mod(msg) and groups or input:match("^بازکردن فروارد$") and is_mod(msg) and groups then
        if not redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل فروارد _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('forwardtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل فروارد _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --arabic/persian
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock persian$") and is_mod(msg) and groups or input:match("^lock persian$") and is_mod(msg) and groups or input:match("^قفل فارسی$") and is_mod(msg) and groups then
        if redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل فارسی _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('arabictg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل فارسی _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock persian$") and is_mod(msg) and groups or input:match("^unlock persian$") and is_mod(msg) and groups or input:match("^بازکردن فارسی$") and is_mod(msg) and groups then
        if not redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل فارسی _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('arabictg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل فارسی _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      ---english
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock english$") and is_mod(msg) and groups or input:match("^lock english$") and is_mod(msg) and groups or input:match("^قفل انگلیسی$") and is_mod(msg) and groups then
        if redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل انگلیسی _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('engtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل انگلیسی _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock english$") and is_mod(msg) and groups or input:match("^unlock english$") and is_mod(msg) and groups or input:match("^بازکردن انگلیسی$") and is_mod(msg) and groups then
        if not redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل انگلیسی _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('engtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل انگلیسی _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock foshtg
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock badwords$") and is_mod(msg) and groups or input:match("^lock badwords$") and is_mod(msg) and groups or input:match("^قفل کلمات زشت$") and is_mod(msg) and groups then
        if redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل کلمات زشت _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('badwordtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل کلمات زشت _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock badwords$") and is_mod(msg) and groups or input:match("^unlock badwords$") and is_mod(msg) and groups or input:match("^بازکردن کلمات زشت$") and is_mod(msg) and groups then
        if not redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل کلمات زشت _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('badwordtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل کلمات زشت _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock edit
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock edit$") and is_mod(msg) and groups or input:match("^lock edit$") and is_mod(msg) and groups and is_mod(msg) and groups or input:match("^قفل ویرایش$") and is_mod(msg) and groups then
        if redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل ویرایش _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('edittg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل ویرایش _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock edit$") and is_mod(msg) and groups or input:match("^unlock edit$") and is_mod(msg) and groups or input:match("^بازکردن ویرایش$") and is_mod(msg) and groups then
        if not redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل ویرایش _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('edittg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل ویرایش _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --- lock Caption
      if input:match("^[#!/]lock caption$") and is_mod(msg) and groups or input:match("^lock caption$") and is_mod(msg) and groups or input:match("^قفل کپشن$") and is_mod(msg) and groups then
        if redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل کپشن _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('captg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل کپشن _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock caption$") and is_mod(msg) and groups or input:match("^unlock caption$") and is_mod(msg) and groups or input:match("^بازکردن کپشن$") and is_mod(msg) and groups then
        if not redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل کپشن _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('captg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل کپشن _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock emoji
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock emoji$") and is_mod(msg) and groups or input:match("^lock emoji$") and is_mod(msg) and groups or input:match("^قفل ایموجی$") and is_mod(msg) and groups then
        if redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل ایموجی _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('emojitg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل ایموجی _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock emoji$") and is_mod(msg) and groups or input:match("^unlock emoji$") and is_mod(msg) and groups or input:match("^بازکردن ایموجی$") and is_mod(msg) and groups then
        if not redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل ایموجی _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('emojitg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل ایموجی _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --- lock inline
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock inline$") and is_mod(msg) and groups or input:match("^lock inline$") and is_mod(msg) and groups or input:match("^قفل اینلاین$") and is_mod(msg) and groups then
        if redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل اینلاین _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('inlinetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل اینلاین _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock inline$") and is_mod(msg) and groups or input:match("^unlock inline$") and is_mod(msg) and groups or input:match("^بازکردن اینلاین$") and is_mod(msg) and groups then
        if not redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل اینلاین _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('inlinetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل اینلاین _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      -- lock reply
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock reply$") and is_mod(msg) and groups or input:match("^lock reply$") and is_mod(msg) and groups or input:match("^قفل پاسخ$") and is_mod(msg) and groups then
        if redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل پاسخ _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('replytg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل پاسخ _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock reply$") and is_mod(msg) and groups or input:match("^unlock reply$") and is_mod(msg) and groups or input:match("^بازکردن پاسخ$") and is_mod(msg) and groups then
        if not redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل پاسخ _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('replytg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل پاسخ _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock tgservice
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Ll]ock tgservice$") and is_mod(msg) and groups or input:match("^[Ll]ock tgservice$") and is_mod(msg) and groups or input:match("^قفل اعلان$") and is_mod(msg) and groups then
        if redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل پیام های تلگرام _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('tgservice:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل پیام های تلگرام _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nlock tgservice$") and is_mod(msg) and groups or input:match("^[Uu]nlock tgservice$") and is_mod(msg) and groups or input:match("^بازکردن اعلان$") and is_mod(msg) and groups then
        if not redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل پیام های تلگرام _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('tgservice:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل پیام های تلگرام _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --lock flood (by @Flooding)
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock flood$") and is_mod(msg) and groups or input:match("^lock flood$") and is_mod(msg) and groups or input:match("^قفل حساسیت$") and is_mod(msg) and groups then
        if redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل حساسیت _قفل_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('floodtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل حساسیت _قفل_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/]unlock flood$") and is_mod(msg) and groups or input:match("^unlock flood$") and is_mod(msg) and groups or input:match("^بازکردن حساسیت$") and is_mod(msg) and groups then
        if not redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #قفل حساسیت _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('flood:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #قفل حساسیت _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end

      --------------------------------
      ---------------------------------------------------------------------------------
      local link = 'lock_linkstg:'..chat_id
      if redis:get(link) then
        link = "🔹 `فعال`"
      else
        link = "🔸 `غیرفعال`"
      end

      local username = 'usernametg:'..chat_id
      if redis:get(username) then
        username = "🔹 `فعال`"
      else
        username = "🔸 `غیرفعال`"
      end

      local tag = 'tagtg:'..chat_id
      if redis:get(tag) then
        tag = "🔹 `فعال`"
      else
        tag = "🔸 `غیرفعال`"
      end

      local flood = 'flood:'..chat_id
      if redis:get(flood) then
        flood = "🔹 `فعال`"
      else
        flood = "🔸 `غیرفعال`"
      end

      local forward = 'forwardtg:'..chat_id
      if redis:get(forward) then
        forward = "🔹 `فعال`"
      else
        forward = "🔸 `غیرفعال`"
      end

      local arabic = 'arabictg:'..chat_id
      if redis:get(arabic) then
        arabic = "🔹 `فعال`"
      else
        arabic = "🔸 `غیرفعال`"
      end

      local eng = 'engtg:'..chat_id
      if redis:get(eng) then
        eng = "🔹 `فعال`"
      else
        eng = "🔸 `غیرفعال`"
      end

      local badword = 'badwordtg:'..chat_id
      if redis:get(badword) then
        badword = "🔹 `فعال`"
      else
        badword = "🔸 `غیرفعال`"
      end

      local edit = 'edittg:'..chat_id
      if redis:get(edit) then
        edit = "🔹 `فعال`"
      else
        edit = "🔸 `غیرفعال`"
      end

      local emoji = 'emojitg:'..chat_id
      if redis:get(emoji) then
        emoji = "🔹 `فعال`"
      else
        emoji = "🔸 `غیرفعال`"
      end

      local caption = 'captg:'..chat_id
      if redis:get(caption) then
        caption = "🔹 `فعال`"
      else
        caption = "🔸 `غیرفعال`"
      end

      local inline = 'inlinetg:'..chat_id
      if redis:get(inline) then
        inline = "🔹 `فعال`"
      else
        inline = "🔸 `غیرفعال`"
      end

      local reply = 'replytg:'..chat_id
      if redis:get(reply) then
        reply = "🔹 `فعال`"
      else
        reply = "🔸 `غیرفعال`"
      end
      ----------------------------
      --muteall
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute all$") and is_mod(msg) and groups or input:match("^[Mm]ute all$") and is_mod(msg) and groups or input:match("^ممنوعیت همه$") and is_mod(msg) and groups then
        if redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت همه _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_alltg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنویعت همه _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute all$") and is_mod(msg) and groups or input:match("^[Uu]nmute all$") and is_mod(msg) and groups or input:match("^-ممنوعیت همه$") and is_mod(msg) and groups then
        if not redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت همه _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_alltg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت همه _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end

      --mute sticker
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute sticker$") and is_mod(msg) and groups or input:match("^[Mm]ute sticker$") and is_mod(msg) and groups or input:match("^ممنوعیت استیکر$") and is_mod(msg) and groups then
        if redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت استیکر _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_stickertg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت استیکر _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute sticker$") and is_mod(msg) and groups or input:match("^[Uu]nmute sticker$") and is_mod(msg) and groups or input:match("^-ممنوعیت استیکر$") and is_mod(msg) and groups then
        if not redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت استیکر _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_stickertg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت استیکر _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute gif
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute gif$") and is_mod(msg) and groups or input:match("^[Mm]ute gif$") and is_mod(msg) and groups or input:match("^ممنوعیت گیف$") and is_mod(msg) and groups then
        if redis:get('mute_giftg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت گیف _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_giftg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت گیف _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute gif$") and is_mod(msg) and groups  or input:match("^[Uu]nmute gif$") and is_mod(msg) and groups or input:match("^-ممنوعیت گیف$") and is_mod(msg) and groups then
        if not redis:get('mute_giftg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت گیف _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_giftg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت گیف _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute contact
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute contact$") and is_mod(msg) and groups or input:match("^[Mm]ute contact$") and is_mod(msg) and groups or input:match("^ممنوعیت شماره$") and is_mod(msg) and groups then
        if redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت شماره _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_contacttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت شماره _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute contact$") and is_mod(msg) and groups or input:match("^[Uu]nmute contact$") and is_mod(msg) and groups or input:match("^-ممنوعیت شماره$") and is_mod(msg) and groups then
        if not redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت شماره _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_contacttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت شماره _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute photo
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute photo$") and is_mod(msg) and groups or input:match("^[Mm]ute photo$") and is_mod(msg) and groups or input:match("^ممنوعیت عکس$") and is_mod(msg) and groups then
        if redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت عکس _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_phototg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت عکس _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute photo$") and is_mod(msg) and groups or input:match("^[Uu]nmute photo$") and is_mod(msg) and groups or input:match("^-ممنوعیت عکس$") and is_mod(msg) and groups then
        if not redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت عکس _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_phototg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت عکس _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute audio
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute audio$") and is_mod(msg) and groups or input:match("^[Mm]ute audio$") and is_mod(msg) and groups or input:match("^ممنوعیت اهنگ$") and is_mod(msg) and groups then
        if redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت اهنگ _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_audiotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت اهنگ _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute audio$") and is_mod(msg) and groups or input:match("^[Uu]nmute audio$") and is_mod(msg) and groups or input:match("^-ممنوعیت اهنگ$") and is_mod(msg) and groups then
        if not redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت اهنگ _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_audiotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت اهنگ _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute voice
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute voice$") and is_mod(msg) and groups or input:match("^[Mm]ute voice$") and is_mod(msg) and groups or input:match("^ممنوعیت صدا$") and is_mod(msg) and groups then
        if redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت صدا _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_voicetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت صدا _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute voice$") and is_mod(msg) and groups or input:match("^[Uu]nmute voice$") and is_mod(msg) and groups or input:match("^-ممنوعیت صدا$") and is_mod(msg) and groups then
        if not redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت صدا _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_voicetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت صدا _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute video
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute video$") and is_mod(msg) and groups or input:match("^[Mm]ute video$") and is_mod(msg) and groups or input:match("^ممنوعیت فیلم$") and is_mod(msg) and groups then
        if redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت فیلم _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_videotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت فیلم _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute video$") and is_mod(msg) and groups or input:match("^[Uu]nmute video$") and is_mod(msg) and groups or input:match("^-ممنوعیت فیلم$") and is_mod(msg) and groups then
        if not redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت فیلم _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_videotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت فیلم _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute document
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute document$") and is_mod(msg) and groups or input:match("^[Mm]ute document$") and is_mod(msg) and groups or input:match("^ممنوعیت فایل$") and is_mod(msg) and groups then
        if redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت فایل _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_documenttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت فایل _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute document$") and is_mod(msg) and groups or input:match("^[Uu]nmute document$") and is_mod(msg) and groups or input:match("^-ممنوعیت فایل$") and is_mod(msg) and groups then
        if not redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت فایل _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_documenttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت فایل _غیر فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --mute  text
      groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/][Mm]ute text$") and is_mod(msg) and groups or input:match("^[Mm]ute text$") and is_mod(msg) and groups or input:match("^ممنوعیت متن$") and is_mod(msg) and groups then
        if redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت چت _فعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:set('mute_texttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت چت _فعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      if input:match("^[#!/][Uu]nmute text$") and is_mod(msg) and groups or input:match("^[Uu]nmute text$") and is_mod(msg) and groups or input:match("^-ممنوعیت متن$") and is_mod(msg) and groups then
        if not redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔸 #ممنوعیت چت _غیرفعال_ است\n🎗 کانال: @JoveTeam', 1, 'md')
        else
          redis:del('mute_texttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔹 #ممنوعیت چت _غیرفعال_ شد\n🎗 کانال: @JoveTeam', 1, 'md')
        end
      end
      --settings
      local all = 'mute_alltg:'..chat_id
      if redis:get(all) then
        All = "🔹 `ممنوع`"
      else
        All = "🔸 `آزاد`"
      end

      local sticker = 'mute_stickertg:'..chat_id
      if redis:get(sticker) then
        sticker = "🔹 `ممنوع`"
      else
        sticker = "🔸 `آزاد`"
      end

      local gif = 'mute_giftg:'..chat_id
      if redis:get(gif) then
        gif = "🔹 `ممنوع`"
      else
        gif = "🔸 `آزاد`"
      end

      local contact = 'mute_contacttg:'..chat_id
      if redis:get(contact) then
        contact = "🔹 `ممنوع`"
      else
        contact = "🔸 `آزاد`"
      end

      local photo = 'mute_phototg:'..chat_id
      if redis:get(photo) then
        photo = "🔹 `ممنوع`"
      else
        photo = "🔸 `آزاد`"
      end

      local audio = 'mute_audiotg:'..chat_id
      if redis:get(audio) then
        audio = "🔹 `ممنوع`"
      else
        audio = "🔸 `آزاد`"
      end

      local voice = 'mute_voicetg:'..chat_id
      if redis:get(voice) then
        voice = "🔹 `ممنوع`"
      else
        voice = "🔸 `آزاد`"
      end

      local video = 'mute_videotg:'..chat_id
      if redis:get(video) then
        video = "🔹 `ممنوع`"
      else
        video = "🔸 `آزاد`"
      end

      local document = 'mute_documenttg:'..chat_id
      if redis:get(document) then
        document = "🔹 `ممنوع`"
      else
        document = "🔸 `آزاد`"
      end

      local text1 = 'mute_texttg:'..chat_id
      if redis:get(text1) then
        text1 = "🔹 `ممنوع`"
      else
        text1 = "🔸 `آزاد`"
      end
      if input:match("^[#!/][Ss]ettings$") and is_mod(msg) and groups or input:match("^[Ss]ettings$") and is_mod(msg) and groups or input:match("^تنظیمات$") and is_mod(msg) and groups then
        local text = "👥 `تنظیمات سوپرگروه`:".."\n"
        .."🏅 #قفل حساسیت => ".."`"..flood.."`".."\n"
        .."🏅 #قفل لینک => ".."`"..link.."`".."\n"
        .."🏅 #قفل تگ => ".."`"..tag.."`".."\n"
        .."🏅 #قفل نام کاربری => ".."`"..username.."`".."\n"
        .."🏅 #قفل فروارد => ".."`"..forward.."`".."\n"
        .."🏅 #قفل فارسی => ".."`"..arabic..'`'..'\n'
        .."🏅 #قفل انگلیسی  => ".."`"..eng..'`'..'\n'
        .."🏅 #قفل پاسخ => ".."`"..reply..'`'..'\n'
        .."🏅 #قفل کلمات زشت => ".."`"..badword..'`'..'\n'
        .."🏅 #قفل ویرایش => ".."`"..edit..'`'..'\n'
        .."🏅 #قفل کپشن => ".."`"..caption..'`'..'\n'
        .."🏅 #قفل اینلاین => ".."`"..inline..'`'..'\n'
        .."🏅 #قفل ایموجی => ".."`"..emoji..'`'..'\n'
        .."*.......................................*".."\n"
        .."🗣 `لیست ممنوعیت` :".."\n"
        .."🏅 #ممنوعیت همه : ".."`"..All.."`".."\n"
        .."🏅 #ممنوعیت استیکر : ".."`"..sticker.."`".."\n"
        .."🏅 #ممنوعیت گیف : ".."`"..gif.."`".."\n"
        .."🏅 #ممنوعیت شماره : ".."`"..contact.."`".."\n"
        .."🏅 #ممنوعیت عکس : ".."`"..photo.."`".."\n"
        .."🏅 #ممنوعیت اهنگ : ".."`"..audio.."`".."\n"
        .."🏅 #ممنوعیت صدا : ".."`"..voice.."`".."\n"
        .."🏅 #ممنوعیت فیلم : ".."`"..video.."`".."\n"
        .."🏅 #ممنوعیت فایل : ".."`"..document.."`".."\n"
        .."🏅 #ممنوعیت متن : ".."`"..text1.."`".."\n"
        .."🏅 ورژن 8.0 اوربیتال ژوپیتر - @JoveTeam"
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end
if input:match("^[#!/][Hh]elp$") and is_mod(msg) or input:match("^[Hh]elp$") and is_mod(msg) or input:match("^راهنما$") and is_mod(msg) then
        local text = "🏅`راهنماي فارسي انگليسي ورژن 8.0`:".."\n"
	.."🏅قفل ها:\n"
        .."🏅 *lock flood* = `قفل حساسیت`\n"
        .."🏅 *lock link* = `قفل لینک`\n"
        .."🏅 *lock tag* = `قفل تگ`\n"
        .."🏅 *lock username* = `قفل نام کاربری`\n"
        .."🏅 *lock forward* = `قفل فروارد`\n"
        .."🏅 *lock persian* = `قفل فارسی`\n"
        .."🏅 *lock english* = `قفل انگلیسی`\n"
        .."🏅 *lock reply* = `قفل پاسخ`\n"
        .."🏅 *lock badwords* = `قفل کلمات زشت`\n"
        .."🏅 *lock edit* = `قفل ویرایش`\n"
        .."🏅 *lock caption* = `قفل کپشن`\n"
        .."🏅 *lock inline* = `قفل اینلاین`\n"
        .."🏅 *lock emoji* = `قفل ایموجی`\n"
	.."🏅_برای باز کردن قفل ها بجای_ *lock* _از_ *unlock* _و در فارسی بجای_ `قفل` از `بازکردن` _استفاده کنید_:\n"
        .."*.................................*".."\n"
	.."🏅ممنوعیت ها:\n"
        .."🏅 *mute all* = `ممنوعیت همه`\n"
        .."🏅 *mute sticker* = `ممنوعیت استیکر`\n"
        .."🏅 *mute gif* = `ممنوعیت گیف`\n"
        .."🏅 *mute contact* = `ممنوعیت شماره`\n"
        .."🏅 *mute photo* = `ممنوعیت عکس`\n"
        .."🏅 *mute audio* = `ممنوعیت اهنگ`\n"
        .."🏅 *mute voice* = `ممنوعیت صدا`\n"
        .."🏅 *mute video* = `ممنوعیت فیلم`\n"
        .."🏅 *mute document* = `ممنوعیت فایل`\n"
	.."🏅 *mute text* = `ممنوعیت متن`\n"
	.."🏅_برای باز کردن ممنوعیت ها بجای_ *mute* _از_ *unmute* _و در فارسی بجای_ `ممنوعیت` از `-ممنوعیت` _استفاده کنید_:\n"
	.."🏅متفرقه"
        .."🏅 *promote [reply/id]* = `ارتقا [ایدی/ریپلای]`\n"
	.."🏅 *demote [reply/id]* = `عزل [ایدی/ریپلای]`\n"
	.."🏅 *pin [reply]* = `سنجاق [ریپلای]`\n"
		.."🏅 *unpin* = `حذف سنجاق`\n"
		.."🏅 *kick* = `اخراج`\n"
		.."🏅 *muteuser* = `ساکت کردن`\n"
		.."🏅 *unmuteuser* = `-ساکت کردن`\n"
		.."🏅 *muteusers* = `لیست ساکت شدگان`\n"
		.."🏅 *setname* = `تنظیم نام`\n"
		.."🏅 *edit* = `ویرایش`\n"
		.."🏅 *del* = `حذف`\n"
.."🏅 *joke* = `جوک`\n"
.."🏅 *setlink* = `تنظيم لينک`\n"
.."🏅 *link* = `لينک`\n"
.."🏅 *setrules* = `تنظيم قوانين`\n"
	.."🏅 *rules* = `قوانين`\n"
	.."🏅 `شما میتونید از ` *!*,*/*,*#* `یا حتی بدون این علائم برای ارسال دستور استفاده کنید`\n"
        .."🏅 ورژن 8.0 اوربیتال ژوپیتر - @JoveTeam"
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end
if input:match("^[#!/][Jj][Oo][Vv][Ee]$") and is_mod(msg) or input:match("^[Jj][Oo][Vv][Ee]$") and is_mod(msg) or input:match("^ژوپيتر$") and is_mod(msg) then
        local text = "🏅 خداي ژوپيتر ورژن 8.0: \n"
	.." ژوپيتر رباتي قدرتمند جهت مديريت سوپرگروه: \n"
        .."🏅 نوشته شده برپايه tdcli(New TG) \n"
        .."🏅  بيس = TeleMute \n"
        .."🏅 پشتيباني از قفل اديت وسنجاق \n"
        .."🏅 سرعت بالا بدون جاگذاشتن لينک \n"
        .."🏅 لانچ شدن خودکار هر 3دقيقه \n"
        .."🏅  ديباگ شده و قدرتمند \n"
        .."🏅  ويرايش و ارتقا: @ByeCoder \n"
        .."🏅  کانال رسمي: @JoveTeam \n"
        .."🏅  پيام رسان: @PvJoveTeamBot \n"
        .."🏅 سرور: #Hetzner \n"
        .."🏅 رم: 16Gig \n"
        .."🏅 پشتيباني: JoveServer.Com \n"
        .." ................................. "
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end

      if input:match("^[#!/][Ff]wd$") and is_sudo(msg) or input:match("^[Ff]wd$") and is_sudo(msg) or input:match("^فروارد$") and is_sudo(msg) then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end

      if input:match("^[#!/][Uu]sername") and is_sudo(msg) or input:match("^[Uu]sername") and is_sudo(msg) or input:match("^نام کاربری") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Username Changed To </b>@'..string.sub(input, 11), 1, 'html')
      end

      if input:match("^[#!/][Ee]cho") and is_sudo(msg) or input:match("^[Ee]cho") and is_sudo(msg) or input:match("^بگو") and is_sudo(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, string.sub(input, 7), 1, 'html')
      end

      if input:match("^[#!/][Ss]etname") and is_owner(msg) or input:match("^[Ss]etname") and is_owner(msg) or input:match("^تنظیم نام") and is_owner(msg) then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅<i> نام سوپر گروه به </i><code>'..string.sub(input, 10)..'</code><i> تغییر کرد </i>', 1, 'html')
      end
	  
      if input:match("^[#!/][Cc]hangename") and is_sudo(msg) or input:match("^[Cc]hangename") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot Name Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^[#!/][Cc]hangeuser") and is_sudo(msg) or input:match("^[Cc]hangeuser") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot UserName Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^[#!/][Dd]eluser") and is_sudo(msg) or input:match("^[Dd]eluser") and is_sudo(msg) then
        tdcli.changeUsername('')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '#Done\nUsername Has Been Deleted', 1, 'html')
      end
	  
      if input:match("^[#!/][Ee]dit") and is_owner(msg) or input:match("^[Ee]dit") and is_owner(msg) or input:match("^ویرایش") and is_owner(msg) then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

      if input:match("^[#!/]delpro") and is_sudo(msg) or input:match("^delpro") and is_sudo(msg) then
        tdcli.DeleteProfilePhoto(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>#done profile has been deleted</b>', 1, 'html')
      end

      if input:match("^[#!/][Ii]nvite") and is_sudo(msg) or input:match("^[Ii]nvite") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
	  
      if input:match("^[#!/][Cc]reatesuper") and is_sudo(msg) or input:match("^[Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^[#!/]del") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 or input:match("^del") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
        tdcli.deleteMessages(msg.chat_id_, {[0] = msg.reply_to_message_id_})
      end

      if input:match('^[#!/]tosuper') and is_sudo(msg) or input:match('^tosuper') and is_sudo(msg) then
        local gpid = msg.chat_id_
        tdcli.migrateGroupChatToChannelChat(gpid)
      end

      if input:match("^[#!/]view") and is_sudo(msg) or input:match("^view") and is_sudo(msg) then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅<i>پیام خوانده شد</i>', 1, 'html')
      end
 if input:match("^[#!/]setnerkh") and is_sudo(msg) or input:match("^setnerkh") and is_sudo(msg) then
  if not is_admin(msg) then 
 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅<i>شما سودو نیستید</i>', 1, 'html')
end 
local nerkh = matches[2] 
redis:set('bot:nerkh',nerkh) 
 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🏅<i>متن شما با موفقیت تنظیم شد</i>', 1, 'html')
end 			
 if input:match("^[#!/]leave") and is_sudo(msg) then
         tdcli.chat_leave(chat_id, {[0] = msg.id_})
         tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<code>باشه!خدافظي :)</code>', 1, 'html')
       end
    end

    local input = msg.content_.text_
    if redis:get('mute_alltg:'..chat_id) and msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_stickertg:'..chat_id) and msg.content_.sticker_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_giftg:'..chat_id) and msg.content_.animation_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_contacttg:'..chat_id) and msg.content_.contact_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_phototg:'..chat_id) and msg.content_.photo_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_audiotg:'..chat_id) and msg.content_.audio_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_voicetg:'..chat_id) and msg.content_.voice_  and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_videotg:'..chat_id) and msg.content_.video_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_documenttg:'..chat_id) and msg.content_.document_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_texttg:'..chat_id) and msg.content_.text_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    if redis:get('forwardtg:'..chat_id) and msg.forward_info_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    local is_link_msg = input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or input:match("[Tt].[Mm][Ee]/")
     if redis:get('lock_linkstg:'..chat_id) and is_link_msg and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tagtg:'..chat_id) and input:match("#") and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('usernametg:'..chat_id) and input:match("@") and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('arabictg:'..chat_id) and input:match("[\216-\219][\128-\191]") and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
    if redis:get('engtg:'..chat_id) and is_english_msg and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_fosh_msg = input:match("کیر") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt") or input:match("حروم") or input:match("لاشی")
    if redis:get('badwordtg:'..chat_id) and is_fosh_msg and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
    if redis:get('emojitg:'..chat_id) and is_emoji_msg and not is_mod(msg) and not is_owner(msg)  then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('captg:'..chat_id) and  msg.content_.caption_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('locatg:'..chat_id) and  msg.content_.location_ and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('inlinetg:'..chat_id) and  msg.via_bot_user_id_ ~= 0 and not is_mod(msg) and not is_owner(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('replytg:'..chat_id) and  msg.reply_to_message_id_ and not is_mod(msg) and not is_owner(msg) ~= 0 then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tbt:'..chat_id) and is_normal(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    -- AntiFlood --
    local floodMax = 5
    local floodTime = 2
    local hashflood = 'floodtg:'..msg.chat_id_
    if redis:get(hashflood) and not is_mod(msg) and not is_owner(msg) then
      local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
      local msgs = tonumber(redis:get(hash) or 0)
      if msgs > (floodMax - 1) then
        tdcli.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
        tdcli.sendText(msg.chat_id_, msg.id_, 1, '🏅 کاربر _'..msg.sender_user_id_..'_ به دلیل ارسال `بیش از حد` پیام اخراج شد!\n🏅 کانال: @JoveTeam', 1, 'md')
        redis:setex(hash, floodTime, msgs+1)
      end
    end
    -- AntiFlood --
		elseif data.ID == "UpdateMessageEdited" then
if redis:get('edittg:'..data.chat_id_) then
  tdcli.deleteMessages(data.chat_id_, {[0] = tonumber(data.message_id_)})
end 
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
	
    -- @JoveTeam
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
