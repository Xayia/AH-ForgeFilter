-- TitanForgeFilter - AH Tooltip Filter for 3.3.5a
-- NOTE: This addon is designed for custom 3.3.5a servers that have added item modifiers
-- like Titanforged, Warforged, etc. It will not find any items on a standard WotLK server.

local ADDON_NAME, ForgeFilter = ...
if type(ForgeFilter) ~= "table" then ForgeFilter = {} end
_G.ForgeFilter = ForgeFilter

-- Load libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ForgeFilter", true) or {}
local LSM = LibStub("LibSharedMedia-3.0")
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Default settings
local defaults = {
    profile = {
        display = {
            showTimeLeft = false,
            showBid = true,
            priceFormat = {
                hideSilver = true,
                hideCopper = true,
            },
        },
        hideTooltip = false, -- New option
        window = {
            width = 350,
            offsetX = 5,
            position = nil,
        },
        font = {
            face = "Friz Quadrata TT",
            size = 12,
            outline = "OUTLINE",
        },
        filters = {
            showTitanforged = true,
            showWarforged = true,
            showLightforged = true,
            showMythic = true,
        },
    }
}

-- Initialize the addon
local addon = AceAddon:NewAddon("ForgeFilter", "AceConsole-3.0", "AceEvent-3.0")
ForgeFilter = addon

function addon:OnInitialize()
    self.db = AceDB:New("ForgeFilterDB", defaults, "Default")
    self.settings = self.db.profile

    self:SetupOptions()
    self:RegisterChatCommand("forgefilter", "ToggleOptions")
    self:RegisterChatCommand("ff", "ToggleOptions")
end

function addon:ToggleOptions()
    AceConfigDialog:Open("ForgeFilter")
end

function addon:SetupOptions()
    local options = {
        name = "Forge Filter",
        handler = self,
        type = "group",
        args = {
            filters = {
                type = "group",
                name = "Filters",
                order = 1,
                args = {
                    showTitanforged = {
                        type = "toggle",
                        name = "Show Titanforged",
                        desc = "Toggle Titanforged items",
                        get = function(info) return self.settings.filters.showTitanforged end,
                        set = function(info, val) self.settings.filters.showTitanforged = val; self:RefreshUI() end,
                    },
                    showWarforged = {
                        type = "toggle",
                        name = "Show Warforged",
                        desc = "Toggle Warforged items",
                        get = function(info) return self.settings.filters.showWarforged end,
                        set = function(info, val) self.settings.filters.showWarforged = val; self:RefreshUI() end,
                    },
                    showLightforged = {
                        type = "toggle",
                        name = "Show Lightforged",
                        desc = "Toggle Lightforged items",
                        get = function(info) return self.settings.filters.showLightforged end,
                        set = function(info, val) self.settings.filters.showLightforged = val; self:RefreshUI() end,
                    },
                    showMythic = {
                        type = "toggle",
                        name = "Show Mythic",
                        desc = "Toggle Mythic items",
                        get = function(info) return self.settings.filters.showMythic end,
                        set = function(info, val) self.settings.filters.showMythic = val; self:RefreshUI() end,
                    },
                },
            },
            display = {
                type = "group",
                name = "Display",
                order = 2,
                args = {
                    priceFormat = {
                        type = "group",
                        name = "Price Formatting",
                        inline = true,
                        args = {
                            showBid = {
                                type = "toggle",
                                name = "Show Bid Prices",
                                desc = "Toggle display of bid prices",
                                get = function(info) return self.settings.display.showBid end,
                                set = function(info, val) self.settings.display.showBid = val; self:RefreshUI() end,
                            },
                            
                            hideSilver = {
                                type = "toggle",
                                name = "Hide Silver",
                                desc = "Hide silver values in prices",
                                get = function(info) return self.settings.display.priceFormat.hideSilver end,
                                set = function(info, val) self.settings.display.priceFormat.hideSilver = val; self:RefreshUI() end,
                            },
                            hideCopper = {
                                type = "toggle",
                                name = "Hide Copper",
                                desc = "Hide copper values in prices",
                                get = function(info) return self.settings.display.priceFormat.hideCopper end,
                                set = function(info, val) self.settings.display.priceFormat.hideCopper = val; self:RefreshUI() end,
                            },
                            
                        },
                    },
                },
            },
            misc = { -- New Misc group
                type = "group",
                name = "Misc",
                order = 2.5,
                args = {
                    showTimeLeft = {
                        type = "toggle",
                        name = "Show Time Remaining",
                        desc = "Show how much time is left on the auction",
                        get = function(info) return self.settings.display.showTimeLeft end,
                        set = function(info, val) self.settings.display.showTimeLeft = val; self:RefreshUI() end,
                    },
                    hideTooltip = {
                        type = "toggle",
                        name = "Hide Tooltip",
                        desc = "Hide item tooltips on mouseover for filtered items",
                        get = function(info) return self.settings.display.hideTooltip end,
                        set = function(info, val) self.settings.display.hideTooltip = val; self:RefreshUI() end,
                    },
                },
            },
            window = {
                type = "group",
                name = "Window",
                order = 3,
                args = {
                    width = {
                        type = "range",
                        name = "Window Width",
                        min = 250,
                        max = 800,
                        step = 10,
                        get = function(info) return self.settings.window.width end,
                        set = function(info, val) self.settings.window.width = val; self:UpdateFramePosition() end,
                    },
                    offsetX = {
                        type = "range",
                        name = "Horizontal Offset",
                        min = -50,
                        max = 150,
                        step = 1,
                        get = function(info) return self.settings.window.offsetX end,
                        set = function(info, val) self.settings.window.offsetX = val; self:UpdateFramePosition() end,
                    },
                },
            },
            font = {
                type = "group",
                name = "Font",
                order = 4,
                args = {
                    face = {
                        type = "select",
                        name = "Font Face",
                        dialogControl = "LSM30_Font",
                        values = AceGUIWidgetLSMlists.font,
                        get = function(info) return self.settings.font.face end,
                        set = function(info, val) self.settings.font.face = val; ForgeFilter_UpdateResultButtons() end,
                    },
                    size = {
                        type = "range",
                        name = "Font Size",
                        min = 8,
                        max = 32,
                        step = 1,
                        get = function(info) return self.settings.font.size end,
                        set = function(info, val) self.settings.font.size = val; ForgeFilter_UpdateResultButtons() end,
                    },
                    outline = {
                        type = "select",
                        name = "Font Outline",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                            ["MONOCHROME"] = "Monochrome",
                        },
                        get = function(info) return self.settings.font.outline end,
                        set = function(info, val) self.settings.font.outline = val; ForgeFilter_UpdateResultButtons() end,
                    },
                },
            },
        },
    }
    AceConfig:RegisterOptionsTable("ForgeFilter", options)
    AceConfigDialog:AddToBlizOptions("ForgeFilter", "Forge Filter")
