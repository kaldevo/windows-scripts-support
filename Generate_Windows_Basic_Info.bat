REM This scripts queries and displays basic information about your Username, Hostname, IP etc.
REM Deploy this script using GPO and create a shortcut in the users Desktop.
REM I made this to give Support/Helpdesk to get the basic information from their users or customers.
REM Usage: Just run it.
@echo off
color 1F
mode con: cols=75 lines=22 
Set "LogFile=%~dpn0.txt"

REM color 71 - Inverted
REM Getting the values of the ip address using the ipconfig command to extract the local IP address. 
FOR /F "tokens=* delims=" %%i IN ('wmic path Win32_NetworkAdapter where "PNPDeviceID like '%%PCI%%' AND AdapterTypeID='0'" get MacAddress /format:value') DO (
    for /f "tokens=* delims=" %%# in ("%%i") do set "%%#"
)
for /f "tokens=2 delims=," %%i in ('wmic os get caption^,version /format:csv') do set os=%%i
REM Multiple Adapters may cause some issue.
for /F "tokens=1-7 delims=:" %%a in ('ipconfig ^| find "IPv4"') do (set "LocalIP=%%b" & goto :next)
:next
REM Grabbing external IP address
for /f "tokens=1* delims=: " %%A in ('nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"') Do set ExtIP=%%B
REM Getting Domain by reading the second line from the output.
for /f "skip=1" %%G IN ('wmic computersystem get domain') DO if not defined ComputerDomain set "ComputerDomain=%%G"
title Workstation: %ComputerName% - Basic Computer Information

REM Result from the values for Hostname and IP address
echo(
	echo Username          : %username%
	echo Hostname          : %ComputerName%
	echo MAC Address       : %MacAddress%
	echo Operating System  : %os%
	echo Local IP          :%LocalIP%
	echo External IP       : %ExtIP%
	echo Domain Name       : %ComputerDomain%

	ping -n 2 -w 700 1.1.1.1 | find "bytes=">nul 
	IF %ERRORLEVEL% EQU 0 (
		echo Ping              : SUCCESS
	) ELSE (
		echo Ping              : FAILED
	)
	echo.
	REM This query the main adapter, if there is Wireless and Ethernet it displays both.
	REM It doesn't test if this adapter is connected or not.
	echo Network Adapter Information:
	wmic path Win32_NetworkAdapter where "PNPDeviceID like '%%PCI%%' AND AdapterTypeID='0'" get name, MacAddress
	echo.
(
	REM Writing log file to text
	echo Username          : %username%
	echo Hostname          : %ComputerName%
	echo MAC Address       : %MacAddress%
	echo Operating System  : %os%
	echo Local IP          :%LocalIP%
	echo External IP       : %ExtIP%
	echo Domain Name       : %ComputerDomain%

	echo.
	REM Tries to test internet connectivity and write it to log.
	echo Ping Results 
	ping -n 2 -w 700 1.1.1.1 | find "bytes="
	IF %ERRORLEVEL% EQU 0 (
		echo Ping              : SUCCESS
	) ELSE (
		echo Ping              : FAILED
	)
	echo.
	echo Date              : %date% 
	echo Time              : %time%
	echo.

)>"%LogFile%"
echo Generating Log. Please wait.
Timeout /T 10 /NoBreak>nul
echo Saved Location  : %~dpn0.txt
echo.
echo Press [ENTER] to open log file and exit this screen.
pause >nul
Start "" "%LogFile%"

