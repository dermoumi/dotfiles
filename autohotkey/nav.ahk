#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  All ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #NoTrayIcon

#singleinstance force

; Makes it so that when tapping caps lock, escape is sent instead
; But while holding it, it acts as ctrl
enable := 1
capslock_down := 0
cancel_esc := 0

; ctrl+win+alt+r to reload this file
^#!r::reload

; ctrl+win+alt+t to toggle all of this
^#!t::enable := !enable

#if enable

; use mouse clicks to cancel the capslock => esc
$~*lbutton::cancel_esc := 1
$~*rbutton::cancel_esc := 1
$~*mbutton::cancel_esc := 1

; while holding caps lock, toggle the extra modifier
$*capslock::
    capslock_down := 1
    sendinput {ctrl down}
    cancel_esc := 0
    keywait, capslock
    sendinput {ctrl up}
    if (a_priorkey = "capslock" and !cancel_esc)
        sendinput {esc}
    capslock_down := 0
return

; make alt+hjkl act as arrow keys
$<!h::sendinput   {left}
$<!j::sendinput   {down}
$<!k::sendinput   {up}
$<!l::sendinput   {right}

$+<!h::sendinput  +{left}
$+<!j::sendinput  +{down}
$+<!k::sendinput  +{up}
$+<!l::sendinput  +{right}

$^<!h::sendinput  ^{left}
$^<!j::sendinput  ^{down}
$^<!k::sendinput  ^{up}
$^<!l::sendinput  ^{right}

$+^<!h::sendinput +^{left}
$+^<!j::sendinput +^{down}
$+^<!k::sendinput +^{up}
$+^<!l::sendinput +^{right}

; alt+i and alt+, as home and end respectively
$<!i::sendinput    {home}
$<!,::sendinput    {end}

$+<!i::sendinput  +{home}
$+<!,::sendinput  +{end}

$^<!i::sendinput  ^{home}
$^<!,::sendinput  ^{end}

$+^<!i::sendinput  +^{home}
$+^<!,::sendinput  +^{end}

; closer media keys
$#!space::media_play_pause
$#+z::media_prev
$#+x::media_next

; change virtual desktops
$#h::
    if (capslock_down) {
        sendinput #^{left}
    } else {
        sendinput #{left}
    }
return

$#l::
    if (capslock_down) {
        send, {ctrl up}
        sendinput #^{right}
    } else {
        sendinput #{right}
    }
return


$#j::sendinput #{down}
$#k::sendinput #{up}

$#+h::sendinput ^#!{left}
$#+l::sendinput ^#!{right}
$#+j::sendinput ^#!{down}
$#+k::sendinput ^#!{up}

; caps+win+del to set dark theme
$#d::
    if (capslock_down) {
        ; run, colctl.exe -accent_color 104C66
        ; set_wallpaper("wallpapers\mysteryshack_night.jpg")
        regwrite, REG_DWORD, HKEY_CURRENT_USER
            , Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, 0
    }
return

; caps+alt+printscr to set light theme
$#f::
    if (capslock_down) {
        ; run, colctl.exe -accent_color E6E6E6
        ; set_wallpaper("wallpapers\mysteryshack_day.jpg")
        regwrite, REG_DWORD, HKEY_CURRENT_USER
            , Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, 1
    }
return

#if ; enable