end

function addon:RefreshUI()
    if ForgeFilter_UpdateFilter then
        ForgeFilter_UpdateFilter()
    end
end

function addon:UpdateFramePosition()
    if ForgeFilter.filterFrame then
        local ahFrame = _G["AuctionFrame"]
        if ahFrame and ahFrame:IsVisible() then
            local ahRight = ahFrame:GetRight()
            local screenWidth = GetScreenWidth()
            local maxWidth = screenWidth - ahRight - 20
            ForgeFilter.filterFrame:SetWidth(math.min(self.settings.window.width, maxWidth))
            ForgeFilter.filterFrame:ClearAllPoints()
            ForgeFilter.filterFrame:SetPoint("TOPLEFT", ahFrame, "TOPRIGHT", self.settings.window.offsetX, 0)
        end
    end
end

-- Fallback for wipe in older clients (should be available in 3.3.5a)
local wipe = wipe or function(tbl) for k in pairs(tbl) do tbl[k] = nil end end

-- Storage
ForgeFilter.filtered = {}          -- Records: {index, name, icon, count, quality, level, buyout, bid, owner, timeLeft, link}
ForgeFilter.ROW_HEIGHT = 20
ForgeFilter.VISIBLE_ROWS = 17  -- Increased from 15 to show 2 more items
ForgeFilter.NUM_ROWS = 16   -- Increased from 14 to match VISIBLE_ROWS - 1
ForgeFilter.tabId = nil
ForgeFilter._tabsHooked = false
ForgeFilter.filterFrame = nil

