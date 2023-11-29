ID_MAP_BAYOU = 725
ID_NPC_BANISH = 43384
ID_NPC_SPIDER = 43383
ID_OBJECT_BOSS_ASHES = 244606
ID_OBJECT_BOUNTY_CHEST = 244607
ID_OBJECT_BOUNTY_PLAYER_DROP = 244608
ID_ITEM_BOUNTY_TOKEN = 56807
ID_SPELL_BANISHING_SHORT = 80866
ID_SPELL_BANISHING = 80882

ADDON_PREFIX_INFO = "BOUNTY_INFO"
ADDON_PREFIX_CARRIERS = "BOUNTY_CARRIERS"
ADDON_PREFIX_BOSS_STATUS = "BOUNTY_BOSS_STATUS"

local spawned_guid = 0
local spawned = false
local is_alive = false
local is_banishing = false
local init = false

local respawn_time = 60 -- Boss respawn time.
local boss_bounty_chest_despawn_time = 10 -- Despawn time for chests.
local last_died_time = 0
local last_spawned_position = {}

-- Ashes on ground after boss dies
local banish_ashes_guid = 0

-- The creature casting Banishing... spell
local banishing_creature_guid = 0

local last_update_carriers = 0
local update_carriers_interval = 1

local function SendAllRaidWarning(msg)
  map = GetMapById(ID_MAP_BAYOU)
  players = map:GetPlayers();
  for k,p in pairs(players) do
    p:SendAddonMessage(ADDON_PREFIX_INFO,msg,0,p)
  end
  SendWorldMessage(msg)
end

local function SpawnBoss()
  pos = {3416.435, 2027.467, -7.1588, 1.422}
  local spawned_boss = PerformIngameSpawn(1, ID_NPC_SPIDER, ID_MAP_BAYOU, 0, pos[1], pos[2], pos[3], pos[4])
  if spawned_boss then
    spawned_guid = spawned_boss:GetGUID()
    print("[BOUNTYSYSTEM] Spawned boss with GUID: "..tostring(spawned_guid))
    spawned = true
    SendAllRaidWarning("A Boss Target has spawned!")
    last_spawned_position = pos
    is_alive = true
  end
end

local function RemoveBountyBox(eventid, delay, repeats, wo)
  wo:RemoveFromWorld()
  print("[BOUNTYSYSTEM] Removed a bounty chest after "..delay.." milliseconds.")
end

local function UnInit()
  print("[BOUNTYSYSTEM] Unitializing bounty system.")
  init = false
  spawned = false
  is_alive = false
  is_banishing = false
  spawned_guid = 0
  last_died_time = 0
end

local function HandleDeadPlayers()
  -- Handle dead players, drop bounty tokens if in inventory
  local map = GetMapById(ID_MAP_BAYOU)
  local players = map:GetPlayers()
  for k,player in pairs(players) do
    if(player:IsDead()) then
      if player:HasItem(ID_ITEM_BOUNTY_TOKEN) then
        print("[BOUNTYSYSTEM] "..player:GetName().." died with Bounty, spawning dropped bounty.")
        player:RemoveItem(ID_ITEM_BOUNTY_TOKEN,1)
        local dropped_bounty_object = PerformIngameSpawn(2, ID_OBJECT_BOUNTY_PLAYER_DROP, ID_MAP_BAYOU, 0, player:GetX(), player:GetY(), player:GetZ(), 0, false, 0, 1)
        dropped_bounty_object:RegisterEvent(RemoveBountyBox, boss_bounty_chest_despawn_time*1000)
        SendAllRaidWarning(player:GetName().." has died and dropped their Bounty Token!")
      end
    end
  end
end

local function UpdateBossStatus()
  map = GetMapById(ID_MAP_BAYOU)
  players = map:GetPlayers()
  for k,player in pairs(players) do
    local status = "ALIVE"
    if not is_alive then status="DEAD" end
    if is_banishing then status="BANISHING" end
    player:SendAddonMessage(ADDON_PREFIX_BOSS_STATUS,status..","..last_spawned_position[1].."_"..last_spawned_position[2].."_"..last_spawned_position[3],0,player)
  end
end

local function UpdateBountyCarriers()
  map = GetMapById(ID_MAP_BAYOU)
  players = map:GetPlayers()

  local carriers = {}
  local count = 0
  for k,player in pairs(players) do
    if player:HasItem(ID_ITEM_BOUNTY_TOKEN) then
      carriers[count+1] = {player:GetName(),player:GetX(),player:GetY()}
      count = count+1
    end
  end
  local msg = ""
  if count > 0 then
    for k,carrier in pairs(carriers) do
      msg = msg..carrier[1].."_"..tostring(carrier[2]).."_"..tostring(carrier[3])
      if not (count == k) then
        msg = msg..","
      end
    end
  end
  for k,player in pairs(players) do
    player:SendAddonMessage(ADDON_PREFIX_CARRIERS,msg,0,player)
  end
