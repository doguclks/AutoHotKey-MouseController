#Persistent
#InstallKeybdHook
SetBatchLines, -1
SetTimer, MoveMouse, 10

; Koordinat modunu ekran bazlı yap
CoordMode, Mouse, Screen

; --- Ayarlar ---
normalSpeed := 6
turboSpeed := 20
accelTime := 500
wPressed := 0
sPressed := 0
aPressed := 0
dPressed := 0
scroll := 0
dragging := 0
mouseMode := true
globalAccelStart := 0

; Çoklu ekran sınırlarını al
SysGet, VirtualScreenLeft, 76
SysGet, VirtualScreenTop, 77
SysGet, VirtualScreenWidth, 78
SysGet, VirtualScreenHeight, 79

; Toplam ekran alanı
maxX := VirtualScreenLeft + VirtualScreenWidth - 1
maxY := VirtualScreenTop + VirtualScreenHeight - 1
minX := VirtualScreenLeft
minY := VirtualScreenTop

; --- Toggle Mouse/WASD Modu ---
^!m::
    mouseMode := !mouseMode
    if (mouseMode)
        ToolTip, Mouse Modu: AÇIK
    else
        ToolTip, Mouse Modu: KAPALI
    SetTimer, RemoveToolTip, 1000
return

RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
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

; Scroll modu ve orta tıklama
i::
    scroll := 1
    Click, middle
return

i up::
    scroll := 0
return

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

; Hızlı ekran geçişi (opsiyonel)
^!Left::  ; Sol ekrana atla
    SysGet, MonitorCount, MonitorCount
    if (MonitorCount > 1) {
        SysGet, Monitor1, Monitor, 1
        centerX := (Monitor1Left + Monitor1Right) / 2
        centerY := (Monitor1Top + Monitor1Bottom) / 2
        DllCall("SetCursorPos", "int", Round(centerX), "int", Round(centerY))
    }
return

^!Right::  ; Sağ ekrana atla
    SysGet, MonitorCount, MonitorCount
    if (MonitorCount > 1) {
        SysGet, Monitor2, Monitor, 2
        centerX := (Monitor2Left + Monitor2Right) / 2
        centerY := (Monitor2Top + Monitor2Bottom) / 2
        DllCall("SetCursorPos", "int", Round(centerX), "int", Round(centerY))
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
        return  ; Hiçbir tuş basılı değilse çık
    }

    ; --- Hareket --- 
    dx := (aPressed ? -1 : 0) + (dPressed ? 1 : 0)
    dy := (wPressed ? -1 : 0) + (sPressed ? 1 : 0)

    ; Vektörel normalize ederek çapraz hız sabitleme
    length := Sqrt(dx*dx + dy*dy)
    if (length = 0)
        return  ; Hareket yoksa çık
    
    dx := dx / length * speed
    dy := dy / length * speed
    
    ; Mevcut pozisyonu al
    MouseGetPos, currentX, currentY
    
    ; Yeni pozisyonu hesapla (float olabilir)
    newX := currentX + dx
    newY := currentY + dy
    
    ; Sınırları kontrol et (tüm ekranlar için)
    if (newX < minX)
        newX := minX
    else if (newX > maxX)
        newX := maxX
    
    if (newY < minY)
        newY := minY
    else if (newY > maxY)
        newY := maxY
    
    ; Tamsayıya yuvarla (SetCursorPos int ister)
    newX := Round(newX)
    newY := Round(newY)
    
    ; Sadece gerçek hareket varsa gönder
    if (newX != currentX || newY != currentY) {
        DllCall("SetCursorPos", "int", newX, "int", newY)
    }
return