-- Hidden tooltip for scanning
local scanner = CreateFrame("GameTooltip", "ForgeFilter_ScannerTooltip", UIParent, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local function scanTooltipHasAny(link, needles)
  if not link then return false end
  scanner:ClearLines()
  scanner:SetHyperlink(link)
  local num = scanner:NumLines() or 0
  if num == 0 then return false end

  -- Prepare search terms in lowercase
  local search = {}
  for _, s in ipairs(needles or {}) do
    if s and s ~= "" then
      table.insert(search, string.lower(s))
    end
  end
  if #search == 0 then
    return true, nil -- no filters -> allow everything
  end

  -- Skip first line (item name) to avoid false positives in name
  for i = 2, num do
    local fs = _G["ForgeFilter_ScannerTooltipTextLeft"..i]
    if fs then
      local txt = fs:GetText()
      if txt and txt ~= "" then
        local low = string.lower(txt)
        for _, needle in ipairs(search) do
          -- exact word boundary match (Lua 5.1 frontier patterns)
          local pattern = "%f[%a]" .. needle .. "%f[^%a]"
          if string.find(low, pattern) then
            -- map exact forge term to code
            local code = nil
            if needle == "titanforged" then code = "TF"
            elseif needle == "warforged" then code = "WF"
            elseif needle == "lightforged" then code = "LF"
            elseif needle == "mythic" then code = "M" end
            return true, code
          end
        end
      end
    end
  end
  return false, nil
end

-- Return a set of all forge/mythic codes present in the tooltip (skips name line)
local function scanTooltipGetCodes(link)
  local found = {}
  if not link then return found end
  scanner:ClearLines()
  scanner:SetHyperlink(link)
  local num = scanner:NumLines() or 0
  if num == 0 then return found end
  for i = 2, num do
    local fs = _G["ForgeFilter_ScannerTooltipTextLeft"..i]
    if fs then
      local txt = fs:GetText()
      if txt and txt ~= "" then
        local low = string.lower(txt)
        local function has(word)
          local pattern = "%f[%a]" .. word .. "%f[^%a]"
          return string.find(low, pattern) ~= nil
        end
        if has("mythic") then found.M = true end
        if has("titanforged") then found.TF = true end
        if has("warforged") then found.WF = true end
        if has("lightforged") then found.LF = true end
      end
    end
  end
  return found
end

local function moneyToString(copper, isBid)
  copper = copper or 0
  if copper <= 0 then return "" end
  
  local g = math.floor(copper / 10000)
  copper = copper % 10000
  local s = math.floor(copper / 100)
  local c = copper % 100
  
  local str = ""
  
  -- Always show gold if there is any, or if all values are zero
  if g > 0 or (g == 0 and s == 0 and c == 0) then 
    str = str .. g .. "|cffffd700g|r"
  end
  
  -- Apply silver/copper hiding to both bid and buyout prices
  if s > 0 and not (addon.settings.display.priceFormat.hideSilver) then
    if str ~= "" then str = str .. " " end
    str = str .. "|cffffff00" .. s .. "|r" .. "|cffc7c7cfs|r"
  end
  
  if c > 0 and not (addon.settings.display.priceFormat.hideCopper) then
    -- Only show copper if it's not the only non-zero value and we're not hiding it
    if str ~= "" or not addon.settings.display.priceFormat.hideSilver then
      if str ~= "" then str = str .. " " end
      str = str .. "|cffffff00" .. c .. "|r" .. "|cffeda55fc|r"
    end
  end
  
  -- If we have no string yet (all values hidden or zero), show at least 0g
  if str == "" then
    return "0|cffffd700g|r"
  end
  
  return str
end

local function timeLeftToText(t)
  -- 1: Short, 2: Medium, 3: Long, 4: Very Long
  if t == 1 then return "Short"
  elseif t == 2 then return "Medium"
  elseif t == 3 then return "Long"
  elseif t == 4 then return "Very Long"
  else return "-" end
end

local function ForgeFilter_CreateFilterFrame()
  if ForgeFilter.filterFrame then return end
  
  -- Get Auction House frame
  local auctionFrame = _G["AuctionFrame"]
  if not auctionFrame then
    ForgeFilter.filterFrame = CreateFrame("Frame", "ForgeFilter_FilterFrame", UIParent)
    ForgeFilter.filterFrame:SetSize(480, 480)
    ForgeFilter.filterFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    return
  end
  
  -- Create frame relative to Auction House
  ForgeFilter.filterFrame = CreateFrame("Frame", "ForgeFilter_FilterFrame", auctionFrame)
  
  -- Initial frame setup
  ForgeFilter.filterFrame:SetSize(350, 400)  -- Default size
  ForgeFilter.filterFrame:SetMovable(false)
  
  -- Create background frame with solid color (WotLK compatible)
  local bg = ForgeFilter.filterFrame:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(0.05, 0.05, 0.05, 0.8)  -- Darker background with full opacity
  bg:SetAllPoints(ForgeFilter.filterFrame)
  
  -- Create border frame (WotLK compatible)
  local border = CreateFrame("Frame", nil, ForgeFilter.filterFrame)
  border:SetPoint("TOPLEFT", ForgeFilter.filterFrame, "TOPLEFT", -1, 0)  -- Reduced top by 1px
  border:SetPoint("BOTTOMRIGHT", ForgeFilter.filterFrame, "BOTTOMRIGHT", 1, 0)  -- Reduced bottom by 1px
  border:SetBackdrop({
    bgFile = "Interface\Tooltips\UI-Tooltip-Background",
    edgeFile = "Interface\Buttons\WHITE8X8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })
  border:SetBackdropColor(0, 0, 0, 0)
  border:SetBackdropBorderColor(0, 0, 0, 1)
  
  ForgeFilter.filterFrame:SetFrameStrata("DIALOG")
  
  -- Create a title bar (ElvUI style)
  local titleBar = ForgeFilter.filterFrame:CreateTexture(nil, "ARTWORK")
  titleBar:SetTexture(0.08, 0.08, 0.08, 0.7)
  titleBar:SetPoint("TOPLEFT", ForgeFilter.filterFrame, "TOPLEFT", -1, 0)  -- Aligned with border
  titleBar:SetPoint("TOPRIGHT", ForgeFilter.filterFrame, "TOPRIGHT", 1, 1)
  titleBar:SetHeight(35) 
  
  -- Add a thin border at the bottom of the title
  local titleBottomBorder = ForgeFilter.filterFrame:CreateTexture(nil, "ARTWORK")
  titleBottomBorder:SetTexture(0, 0, 0, 1)
  titleBottomBorder:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 0, 0)
  titleBottomBorder:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
  titleBottomBorder:SetHeight(1)
  
  -- Position and size relative to AH frame
  function addon:UpdateFramePosition()
    if not auctionFrame:IsVisible() then return end
    
    -- Get AH frame dimensions
    local ahTop = auctionFrame:GetTop() or 0
    local ahBottom = auctionFrame:GetBottom() or 0
    local ahRight = auctionFrame:GetRight() or 0
    
    -- Position the frame to the right of the AH, with custom height
    ForgeFilter.filterFrame:ClearAllPoints()
    if addon.settings.window.position and addon.settings.window.position.relativeTo then
        local pos = addon.settings.window.position
        local relativeFrame = _G[pos.relativeTo] or UIParent
        ForgeFilter.filterFrame:SetPoint(pos.point, relativeFrame, pos.relativePoint, pos.x, pos.y)
    else
        -- Default position
        ForgeFilter.filterFrame:SetPoint("TOPLEFT", auctionFrame, "TOPRIGHT", addon.settings.window.offsetX or 5, 0)
    end
    ForgeFilter.filterFrame:SetHeight(424)
    
    -- Ensure window stays within screen bounds
    local screenWidth = GetScreenWidth()
    local maxWidth = screenWidth - ahRight - 20  -- Leave some margin from screen edge
    ForgeFilter.filterFrame:SetWidth(math.min(addon.settings.window.width or 450, maxWidth))
  end
  
  -- Initial positioning
  addon:UpdateFramePosition()
  
  -- Update when AH is shown or moved
  auctionFrame:HookScript("OnShow", function()
    ForgeFilter.filterFrame:Show()
    addon:UpdateFramePosition()
  end)
  
  auctionFrame:HookScript("OnHide", function()
    ForgeFilter.filterFrame:Hide()
  end)
  
  -- Create a frame to monitor AH position changes
  local positionWatcher = CreateFrame("Frame")
  positionWatcher:SetScript("OnUpdate", function()
    if auctionFrame:IsVisible() then
      addon:UpdateFramePosition()
    end
  end)
  

  -- Static popup for confirming buyout
  if not StaticPopupDialogs["ForgeFilter_CONFIRM_BUYOUT"] then
    StaticPopupDialogs["ForgeFilter_CONFIRM_BUYOUT"] = {
      text = "Buyout %s for %s?",
      button1 = ACCEPT,
      button2 = CANCEL,
      OnAccept = function(self, data)
        if data and data.index and data.buyout and data.buyout > 0 then
          -- Ensure the right item is targeted and place the buyout bid
          PlaceAuctionBid("list", data.index, data.buyout)
        end
      end,
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
      preferredIndex = 3,
    }
  end
  
  -- Create a title region (mimics BasicFrameTemplate)
  ForgeFilter.filterFrame:EnableMouse(true)
  ForgeFilter.filterFrame:SetMovable(true)
  ForgeFilter.filterFrame:RegisterForDrag("LeftButton")
  ForgeFilter.filterFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  ForgeFilter.filterFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, x, y = self:GetPoint()
    if relativeTo then
        addon.settings.window.position = {
            point = point,
            relativeTo = relativeTo:GetName(),
            relativePoint = relativePoint,
            x = x,
            y = y
        }
    end
  end)
  
  -- Title text with larger font and colored parts (positioned lower and to the left)
  local title = ForgeFilter.filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 10, -10)
  title:SetFormattedText("|cFFFFFFFFForge Filter by |cFFFF0000Xayia")
  
  -- Clear any checkbox references
  ForgeFilter.Check_Titan = nil
  ForgeFilter.Check_War = nil
  ForgeFilter.Check_Light = nil
  ForgeFilter.Check_Myth = nil
  
  -- Results area
  if ForgeFilter.resultsArea then ForgeFilter.resultsArea:Hide() end
  ForgeFilter.resultsArea = CreateFrame("Frame", nil, ForgeFilter.filterFrame)
  -- Position below the title
  ForgeFilter.resultsArea:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
  ForgeFilter.resultsArea:SetPoint("BOTTOMRIGHT", ForgeFilter.filterFrame, "BOTTOMRIGHT", -15, 10)
  
  -- Faux scroll frame (only for scrollbar/offset; buttons are siblings)
  ForgeFilter.resultScrollFrame = CreateFrame("ScrollFrame", "ForgeFilter_ResultScrollFrame", ForgeFilter.resultsArea, "FauxScrollFrameTemplate")
  ForgeFilter.resultScrollFrame:SetAllPoints()
  ForgeFilter.resultScrollFrame:EnableMouseWheel(true)
  -- Hide the visual scrollbar
  local sb = _G["ForgeFilter_ResultScrollFrameScrollBar"]
  if sb then
    sb:Hide(); sb:EnableMouse(false)
    local up = _G["ForgeFilter_ResultScrollFrameScrollBarScrollUpButton"]
    local down = _G["ForgeFilter_ResultScrollFrameScrollBarScrollDownButton"]
    local thumb = sb.GetThumbTexture and sb:GetThumbTexture() or nil
    if up then up:Hide(); up:EnableMouse(false) end
    if down then down:Hide(); down:EnableMouse(false) end
    if thumb then thumb:Hide() end
  end
  
  -- Create result buttons (fixed visible rows)
  ForgeFilter.resultButtons = {}
  for i = 1, ForgeFilter.VISIBLE_ROWS do
    local btn = CreateFrame("Button", "ForgeFilter_ResultButton"..i, ForgeFilter.resultsArea)
    btn:SetHeight(ForgeFilter.ROW_HEIGHT)
    btn:SetPoint("LEFT", 0, 0)
    btn:SetPoint("RIGHT", 0, 0)
    if i == 1 then
      btn:SetPoint("TOPLEFT", ForgeFilter.resultsArea, "TOPLEFT", 0, 0)
    else
      btn:SetPoint("TOPLEFT", ForgeFilter.resultButtons[i-1], "BOTTOMLEFT", 0, -2)
    end
    btn:SetHighlightTexture("Interface\QuestFrame\UI-QuestTitleHighlight", "ADD")
    btn.text = btn:CreateFontString(nil, "OVERLAY") -- Font will be set in update function
    btn.text:SetFont(LSM:Fetch("font", addon.settings.font.face), addon.settings.font.size, addon.settings.font.outline)
    btn.text:SetPoint("LEFT", btn, "LEFT", 0, 0)  -- Changed from -10 to 10 for better left padding
    btn.text:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
    btn.text:SetJustifyH("LEFT")
    btn:RegisterForClicks("AnyUp")
    ForgeFilter.resultButtons[i] = btn
  end
  
  -- Scroll handling
  ForgeFilter.resultScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, ForgeFilter.ROW_HEIGHT + 2, ForgeFilter_UpdateResultButtons)
  end)
  ForgeFilter.resultScrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local offset = FauxScrollFrame_GetOffset(self) or 0
    offset = offset - delta
    if offset < 0 then offset = 0 end
    local maxOffset = math.max(0, (#ForgeFilter.filtered - ForgeFilter.VISIBLE_ROWS))
    if offset > maxOffset then offset = maxOffset end
    FauxScrollFrame_SetOffset(self, offset)
    ForgeFilter_UpdateResultButtons()
  end)
  ForgeFilter.resultsArea:EnableMouseWheel(true)
  ForgeFilter.resultsArea:SetScript("OnMouseWheel", function(_, delta)
    local offset = FauxScrollFrame_GetOffset(ForgeFilter.resultScrollFrame) or 0
    offset = offset - delta
    if offset < 0 then offset = 0 end
    local maxOffset = math.max(0, (#ForgeFilter.filtered - ForgeFilter.VISIBLE_ROWS))
    if offset > maxOffset then offset = maxOffset end
    FauxScrollFrame_SetOffset(ForgeFilter.resultScrollFrame, offset)
    ForgeFilter_UpdateResultButtons()
  end)
  
  -- Simple close button using default UI textures
  local closeButton = CreateFrame("Button", nil, ForgeFilter.filterFrame, "UIPanelCloseButton")
  closeButton:SetSize(24, 24)
  closeButton:SetPoint("TOPRIGHT", ForgeFilter.filterFrame, "TOPRIGHT", -6, -6)
  closeButton:SetScript("OnClick", function() ForgeFilter.filterFrame:Hide() end)
  
  -- Style the close button
  closeButton:GetNormalTexture():SetDesaturated(true)
  closeButton:GetPushedTexture():SetDesaturated(true)
  closeButton:GetHighlightTexture():SetDesaturated(true)
  closeButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.9)
  closeButton:SetHighlightTexture("Interface\Buttons\UI-Common-MouseHilight", "ADD")

  -- Options button
  local optionsButton = CreateFrame("Button", nil, ForgeFilter.filterFrame)
  optionsButton:SetSize(60, 15) -- Made wider and shorter to fit text
  optionsButton:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)
  optionsButton:SetScript("OnClick", function()
    addon:ToggleOptions()
  end)
  
  -- Set the text to 'Options'
  local optionsButtonText = optionsButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  optionsButtonText:SetText("Options") -- Changed text to 'Options'
  optionsButtonText:SetPoint("CENTER")
  optionsButtonText:SetVertexColor(0.8, 0.8, 0.8, 0.9)

  -- Add mouseover highlight for text
  optionsButton:SetScript("OnEnter", function(self)
    optionsButtonText:SetVertexColor(1, 1, 0, 1) -- Yellow highlight
  end)
  optionsButton:SetScript("OnLeave", function(self)
    optionsButtonText:SetVertexColor(0.8, 0.8, 0.8, 0.9) -- Original color
  end)

  -- Style the options button to match the close button
  -- optionsButton:GetNormalTexture():SetDesaturated(true)
  -- optionsButton:GetPushedTexture():SetDesaturated(true)
  -- optionsButton:GetHighlightTexture():SetDesaturated(true)
  -- optionsButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.9)
  optionsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  
  -- Disable frame resizing
  ForgeFilter.filterFrame:SetResizable(false)
  
  -- Dropdown host for right-click context menu
  if not ForgeFilter.dropdown then
    ForgeFilter.dropdown = CreateFrame("Frame", "ForgeFilter_Dropdown", UIParent, "UIDropDownMenuTemplate")
  end
