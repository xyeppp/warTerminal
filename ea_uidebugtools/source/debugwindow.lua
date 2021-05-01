
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

DebugWindow = {}
DebugWindow.history = {}
DebugWindow.spyfilter = SystemData.Events
DebugWindow.registeredevents = {}
DebugWindow.RegisteredFunctionList = {}
DebugWindow.Settings =
{
    logsOn = true,
    useDevErrorHandling = true,
    loadLuaDebugLibrary = false
}

DebugWindow.Settings.LogFilters = {}
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.SYSTEM ]   = { enabled=true,   color=DefaultColor.MAGENTA }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.WARNING ]  = { enabled=true,   color=DefaultColor.ORANGE }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.ERROR ]    = { enabled=true,   color=DefaultColor.RED }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.DEBUG ]    = { enabled=true,   color=DefaultColor.YELLOW }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.LOADING ]  = { enabled=false,  color=DefaultColor.LIGHT_GRAY }
DebugWindow.Settings.LogFilters[ SystemData.UiLogFilters.FUNCTION ] = { enabled=false,  color=DefaultColor.GREEN }
DebugWindow.Settings.LogFilters[9] = { enabled=true,  color=DefaultColor.MAGENTA }
DebugWindow.Settings.LogFilters[10] = { enabled=true,  color=DefaultColor.LIGHT_BLUE }
DebugWindow.Settings.LogFilters[11] = { enabled=true,  color=DefaultColor.GOLD }

DebugWindow.currentMouseoverWindow = nil


-- For Internal Builds, Default the Settings to the current log states in the pregame
-- if the log is currently enabled.
if( IsInternalBuild() and (InterfaceCore.inGame == false) and TextLogGetEnabled( "UiLog" ) )
then
    DebugWindow.Settings.logsOn = true
    DebugWindow.Settings.useDevErrorHandling = GetUseLuaErrorHandling()
    DebugWindow.Settings.loadLuaDebugLibrary = GetLoadLuaDebugLibrary()

    -- Filters
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
       filterData.enabled = TextLogGetFilterEnabled( "UiLog", filterType)
    end

end

local function HandlePregameInit()

    if( IsInternalBuild() and (InterfaceCore.inGame == false) )
    then

        -- If the Logs are enabled in the pregame, show the window
        if( DebugWindow.Settings.logsOn )
        then
            WindowSetShowing( "DebugWindow", true )
        end
    end
end

----------------------------------------------------------------
-- DebugWindow Functions
----------------------------------------------------------------

local function UpdateLoggingButton ()

    if ( DebugWindow.Settings.logsOn == true) then
        ButtonSetText("DebugWindowToggleLogging", L"Logs (On)")
    else
        ButtonSetText("DebugWindowToggleLogging", L"Logs (Off)")
    end

end

