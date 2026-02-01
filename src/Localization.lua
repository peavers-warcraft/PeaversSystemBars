local _, PSB = ...

-- Initialize Localization namespace
PSB.L = {}
local L = PSB.L

-- Get the client's locale
local locale = GetLocale()

-- Default locale (English)
local defaultLocale = "enUS"

-- Localization tables
local Locales = {}

-- English (Default)
Locales["enUS"] = {
    -- Stat Names
    ["STAT_FPS"] = "FPS",
    ["STAT_HOME"] = "Home",
    ["STAT_WORLD"] = "World",

    -- Units
    ["UNIT_FPS"] = "fps",
    ["UNIT_MS"] = "ms",

    -- Commands
    ["CMD_TOGGLE"] = "Toggle system bars display",
    ["CMD_CONFIG"] = "Open configuration panel",
    ["CMD_HELP"] = "Show available commands",

    -- Messages
    ["MSG_ADDON_LOADED"] = "PeaversSystemBars loaded. Type /psb for commands.",
    ["MSG_SHOWN"] = "PeaversSystemBars shown.",
    ["MSG_HIDDEN"] = "PeaversSystemBars hidden.",

    -- Config UI - Section Headers
    ["CONFIG_DISPLAY_SETTINGS"] = "Display Settings",
    ["CONFIG_BAR_APPEARANCE"] = "Bar Appearance",
    ["CONFIG_TEXT_SETTINGS"] = "Text Settings",
    ["CONFIG_STAT_COLORS"] = "Stat Colors",

    -- Config UI - Display Settings
    ["CONFIG_FRAME_DIMENSIONS"] = "Frame Dimensions:",
    ["CONFIG_FRAME_WIDTH"] = "Frame Width",
    ["CONFIG_BG_OPACITY"] = "Background Opacity",
    ["CONFIG_VISIBILITY_OPTIONS"] = "Visibility Options:",
    ["CONFIG_SHOW_TITLE_BAR"] = "Show Title Bar",
    ["CONFIG_LOCK_POSITION"] = "Lock Frame Position",

    -- Config UI - Bar Appearance
    ["CONFIG_BAR_DIMENSIONS"] = "Bar Dimensions:",
    ["CONFIG_BAR_HEIGHT"] = "Bar Height",
    ["CONFIG_BAR_SPACING"] = "Bar Spacing",
    ["CONFIG_BAR_BG_OPACITY"] = "Bar Background Opacity",
    ["CONFIG_BAR_OPACITY"] = "Bar Fill Opacity",
    ["CONFIG_BAR_STYLE"] = "Bar Style:",
    ["CONFIG_BAR_TEXTURE"] = "Bar Texture",
    ["CONFIG_BAR_COLOR"] = "Bar Color:",

    -- Config UI - Text Settings
    ["CONFIG_FONT_SELECTION"] = "Font Selection:",
    ["CONFIG_FONT"] = "Font",
    ["CONFIG_FONT_SIZE"] = "Font Size",
    ["CONFIG_FONT_STYLE"] = "Font Style:",
    ["CONFIG_FONT_OUTLINE"] = "Outlined Font",
    ["CONFIG_FONT_SHADOW"] = "Font Shadow",
}

