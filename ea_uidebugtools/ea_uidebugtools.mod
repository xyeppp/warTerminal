<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

    <UiMod name="EA_UiDebugTools" version="2.0" date="24/04/21" >
        <Author name="EAMythic" email="" />
        <Description text="This module contains the UI development debugging tools - overhauled by xyeppp." />
        <Dependencies>
            <Dependency name="EATemplate_DefaultWindowSkin" />
              </Dependencies>
        <Files>
            <File name="Source/Debug.lua" />
            <File name="Source/DebugWindowCodePad.lua" />
            <File name="Source/DebugWindow.xml" />
            <File name="Source/DebugWindowVerticalScroll.xml" />
          </Files>
        <OnInitialize>
            <CreateWindow name="DebugWindow" show="false" />
            <CallFunction name="DevPad.Initialize" />
        </OnInitialize>
        <SavedVariables>
            <SavedVariable name="DebugWindow.Settings" />
            <SavedVariable name="DebugWindow.history" />
            <SavedVariable name="DebugWindow.RegisteredFunctionList" />
            <SavedVariable name="RegisteredEvents" />
            <SavedVariable name="DevPad_Settings" />
            <SavedVariable name="DevPad_Save" />
            <SavedVariable name="DevPad_FileCount" />
        </SavedVariables>
        <OnShutdown>
            <CallFunction name="DebugWindow.Shutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