-- OnInitialize Handler
function DebugWindow.Initialize()
  --DebugWindow.RegisterHandleSpy()




    -- Setup the Log
    DebugWindow.UpdateLog()





    -- Init the Settings
    for filterName, filterType in pairs( SystemData.UiLogFilters )
    do
        if( DebugWindow.Settings.LogFilters[filterType] == nil )
        then
            DebugWindow.Settings.LogFilters[filterType] = { enabled=true, color=DefaultColors.WHITE }
        end

    end


    LabelSetText("DebugWindowMouseOverLabel", L"Mouseover Window:" )

    LabelSetText("DebugWindowMousePointLabel", L"Mouseover X,Y: " )
    LabelSetText("DebugWindowMousePointText", L"" )
    LabelSetTextColor("DebugWindowMouseOverText", 255, 255, 0 )
        LabelSetTextColor("DebugWindowMousePointText", 255, 255, 0 )

    -- Display Settings
    LogDisplaySetShowTimestamp( "DebugWindowText", true )
    LogDisplaySetShowLogName( "DebugWindowText", false )
    LogDisplaySetShowFilterName( "DebugWindowText", true )

    -- Add the Lua Log
    DebugWindow.AddUiLog()
    ButtonSetText("DebugWindowReloadUi", L"Reload UI")
    ButtonSetText("DebugWindowClose", L"Close")



    -- Options
    ButtonSetText( "DebugWindowToggleOptions", L"Options")



    CreateWindow( "DebugWindowOptions", false )


    LabelSetText( "DebugWindowOptionsFiltersTitle", L"Logging Filters:" )
    LabelSetText( "DebugWindowOptionsFilterType1Label", L"Ui System Messages" )
    LabelSetText( "DebugWindowOptionsFilterType2Label", L"Warning Messages" )
    LabelSetText( "DebugWindowOptionsFilterType3Label", L"Error Messages" )
    LabelSetText( "DebugWindowOptionsFilterType4Label", L"Debug Messages" )
    LabelSetText( "DebugWindowOptionsFilterType5Label", L"Function Calls Messages" )
    LabelSetText( "DebugWindowOptionsFilterType6Label", L"File Loading Messages" )
    LabelSetText( "DebugWindowOptionsFilterType9Label", L"Input Messages" )
    LabelSetText( "DebugWindowOptionsFilterType10Label", L"Output Messages" )
    LabelSetText( "DebugWindowOptionsFilterType11Label", L"Event Messages" )
    ButtonSetText("DebugWindowOptionsClose", L"Close")

    -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        local buttonName = "DebugWindowOptionsFilterType"..filterType.."Button"
        ButtonSetStayDownFlag( buttonName, true )

        LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterType, filterData.enabled )
        ButtonSetPressedFlag( buttonName, filterData.enabled )
        WindowSetId( buttonName, filterType )

        -- When UI Log filters are off, disable logging of that filter type entirely.
        TextLogSetFilterEnabled( "UiLog", filterType, filterData.enabled  )
    end

    LabelSetText(  "DebugWindowOptionsErrorHandlingTitle", L"Generate lua-errors from:" )
    LabelSetText(  "DebugWindowOptionsErrorOption1Label", L"Lua calls to ERROR()" )
    LabelSetText(  "DebugWindowOptionsErrorOption2Label", L"Errors in lua calls to C" )

    for index = 1, 2
    do
        ButtonSetStayDownFlag( "DebugWindowOptionsErrorOption"..index.."Button", true )
    end
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", GetUseLuaErrorHandling() )

    LabelSetText(  "DebugWindowOptionsLuaDebugLibraryLabel", L"Load Lua Debug Library" )
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", GetLoadLuaDebugLibrary() )

    ButtonSetText( "DebugWindowOptionsClearLogText", L"Clear Log" )
    WindowSetShowing("DebugWindowOptionsFilterType10", false)

    WindowSetShowing("DebugWindowOptions", false )

    HandlePregameInit()
    TextEditBoxSetHistory("DebugWindowTextBox", DebugWindow.history )
    if( DebugWindow.history ) then
        TextEditBoxSetHistory("DebugWindowTextBox", DebugWindow.history )
      end
    DebugWindow.SpyCheck()
end


-- OnShutdown Handler
function DebugWindow.Shutdown()
  DebugWindow.history = TextEditBoxGetHistory("DebugWindowTextBox")
end


-- OnUpdate Handler
function DebugWindow.Update( timePassed )

    if (DebugWindow.lastMouseX ~= SystemData.MousePosition.x or DebugWindow.lastMouseY ~= SystemData.MousePosition.x) then
        local mousePoint = L""..SystemData.MousePosition.x..L", "..SystemData.MousePosition.y;
        LabelSetText ("DebugWindowMousePointText", mousePoint);

        DebugWindow.lastMouseX = SystemData.MousePosition.x;
        DebugWindow.lastMouseY = SystemData.MousePosition.y;
    end



    -- Update the MouseoverWindow
    if( DebugWindow.lastMouseOverWindow ~= SystemData.MouseOverWindow.name ) then
        LabelSetText( "DebugWindowMouseOverText", StringToWString(SystemData.MouseOverWindow.name) )
        DebugWindow.lastMouseOverWindow = SystemData.MouseOverWindow.name
    end
end


function DebugWindow.Hide()
    WindowSetShowing("DebugWindow", false )
    WindowSetShowing("DebugWindowOptions", false )
end

function DebugWindow.ToggleLogging()

    DebugWindow.Settings.logsOn = not DebugWindow.Settings.logsOn

    if( DebugWindow.Settings.logsOn ) then
        CHAT_DEBUG( L" UI Logging: ON" )
    else
        CHAT_DEBUG( L" UI Logging: OFF" )
    end

    DebugWindow.UpdateLog()
  end

function DebugWindow.UpdateLog()

    TextLogSetIncrementalSaving( "UiLog", DebugWindow.Settings.logsOn, L"logs/uilog.log");
    TextLogSetEnabled( "UiLog", DebugWindow.Settings.logsOn )

    UpdateLoggingButton()

end

