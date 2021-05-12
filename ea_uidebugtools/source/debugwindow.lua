
----------------------------------------------------------------
-- Global Variables
----------------------------------------------------------------

DebugWindow = {}
DebugWindow.history = {}
DebugWindow.spyfilter = SystemData.Events
RegisteredEvents = {}
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



    -- Setup the Log
    DebugWindow.UpdateLog()
    DebugWindow.SpyCheck()




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

    --DevPad
    ButtonSetText( "DebugWindowToggleDevPad", L"DevPad")


    CreateWindow( "DebugWindowOptions", false )
    CreateWindow( "DevPadWindow", false )


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
    WindowSetShowing("EA_LabelCheckButtonSmallCopy", false)

    WindowSetShowing("DebugWindowOptions", false )

    HandlePregameInit()
    TextEditBoxSetHistory("DebugWindowTextBox", DebugWindow.history )
    if( DebugWindow.history ) then
        TextEditBoxSetHistory("DebugWindowTextBox", DebugWindow.history )
      end

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
        DebugWindow.OnShowFocus()
        CHAT_DEBUG( L" UI Logging: ON" )
    else
        DebugWindow.OnShowFocus()
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



-----------------CHAT HISTORY-----------------
function DebugWindow.AddInputHistory()
  table.insert(DebugWindow.history, text)
end


------------SCROLL TO BOTTOM----------------------
function DebugWindow.ScrollToBottom ()
    LogDisplayScrollToBottom ("DebugWindowText")
    WindowAssignFocus("DebugWindowTextBox", true)
end



---------------------MAIN CHAT SEND-----------------
function DebugWindow.TextSend()
  text = towstring(TextEditBoxGetText(SystemData.ActiveWindow.name))
    if text == L"" then
      DebugWindow.TextSender()
    elseif text == L"h" then
      DebugWindow.TextSender()
      DebugWindow.help()
    elseif text == L"r" then
      InterfaceCore.ReloadUI()
    elseif text == L"f" then
      DebugWindow.TextSender()
      functionlist()
    elseif text == L"e" then
      DebugWindow.TextSender()
      DebugWindow.EventList()
    elseif text == L"s" then
      DebugWindow.TextSender()
      DebugWindow.Spy()
    elseif text ~= nil then
      DebugWindow.TextSender()
      DebugWindow.ScriptSender()
  end
end

-------------AUTOSEND----------------
function DebugWindow.AutoSender()
  local text = towstring(TextEditBoxGetText("DebugWindowTextBox"))
  if text == L"ff" then
    DebugWindow.TextSender()
    DebugWindow.RegisteredList()
  elseif text == L"ror" then
    DebugWindow.TextSender()
    DebugWindow.ror()
  elseif text == L"ss" then
    DebugWindow.TextSender()
    DebugWindow.SpyStop()
  elseif text == L"spylist" then
    DebugWindow.TextSender()
    DebugWindow.SpyList()
  elseif text == L"devpad" then
    DebugWindow.TextSender()
    DevPadWindow.Toggle()
end
end



---------------------------------------------------------------------
----------------EVENT SPY--------------------


  function DebugWindow.OnShowFocus()
    local  visible = WindowGetShowing("DebugWindow") == true
    local  codevis=WindowGetShowing("DevPadWindowDevPadCode")==true
        if codevis==true and  visible==false then
          WindowAssignFocus("DevPadWindowDevPadCode", true)
        elseif visible==true then
        WindowAssignFocus( "DebugWindowTextBox", true ) end
      end

-----------REGISTER MAIN FUNCTION---------------
function DebugWindow.EventRegister()
  for k,v in pairs(DebugWindow.spyfilter) do
    _G["EventDebug_" .. k] = function(...)
      eve(k .. ": " .. DebugWindow.tableConcat({...}, ", ")) end
    end
end


-----------REGISTER EVENT SPY---------------
  function DebugWindow.RegisterHandleSpy()
        DebugWindow.EventRegister()
        if next(RegisteredEvents) == nil then
            for k,v in pairs(DebugWindow.spyfilter) do
              if k ~= "UPDATE_PROCESSED"  and k ~="PLAYER_POSITION_UPDATED" and k ~= "RVR_REWARD_POOLS_UPDATED" then
                RegisteredEvents[k]=v end
              end
            end
          end
--------------------CLEAR TABLE ON UNREGISTER--------------------

function DebugWindow.TableClear()
for k in pairs (RegisteredEvents) do
  RegisteredEvents[k] = nil
end
end

---------CHECK IF SPYING ON RELUI----------
function DebugWindow.SpyCheck()
if RegisteredEvents == nil then return end
if next(RegisteredEvents) ~= nil then
  for k,v in pairs(RegisteredEvents) do
      _G["EventDebug_" .. k] = function(...)
      eve(k .. ": " .. DebugWindow.tableConcat({...}, ", ")) end
    end
    end
        for k,v in pairs(RegisteredEvents) do
          RegisterEventHandler(RegisteredEvents[k], "EventDebug_" .. k)
        end
end