end

local function ForgeFilter_ShowFilterFrame(show)
  if not ForgeFilter.filterFrame then
    ForgeFilter_CreateFilterFrame()
  end
  
  if show then
    if not AuctionFrame or not AuctionFrame:IsVisible() then
      print("Auction house is not open")
      return
    end
    
    -- Position the frame relative to the auction house
    ForgeFilter.filterFrame:ClearAllPoints()
    ForgeFilter.filterFrame:SetPoint("LEFT", AuctionFrame, "RIGHT", addon.settings.window.offsetX or 5, 0)
    ForgeFilter.filterFrame:Show()
    
    -- Update the list
    ForgeFilter_RebuildFromBrowse()
  else
    ForgeFilter.filterFrame:Hide()
  end
end

local function ForgeFilter_EnsureBlizzardAuction()
  if not IsAddOnLoaded or not LoadAddOn then return end
  if not IsAddOnLoaded("Blizzard_AuctionUI") then
    -- Load the Blizzard auction house interface so AuctionFrameTab_OnClick exists
    pcall(LoadAddOn, "Blizzard_AuctionUI")
  end
end

-- Update list UI
local function ForgeFilter_ShowRowMenu(item)
  if not item or not item.index then return end
  local function infoFor(index)
    local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", index)
    return {
      minBid = minBid or 0,
      minInc = minIncrement or 0,
      buyout = buyoutPrice or 0,
      bid = bidAmount or 0,
      name = name,
    }
  end
  local ai = infoFor(item.index)
  local menu = {
    { text = item.name or "Item", isTitle = true, notCheckable = true },
    { text = "Buyout", notCheckable = true, disabled = (ai.buyout or 0) <= 0, func = function()
        if (ai.buyout or 0) > 0 then
          StaticPopup_Show("ForgeFilter_CONFIRM_BUYOUT", item.name or "?", moneyToString(ai.buyout, false), { index = item.index, buyout = ai.buyout })
        end
      end },
    { text = "Bid", notCheckable = true, func = function()
        local amount = 0
        if (ai.bid or 0) > 0 and (ai.minInc or 0) > 0 then
          amount = ai.bid + ai.minInc
        else
          amount = ai.minBid
        end
        if amount and amount > 0 then
          PlaceAuctionBid("list", item.index, amount)
        else
          UIErrorsFrame:AddMessage("Cannot determine minimum bid", 1, 0.1, 0.1, 1)
        end
      end },
    { text = "Link to chat", notCheckable = true, func = function()
        if item.link then ChatEdit_InsertLink(item.link) end
      end },
    { text = "", notCheckable = true, disabled = true }, -- Separator
    { text = "Search for Item", notCheckable = true, func = function()
        if item.name and _G["BrowseName"] and _G["BrowseSearchButton"] then
            _G["BrowseName"]:SetText(item.name)
            _G["BrowseSearchButton"]:Click()
        end
      end },
    { text = "|cffff5555Report as Invalid|r", notCheckable = true, func = function()
        -- This is a placeholder. In a real scenario, this might send data to a server
        -- or save it locally for the addon author.
        print(string.format("ForgeFilter: Reported '%s' as invalid. (feature placeholder)", item.name or "Unknown Item"))
      end },
    { text = CANCEL, notCheckable = true },
  }
  if EasyMenu then
    EasyMenu(menu, ForgeFilter.dropdown, "cursor", 0, 0, "MENU", 2)
  end
