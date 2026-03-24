#Persistent
#InstallKeybdHook
SetBatchLines, -1
SetTimer, MoveMouse, 5

CoordMode, Mouse, Screen

; --- Ayarlar ---
; ** normalSpeed artırıldı: ilk an bile hissedilir hareket olsun **
normalSpeed := 8
turboSpeed := 28
; ** accelTime kısaltıldı: tam hıza daha çabuk ulaş **
accelTime := 600
; ** Precision modu: Shift basılıyken sabit yavaş hız **
precisionSpeed := 2

wPressed := 0
sPressed := 0
aPressed := 0
dPressed := 0
scroll := 0
dragging := 0
mouseMode := true
globalAccelStart := 0
precisionOn := 0

; Sub-pixel birikim (akıcı düşük hız hareketi için)
accumX := 0.0
accumY := 0.0

; Çoklu ekran sınırları
SysGet, VirtualScreenLeft, 76
SysGet, VirtualScreenTop, 77
SysGet, VirtualScreenWidth, 78
SysGet, VirtualScreenHeight, 79

maxX := VirtualScreenLeft + VirtualScreenWidth - 1
maxY := VirtualScreenTop + VirtualScreenHeight - 1
minX := VirtualScreenLeft
minY := VirtualScreenTop

; --- Toggle ---
^!m::
    mouseMode := !mouseMode
    ToolTip, % "Mouse Modu: " . (mouseMode ? "AÇIK" : "KAPALI")
    SetTimer, RemoveToolTip, 1000
return

RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
return

#If mouseMode

w::wPressed := 1
w up::wPressed := 0
s::sPressed := 1
s up::sPressed := 0
a::aPressed := 1
a up::aPressed := 0
d::dPressed := 1
d up::dPressed := 0

; Precision modu (Shift basılı = yavaş)
LShift::precisionOn := 1
LShift up::precisionOn := 0
RShift::precisionOn := 1
RShift up::precisionOn := 0

j::Click, left
k::Click, right
l::Click, 2

i::
    iDownTime := A_TickCount
    scroll := 1
return
i up::
    scroll := 0
    ; 200ms'den kısa basış = middle click
    if (A_TickCount - iDownTime < 200)
        Click, middle
return

u::
    if (dragging) {
        MouseClick, left,,, , , U
        dragging := 0
    } else {
        MouseClick, left,,, , , D
        dragging := 1
    }
return

^!Left::
    SysGet, MonitorCount, MonitorCount
    if (MonitorCount > 1) {
        SysGet, Mon, Monitor, 1
        DllCall("SetCursorPos", "int", Round((MonLeft + MonRight) / 2), "int", Round((MonTop + MonBottom) / 2))
    }
return

^!Right::
    SysGet, MonitorCount, MonitorCount
    if (MonitorCount > 1) {
        SysGet, Mon, Monitor, 2
        DllCall("SetCursorPos", "int", Round((MonLeft + MonRight) / 2), "int", Round((MonTop + MonBottom) / 2))
    }
return

#If

; --- Ana Döngü ---
MoveMouse:
    if (!mouseMode)
        return

    ; Scroll modu
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

    ; Yön hesapla
    dx := (dPressed - aPressed)
    dy := (sPressed - wPressed)

    if (dx = 0 && dy = 0) {
        globalAccelStart := 0
        accumX := 0.0
        accumY := 0.0
        return
    }

    ; ** Precision modu: Shift basılıysa ivme yok, sabit yavaş hız **
    if (precisionOn) {
        speed := precisionSpeed
        globalAccelStart := 0
    } else {
        ; İvme
        if (!globalAccelStart)
            globalAccelStart := A_TickCount

        elapsed := A_TickCount - globalAccelStart
        progress := elapsed / accelTime
        if (progress > 1)
            progress := 1

        ; ** Ease-out kare kök eğrisi: hızlı başla, yumuşak dur **
        ; Eski: progress * progress (çok yavaş başlıyor)
        ; Yeni: sqrt(progress) (anında tepki, yumuşak geçiş)
        progress := Sqrt(progress)

        speed := normalSpeed + ((turboSpeed - normalSpeed) * progress)
    }

    ; Normalize
    length := Sqrt(dx*dx + dy*dy)
    moveX := (dx / length) * speed
    moveY := (dy / length) * speed

    ; Sub-pixel birikim (5ms timer'da küçük değerler kaybolmasın)
    accumX += moveX
    accumY += moveY

    ; Tamsayı kısmını al, kalanı biriktir
    intX := Floor(accumX)
    intY := Floor(accumY)

    if (accumX < 0)
        intX := Ceil(accumX)
    if (accumY < 0)
        intY := Ceil(accumY)

    if (intX = 0 && intY = 0)
        return

    accumX -= intX
    accumY -= intY

    ; Pozisyon
    MouseGetPos, cx, cy
    newX := cx + intX
    newY := cy + intY

    ; Sınırlar
    newX := (newX < minX) ? minX : (newX > maxX) ? maxX : newX
    newY := (newY < minY) ? minY : (newY > maxY) ? maxY : newY

    if (newX != cx || newY != cy)
        DllCall("SetCursorPos", "int", newX, "int", newY)
return
