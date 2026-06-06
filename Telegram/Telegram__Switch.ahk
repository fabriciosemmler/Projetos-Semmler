#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode 2

#HotIf WinActive("Telegram")
Up::WheelUp
Down::WheelDown
#HotIf
