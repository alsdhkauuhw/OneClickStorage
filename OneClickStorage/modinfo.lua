name = "One Click Storage"
description = "一键入箱 - 自动将物品存入附近的箱子\n\n支持:\n- Portable Cellar (便携地窖)\n- 原版箱子 (Chest)\n- 原版冰箱 (Ice Box)\n\nOne Click Storage - Automatically store items into nearby containers\n\nSupports:\n- Portable Cellar\n- Vanilla Chest\n- Vanilla Ice Box\n\nv1.0"
author = "大胜利"
version = "1.0.1"
forumthread = ""
api_version = 6

priority = 100
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
dst_compatible = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- 按键选项
local key_options = {
    {description = "R", data = "R"},
    {description = "T", data = "T"},
    {description = "Y", data = "Y"},
    {description = "U", data = "U"},
    {description = "G", data = "G"},
    {description = "H", data = "H"},
    {description = "J", data = "J"},
    {description = "Z", data = "Z"},
    {description = "X", data = "X"},
    {description = "C", data = "C"},
    {description = "V", data = "V"},
    {description = "B", data = "B"},
    {description = "N", data = "N"},
    {description = "K", data = "K"},
    {description = "L", data = "L"},
    {description = "O", data = "O"},
    {description = "P", data = "P"}
}

configuration_options = {
    {
        name = "storage_key",
        label = "一键入箱按键 Storage Key",
        options = key_options,
        default = "Z",
        hover = "按下此键触发一键入箱功能 Press this key to trigger one-click storage"
    },
    {
        name = "search_range",
        label = "搜索范围 Search Range",
        options = {
            {description = "10", data = 10},
            {description = "15", data = 15},
            {description = "20", data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30}
        },
        default = 20,
        hover = "搜索附近容器的范围 Range to search for nearby containers"
    },
    {
        name = "include_floor",
        label = "包含地面物品 Include Floor Items",
        options = {
            {description = "是 Yes", data = true},
            {description = "否 No", data = false}
        },
        default = true,
        hover = "是否将地面物品也放入箱子 Whether to store floor items into containers"
    },
    {
        name = "support_portablecellar",
        label = "支持便携地窖 Support Portable Cellar",
        options = {
            {description = "是 Yes", data = true},
            {description = "否 No", data = false}
        },
        default = true,
        hover = "是否支持Portable Cellar模组 Whether to support Portable Cellar mod"
    },
    {
        name = "support_chest",
        label = "支持原版箱子 Support Vanilla Chest",
        options = {
            {description = "是 Yes", data = true},
            {description = "否 No", data = false}
        },
        default = true,
        hover = "是否支持原版箱子 Whether to support vanilla chest"
    },
    {
        name = "support_icebox",
        label = "支持原版冰箱 Support Vanilla Ice Box",
        options = {
            {description = "是 Yes", data = true},
            {description = "否 No", data = false}
        },
        default = true,
        hover = "是否支持原版冰箱 Whether to support vanilla ice box"
    }
}