-- Simplified Chinese
Locales["zhCN"] = {
    ["STAT_FPS"] = "帧率",
    ["STAT_HOME"] = "本地",
    ["STAT_WORLD"] = "世界",
    ["UNIT_FPS"] = "帧",
    ["UNIT_MS"] = "毫秒",
    ["CMD_TOGGLE"] = "切换系统状态条显示",
    ["CMD_CONFIG"] = "打开配置面板",
    ["CMD_HELP"] = "显示可用命令",
    ["MSG_ADDON_LOADED"] = "PeaversSystemBars 已加载。输入 /psb 查看命令。",
    ["MSG_SHOWN"] = "PeaversSystemBars 已显示。",
    ["MSG_HIDDEN"] = "PeaversSystemBars 已隐藏。",
    ["CONFIG_DISPLAY_SETTINGS"] = "显示设置",
    ["CONFIG_BAR_APPEARANCE"] = "进度条外观",
    ["CONFIG_TEXT_SETTINGS"] = "文字设置",
    ["CONFIG_STAT_COLORS"] = "属性颜色",
    ["CONFIG_FRAME_DIMENSIONS"] = "框架尺寸：",
    ["CONFIG_FRAME_WIDTH"] = "框架宽度",
    ["CONFIG_BG_OPACITY"] = "背景透明度",
    ["CONFIG_VISIBILITY_OPTIONS"] = "可见性选项：",
    ["CONFIG_SHOW_TITLE_BAR"] = "显示标题栏",
    ["CONFIG_LOCK_POSITION"] = "锁定框架位置",
    ["CONFIG_BAR_DIMENSIONS"] = "进度条尺寸：",
    ["CONFIG_BAR_HEIGHT"] = "进度条高度",
    ["CONFIG_BAR_SPACING"] = "进度条间距",
    ["CONFIG_BAR_BG_OPACITY"] = "进度条背景透明度",
    ["CONFIG_BAR_OPACITY"] = "进度条填充透明度",
    ["CONFIG_BAR_STYLE"] = "进度条样式：",
    ["CONFIG_BAR_TEXTURE"] = "进度条材质",
    ["CONFIG_BAR_COLOR"] = "进度条颜色：",
    ["CONFIG_FONT_SELECTION"] = "字体选择：",
    ["CONFIG_FONT"] = "字体",
    ["CONFIG_FONT_SIZE"] = "字体大小",
    ["CONFIG_FONT_STYLE"] = "字体样式：",
    ["CONFIG_FONT_OUTLINE"] = "字体描边",
    ["CONFIG_FONT_SHADOW"] = "字体阴影",
}

-- Traditional Chinese
Locales["zhTW"] = {
    ["STAT_FPS"] = "畫格率",
    ["STAT_HOME"] = "本地",
    ["STAT_WORLD"] = "世界",
    ["UNIT_FPS"] = "fps",
    ["UNIT_MS"] = "毫秒",
    ["CMD_TOGGLE"] = "切換系統狀態條顯示",
    ["CMD_CONFIG"] = "開啟設定面板",
    ["CMD_HELP"] = "顯示可用指令",
    ["MSG_ADDON_LOADED"] = "PeaversSystemBars 已載入。輸入 /psb 查看指令。",
    ["MSG_SHOWN"] = "PeaversSystemBars 已顯示。",
    ["MSG_HIDDEN"] = "PeaversSystemBars 已隱藏。",
    ["CONFIG_DISPLAY_SETTINGS"] = "顯示設定",
    ["CONFIG_BAR_APPEARANCE"] = "進度條外觀",
    ["CONFIG_TEXT_SETTINGS"] = "文字設定",
    ["CONFIG_STAT_COLORS"] = "屬性顏色",
    ["CONFIG_FRAME_DIMENSIONS"] = "框架尺寸：",
    ["CONFIG_FRAME_WIDTH"] = "框架寬度",
    ["CONFIG_BG_OPACITY"] = "背景透明度",
    ["CONFIG_VISIBILITY_OPTIONS"] = "可見性選項：",
    ["CONFIG_SHOW_TITLE_BAR"] = "顯示標題列",
    ["CONFIG_LOCK_POSITION"] = "鎖定框架位置",
    ["CONFIG_BAR_DIMENSIONS"] = "進度條尺寸：",
    ["CONFIG_BAR_HEIGHT"] = "進度條高度",
    ["CONFIG_BAR_SPACING"] = "進度條間距",
    ["CONFIG_BAR_BG_OPACITY"] = "進度條背景透明度",
    ["CONFIG_BAR_OPACITY"] = "進度條填充透明度",
    ["CONFIG_BAR_STYLE"] = "進度條樣式：",
    ["CONFIG_BAR_TEXTURE"] = "進度條材質",
    ["CONFIG_BAR_COLOR"] = "進度條顏色：",
    ["CONFIG_FONT_SELECTION"] = "字型選擇：",
    ["CONFIG_FONT"] = "字型",
    ["CONFIG_FONT_SIZE"] = "字型大小",
    ["CONFIG_FONT_STYLE"] = "字型樣式：",
    ["CONFIG_FONT_OUTLINE"] = "字型描邊",
    ["CONFIG_FONT_SHADOW"] = "字型陰影",
}