function DebugWindow.OnResizeBegin()
  WindowUtils.BeginResize( "DebugWindow", "topleft", 300, 200, nil)
end



--- Options Window

function DebugWindow.ToggleOptions()
    local showing = WindowGetShowing( "DebugWindowOptions" )
    WindowSetShowing("DebugWindowOptions", showing == false )
end

function DebugWindow.HideOptions()
    WindowSetShowing("DebugWindowOptions", false )
end

function DebugWindow.ClearTextLog()
    --DEBUG(L"Entered Clear text Log")

    -- Clear the UI log
    TextLogClear("UiLog")

    -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterType, filterData.enabled )

        -- When UI Log filters are off, disable logging of that filter type entirely.
        TextLogSetFilterEnabled( "UiLog", filterType, filterData.enabled  )
    end


    for index = 1, 2
    do
        ButtonSetStayDownFlag( "DebugWindowOptionsErrorOption"..index.."Button", true )
    end

    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", GetUseLuaErrorHandling() )
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", GetLoadLuaDebugLibrary() )

end

function DebugWindow.AddUiLog()
    LogDisplayAddLog("DebugWindowText", "UiLog", true)

        -- Options
    for filterType, filterData in pairs( DebugWindow.Settings.LogFilters )
    do
        LogDisplaySetFilterColor( "DebugWindowText", "UiLog", filterType, filterData.color.r, filterData.color.g, filterData.color.b )
    end

    UpdateLoggingButton()

end

function DebugWindow.UpdateDisplayFilter()

    local filterId = WindowGetId(SystemData.ActiveWindow.name)

    local enabled = not DebugWindow.Settings.LogFilters[filterId].enabled
    DebugWindow.Settings.LogFilters[filterId].enabled = enabled

    ButtonSetPressedFlag( "DebugWindowOptionsFilterType"..filterId.."Button", enabled )
    LogDisplaySetFilterState( "DebugWindowText", "UiLog", filterId, enabled )


    -- When UI Log filters are off, disable logging of that filter type entirely.
    TextLogSetFilterEnabled( "UiLog", filterId, enabled )

end

function DebugWindow.UpdateLuaErrorHandling()

    DebugWindow.Settings.useDevErrorHandling = not DebugWindow.Settings.useDevErrorHandling ;
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption1Button", DebugWindow.Settings.useDevErrorHandling  )
end

function DebugWindow.UpdateCodeErrorHandling()
    local enabled = GetUseLuaErrorHandling()
    enabled = not enabled

    SetUseLuaErrorHandling( enabled )
    ButtonSetPressedFlag( "DebugWindowOptionsErrorOption2Button", enabled )
end

function DebugWindow.UpdateLoadLuaDebugLibrary()
    local enabled = GetLoadLuaDebugLibrary()
    enabled = not enabled

    SetLoadLuaDebugLibrary( enabled )
    ButtonSetPressedFlag( "DebugWindowOptionsLuaDebugLibraryButton", enabled )
end


function DebugWindow.AddInputHistory()
  table.insert(DebugWindow.history, text)
end

function DebugWindow.ScrollToBottom ()
    LogDisplayScrollToBottom ("DebugWindowText")
end


function DebugWindow.TextSend()
  text = towstring(TextEditBoxGetText(SystemData.ActiveWindow.name))
    if text == L"" then
      DebugWindow.TextSender()
    elseif text == L"h" then
      DebugWindow.TextSender()
      DebugWindow.help()
    elseif text == L"reg" then
      DebugWindow.TextSender()
      DebugWindow.RegisterFunctions()
    elseif text == L"r" then
      InterfaceCore.ReloadUI()
    elseif text == L"f" then
      DebugWindow.TextSender()
      functionlist()
    elseif text == L"ff" then
      DebugWindow.TextSender()
      DebugWindow.RegisteredList()
    elseif text == L"ror" then
      DebugWindow.TextSender()
      DebugWindow.ror()
    elseif text == L"e" then
      DebugWindow.TextSender()
      DebugWindow.EventList()
    elseif text == L"s" then
      DebugWindow.TextSender()
      DebugWindow.Spy()
    elseif text == L"ss" then
      DebugWindow.TextSender()
      DebugWindow.SpyStop()
  --  elseif text == string.match("hw", tostring(text)) then
  --    DebugWindow.TextSender()
  --    hw(text)
    elseif text ~= nil then
      DebugWindow.TextSender()
      DebugWindow.ScriptSender()
  end
end