end

local function OnServerUpdate(event, diff)
  if GetMapById(ID_MAP_BAYOU) then
    HandleDeadPlayers()
    if GetGameTime() > (last_update_carriers+update_carriers_interval) then
      UpdateBountyCarriers()
      UpdateBossStatus()
      last_update_carriers = GetGameTime()
    end
  end

  if not init then return end
  if(spawned == false and GetGameTime() > (last_died_time+respawn_time)) then
    SpawnBoss(); -- if time to respawn, respawn.
  end
  map = GetMapById(ID_MAP_BAYOU)
  if is_alive and not map:GetWorldObject(spawned_guid) then
    UnInit()
  end
end

local function Init()
  print("[BOUNTYSYSTEM] Initializing... Spawning first boss and registering UpdateEvent.");
  SpawnBoss()
  RegisterServerEvent( 13, OnServerUpdate)
  init = true
end

local function OnDeath(event, creature, killer)
  if (creature:GetGUID() == spawned_guid) then
    print("[BOUNTYSYSTEM] Boss died: "..creature:GetName())
    -- Spawn banish object
    banish_ashes = PerformIngameSpawn(2, ID_OBJECT_BOSS_ASHES, ID_MAP_BAYOU, 0, creature:GetX(), creature:GetY(), creature:GetZ(), 0)
    banish_ashes:RegisterEvent(RemoveBountyBox, boss_bounty_chest_despawn_time*1000)
    banish_ashes_guid = banish_ashes:GetGUID()
    creature:RemoveCorpse()
    is_alive = false
  end
end

local function OnAshesUse(event, go, player)
  if(go:GetGUID() == banish_ashes_guid) then
    print("[BOUNTYSYSTEM] Banishing boss!")
    SendAllRaidWarning("Boss is being banished!")
    banishing_creature = PerformIngameSpawn(1, ID_NPC_BANISH, ID_MAP_BAYOU, 0, go:GetX(), go:GetY(), go:GetZ(), 0)
    banishing_creature:CastSpell(banishing_creature,ID_SPELL_BANISHING,false)
    banishing_creature_guid = banishing_creature:GetGUID()
    is_banishing = true
    go:RemoveFromWorld(0)
  end
end

local function OnBanishSpellFinish(event, creature, caster, spellid)
  if creature:GetGUID() == banishing_creature_guid and spellid == ID_SPELL_BANISHING then
    print("[BOUNTYSYSTEM] Boss banished! Deleting caster and spawning loot.");
    boss_bounty_chest_object = PerformIngameSpawn(2, ID_OBJECT_BOUNTY_CHEST, ID_MAP_BAYOU, 0, creature:GetX(), creature:GetY(), creature:GetZ(), 0, false, 0, 1)
    boss_bounty_chest_object:RegisterEvent(RemoveBountyBox, boss_bounty_chest_despawn_time*1000)
    creature:DespawnOrUnsummon(0)
    spawned = false
    is_banishing = false
    last_died_time = GetGameTime()
  end
end

local function OnPlayerEnter(event, map, player)
  if (map:GetMapId() == ID_MAP_BAYOU) and init == false then
    Init()
  end
end

local function OnPlayerUpdateZone(event, player, newZone, newArea)
  local map = GetMapById(ID_MAP_BAYOU)
  if map and not init then
    Init()
  end
end

local function OnBaoyuMapLoad(event, instance_data, map)
  if (map:GetMapId() == ID_MAP_BAYOU) and init == false then
    Init()
  end
end

local function OnPlayerLoot(event, player, item, count)
  if item:GetEntry() == ID_ITEM_BOUNTY_TOKEN then
    SendAllRaidWarning(player:GetName().." has collected a bounty token!")
  end
end

local function Reset()
  local map = GetMapById(ID_MAP_BAYOU)
  local creature = map:GetWorldObject(spawned_guid)
  if creature then
    creature:DespawnOrUnsummon(0)
  end
  UnInit()
  Init()
end

local function OnPlayerChat(event, player, msg, Type, lang)
  if msg == "-bs reset" and player:GetGMRank() then
    Reset()
  end
end

RegisterCreatureEvent(ID_NPC_SPIDER,4,OnDeath)
RegisterServerEvent(21, OnPlayerEnter)
RegisterGameObjectEvent(ID_OBJECT_BOSS_ASHES, 14, OnAshesUse)
RegisterCreatureEvent(ID_NPC_BANISH, 14, OnBanishSpellFinish)
RegisterPlayerEvent(32, OnPlayerLoot)
RegisterPlayerEvent(18, OnPlayerChat)
RegisterServerEvent(13, OnServerUpdate)
RegisterPlayerEvent(27, OnPlayerUpdateZone)