end

ForgeFilter_UpdateResultButtons = function()
  if not ForgeFilter.resultButtons then return end
  
  local total = #ForgeFilter.filtered
  local offset = FauxScrollFrame_GetOffset(ForgeFilter.resultScrollFrame) or 0
  local buttons = ForgeFilter.resultButtons
  -- update scroll metrics
  FauxScrollFrame_Update(ForgeFilter.resultScrollFrame, total, ForgeFilter.VISIBLE_ROWS, ForgeFilter.ROW_HEIGHT + 2)
  
  for i = 1, #buttons do
    local button = buttons[i]
    local index = offset + i
    if index <= total then
      local item = ForgeFilter.filtered[index]
      if item then
        local color = ITEM_QUALITY_COLORS[item.quality or 0] or ITEM_QUALITY_COLORS[0]
        local countPrefix = (item.count or 0) > 1 and ("[%dx] "):format(item.count) or ""

        -- Apply font settings
        local fontFace = LSM:Fetch("font", addon.settings.font.face or "Friz Quadrata TT")
        local fontSize = addon.settings.font.size or 12
        local fontOutline = addon.settings.font.outline or "OUTLINE"
        button.text:SetFont(fontFace, fontSize, fontOutline)

        -- Build colored bracketed tags from detected codes (order: M, TF, WF, LF)
        local tags = {}
        local c = item.codes or {}
        if c.M then table.insert(tags, "|cffff99cc[M]|r") end -- light pink
        if c.TF then table.insert(tags, "|cff3399FF[TF]|r") end -- blue
        if c.WF then table.insert(tags, "|cffff3333[WF]|r") end -- red
        if c.LF then table.insert(tags, "|cffffe066[LF]|r") end -- yellow
        local tagPrefix = table.concat(tags, "")
        if tagPrefix ~= "" then tagPrefix = tagPrefix .. " " end
        local buyText = string.format("|cffffff00%s|r", moneyToString(item.buyout or 0, false))
        
        local label
        local timeText = addon.settings.display.showTimeLeft and string.format("|cFF888888(%s)|r", timeLeftToText(item.timeLeft or 0)) or ""
        
        if addon.settings.display.showBid then
          local bidAmount = (item.bid and item.bid > 0) and item.bid or (item.minBid or 0)
          label = string.format("%s%s%s - %s %s |cffffff00Bid: %s|r", 
            tagPrefix,
            countPrefix, 
            item.name, 
            buyText,
            timeText,
            moneyToString(bidAmount, true)
          )
        else
          label = string.format("%s%s%s - %s %s", 
            tagPrefix,
            countPrefix, 
            item.name, 
            buyText,
            timeText
          )
        end
        
        button.text:SetText(label)
        button.text:SetTextColor(color.r, color.g, color.b)
        button:Show()
        
        -- Create background highlight texture
        if not button.highlightBg then -- Added 'if' here
            button.highlightBg = button:CreateTexture(nil, "BACKGROUND")
            button.highlightBg:SetAllPoints(button)
            button.highlightBg:SetTexture("Interface\Buttons\WHITE8X8") -- Use a white texture
            button.highlightBg:SetVertexColor(0.5, 0.5, 0.5, 0.2) -- Gray with 20% opacity
            button.highlightBg:Hide()
        end -- Added 'end' here

        -- Clicks: Left -> confirm buyout; Right -> context menu; Shift always links
        button:SetScript("OnClick", function(self, btn)
          if IsShiftKeyDown() and item.link then
            ChatEdit_InsertLink(item.link)
            return
          end
          if btn == "RightButton" then
            ForgeFilter_ShowRowMenu(item)
            return
          end
          -- Left click: confirm buyout
          local buyout = tonumber(item.buyout or 0) or 0
          if buyout > 0 then
            StaticPopup_Show("ForgeFilter_CONFIRM_BUYOUT", item.name or "?", moneyToString(buyout, false), { index = item.index, buyout = buyout })
          else
            UIErrorsFrame:AddMessage("No buyout available", 1, 0.1, 0.1, 1)
          end
        end)
        
        -- Tooltip and background highlight on hover
        button:SetScript("OnEnter", function(self)
          self.text:SetTextColor(1, 1, 0) -- Yellow highlight
          if self.highlightBg then
              self.highlightBg:Show()
          end
          if not addon.settings.display.hideTooltip then
            if item.link then
              GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
              GameTooltip:SetHyperlink(item.link)
              GameTooltip:Show()
            end
          end
        end)
        button:SetScript("OnLeave", function(self)
          self.text:SetTextColor(color.r, color.g, color.b) -- Revert to original color
          if self.highlightBg then
              self.highlightBg:Hide()
          end
          if not addon.settings.display.hideTooltip then
            GameTooltip:Hide()
          end
        end)
        button:Show()
      end
    else
      button:Hide()
    end
  end