---------------------------------------------------------------------
----------------PRINT FUNCTIONS TO WINDOW ------------------------


-----------REGISTER EVENT SPY---------------
  function DebugWindow.RegisterHandleSpy()
    for k,v in pairs(DebugWindow.spyfilter) do
      DebugWindow.registeredevents[k]=v end
    for k,v in pairs(DebugWindow.registeredevents) do
        _G["EventDebug_" .. k] = function(...)
        eve(k .. ": " .. DebugWindow.tableConcat({...}, ", ")) end
  end
end
----------------------------------------

function DebugWindow.TableClear()
for k in pairs (DebugWindow.registeredevents) do
  DebugWindow.registeredevents[k] = nil
end
end

function DebugWindow.SpyCheck()
if DebugWindow.registeredevents == nil then return end
if next(DebugWindow.registeredevents) ~= nil then
  for k,v in pairs(DebugWindow.registeredevents) do
      _G["EventDebug_" .. k] = function(...)
      eve(k .. ": " .. DebugWindow.tableConcat({...}, ", ")) end
    end
  end
        for k,v in pairs(DebugWindow.registeredevents) do
          if k ~= "UPDATE_PROCESSED"  and k ~="PLAYER_POSITION_UPDATED" then
          RegisterEventHandler(DebugWindow.registeredevents[k], "EventDebug_" .. k)
      end
    end
end


function DebugWindow.Spy()
  if next(DebugWindow.registeredevents) ~= nil then
    pp("You are already spying.") return end
    DebugWindow.RegisterHandleSpy()
            for k,v in pairs(DebugWindow.registeredevents) do
              if k ~= "UPDATE_PROCESSED"  and k ~="PLAYER_POSITION_UPDATED" then
              RegisterEventHandler(DebugWindow.registeredevents[k], "EventDebug_" .. k)
          end
      end
        pp(L"Starting Event Spy")
end


function DebugWindow.SpyStop()

    if next(DebugWindow.registeredevents) == nil then
            pp("You are not spying anything.")
      elseif DebugWindow.registeredevents ~= nil then
        for k,v in pairs(DebugWindow.registeredevents) do
            if k ~="PLAYER_POSITION_UPDATED" and k ~= "UPDATE_PROCESSED" then
              UnregisterEventHandler(DebugWindow.registeredevents[k], "EventDebug_" .. k)
            end
        end
        DebugWindow.TableClear()
        pp(L"Stopping Event Spy")
    end
end


------EVENT LIST---------
function DebugWindow.EventList()
          p(SystemData.Events)
        end

-----------------------
-------------REGISTER ALL FUNCTIONS------------
function DebugWindow.RegisterFunctions()
  for k in pairs (DebugWindow.RegisteredFunctionList) do
      DebugWindow.RegisteredFunctionList[k] = nil
      end
        for i,v in pairs(_G) do
        if type(v) == "function" then
          table.insert(DebugWindow.RegisteredFunctionList, i)
          end
         end
         table.sort(DebugWindow.RegisteredFunctionList)
    end

---------------------------------------------------------------------
------------- PRINT ALL REGISTERED FUINCTIONS---------------------

      function DebugWindow.RegisteredList()
          p(DebugWindow.RegisteredFunctionList)
      end

------------------------------SEND TO TERMINAL-------------

function DebugWindow.ScriptSender()
SendChatText(L"/script "..towstring(text), L"")
end

function DebugWindow.TextSender()
  inp(text)
  DebugWindow.AddInputHistory()
  DebugWindow.ScrollToBottom ()
  TextEditBoxSetText(SystemData.ActiveWindow.name,L"")
end
--------------------------------------------------------------------
function DebugWindow.TextClear()
    local scrollcondition = LogDisplayIsScrolledToBottom ("DebugWindowText") == true
    local text = TextEditBoxGetText(SystemData.ActiveWindow.name)
    if (text == L"" and scrollcondition == true) then
  	       WindowSetShowing("DebugWindow", false)
      else
          TextEditBoxSetText(SystemData.ActiveWindow.name,L"")
          DebugWindow.ScrollToBottom ()
          end
  end
---------------------------------------------------------------------
---------on esc window behavior------------------------------
function DebugWindow.OnKeyEscape()
    if WindowGetShowing ("DebugWindow", true) then
      WindowAssignFocus( "DebugWindowTextBox", true)
      DebugWindow.ScrollToBottom ()
    end
end
------------------------


