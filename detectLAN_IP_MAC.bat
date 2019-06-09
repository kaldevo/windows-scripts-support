REM Credits: http://qaru.site/questions/16326782/get-ip-address-of-ethernet-if-not-present-then-get-it-of-wifi-adapater-using-batch-script
@echo off
Title Get (LAN ,Public) (IP) and MAC Addresses by Hackoo 2017
mode con cols=80 lines=5 & Color 9E
echo( & echo(
echo   Please Wait a While ... Searching for (LAN ,Public)(IP) and MAC addresses ...
Set "LogFile=%~dpn0.txt"
@for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do (
    set "LAN_IP=%%a"
)

for /f "tokens=2 delims=: " %%A in (
  'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"'
) Do set ExtIP=%%A


@For /f %%a in ('getmac /NH /FO Table') do  (
    @For /f %%b in ('echo %%a') do (
        If /I NOT "%%b"=="N/A" (
            Set "MY_MAC=%%b"
        )
    )
)
    Cls 
    echo(
    echo                My Private LAN IP       : %LAN_IP%
    echo                My External Public IP   : %ExtIP%
    echo                MAC Addres              : %MY_MAC%

(
    echo My Private LAN IP      : %LAN_IP%
    echo My External Public IP  : %ExtIP%
    echo MAC Address            : %MY_MAC%

)>"%LogFile%"
Timeout /T 5 /NoBreak>nul
Start "" "%LogFile%"