end

function ForgeFilter_RefreshList()
  -- Update our custom filter frame with filtered results
  if not ForgeFilter.resultScrollFrame or not ForgeFilter.resultButtons then 
    print("Error: UI elements not properly initialized")
    return 
  end
  
  -- Update the scroll frame and buttons
  ForgeFilter_UpdateResultButtons()
end

-- Rebuild filter list
function ForgeFilter_RebuildFromBrowse()
  -- Only run if our filter frame is visible
  if not ForgeFilter.filterFrame or not ForgeFilter.filterFrame:IsVisible() then
    return
  end
  
  wipe(ForgeFilter.filtered)
  
  local total = GetNumAuctionItems("list") or 0
  
  if total <= 0 then
    ForgeFilter_RefreshList()
    return
  end

  -- Build needles from settings
  local needles = {}
  if addon.settings.filters.showTitanforged then table.insert(needles, "titanforged") end
  if addon.settings.filters.showWarforged   then table.insert(needles, "warforged") end
  if addon.settings.filters.showLightforged then table.insert(needles, "lightforged") end
  if addon.settings.filters.showMythic      then table.insert(needles, "mythic") end

  -- Add custom keywords from search box (comma / semicolon separated)
  if ForgeFilter.SearchBox then
    local text = ForgeFilter.SearchBox:GetText() or ""
    -- Use gmatch to split by comma, semicolon, or space
    for token in string.gmatch(text, "[^,;%s]+") do
      token = string.lower(string.trim and string.trim(token) or token:match("^%s*(.-)%s*$"))
      if token ~= "" then table.insert(needles, token) end
    end
  end
  
  -- If no filters are selected, show nothing (to avoid showing the entire AH)
  if #needles == 0 then
    ForgeFilter_RefreshList() -- This will show an empty list
    return
  end
  
  -- Filter items based on selected needles
  for i = 1, total do
    local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus, itemId = GetAuctionItemInfo("list", i)
    local link = GetAuctionItemLink("list", i)
    local timeLeft = GetAuctionItemTimeLeft and GetAuctionItemTimeLeft("list", i) or 0

    if name and link then
      local ok = scanTooltipHasAny(link, needles)
      if ok then
        local codes = scanTooltipGetCodes(link)
        table.insert(ForgeFilter.filtered, {
          index = i,
          name = name,
          icon = texture,
          count = count,
          quality = quality or 0,
          level = level or 0,
          buyout = buyoutPrice or 0,
          bid = bidAmount or 0,
          minBid = minBid or 0,
          minInc = minIncrement or 0,
          owner = owner,
          timeLeft = timeLeft or 0,
          link = link,
          codes = codes,
        })
      end
    end
  end
  
  -- Reset scroll to top on rebuild and refresh
  if ForgeFilter.resultScrollFrame then
    FauxScrollFrame_SetOffset(ForgeFilter.resultScrollFrame, 0)
  end
  ForgeFilter_RefreshList()
end

function ForgeFilter_UpdateFilter()
  ForgeFilter_RebuildFromBrowse()
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("AUCTION_HOUSE_SHOW")
f:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
f:RegisterEvent("AUCTION_HOUSE_CLOSED")

f:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "ForgeFilter" then
    -- Initialize settings when the addon loads
    -- addon:OnInitialize() -- This is now handled by AceAddon-3.0
    print("ForgeFilter settings loaded")
  elseif event == "AUCTION_HOUSE_SHOW" then
    -- Ensure Blizzard auction UI is loaded
    ForgeFilter_EnsureBlizzardAuction()
    -- Show our filter frame
    ForgeFilter_ShowFilterFrame(true)
  elseif event == "AUCTION_ITEM_LIST_UPDATE" then
    -- New search results -> if our filter frame is open, rescan
    if ForgeFilter.filterFrame and ForgeFilter.filterFrame:IsVisible() then
      ForgeFilter_RebuildFromBrowse()
    end
  elseif event == "AUCTION_HOUSE_CLOSED" then
    ForgeFilter_ShowFilterFrame(false)
  end
end)