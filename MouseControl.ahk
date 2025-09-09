#Persistent
#InstallKeybdHook
SetBatchLines, -1
SetTimer, MoveMouse, 10

; --- Ayarlar ---
normalSpeed := 6
turboSpeed := 20
accelTime := 1000  ; 1 saniyede maksimum hıza ulaşır
wPressed := 0
sPressed := 0
aPressed := 0
dPressed := 0
scroll := 0
dragging := 0
mouseMode := true
globalAccelStart := 0  ; ivme başlangıcı

; --- Toggle Mouse/WASD Modu ---
^!m::
    mouseMode := !mouseMode
return

#If mouseMode

; Tuş basma izleme
w::
    wPressed := 1
return
w up::
    wPressed := 0
return

s::
    sPressed := 1
return
s up::
    sPressed := 0
return

a::
    aPressed := 1
return
a up::
    aPressed := 0
return

d::
    dPressed := 1
return
d up::
    dPressed := 0
return

; Mouse tıklamaları
j::Click, left
k::Click, right
l::Click, 2
i::Click, middle

; Drag & Drop
u::
    if (dragging) {
        MouseClick, left,,, , , U
        dragging := 0
    } else {
        MouseClick, left,,, , , D
        dragging := 1
    }
return

#If

; --- Hareket / Scroll Döngüsü ---
MoveMouse:
    if (!mouseMode)
        return

    ; --- Scroll modu ---
    if (scroll) {
        if (wPressed)
            Send {WheelUp}
        if (sPressed)
            Send {WheelDown}
        if (aPressed)
            Send {WheelLeft}
        if (dPressed)
            Send {WheelRight}
        return
    }

    ; --- İvme hesaplama ---
    anyPressed := wPressed || sPressed || aPressed || dPressed
    if (anyPressed) {
        if (!globalAccelStart)
            globalAccelStart := A_TickCount
        speed := normalSpeed + ((turboSpeed - normalSpeed) * Min((A_TickCount - globalAccelStart) / accelTime, 1))
    } else {
        globalAccelStart := 0
        speed := 0
    }

    ; --- Hareket --- 
    dx := (aPressed ? -1 : 0) + (dPressed ? 1 : 0)
    dy := (wPressed ? -1 : 0) + (sPressed ? 1 : 0)

    ; Vektörel normalize ederek çapraz hız sabitleme
    length := Sqrt(dx*dx + dy*dy)
    if (length != 0) {
        dx := dx / length * speed
        dy := dy / length * speed
        MouseMove, dx, dy, 0, R
    }
return
