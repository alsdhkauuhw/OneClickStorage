-- 设置全局环境
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

-- 获取配置
local storage_key = GetModConfigData("storage_key")
local search_range = GetModConfigData("search_range")
local include_floor = GetModConfigData("include_floor")
local support_portablecellar = GetModConfigData("support_portablecellar")
local support_chest = GetModConfigData("support_chest")
local support_icebox = GetModConfigData("support_icebox")
local only_floor_items = GetModConfigData("only_floor_items")
local enable_slot_lock = GetModConfigData("enable_slot_lock")

-- ===== 格子锁定 Slot Lock（中键锁定物品栏某格，使其不入箱）=====
-- 锁定状态：{ [槽位号] = true }，按 (存档槽, 人物) 维度持久化
-- Locked slots are skipped during one-click storage; persisted per (save slot, character).
local locked_slots = {}
local persistence_filename = nil
local _ocs_middle_registered = false
-- 中键常量（若该版本缺失 MOUSEBUTTON_MIDDLE，回退到常见值 3）
local OCS_MOUSE_MIDDLE = MOUSEBUTTON_MIDDLE or 3

-- 持久化：把 locked_slots 序列化写入文件（文件名已编码 存档槽+人物）
local function ocs_save_locks()
    if not persistence_filename then return end
    TheSim:SetPersistentString(persistence_filename, json.encode(locked_slots), false, nil)
end

-- 持久化：异步读取并归一化为数字键
local function ocs_load_locks(filename, onload)
    TheSim:GetPersistentString(filename, function(str)
        local data = {}
        if str then
            local ok, decoded = pcall(json.decode, str)
            if ok and type(decoded) == "table" then
                for k in pairs(decoded) do
                    data[tonumber(k) or k] = true
                end
            end
        end
        onload(data)
    end, false)
end

-- widget 是否获得焦点（优先用方法，回退到 focus 字段）
local function ocs_has_focus(w)
    if w.HasFocus then return w:HasFocus() end
    return w.focus == true
end

-- 在物品栏 widget 树里查找当前获得焦点(focus)的 InvSlot（带 num 字段）
local function find_focused_invslot(widget)
    if not widget then return nil end
    if widget.num ~= nil and ocs_has_focus(widget) then
        return widget
    end
    if widget.children then
        for _, c in ipairs(widget.children) do
            local hit = find_focused_invslot(c)
            if hit then return hit end
        end
    end
    return nil
end

-- 取得物品栏 InventoryBar widget（player.HUD.controls.inv 或 player.components.playerhud.controls.inv）
local function ocs_get_invbar()
    local player = GetPlayer()
    if not player then return nil end
    local hud = player.HUD or (player.components and player.components.playerhud)
    return hud and hud.controls and hud.controls.inv
end

-- 中键切换某格的锁定状态
local function ocs_toggle_lock()
    if not enable_slot_lock then return end
    local slot = find_focused_invslot(ocs_get_invbar())
    if not slot or slot.num == nil then return end

    local n = slot.num
    if locked_slots[n] then
        locked_slots[n] = nil
    else
        locked_slots[n] = true
    end
    ocs_save_locks()

    local player = GetPlayer()
    if player and player.components.talker then
        player.components.talker:Say(locked_slots[n] and "已锁定该格（不入箱）" or "已解锁该格")
    end
end

-- 视觉提示：锁定格整体偏红；每 0.5s 重应用以抗物品栏刷新/重排
local function ocs_apply_visuals()
    local inv = ocs_get_invbar()
    if not inv then return end
    local function walk(w)
        if w and w.num ~= nil then
            if locked_slots[w.num] then
                w:SetMultColour(1, 0.3, 0.3, 1)
            else
                w:SetMultColour(1, 1, 1, 1)
            end
        end
        if w and w.children then
            for _, c in ipairs(w.children) do walk(c) end
        end
    end
    walk(inv)
end

-- 按键映射表
local key_map = {
    R = KEY_R, T = KEY_T, Y = KEY_Y, U = KEY_U,
    G = KEY_G, H = KEY_H, J = KEY_J, Z = KEY_Z,
    X = KEY_X, C = KEY_C, V = KEY_V, B = KEY_B,
    N = KEY_N, K = KEY_K, L = KEY_L, O = KEY_O, P = KEY_P,
    F1 = KEY_F1, F2 = KEY_F2, F3 = KEY_F3, F4 = KEY_F4,
    F5 = KEY_F5, F6 = KEY_F6, F7 = KEY_F7, F8 = KEY_F8,
    F9 = KEY_F9, F10 = KEY_F10, F11 = KEY_F11, F12 = KEY_F12
}