--------------------print help--------------------------
function DebugWindow.help()
 local help = {[[

 ______________________________________
 \_____________________________________/

                            warTerminal v1.0
  _____________________________________
/______________________________________\

Available commands:

p(text) - Prints to the terminal.

f - Prints all available game-related functions.
reg - Saves all currently registered functions to a table.
ff- Prints all currently registered functions.

r - Reloads UI

hw(windowName) - Highlights where a specified window is being drawn even if not currently visible.
(Not compatible with NoUselessMods-HelpTips)

ror - List of RoR server commands

Event Spy
e - Prints a list of all game events.
s - Start on-the-fly event spying.
(UPDATE_PROCESSED and PLAYER_POSITION_UPDATED are not spied upon)
ss - Stop on-the-fly event spying.
]]
    }

    for k,v in pairs(help) do
           pp(v)
            end
end


----------------------------------------------------------------------------------------------------------print ror functions----------------

function DebugWindow.ror()
  local ror = {[[


AVAILABLE ROR SERVER COMMANDS
===================================
RANKED: Ranked commands.
READYCHECK: Ready check commands.
RESPEC: Respecialization commands.
SPEC: Respecialization commands.
CHANGENAME: Requests a name change, one per account per month
GMLIST: Lists available GMs.
RULES: Sends a condensed list of in-game rules.
ASSIST: Switches to friendly target's target
UNLOCK: Used to fix stuck-in-combat problems preventing you from joining a scenario.
TELLBLOCK: Allows you to block whispers from non-staff players who are outside of your guild.
GETSTATS: Shows your own linear stat bonuses.
STANDARD: Assigns Standard Bearer Titel to the Player.
ROR: Help Files for RoR-specific features.
LANGUAGE: Change the language of data.
TOKFIX: Checks if player have all ToKs and fixes if needed
RVRSTATUS: Displays current status of RvR.
PUG: Displays current PUG scenario.
SURRENDER: Starts surrender vote in scenario.
YES: Vote YES durring scenario surrender vote.
NO: Vote NO durring scenario surrender vote.
SORENABLE: Enables SoR addon.
SORDISABLE: Disables SoR addon.
MMRENABLE: Enables MMR addon.
GUILDINVOLVE: Allows you to involve your guild with RvR campaign.
GUILDCHANGENAME: Change guild name, costs 1000 gold
CLAIMKEEP: Allows you to claim keep for your guild in RvR campaign.
APPRENTICE: Allows you to claim keep for your guild in RvR campaign.
LOCKOUTS: Displays lockouts of player and his party.
BAGBONUS: Displays accumulated bonuses for RvR bags.
ALERT: Sends an alert to the player specified using channel 9(string playerName string message). Used for Addons.
RANKEDSCSTATUS: Shows player count of the ranked solo scenario queue.
UISCSTATUS: Shows player count of the ranked solo scenario queue for the UI.
UISERVER: Sends user interface server settings.
GROUPSCOREBOARDRESET: Reset Group Scoreboard
GROUPCHALLENGE: Challenge another group to a scenario
===================================
  ]]}

  for k,v in pairs(ror) do
         pp(v)
          end
end

-----
---maybe move this to debugwindow.spy and keep the table.insert functionality out of here because you filter 3 events on starting spy annd it conflicts with two tables


--------------TABLE CONCAT CHANGES TO PRINT EVENTS CORRECTLY -----------------



do
   local orig_table_concat = table.concat

   -- Define new function "table.concat" which overrides standard one
   function DebugWindow.tableConcat(list, sep, i, j, ...)
      -- Usual parameters are followed by a list of value converters
      local first_conv_idx, converters, t = 4, {sep, i, j, ...}, {}
      local conv_types = {
         ['function'] = function(cnv, val) return cnv(val)        end,
         table        = function(cnv, val) return cnv[val] or val end
      }
      if conv_types[type(sep)]   then first_conv_idx, sep, i, j = 1
      elseif conv_types[type(i)] then first_conv_idx,      i, j = 2
      elseif conv_types[type(j)] then first_conv_idx,         j = 3
      end
      sep, i, j = sep or '', i or 1, j or #list
      for k = i, j do
         local v, idx = list[k], first_conv_idx
         while conv_types[type(converters[idx])] do
            v = conv_types[type(converters[idx])](converters[idx], v)
            idx = idx + 1
         end
         t[k] = tostring(v) -- 'tostring' is always the final converter
      end
      return orig_table_concat(t, sep, i, j)
   end
end
