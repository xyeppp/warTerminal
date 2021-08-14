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
            <File name="Source/chook/CaptainHook.lua" />
            <File name="Source/devpad/DebugWindowCodePad.lua" />
            <File name="Source/DebugWindow.xml" />
            <File name="Source/DebugWindowVerticalScroll.xml" />
            <File name="Source/mesh/Mesh.lua" />
            <File name="Source/mesh/Mesh.xml" />
            <File name="Source/mesh/Templates.xml" />
            <File name="Source/objectinsp/ObjectInspector.lua" />
            <File name="Source/objectinsp/ObjectInspector.xml" />
            <File name="Source/bust/Busted.lua" />
            <File name="Source/cacher/warcacher.lua" />
          <!--  <File name="Source/Tip/TooltipSpy.xml" />-->
          <!--  <File name="Source/Tip/TooptipSpy.lua" />-->
        </Files>
        <OnInitialize>
            <CreateWindow name="DebugWindow" show="false" />
            <CallFunction name="Busted.Initialize" />
            <CallFunction name="BustedGUI.Initialize" />
          </OnInitialize>
        <SavedVariables>
            <SavedVariable name="DebugWindow.Settings" />
            <SavedVariable name="DebugWindow.history" />
            <SavedVariable name="DebugWindow.RegisteredFunctionList" />
            <SavedVariable name="RegisteredEvents" />
            <SavedVariable name="DevPad_Settings" />
            <SavedVariable name="DevPad_Save" />
            <SavedVariable name="DevPad_FileCount" />
            <SavedVariable name="Mesh.isMeshing"/>
            <SavedVariable name="Mesh.meshSizeCurrent"/>
            <SavedVariable name="ObjectInspector.Settings" />
            <SavedVariable name="ObjectInspector.history" />
            <SavedVariable name="Busted.Show" />
            </SavedVariables>
        <OnShutdown>
            <CallFunction name="DebugWindow.Shutdown" />
            <CallFunction name="ObjectInspector.OnShutdown" />
        </OnShutdown>
    </UiMod>

</ModuleFile>
