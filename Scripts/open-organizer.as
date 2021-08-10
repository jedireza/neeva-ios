tell application "Xcode"
	activate
end tell

tell application "System Events"
	tell menu item "Organizer" of menu "Window" of menu bar item "Window" of menu bar 1 of process "Xcode"
		perform action "AXPress"
	end tell
end tell