-- 特效函数
local function CreateFx(inst, fx_name, color)
    local fx = SpawnPrefab(fx_name or "statue_transition_2")
    if color then
        fx.AnimState:SetMultColour(color[1]/255, color[2]/255, color[3]/255, 1)
    end
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

-- 判断容器是否可用
local function IsValidContainer(target)
    if not target or not target.components.container then
        return false
    end

    -- 检查是否是便携地窖
    if support_portablecellar and target.prefab == "portablecellar" then
        return true
    end

    -- 检查是否是原版箱子 (treasurechest 是原版箱子的prefab名，不带下划线)
    if support_chest and target.prefab == "treasurechest" then
        return true
    end

    -- 检查是否是原版冰箱
    if support_icebox and target.prefab == "icebox" then
        return true
    end

    return false
end

-- 一键入箱核心功能
local function OneClickStorage(container, include_floor_items)
    local player = GetPlayer()
    if not player then return end

    -- 获取箱子中已有的物品种类
    local container_slots = container.components.container.slots
    local item_types = {}

    for _, item in pairs(container_slots) do
        if item and not item_types[item.prefab] then
            item_types[item.prefab] = true
        end
    end

    -- 如果箱子是空的，不执行操作
    if next(item_types) == nil then
        if player.components.talker then
            player.components.talker:Say("空箱子不能使用一键入箱！")
        end
        return
    end

    local has_stored = false
    local is_full = false

    -- 存储物品的函数
    local function StoreItem(item, source_container, slot_num)
        if not item or not item_types[item.prefab] then
            return
        end

        -- 排除一些特殊物品
        if item.prefab == "super_package" then
            return
        end

        -- 排除便携地窖（永远不要把便携地窖当作存储目标物品）
        if item.prefab == "portablecellar" then
            return
        end

        -- 排除当前目标容器本身（避免把容器放进自己里面）
        if item == container then
            return
        end

        -- 可堆叠物品的处理
        if item.components.stackable then
            if not container.components.container:IsFull() then
                CreateFx(container, "statue_transition_2", {218,112,214})
                if source_container and slot_num then
                    -- 从玩家物品栏或背包中移除
                    container.components.container:GiveItem(
                        source_container:RemoveItemBySlot(slot_num),
                        nil,
                        Vector3(TheSim:GetScreenPos(player.Transform:GetWorldPosition()))
                    )
                else
                    -- 从地面拾取
                    container.components.container:GiveItem(
                        item,
                        nil,
                        Vector3(TheSim:GetScreenPos(item.Transform:GetWorldPosition()))
                    )
                end
                has_stored = true
            elseif container.components.container:IsFull() then
                -- 箱子满了，尝试堆叠到现有物品
                for k, v in pairs(container_slots) do
                    if v and v.prefab == item.prefab and v.components.stackable and not v.components.stackable:IsFull() then
                        local space_left = v.components.stackable.maxsize - v.components.stackable.stacksize
                        if space_left >= item.components.stackable.stacksize then
                            if source_container and slot_num then
                                container.components.container:GiveItem(
                                    source_container:RemoveItemBySlot(slot_num),
                                    nil,
                                    Vector3(TheSim:GetScreenPos(player.Transform:GetWorldPosition()))
                                )
                            else
                                container.components.container:GiveItem(
                                    item,
                                    nil,
                                    Vector3(TheSim:GetScreenPos(item.Transform:GetWorldPosition()))
                                )
                            end
                            has_stored = true
                            break
                        else
                            -- 只放入部分
                            local new_item = SpawnPrefab(item.prefab)
                            if item.components.perishable then
                                new_item.components.perishable.perishremainingtime = item.components.perishable.perishremainingtime
                            end
                            new_item.components.stackable.stacksize = space_left
                            container.components.container:GiveItem(
                                new_item,
                                nil,
                                Vector3(TheSim:GetScreenPos(player.Transform:GetWorldPosition()))
                            )
                            if source_container and slot_num then
                                player.components.inventory:ConsumeByName(item.prefab, space_left)
                            else
                                item.components.stackable.stacksize = item.components.stackable.stacksize - space_left
                            end
                            has_stored = true
                        end
                    else
                        is_full = true
                    end
                end
            end
        else
            -- 不可堆叠物品
            if not container.components.container:IsFull() then
                CreateFx(container, "statue_transition_2", {218,112,214})
                if source_container and slot_num then
                    container.components.container:GiveItem(
                        source_container:RemoveItemBySlot(slot_num),
                        nil,
                        Vector3(TheSim:GetScreenPos(player.Transform:GetWorldPosition()))
                    )
                else
                    container.components.container:GiveItem(
                        item,
                        nil,
                        Vector3(TheSim:GetScreenPos(item.Transform:GetWorldPosition()))
                    )
                end
                has_stored = true
            else
                is_full = true
            end
        end
    end

    -- 1. 处理玩家物品栏（跳过被锁定的格子）
    if not only_floor_items then
        local player_slots = player.components.inventory.itemslots
        for slot_num, item in pairs(player_slots) do
            if not locked_slots[slot_num] then
                StoreItem(item, player.components.inventory, slot_num)
            end
        end
    end

    -- 2. 处理玩家背包
    if not only_floor_items then
        local backpack = player.components.inventory.equipslots[EQUIPSLOTS.BACK] or
                         player.components.inventory.equipslots[EQUIPSLOTS.BODY]
        if backpack and backpack.components.container then
            local backpack_slots = backpack.components.container.slots
            for slot_num, item in pairs(backpack_slots) do
                StoreItem(item, backpack.components.container, slot_num)
            end
        end
    end

    -- 3. 处理地面物品
    if include_floor_items then
        local pos = Vector3(player.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 10, nil, {"INLIMBO", "NOCLICK", "catchable", "fire"})
        for _, item in pairs(ents) do
            if item and item_types[item.prefab] and
               item.prefab ~= "super_package" and
               item.prefab ~= "fireflies" and
               not item.components.health then
                StoreItem(item, nil, nil)
            end
        end
    end

    -- 显示结果
    if has_stored then
        if player.components.talker then
            player.components.talker:Say("放入完毕！")
        end
        container.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/open")
    else
        if player.components.talker then
            player.components.talker:Say("当前没有物品可自动放入！")
        end
    end

    if is_full then
        if player.components.talker then
            player.components.talker:Say("箱子已满无法自动放入！")
        end
    end
