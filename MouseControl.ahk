#Persistent
#InstallKeybdHook
SetBatchLines, -1
SetTimer, MoveMouse, 10

; --- Ayarlar ---
normalSpeed := 6
turboSpeed := 20
smoothFactor := 3
w := 0, a := 0, s := 0, d := 0
shift := 0
scroll := 0
dragging := 0
mouseMode := true  ; Başlangıçta aktif

; --- Toggle Mouse/WASD Modu (F12) ---
^!m::  ; Ctrl + Alt + M
    mouseMode := !mouseMode
    
return


; --- MouseMode aktifken hotkeyler ---
#If mouseMode

; WASD hareketleri
w::w := 1
w up::w := 0
a::a := 1
a up::a := 0
s::s := 1
s up::s := 0
d::d := 1
d up::d := 0

; Shift turbo
$Shift::shift := 1
$Shift up::shift := 0

; CapsLock scroll
$CapsLock::scroll := 1
$CapsLock up::scroll := 0

; Mouse tıklamaları
j::Click, left
k::Click, right
l::Click, 2
i::Click, middle

; Drag & Drop
u::
    if (dragging) {
        MouseClick, left, , , , , U
        dragging := 0
    } else {
        MouseClick, left, , , , , D
        dragging := 1
    }
return

; Hız ayarı
[::  
    normalSpeed := normalSpeed > 2 ? normalSpeed - 2 : 2
    TrayTip, Mouse Speed, Hız azaltıldı: %normalSpeed%, 500
return

]::  
    normalSpeed += 2
    TrayTip, Mouse Speed, Hız artırıldı: %normalSpeed%, 500
return

#If  ; mouseMode dışında hotkey yok

; --- Hareket / Scroll Döngüsü ---
MoveMouse:
    if (!mouseMode)
        return  ; mouse modu kapalıysa hiçbir şey yapma

    if (scroll) {
        if (w)
            Send {WheelUp}
        if (s)
            Send {WheelDown}
        if (a)
            Send {WheelLeft}
        if (d)
            Send {WheelRight}
        return
    }

    dx := 0
    dy := 0
    speed := shift ? turboSpeed : normalSpeed

    if (w)
        dy -= speed
    if (s)
        dy += speed
    if (a)
        dx -= speed
    if (d)
        dx += speed

    if (dx != 0 or dy != 0)
        MouseMove, dx, dy, 0, R
return