-- Korean
Locales["koKR"] = {
    ["STAT_FPS"] = "FPS",
    ["STAT_HOME"] = "홈",
    ["STAT_WORLD"] = "월드",
    ["UNIT_FPS"] = "fps",
    ["UNIT_MS"] = "ms",
    ["CMD_TOGGLE"] = "시스템 바 표시 전환",
    ["CMD_CONFIG"] = "설정 패널 열기",
    ["CMD_HELP"] = "사용 가능한 명령어 표시",
    ["MSG_ADDON_LOADED"] = "PeaversSystemBars가 로드되었습니다. /psb를 입력하여 명령어를 확인하세요.",
    ["MSG_SHOWN"] = "PeaversSystemBars가 표시되었습니다.",
    ["MSG_HIDDEN"] = "PeaversSystemBars가 숨겨졌습니다.",
    ["CONFIG_DISPLAY_SETTINGS"] = "표시 설정",
    ["CONFIG_BAR_APPEARANCE"] = "바 외형",
    ["CONFIG_TEXT_SETTINGS"] = "텍스트 설정",
    ["CONFIG_STAT_COLORS"] = "능력치 색상",
    ["CONFIG_FRAME_DIMENSIONS"] = "프레임 크기:",
    ["CONFIG_FRAME_WIDTH"] = "프레임 너비",
    ["CONFIG_BG_OPACITY"] = "배경 투명도",
    ["CONFIG_VISIBILITY_OPTIONS"] = "표시 옵션:",
    ["CONFIG_SHOW_TITLE_BAR"] = "제목 표시줄 표시",
    ["CONFIG_LOCK_POSITION"] = "프레임 위치 잠금",
    ["CONFIG_BAR_DIMENSIONS"] = "바 크기:",
    ["CONFIG_BAR_HEIGHT"] = "바 높이",
    ["CONFIG_BAR_SPACING"] = "바 간격",
    ["CONFIG_BAR_BG_OPACITY"] = "바 배경 투명도",
    ["CONFIG_BAR_OPACITY"] = "바 채우기 투명도",
    ["CONFIG_BAR_STYLE"] = "바 스타일:",
    ["CONFIG_BAR_TEXTURE"] = "바 텍스처",
    ["CONFIG_BAR_COLOR"] = "바 색상:",
    ["CONFIG_FONT_SELECTION"] = "글꼴 선택:",
    ["CONFIG_FONT"] = "글꼴",
    ["CONFIG_FONT_SIZE"] = "글꼴 크기",
    ["CONFIG_FONT_STYLE"] = "글꼴 스타일:",
    ["CONFIG_FONT_OUTLINE"] = "글꼴 외곽선",
    ["CONFIG_FONT_SHADOW"] = "글꼴 그림자",
}

-- Set the active locale table
local activeLocale = Locales[locale] or Locales[defaultLocale]

-- First, copy all English strings as base
for key, value in pairs(Locales[defaultLocale]) do
    L[key] = value
end

-- Then override with active locale strings (if different from English)
if activeLocale ~= Locales[defaultLocale] then
    for key, value in pairs(activeLocale) do
        L[key] = value
    end
end

-- Function to get localized text with formatting
function PSB.L:Get(key, ...)
    local text = L[key]
    if ... then
        return string.format(text, ...)
    end
    return text
end