end

-- 添加按键监听
AddPlayerPostInit(function(inst)
    if inst == GetPlayer() then
        -- ===== 格子锁定初始化 Slot Lock init（仅当功能开启）=====
        if enable_slot_lock then
            local save_slot = (SaveGameIndex and SaveGameIndex.GetCurrentSaveSlot and SaveGameIndex:GetCurrentSaveSlot())
                          or (SaveGameIndex and SaveGameIndex.current_slot) or 0
            local character = inst.prefab or "unknown"
            persistence_filename = string.format("ocs_slotlocks_%s_%s", tostring(save_slot), tostring(character))

            ocs_load_locks(persistence_filename, function(data)
                locked_slots = data
            end)

            -- 注册中键切换（只注册一次）
            if not _ocs_middle_registered then
                _ocs_middle_registered = true
                TheInput:AddMouseButtonHandler(OCS_MOUSE_MIDDLE, true, function()
                    ocs_toggle_lock()
                end)
            end

            -- 视觉提示：每 0.5s 重应用，锁定格偏红
            inst:DoPeriodicTask(0.5, ocs_apply_visuals)
        end

        TheInput:AddKeyDownHandler(key_map[storage_key], function()
            local player = GetPlayer()
            if not player then return end

            local pos = Vector3(player.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, search_range, nil, {"INLIMBO", "NOCLICK", "catchable", "fire"})

            local containers_found = {}

            -- 1. 收集地面上的容器
            for _, ent in pairs(ents) do
                if IsValidContainer(ent) then
                    table.insert(containers_found, ent)
                end
            end

            -- 2. 收集物品栏中的便携地窖
            if support_portablecellar and not only_floor_items then
                local player_slots = player.components.inventory.itemslots
                for _, item in pairs(player_slots) do
                    if item and item.prefab == "portablecellar" then
                        table.insert(containers_found, item)
                    end
                end

                -- 3. 收集背包中的便携地窖
                local backpack = player.components.inventory.equipslots[EQUIPSLOTS.BACK] or
                                 player.components.inventory.equipslots[EQUIPSLOTS.BODY]
                if backpack and backpack.components.container then
                    local backpack_slots = backpack.components.container.slots
                    for _, item in pairs(backpack_slots) do
                        if item and item.prefab == "portablecellar" then
                            table.insert(containers_found, item)
                        end
                    end
                end
            end

            -- 对每个容器执行一键入箱
            if #containers_found > 0 then
                for _, container in ipairs(containers_found) do
                    OneClickStorage(container, include_floor)
                end

                if player.components.talker then
                    player.components.talker:Say("一键入箱完成！")
                end
            else
                if player.components.talker then
                    player.components.talker:Say("附近没有可用的容器！")
                end
            end
        end)
    end
end)
