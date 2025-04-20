#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner & Loading
clear
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "       ██╗  ██╗██╗   ██╗██████╗ ██████╗  ██████╗  ██████╗ ███████╗███╗   ██╗"
echo "       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝ ██╔════╝████╗  ██║"
echo "       ███████║ ╚████╔╝ ██║  ██║██████╔╝██║   ██║██║  ███╗█████╗  ██╔██╗ ██║"
echo "       ██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██║   ██║██║   ██║██╔══╝  ██║╚██╗██║"
echo "       ██║  ██║   ██║   ██████╔╝██║  ██║╚██████╔╝╚██████╔╝███████╗██║ ╚████║"
echo "       ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -ne "${CYAN}Loading"; for i in {1..3}; do sleep 0.4; echo -n "."; done; echo -e "${NC}"
sleep 0.5

echo -e "${CYAN}Thank you for using Hydrogen Helper! If there's any issues please contact m-oblilyum(${NC}"

osascript <<'APPLESCRIPT'
use scripting additions

property RBX_APP        : "/Applications/Roblox.app"
property HYD_APP        : "/Applications/Hydrogen-M.app"
property HYD_URL        : "https://0ai4bbbahf.ufs.sh/f/4fzhZqSSYIjmaQcw2hMCuIoXRdv5E3iwKj1g7S8GWLOxkpfJ"

on sh(cmd)
	try
		return do shell script cmd
	on error e
		return "[ERROR] " & e
	end try
end sh

-- Open Roblox
on openRoblox()
	if sh("test -x " & quoted form of (RBX_APP & "/Contents/MacOS/RobloxPlayer") & " && echo OK") ≠ "OK" then
		display alert "Cannot open Roblox" message "Roblox.app missing or broken." buttons {"OK"} as critical
	else
		sh("open -a " & quoted form of RBX_APP)
	end if
end openRoblox

-- Clear Roblox cache
on clearCache()
	sh("rm -rf ~/Library/Application\\ Support/Roblox")
	sh("rm -rf ~/Library/Caches/com.roblox.Roblox")
	display dialog "Roblox cache cleared." buttons {"OK"} default button "OK"
end clearCache

-- Uninstall both Roblox & Hydrogen
on uninstallAll()
	sh("rm -rf " & quoted form of RBX_APP)
	sh("rm -rf " & quoted form of HYD_APP)
	sh("rm -rf ~/Library/Application\\ Support/Roblox")
	sh("rm -rf ~/Library/Caches/com.roblox.Roblox")
	display dialog "Uninstalled Roblox and Hydrogen‑M (if present)." buttons {"OK"} default button "OK"
end uninstallAll

-- Reinstall both (Roblox & Hydrogen)
on reinstallBoth()
	display dialog "Reinstalling Roblox (this will also reinstall Hydrogen)..." buttons {"OK"} default button "OK"
	uninstallAll()
	installHydrogen()
	display dialog "Reinstallation complete!" buttons {"OK"} default button "OK"
end reinstallBoth

-- Install Hydrogen
on installHydrogen()
	set HYD_CMD to "curl -fsSL " & HYD_URL & " | bash"
	tell application "Terminal"
		activate
		do script HYD_CMD
	end tell
	display notification "Hydrogen‑M is running in Terminal" with title "Hydrogen Helper"
end installHydrogen

-- Fixer handlers
on checkSysReq()
	set v to system version of (system info)
	set arch to do shell script "uname -m"
	if v < "11.0" then
		display dialog "macOS 11+ required. You’re on " & v buttons {"OK"} default button "OK"
	else
		display dialog "System meets requirements:" & return & "macOS " & v & return & "CPU: " & arch buttons {"OK"} default button "OK"
	end if
end checkSysReq

on fixSuddenClose()
	display dialog "Fix if Hydrogen‑M closes suddenly:" & return & return & ¬
		"1) Redownload Hydrogen and open it." & return & ¬
		"2) Open Roblox, let it fully load." & return & ¬
		"3) Restart your Mac if needed." buttons {"OK"} default button "OK"
end fixSuddenClose

on fixRobloxArch()
	set info to sh("file " & quoted form of (RBX_APP & "/Contents/MacOS/RobloxPlayer"))
	if info contains "arm64" or info contains "x86_64" then
		display dialog "Roblox architecture is OK." buttons {"OK"} default button "OK"
	else
		display dialog "RobloxPlayer isn’t arm64/x86_64." & return & return & ¬
			"1) Delete /Applications/Roblox.app" & return & ¬
			"2) Download correct build from roblox.com" & return & ¬
			"3) Install it (no Rosetta)" buttons {"OK"} default button "OK"
	end if
end fixRobloxArch

on fixPortBinding()
	openRoblox()
	delay 5
	if sh("lsof -iTCP -sTCP:LISTEN | grep -E '6969|6970|7069'") = "" then
		display dialog "No HTTP server on ports 6969–7069." buttons {"Install Hydrogen‑M"} default button "Install Hydrogen‑M"
		installHydrogen()
	else
		display dialog "Ports 6969–7069 are active. Hydrogen‑M is loaded." buttons {"OK"} default button "OK"
	end if
end fixPortBinding

on fixPasswordPrompt()
	display dialog "Password prompt hidden? Type your password and press Enter." buttons {"OK"} default button "OK"
end fixPasswordPrompt

-- Helper menu
on helperMenu()
	repeat
		set choice to choose from list ¬
			{"Open Roblox", "Clear Roblox Cache", ¬
			 "Reinstall Roblox (will reinstall Hydrogen)", ¬
			 "Install Hydrogen‑M", "Uninstall All", "Back"} ¬
			with title "Hydrogen Helper" with prompt "Helper Options:"
		if choice is false or item 1 of choice = "Back" then return
		set sel to item 1 of choice
		if sel = "Open Roblox" then openRoblox()
		if sel = "Clear Roblox Cache" then clearCache()
		if sel = "Reinstall Roblox (will reinstall Hydrogen)" then reinstallBoth()
		if sel = "Install Hydrogen‑M" then installHydrogen()
		if sel = "Uninstall All" then uninstallAll()
	end repeat
end helperMenu

-- Fixer menu
on fixerMenu()
	repeat
		set choice to choose from list ¬
			{"System Requirements Check", "Fix Sudden Close", ¬
			 "Fix Roblox Architecture", "Fix Port Binding", ¬
			 "Password Prompt Fix", "Back"} ¬
			with title "Hydrogen Fixer" with prompt "Fixer Options:"
		if choice is false or item 1 of choice = "Back" then return
		set sel to item 1 of choice
		if sel = "System Requirements Check" then checkSysReq()
		if sel = "Fix Sudden Close" then fixSuddenClose()
		if sel = "Fix Roblox Architecture" then fixRobloxArch()
		if sel = "Fix Port Binding" then fixPortBinding()
		if sel = "Password Prompt Fix" then fixPasswordPrompt()
	end repeat
end fixerMenu

-- Main loop (close to exit)
repeat
	set page to choose from list {"Helper", "Fixer"} with title "Hydrogen Menu - from m-oblilyum " with prompt "Select Page:"
	if page is false then exit repeat
	if item 1 of page = "Helper" then helperMenu()
	if item 1 of page = "Fixer" then fixerMenu()
end repeat

END
