REM uniquegeek@gmail.com
REM Purpose: Silently uninstall old Cisco WebEx (Meeting Manager, Access Anywhere, Remote Access Agent) with atcliun.exe
REM    Silent uninstall is undocumented and I could not find or guess a silent switch with procexp.exe
REM    Please note this uninstalls versions that are casual users only (did not buy WebEx). 
REM    i.e. This does not uninstall MSI versions.
REM    This uninstalls versions with this regkey:
REM      HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ActiveTouchMeetingClient
REM      "UninstallString"="C:\\PROGRA~3\\WebEx\\atcliun.exe"
REM       where PROGRA~3 IS ProgramData
REM    This does NOT uninstall the web plugin.
REM    Does NOT require futzing around with SendKeys.  Uses simple batch file only, no imports need.
REM
REM Input: none
REM Output: none
REM Directions: Run as user on a workstation with your automation method of choice (GPO, PowerShell, automation framework...)

@echo off
REM run and immediately continue, pass an enter to the application to get past first screen
cmd /c echo.| c:\ProgramData\WebEx\atcliun.exe /v_meet /v_ra /v_smt

REM allow previous task to finish
ping 127.0.0.1 -n 20 > nul

REM end process that is done and waiting for finish button to be clicked
taskkill /im atcliun.exe

REM kill other associated tasks that are waiting for finish
taskkill /fi Del*.tmp

REM allow previous task to finish
ping 127.0.0.1 -n 2 > nul

REM verify aticlun.exe completed and del dir
if not exist "c:\ProgramData\WebEx\WebEx" (
  if exist c:\ProgramData\WebEx (rmdir /S c:\ProgramData\WebEx)
)