-----------007 SPY -----------------
function DebugWindow.Spy()
  if next(RegisteredEvents) ~= nil then
    pp("You are already spying.") return
  end
    DebugWindow.RegisterHandleSpy()
    for k,v in pairs(DebugWindow.spyfilter) do
      if k ~= "UPDATE_PROCESSED"  and k ~="PLAYER_POSITION_UPDATED" and k ~= "RVR_REWARD_POOLS_UPDATED" then
        RegisteredEvents[k]=v end end
            for k,v in pairs(RegisteredEvents) do
              RegisterEventHandler(RegisteredEvents[k], "EventDebug_" .. k)
            end
        pp(L"Starting Event Spy")
end

----------------007 SPYSTOP------------------
function DebugWindow.SpyStop()

    if next(RegisteredEvents) == nil then
            pp("You are not spying anything.")
      elseif RegisteredEvents ~= nil then
        for k,v in pairs(RegisteredEvents) do
              UnregisterEventHandler(RegisteredEvents[k], "EventDebug_" .. k)
        end
        DebugWindow.TableClear()
        pp(L"Stopping Event Spy")
    end
end

----------ADD TO SPY-------
function spyadd(text)
local wasFound=false;

    for k,v in pairs(DebugWindow.spyfilter) do
        if string.find(k, text) then
          wasFound=true;
          if RegisteredEvents[k]==nil then
            RegisteredEvents[k]=v
            DebugWindow.RegisterHandleSpy()
            pp("Adding "..k.." to Event Spy.")
            RegisterEventHandler(RegisteredEvents[k], "EventDebug_" .. k)
        elseif RegisteredEvents[k] ~=nil then
          pp("Already spying on "..k..".")
            end
          end
        end
        if not wasFound then
          pp("No matching events found.")
        end
end

----------REMOVE FROM EVENT SPY
function spyrem(text)
  for k,v in pairs (DebugWindow.spyfilter) do
    if string.find(k,text) then
      if RegisteredEvents[k] ==nil then pp("You are not spying on "..k.." currently.")
      end
    end
end
    for k,v in pairs(RegisteredEvents) do
        if string.find(k, text) then
          if RegisteredEvents[k]~=nil then
            pp("Removing "..k.." from Event Spy.")
            UnregisterEventHandler(RegisteredEvents[k], "EventDebug_" .. k)
            RegisteredEvents[k]=nil
            end
          end
        end
end
-----LIST OF EVENTS SPIED UPON
function DebugWindow.SpyList()
if next(RegisteredEvents)==nil then
  pp("You are not spying anything.")
elseif next(RegisteredEvents) ~= nil then
  pp("Currently spying on:")
  p(RegisteredEvents)
end
end

---------------------------------
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
          DebugWindow.RegisteredFunctionList[i]=v
          end
         end
         table.sort(DebugWindow.RegisteredFunctionList)
    end

---------------------------------------------------------------------
------------- PRINT ALL REGISTERED FUINCTIONS---------------------

      function DebugWindow.RegisteredList()
        DebugWindow.RegisterFunctions()
          p(DebugWindow.RegisteredFunctionList)
      end

------------------------------SEND FROM TERMINAL-------------

function DebugWindow.ScriptSender()
SendChatText(L"/script "..towstring(text), L"")
end

function DebugWindow.TextSender()
  local text = towstring(TextEditBoxGetText("DebugWindowTextBox"))
  inp(text)
  DebugWindow.AddInputHistory()
  DebugWindow.ScrollToBottom ()
  TextEditBoxSetText(SystemData.ActiveWindow.name,L"")
end

-----------------------ON ESC BEHAVIOR TEXTBOX---------------------------------------
function DebugWindow.TextClear()
    local devpad=WindowGetShowing("DevPadWindow")==true
    local scrollcondition = LogDisplayIsScrolledToBottom ("DebugWindowText") == true
    local text = TextEditBoxGetText("DebugWindowTextBox")
    local texting=true;
    if (text == L"" and scrollcondition == true) then
        texting=false;
          if devpad==true then
            WindowAssignFocus("DevPadWindowDevPadCode", true)
          else
  	        DebugWindow.Hide()
          end
    end
      if texting then
          DebugWindow.ScrollToBottom ()
            if scrollcondition==true then
              TextEditBoxSetText(SystemData.ActiveWindow.name,L"")
            end
      end
  end
---------------------------------------------------------------------
---------on esc window behavior------------------------------
function DebugWindow.OnKeyEscape()
  if WindowGetShowing("DebugWindow") then
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

                         warTerminal v1.1.1
  _____________________________________
/______________________________________\

Available commands:

p(text) - Prints to the terminal.

f - Prints a list of all basic game functions.
ff- Prints a list of all currently registered functions.

r - Reloads UI

hw"windowName" - Highlights where a specified window is being drawn even if not currently visible.
(Not compatible with NoUselessMods-HelpTips)

ror - List of RoR server commands

Event Spy
e - Prints a list of all game events.
s - Start on-the-fly event spying.
(UPDATE_PROCESSED, RVR_REWARD_POOLS_UPDATED and PLAYER_POSITION_UPDATED are not spied upon by default)
ss - Stop on-the-fly event spying.
spylist - Prints a list of events being spied upon currently.
spyadd"text" - Looks for partial matches and adds an event to Event Spy.
spyrem"text" - Looks for partial matches and removes an event from Event Spy.
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
